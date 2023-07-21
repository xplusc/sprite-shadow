import java.util.Map;

/**
 * DEFINITIONS
 * WORLD UNIT (wu)  - 3D coordinate
 * SCREEN UNIT (su) - 2D screen coordinate
 * FRAME UNIT (fu)  - su / PIXEL_SCALE
 * PIXEL (p)        - CHECK SCREEN RESOLUTION
 */

final float TIME_DELTA          =  16.667; // ms (per frame?)
final float TIME_SCALE          =   1.0;   // 1.0 = normal speed
final int   SCREEN_WIDTH        = 640;     // pixels MAKE SURE THE ASPECT RATIO MATCHES WORLD DIMENSIONS
final int   SCREEN_HEIGHT       = 480;     // pixels
//final float WORLD_WIDTH         = 400;     // world units
//final float WORLD_HEIGHT        = 300;     // world units
//final float WORLD_TO_SCREEN     = SCREEN_WIDTH / WORLD_WIDTH;
final float PIXEL_SCALE         = 4;       // screen pixels per framebuffer pixel

final float CAMERA_ANGLE_OF_ALTITUDE = 30 * PI / 180;   // radians, 30 degrees
final float X_DOT_X  =  sqrt(2) / 2;
final float X_DOT_Y  = (sqrt(2) / 2) * sin(CAMERA_ANGLE_OF_ALTITUDE);
final float Y_DOT_X  = 0;
final float Y_DOT_Y  = cos(CAMERA_ANGLE_OF_ALTITUDE);
final PVector ORIGIN = new PVector(SCREEN_WIDTH / 2, 3 * SCREEN_HEIGHT / 4); // where (0, 0, 0) is on the screen, wu
final PVector X_UNIT = new PVector(-X_DOT_X, -X_DOT_Y); // for transforming world coordinates
final PVector Z_UNIT = new PVector( X_DOT_X, -X_DOT_Y); // onto the screen
final PVector Y_UNIT = new PVector( Y_DOT_X, -Y_DOT_Y);
final PVector C_UNIT = new PVector                      // unit vector in the direction of the camera
(                                                       // also the normal vector for the camera plane
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE),
  -sin(CAMERA_ANGLE_OF_ALTITUDE),
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE)
);

final float K = 2.4452237 * PIXEL_SCALE;

/* ----- FUNCS ----- */

/*
 * Take the JSON file pointed to by <path> and initialize important
 * global variables (e.g. <sprites>) with the data contained within.
 */
void initObjectsFromJSON(String path)
{
  sprites = new ArrayList<Sprite>();
  sprite_map = new HashMap<String, Sprite>();
  
  json = loadJSONObject(path);
  JSONArray jsprites = json.getJSONArray("sprites");
  for (int i = 0; i < jsprites.size(); ++i) {
    JSONObject jsprite = jsprites.getJSONObject(i);
    String jpath       = jsprite.getString("path");
    String jzd_path    = jsprite.getString("zd_path");
    String jname       = jsprite.getString("name");
    int jzd_offset     = jsprite.getInt("zd_offset");
    
    PImage pi = loadImage(jpath);
    PImage zd = loadImage(jzd_path);
    Sprite sp = new Sprite(pi, zd, jname, jzd_offset);
    //sprites.add(sp); // until needed
    
    // Sprite data also goes into a map from names -> Sprites
    sprite_map.put(jname, sp);
  }
}

PVector pv_scale(PVector p, float s)
{
  return new PVector(s * p.x, s * p.y, s * p.z);
}

PVector worldToScreen(PVector wc)
{
  PVector sc = new PVector();
  sc = PVector.add(pv_scale(X_UNIT, wc.x), PVector.add(pv_scale(Y_UNIT, wc.y), pv_scale(Z_UNIT, wc.z)));
  sc = PVector.add(sc, ORIGIN);
  //println(sc);
  return sc;
}

