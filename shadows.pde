import java.util.Map;

/**
 * DEFINITIONS
 * WORLD UNIT (wu)  - for 3D coordinate system
 * GRID UNIT (fu)   - for 2D grid coordinate system, like world coordinates but 2D
 * SCREEN UNIT (su) - for 2D screen coordinate system, screen pixels
 * PIXEL (p)        - can be pixel on screen or in frame buffer
 */

final float TIME_DELTA          =  16.667; // ms per frame
final float TIME_SCALE          =   1.0;   // 1.0 = normal speed
final int   SCREEN_WIDTH        = 640;     // pixels //MAKE SURE THE ASPECT RATIO MATCHES WORLD DIMENSIONS
final int   SCREEN_HEIGHT       = 480;     // pixels
//final float WORLD_WIDTH         = 400;     // world units
//final float WORLD_HEIGHT        = 300;     // world units
//final float WORLD_TO_SCREEN     = SCREEN_WIDTH / WORLD_WIDTH;
//final float PIXEL_SCALE         = 1;       // screen pixels per framebuffer pixel

final float CAMERA_ANGLE_OF_ALTITUDE = 30 * PI / 180;   // radians, 30 degrees
final float X_DOT_X  =  sqrt(2) / 2;
final float X_DOT_Y  = (sqrt(2) / 2) * sin(CAMERA_ANGLE_OF_ALTITUDE);
final float Y_DOT_X  = 0;
final float Y_DOT_Y  = cos(CAMERA_ANGLE_OF_ALTITUDE);
//final PVector ORIGIN = new PVector(SCREEN_WIDTH / 2, 3 * SCREEN_HEIGHT / 4); // where (0, 0, 0) is on the screen, wu
final PVector X_UNIT = new PVector(-X_DOT_X, -X_DOT_Y); // for transforming world coordinates
final PVector Z_UNIT = new PVector( X_DOT_X, -X_DOT_Y); // onto the screen
final PVector Y_UNIT = new PVector( Y_DOT_X, -Y_DOT_Y);
final PVector C_UNIT = new PVector                      // unit vector in the direction of the camera
(                                                       // also the normal vector for the camera plane
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE),
  -sin(CAMERA_ANGLE_OF_ALTITUDE),
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE)
);

final float K = 2.4452237;

/* ----- FUNCS ----- */

/**
 * Takes the JSON file pointed to by <path> and initialize important
 * global variables (e.g. <sprite_map>) with the data contained within.
 */
void initFromJSON(String path)
{
  json = loadJSONObject(path);
  String archetype = json.getString("archetype");
  println("Loading .json with archetype: " + archetype);
  if (archetype.equals("SPRITES")) {
    parseSpritesJSON(json);
  } else if (archetype.equals("PROPS")) {
    parsePropsJSON(json);
  } else {
    println("initFromJSON(): Archetype not found.");
  }
}

/**
 * Parses the data stored in a .json with the archetype "SPRITES" and updates
 * <sprite_map> accordingly.
 */
void parseSpritesJSON(JSONObject json)
{
  sprite_map = new HashMap<String, Sprite>();
  
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
    
    // Sprite data goes into a map from names -> Sprites
    sprite_map.put(jname, sp);
  }
}

/**
 * Parses the data stored in a .json with the archetype "PROPS" and updates
 * <props> accordingly.
 */
void parsePropsJSON(JSONObject json)
{
  props = new ArrayList<Prop>();
  
  JSONArray jprops = json.getJSONArray("props");
  for (int i = 0; i < jprops.size(); ++i) {
    JSONObject jprop = jprops.getJSONObject(i);
    String jsprite     = jprop.getString("sprite");
    JSONArray jpos     = jprop.getJSONArray("pos");
    PVector pos        = new PVector(
      jpos.getFloat(0),
      jpos.getFloat(1),
      jpos.getFloat(2)
    );
    
    Prop p = new Prop(jsprite, pos);
    props.add(p);
  }
}

/**
 * Clamps the value of <x> to be between the bounds <l> and <u>.
 */
float clamp(float x, float l, float u)
{
  return min(max(x, l), u);
}

/**
 * Scales vector <p> by <s>
 */
PVector pv_scale(PVector p, float s)
{
  return new PVector(s * p.x, s * p.y, s * p.z);
}

/**
 * Maps min() across two PVectors <p> and <q>.
 */
PVector pv_min(PVector p, PVector q)
{
  return new PVector(min(p.x, q.x), min(p.y, q.y), min(p.z, q.z));
}

/**
 * Maps max() across two PVectors <p> and <q>.
 */
PVector pv_max(PVector p, PVector q)
{
  return new PVector(max(p.x, q.x), max(p.y, q.y), max(p.z, q.z));
}

/**
 * Transforms the 3D world coordinate <wc> into a grid coordinate.
 */
