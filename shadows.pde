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
final float X_DOT_Y  = (sqrt(2) / 2) * tan(CAMERA_ANGLE_OF_ALTITUDE) * cos(CAMERA_ANGLE_OF_ALTITUDE);
final float Y_DOT_X  = 0;
final float Y_DOT_Y  = cos(CAMERA_ANGLE_OF_ALTITUDE);
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

PVector scale(PVector p, float s)
{
  return new PVector(s * p.x, s * p.y, s * p.z);
}

PVector add(PVector p, PVector q)
{
  return new PVector(p.x + q.x, p.y + q.y, p.z + q.z);
}

PVector worldToScreen(PVector wc)
{
  PVector sc = new PVector();
  sc = add(scale(X_UNIT, wc.x), add(scale(Y_UNIT, wc.y), scale(Z_UNIT, wc.z)));
  sc.x += SCREEN_WIDTH  / 2;
  sc.y += 3 * SCREEN_HEIGHT / 4;
  //println(sc);
  return sc;
}

float distanceFromCameraPlane(PVector p)
{
  return C_UNIT.dot(p);
}

void drawPoint(PVector p)
{
  noStroke();
  if (show_zdepth) {
    float d = distanceFromCameraPlane(p);
    if (debug) {
      println("p: ", p);
      println("d: ", d);
    }
    fill(127 - d / 3);
  } else {
    fill(255);
  }
  PVector sc = worldToScreen(p);
  circle(sc.x, sc.y, 3);
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
  //println(X_UNIT);
  //println(Y_UNIT);
  //println(Z_UNIT);
  //println(C_UNIT);
  //println(C_UNIT.dot(new PVector(1, 0, 0)));
  //println(C_UNIT.dot(new PVector(0, 1, 0)));
  //println(C_UNIT.dot(new PVector(0, 0, 1)));
  
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
  
  PImage current_sprite = show_zdepth ? loy_mech_01_lo_zd : loy_mech_01_lo;
  fb.addSprite(current_sprite, round(320 - PIXEL_SCALE * current_sprite.width / 2), round(360 - PIXEL_SCALE * current_sprite.height));
  
  fb.draw();
  
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
}