PVector screenToWorld(PVector sc)
{
  sc = PVector.sub(sc, ORIGIN); // shift sc so the origin is back at (0, 0)
  //println("sc: ", sc);
  float x_dot  = PVector.dot(sc, X_UNIT);
  float z_dot  = PVector.dot(sc, Z_UNIT);
  float sc_mag = sc.mag();
  float xz_mag = X_UNIT.mag();                             // X_UNIT and Z_UNIT have the same magnitude
  float m      = X_UNIT.y / X_UNIT.x;                      // slope of the x and z-axis lines
  float x_ht   =  m * sc.x;                                // height (y coord) of x-axis at sc.x
  float z_ht   = -m * sc.x;                                // height (y coord) of z-axis at sc.x
  float sign_x = sc.y > z_ht ? -1 : 1;                     // choice of sign depends on sc being
  float sign_z = sc.y > x_ht ? -1 : 1;                     // above or below the x or z-axis
  float a      = acos(sign_x * x_dot / (sc_mag * xz_mag)); // a is angle from sc to x-axis
  float b      = acos(sign_z * z_dot / (sc_mag * xz_mag)); // b is angle from sc to z-axis
  a = Float.isNaN(a) ? 0 : a;                              // check if directly on axes
  b = Float.isNaN(b) ? 0 : b;
  float c      = PI - a - b;
  //println("a: ", a);
  //println("b: ", b);
  //println("c: ", c);
  float law_of_sines = sc_mag / (sin(c) * xz_mag);
  law_of_sines = Float.isNaN(law_of_sines) ? 0 : law_of_sines; // check for divide-by-zero, if there is one we're probably at the origin
  PVector wc   = new PVector(sign_x * sin(b) * law_of_sines, 0, sign_z * sin(a) * law_of_sines);
  //println("wc: ", wc);
  return wc; // assumes the y coordinate is 0
}

float distanceFromCameraPlane(PVector wc)
{
  return PVector.dot(C_UNIT, wc);
}

void drawPoint(PVector wc)
{
  float d = distanceFromCameraPlane(wc); // wu
  PVector fc = pv_scale(worldToScreen(wc), 1 / PIXEL_SCALE); // frame coordinate
  if (
    fc.x >= 0    &&
    fc.x <  fb.w &&
    fc.y >= 0    &&
    fc.y <  fb.h
  ) {
    zd.setPixel(fc, d);
    fb.setPixel(fc, color(255));
  }
}

void addSprite(Sprite sp, PVector wc, PVector tl)
{
  float bottom_edge_depth = distanceFromCameraPlane(wc);
  loadPixels();
  for (int y = 0; y < sp.h; ++y) {
    for (int x = 0; x < sp.w; ++x) {
      if (
        x + tl.x >= 0    && // if pixel is in view
        x + tl.x <  zd.w &&
        y + tl.y >= 0    &&
        y + tl.y <  zd.h
      ) {
        if (((sp.zd_data.pixels[x + sp.w * y] >> 8) & 0xFF) > 0) { // if zdepth data exists for this pixel (not a transparent pixel)
          float depth = bottom_edge_depth + K * (sp.zd_offset - (sp.zd_data.pixels[x + sp.w * y] & 0xFF));
          if (zd.frame[y + (int) tl.y][x + (int) tl.x] <= depth) // is this pixel occluded?
            continue;
          if ((sp.data.pixels[x + sp.w * y] & 0xFF000000) == 0)  // is this pixel transparent?
            continue;
          zd.frame[y + (int) tl.y][x + (int) tl.x] = depth;      // update depth buffer
          zd.min = min(depth, zd.min);
          zd.max = max(depth, zd.max);
          fb.frame[y + (int) tl.y][x + (int) tl.x] = sp.data.pixels[x + sp.w * y]; // add sprite color to frame buffer
        }
      }
    }
  }
  updatePixels();
}