PVector worldToGrid(PVector wc)
{
  PVector gc = new PVector();
  gc = PVector.add(pv_scale(X_UNIT, wc.x), PVector.add(pv_scale(Y_UNIT, wc.y), pv_scale(Z_UNIT, wc.z)));
  //println(gc);
  return gc;
}

/**
 * Transforms the 2D grid coordinate <gc> into a world coordinate with a y-value of 0.
 */
PVector gridToWorld(PVector gc)
{
  //println("gc: ", gc);
  float x_dot  = PVector.dot(gc, X_UNIT);
  float z_dot  = PVector.dot(gc, Z_UNIT);
  float gc_mag = gc.mag();
  float xz_mag = X_UNIT.mag();                             // X_UNIT and Z_UNIT have the same magnitude
  float m      = X_UNIT.y / X_UNIT.x;                      // slope of the x and z-axis lines
  float x_ht   =  m * gc.x;                                // height (y coord) of x-axis at sc.x
  float z_ht   = -m * gc.x;                                // height (y coord) of z-axis at sc.x
  float sign_x = gc.y > z_ht ? -1 : 1;                     // choice of sign depends on sc being
  float sign_z = gc.y > x_ht ? -1 : 1;                     // above or below the x or z-axis
  float a      = acos(sign_x * x_dot / (gc_mag * xz_mag)); // a is angle from sc to x-axis
  float b      = acos(sign_z * z_dot / (gc_mag * xz_mag)); // b is angle from sc to z-axis
  a = Float.isNaN(a) ? 0 : a;                              // check if directly on axes
  b = Float.isNaN(b) ? 0 : b;
  float c      = PI - a - b;
  //println("a: ", a);
  //println("b: ", b);
  //println("c: ", c);
  float law_of_sines = gc_mag / (sin(c) * xz_mag);
  law_of_sines = Float.isNaN(law_of_sines) ? 0 : law_of_sines; // check for divide-by-zero, if there is one we're probably at the origin
  PVector wc   = new PVector(sign_x * sin(b) * law_of_sines, 0, sign_z * sin(a) * law_of_sines);
  //println("wc: ", wc);
  return wc; // assumes the y-value is 0
}

/**
 * Transforms the grid coordinate <gc> into a screen coordinate.
 */
PVector gridToScreen(PVector gc)
{
  PVector sc = new PVector();
  sc = PVector.sub(gc, camera.tl);
  sc = pv_scale(sc, camera.z);
  return sc;
}

/**
 * Transforms the screen coordinate <sc> into a grid coordinate.
 */
PVector screenToGrid(PVector sc)
{
  PVector gc = new PVector();
  gc = pv_scale(sc, 1 / camera.z);
  gc = PVector.add(gc, camera.tl);
  return gc;
}

/**
 * Calculates the distance between the world coordinate <wc> and a plane that has the normal vector <C_UNIT>.
 */
float distanceFromCameraPlane(PVector wc)
{
  return PVector.dot(C_UNIT, wc);
}

/**
 * Draws a point (white pixel) at the specified world coordinate <wc>.
 */
//void drawPoint(PVector wc)
//{
//  float d = distanceFromCameraPlane(wc); // wu
//  PVector gc = worldToGrid(wc);          // grid coordinate
//  if (
//    gc.x >= 0    && // TODO: change this to check the camera bounds
//    gc.x <  fb.w &&
//    gc.y >= 0    &&
//    gc.y <  fb.h
//  ) {
//    zd.setPixel(gc, d);
//    fb.setPixel(gc, color(255));
//  }
//}

/**
 * Draws (adds to frame buffer) the specified sprite <sp> with <tl> being the top-left 
 * corner of the sprite and <d> being the depth of the sprite's base (usually bottom edge).
 * Depth buffer is used to mask pixels closer to camera.
 */
