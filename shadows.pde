/**
 * DEFINITIONS
 * WORLD UNIT (wu) - 300 WIDE, 400 HIGH
 * PIXEL (p)       - CHECK SCREEN RESOLUTION
 */

final float TIME_DELTA          =  16.667; // ms (per frame?)
final float TIME_SCALE          =   1.0;   // 1.0 = normal speed
final int   SCREEN_WIDTH        = 640;     // pixels MAKE SURE THE ASPECT RATIO MATCHES WORLD DIMENSIONS
final int   SCREEN_HEIGHT       = 480;     // pixels
//final float WORLD_WIDTH         = 400;     // world units
//final float WORLD_HEIGHT        = 300;     // world units
//final float WORLD_TO_SCREEN     = SCREEN_WIDTH / WORLD_WIDTH;
final float PIXEL_SCALE         = 3;       // screen pixels per framebuffer pixel

final float CAMERA_ANGLE_OF_ALTITUDE = 30 * PI / 180; // radians, 30 degrees
final float X_DOT_X  =  sqrt(2) / 2;
final float X_DOT_Y  = (sqrt(2) / 2) * sin(CAMERA_ANGLE_OF_ALTITUDE);
final float Y_DOT_X  = 0;
final float Y_DOT_Y  = cos(CAMERA_ANGLE_OF_ALTITUDE);
final PVector ORIGIN = new PVector(SCREEN_WIDTH / 2, 3 * SCREEN_HEIGHT / 4); // where (0, 0, 0) is on the screen
final PVector X_UNIT = new PVector(-X_DOT_X, -X_DOT_Y); // for transforming world coordinates
final PVector Z_UNIT = new PVector( X_DOT_X, -X_DOT_Y); // onto the screen
final PVector Y_UNIT = new PVector( Y_DOT_X, -Y_DOT_Y);
final PVector C_UNIT = new PVector                      // unit vector in the direction of the camera
(                                                       // also the normal vector for the camera plane
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE),
  -sin(CAMERA_ANGLE_OF_ALTITUDE),
  (sqrt(2) / 2) * cos(CAMERA_ANGLE_OF_ALTITUDE)
);

/* ----- FUNCS ----- */

void initObjectsFromJSON(String path)
{
  // TODO
}

PVector pv_scale(PVector p, float s)
{
  return new PVector(s * p.x, s * p.y, s * p.z);
}

PVector pv_add(PVector p, PVector q)
{
  return new PVector(p.x + q.x, p.y + q.y, p.z + q.z);
}

PVector pv_sub(PVector p, PVector q)
{
  return new PVector(p.x - q.x, p.y - q.y, p.z - q.z);
}

PVector worldToScreen(PVector wc)
{
  PVector sc = new PVector();
  sc = pv_add(pv_scale(X_UNIT, wc.x), pv_add(pv_scale(Y_UNIT, wc.y), pv_scale(Z_UNIT, wc.z)));
  sc = pv_add(sc, ORIGIN);
  //println(sc);
  return sc;
}

PVector screenToWorld(PVector sc)
{
  sc = pv_sub(sc, ORIGIN); // shift sc so the origin is back at (0, 0)
  //println("sc: ", sc);
  float x_dot  = sc.x * X_UNIT.x + sc.y * X_UNIT.y;
  float z_dot  = sc.x * Z_UNIT.x + sc.y * Z_UNIT.y;
  float sc_mag = sc.mag();
  float xz_mag = X_UNIT.mag(); // X_UNIT and Z_UNIT have the same magnitude
  float m      = X_UNIT.y / X_UNIT.x; // slope of the x and z-axis lines
  float x_ht   =  m * sc.x; // height (y coord) of x-axis at sc.x
  float z_ht   = -m * sc.x; // height (y coord) of z-axis at sc.x
  float sign_x = sc.y > z_ht ? -1 : 1; // choice of sign depends on sc being
  float sign_z = sc.y > x_ht ? -1 : 1; // above or below the x or z-axis
  float a      = acos(sign_x * x_dot / (sc_mag * xz_mag)); // a is angle from sc to x-axis
  float b      = acos(sign_z * z_dot / (sc_mag * xz_mag)); // b is angle from sc to z-axis
  a = Float.isNaN(a) ? 0 : a; // check if directly on axes
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

float distanceFromCameraPlane(PVector p)
{
  return C_UNIT.dot(p);
}

void drawPoint(PVector p)
{
  float d = distanceFromCameraPlane(p);
  PVector sc = worldToScreen(p);
  zd.setPixel(sc, d);
  fb.setPixel(sc, color(255));
}

/* ----- SETUP ----- */

JSONObject json;

FrameBuffer fb;
DepthBuffer zd;
PImage loy_mech_01_lo;
PImage loy_mech_01_lo_zd;

// flags
boolean show_zdepth;
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
  
  loy_mech_01_lo    = loadImage("loy_mech_01_lo.png");
  loy_mech_01_lo_zd = loadImage("loy_mech_01_lo_zd.png");
  
  initObjectsFromJSON("objects.json");
  println(X_UNIT);
  //println(Y_UNIT);
  //println(Z_UNIT);
  //println(C_UNIT);
  //println(C_UNIT.dot(new PVector(1, 0, 0)));
  //println(C_UNIT.dot(new PVector(0, 1, 0)));
  //println(C_UNIT.dot(new PVector(0, 0, 1)));
  //println(screenToWorld(new PVector(0, 360)));
  PVector v = new PVector( 100, 0,  200);
  println(v);
  println(worldToScreen(v));
  println(screenToWorld(worldToScreen(v)));
  
  // initialize flags
  show_zdepth = false;
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
  
  PImage current_sprite = show_zdepth ? loy_mech_01_lo_zd : loy_mech_01_lo;
  fb.addSprite(current_sprite, round(320 - PIXEL_SCALE * current_sprite.width / 2), round(360 - PIXEL_SCALE * current_sprite.height));
  
  drawPoint(new PVector(0, 0, 0));
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
  }
  
  if (show_zdepth) {
    zd.draw();
  } else {
    fb.draw();
  }
}
