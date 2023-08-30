/**
 * Miscellaneous utility functions. Mostly conversions between coordinate systems.
 */

/**
 * Returns the sign of <n>.
 */
int sign(int n)   { return n < 0 ? -1 : 1; }
int sign(float n) { return n < 0 ? -1 : 1; }

/**
 * Scales vector <p> by <s>
 */
PVector pv_scale(PVector p, float s)
{
  return new PVector(s * p.x, s * p.y, s * p.z);
}

/**
 * Maps min() across two vectors <p> and <q>.
 */
PVector pv_min(PVector p, PVector q)
{
  return new PVector(min(p.x, q.x), min(p.y, q.y), min(p.z, q.z));
}

/**
 * Maps max() across two vectors <p> and <q>.
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
  return gc;
}

/**
 * Transforms the 2D grid coordinate <gc> into a world coordinate with a y-value of 0.
 */
PVector gridToWorld(PVector gc)
{
  float x_dot  = PVector.dot(gc, X_UNIT);
  float z_dot  = PVector.dot(gc, Z_UNIT);
  float gc_mag = gc.mag();
  float xz_mag = X_UNIT.mag();                             // X_UNIT and Z_UNIT have the same magnitude
  float m      = X_UNIT.y / X_UNIT.x;                      // slope of the x and z-axis lines
  float x_ht   =  m * gc.x;                                // height (y coord) of x-axis at gc.x
  float z_ht   = -m * gc.x;                                // height (y coord) of z-axis at gc.x
  float sign_x = gc.y > z_ht ? -1 : 1;                     // choice of sign depends on gc being
  float sign_z = gc.y > x_ht ? -1 : 1;                     // above or below the x or z-axis
  float a      = acos(sign_x * x_dot / (gc_mag * xz_mag)); // a is angle from gc to x-axis
  float b      = acos(sign_z * z_dot / (gc_mag * xz_mag)); // b is angle from gc to z-axis
  a = Float.isNaN(a) ? 0 : a;                              // check if directly on axes
  b = Float.isNaN(b) ? 0 : b;
  float c      = PI - a - b;                               // other angle in the a-b-c triangle
  float law_of_sines = gc_mag / (sin(c) * xz_mag);
  law_of_sines = Float.isNaN(law_of_sines) ? 0 : law_of_sines; // check for divide-by-zero, if there is one we're probably at the origin
  PVector wc   = new PVector(sign_x * sin(b) * law_of_sines, 0, sign_z * sin(a) * law_of_sines);
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
 * Calculates the distance between the world coordinate <wc> and a plane that has the normal vector <C_UNIT>
 * and passes through the world coordinate origin. Negative values go out of the screen toward you.
 */
float distanceFromCameraPlane(PVector wc)
{
  return PVector.dot(C_UNIT, wc);
}

// no longer works
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