void addProp(Prop p)
{
  Sprite sp = sprite_map.get(p.sprite_name);
  PVector fc = pv_scale(worldToScreen(p.pos), 1 / PIXEL_SCALE); // frame coordinate of this prop's position
  PVector tl = PVector.add(fc, new PVector(-sp.w / 2, -sp.h));  // top-left frame coordinate of this prop's sprite
  tl = new PVector(floor(tl.x), floor(tl.y));                   // align to frame buffer grid
  if (
    tl.x + sp.w >= 0    && // check if any part of the sprite is in view
    tl.x        <  fb.w &&
    tl.y + sp.h >= 0    &&
    tl.y        <  fb.h
  ) {
    addSprite(sp, p.pos, tl);
  }
}

/* ----- SETUP ----- */

JSONObject json;

FrameBuffer fb;
DepthBuffer zd;
ArrayList<Sprite> sprites;
HashMap<String, Sprite> sprite_map;

Prop touro_legs;
Prop box;

// flags
boolean show_zdepth;
boolean greybox;
boolean debug;

void settings()
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup()
{
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(14);
  frameRate(TIME_SCALE * (1000 / TIME_DELTA));
  
  fb = new FrameBuffer();
  zd = new DepthBuffer();
  
  initObjectsFromJSON("data/sprites.json");
  //println(X_UNIT);
  //println(Y_UNIT);
  //println(Z_UNIT);
  //println(C_UNIT);
  //println(C_UNIT.dot(new PVector(1, 0, 0)));
  //println(C_UNIT.dot(new PVector(0, 1, 0)));
  //println(C_UNIT.dot(new PVector(0, 0, 1)));
  //println(screenToWorld(new PVector(0, 360)));
  //PVector v = new PVector( 100, 0,  200);
  //println(v);
  //println(worldToScreen(v));
  //println(screenToWorld(worldToScreen(v)));
  //println(fb.w * fb.h);
  //println(SCREEN_WIDTH * SCREEN_HEIGHT);
  
  touro_legs = new Prop("loy_mech_01_lo", new PVector(0, 0, 0));
  box        = new Prop("greybox_1_2",    new PVector(0, 0, 0));
  
  // initialize flags
  show_zdepth = false;
  greybox = false;
  debug = false;
}

/* ----- INPUT ----- */

void keyPressed()
{
  if (key == CODED) {
    switch (keyCode) {
      default: break;
    }
  } else {
    switch (key) {
      case 'z':
      case 'Z': show_zdepth = !show_zdepth; break;
      case 'g':
      case 'G': greybox = !greybox; break;
      default: break;
    }
  }
}

/* ----- DRAW  ----- */

void draw()
{
  //background(0);
  fb.clear();
  zd.clear();
  
  Prop current_prop = greybox ? box : touro_legs;
  //Sprite current_sprite = sprite_map.get(current_prop.sprite_name);
  addProp(current_prop);
  //addSprite(current_sprite, new PVector(0, 0, 0), new PVector(270, 290));
  
  /*drawPoint(new PVector(0, 0, 0));
  int size = 20;
  for (int i = 1; i <= size; ++i) {
    drawPoint(new PVector(10 * i, 0, 0));
    drawPoint(new PVector(0, 10 * i, 0));
    drawPoint(new PVector(0, 0, 10 * i));
    drawPoint(new PVector(10 * i, 10 * size, 0));
    drawPoint(new PVector(10 * size, 10 * i, 0));
    drawPoint(new PVector(0, 10 * i, 10 * size));
    drawPoint(new PVector(0, 10 * size, 10 * i));
    drawPoint(new PVector(10 * i, 0, 10 * size));
    drawPoint(new PVector(10 * size, 0, 10 * i));
    drawPoint(new PVector(10 * i, 10 * size, 10 * size));
    drawPoint(new PVector(10 * size, 10 * i, 10 * size));
    drawPoint(new PVector(10 * size, 10 * size, 10 * i));
    if (show_zdepth) { debug = false; }
  }*/
  
  if (show_zdepth) {
    zd.draw();
  } else {
    fb.draw();
  }
}