void addSprite(Sprite sp, PVector tl, float d)
{
  //println("camera.c:  " + camera.c);
  //println("camera.tl: " + camera.tl);
  //println("camera.z:  " + camera.z);
  //println("tl:        " + tl);
  
  // find all bounds for the loops
  PVector start_gc = new PVector( // top-left of the area that will be drawn, gc
    max(tl.x, camera.tl.x),
    max(tl.y, camera.tl.y)
  );
  PVector end_gc   = new PVector( // bottom-right of the area that will be drawn, gc
    min(tl.x + sp.w, camera.tl.x + camera.w),
    min(tl.y + sp.h, camera.tl.y + camera.h)
  );
  PVector start_sc = pv_max(gridToScreen(start_gc), new PVector(0, 0)); // top-left of the area that will be drawn, sc
  PVector end_sc   = pv_min(gridToScreen(end_gc),   new PVector(SCREEN_WIDTH, SCREEN_HEIGHT)); // bottom-right, sc
  PVector start_sp = PVector.sub(start_gc, tl); // top-left of the sprite data that will be pulled, gc
  PVector end_sp   = PVector.sub(end_gc,   tl); // bottom-right, gc
  float drawn_w  = end_sc.x - start_sc.x; // drawn means the area on the screen where the sprite gets drawn
  float drawn_h  = end_sc.y - start_sc.y;
  float picked_w = end_sp.x - start_sp.x; // picked means the area from the sprite that is 
  float picked_h = end_sp.y - start_sp.y; // in view of the camera and gets "picked" to be drawn
  //println("start_gc:  " + start_gc);
  //println("end_gc:    " + end_gc);
  //println("start_sc:  " + start_sc);
  //println("end_sc:    " + end_sc);
  //println("start_sp:  " + start_sp);
  //println("end_sp:    " + end_sp);
  //println("drawn_wh:  [ " + drawn_w  + ", " + drawn_h  + " ]");
  //println("picked_wh: [ " + picked_w + ", " + picked_h + " ]");
  //println();
  
  loadPixels();
  // iterate across the pixels contained in the area being drawn
  for (int sc_y = (int) start_sc.y; sc_y < (int) end_sc.y; ++sc_y) {
    for (int sc_x = (int) start_sc.x; sc_x < (int) end_sc.x; ++sc_x) {
      float t_x = (sc_x - start_sc.x) / drawn_w;
      float t_y = (sc_y - start_sc.y) / drawn_h;
      t_x = clamp(t_x, 0, 1); // wish I could get rid of these (maybe I can?)
      t_y = clamp(t_y, 0, 1);
      int sp_x = (int) (start_sp.x + t_x * picked_w);
      int sp_y = (int) (start_sp.y + t_y * picked_h);
      //println();
      //println("sc_xy: [ " + sc_x + ", " + sc_y + " ]");
      ////println("start_sp.y + t_y * picked_h: " + (start_sp.y + t_y * picked_h));
      //println("sp_xy: [ " + sp_x + ", " + sp_y + " ]");
      //println("t:     [ " + t_x  + ", " + t_y  + " ]");
      
      int zd_value = sp.zd_data.pixels[sp_x + sp.w * sp_y] & 0xFF;
      float depth  = d + K * (sp.zd_offset - zd_value);
      if (zd.frame[sc_y][sc_x] <= depth) // is this pixel occluded?
        continue;
      if ((sp.data.pixels[sp_x + sp.w * sp_y] & 0xFF000000) == 0) // is this pixel transparent?
        continue;
      zd.frame[sc_y][sc_x] = depth; // update depth buffer
      zd.min = min(depth, zd.min);
      zd.max = max(depth, zd.max);
      fb.frame[sc_y][sc_x] = sp.data.pixels[sp_x + sp.w * sp_y]; // add sprite color to frame buffer
    }
  }
  updatePixels();
}

/**
 * Draws (adds to frame buffer) the specified prop <p>.
 */
void addProp(Prop p)
{
  Sprite sp = sprite_map.get(p.sprite_name);
  PVector gc = worldToGrid(p.pos);                              // grid coordinate of this prop's position
  PVector tl = PVector.add(gc, new PVector(-sp.w / 2, -sp.h));  // top-left grid coordinate of this prop's sprite
  tl = new PVector(floor(tl.x), floor(tl.y));                   // align to world grid
  //println("tl: " + tl);
  //println("camera.tl: " + camera.tl);
  if (
    camera.inView(tl.x, tl.y, sp.w, sp.h)
  ) {
    //println("tl: " + tl);
    //println("d:  " + distanceFromCameraPlane(p.pos));
    addSprite(sp, tl, distanceFromCameraPlane(p.pos));
  }
}

/* ----- SETUP ----- */

// mutable globals
JSONObject json;

FrameBuffer fb;
DepthBuffer zd;
//ArrayList<Sprite> sprites;
HashMap<String, Sprite> sprite_map;
ArrayList<Prop> props;
Camera camera;

// flags
boolean zdepth;
//boolean greybox;
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
  camera = new Camera(new PVector(0, 0), 1);
  
  initFromJSON("data/sprites.json");
  initFromJSON("data/props.json");
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
  
  // initialize flags
  zdepth  = false;
  //greybox = false;
  debug   = false;
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
      case 'w': camera.moveCamera(new PVector( 0, -3 / camera.z)); break;
      case 'a': camera.moveCamera(new PVector(-3 / camera.z,  0)); break;
      case 's': camera.moveCamera(new PVector( 0,  3 / camera.z)); break;
      case 'd': camera.moveCamera(new PVector( 3 / camera.z,  0)); break;
      case '=': camera.setZoom(camera.z * 2); break;
      case '-': camera.setZoom(camera.z * 0.5); break;
      case 'z': zdepth = !zdepth; break;
      //case 'g': greybox = !greybox; break;
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
  
  for (int i = 0; i < props.size(); ++i) {
    addProp(props.get(i));
  }
  
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
    if (zdepth) { debug = false; }
  }*/
  
  if (zdepth) {
    zd.draw();
  } else {
    fb.draw();
  }
}
