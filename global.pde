/**
 * Immutable globals are stored here.
 */

/**
 * DEFINITIONS
 * WORLD UNIT (wu)  - for the 3D coordinate system
 * GRID UNIT (fu)   - for the 2D grid coordinate system, like world coordinates but 2D
 * SCREEN UNIT (su) - for the 2D screen coordinate system, screen pixels
 * PIXEL (p)        - can be pixel on screen or in grid space
 * TILE UNIT (tu)   - from one tile to another is one tile unit, tiles are 1 tu x 1 tu
 * 
 * COORDINATE (c)   - any of the previous units can be in vector form as a coordinate (e.g. world coordinate = wc)
 */

final float TIME_DELTA          =  16.667;              // ms per frame
final float TIME_SCALE          =   1.0;                // 1.0 = normal speed
final int   SCREEN_WIDTH        = 640;                  // pixels
final int   SCREEN_HEIGHT       = 480;                  // pixels

final float CAMERA_ELEVATION_ANGLE = 30 * PI / 180;     // radians, 30 degrees
final float X_DOT_X  =  sqrt(2) / 2;
final float X_DOT_Y  = (sqrt(2) / 2) * sin(CAMERA_ELEVATION_ANGLE);
final float Y_DOT_X  = 0;
final float Y_DOT_Y  = cos(CAMERA_ELEVATION_ANGLE);
final PVector X_UNIT = new PVector(-X_DOT_X, -X_DOT_Y); // for transforming world coordinates
final PVector Z_UNIT = new PVector( X_DOT_X, -X_DOT_Y); // onto the grid
final PVector Y_UNIT = new PVector( Y_DOT_X, -Y_DOT_Y);
final PVector C_UNIT = new PVector                      // This is the unit vector in the direction of the
(                                                       // camera, and also the normal vector for the camera
  (sqrt(2) / 2) * cos(CAMERA_ELEVATION_ANGLE),          // plane. The camera plane goes through the world co-
  -sin(CAMERA_ELEVATION_ANGLE),                         // ordinate origin.
  (sqrt(2) / 2) * cos(CAMERA_ELEVATION_ANGLE)
);

final float TILE_SIDE_LENGTH = 69;                      // wu per tu; not a joke, 70 was too large
final float K = 2.4452237;                              // magic number used to scale Brigador's depth data into this program's depth data
final float LIGHTING_CHECK_DISTANCE = 160;              // How far to check to see if a light source is occluded for a particular pixel.
                                                        // I don't know what to call its units. Gets multiplied by the camera zoom level to
                                                        // make shadow lengths look more consistent.
