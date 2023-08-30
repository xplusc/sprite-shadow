/**
 * SHADOWS
 * Author: "+ C"
 * Github: https://github.com/xplusc
 */

import java.util.Map;

/* ----- FUNCS ----- */

/**
 * Draws (adds to frame buffer) the specified sprite <sp> with <tl> being the top-left 
 * corner of the sprite and <d> being the depth of the sprite's base (usually bottom edge).
 * Depth buffer is used to perform depth sorting.
 */
void drawSprite(Sprite sp, PVector tl, float d, boolean check_zd)
{
  // find all bounds for the loops
  PVector start_gc = pv_max(tl, camera.tl); // top-left of the area that will be drawn, gc
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
  float pulled_w = end_sp.x - start_sp.x; // pulled means the area from the sprite that is 
  float pulled_h = end_sp.y - start_sp.y; // in view of the camera and gets "pulled" to be drawn
  
  loadPixels();
  // iterate across the pixels contained in the area being drawn
  for (int sc_y = (int) start_sc.y; sc_y < (int) end_sc.y; ++sc_y) {
    for (int sc_x = (int) start_sc.x; sc_x < (int) end_sc.x; ++sc_x) {
      float t_x = (sc_x - start_sc.x) / drawn_w;
      float t_y = (sc_y - start_sc.y) / drawn_h;
      t_x = constrain(t_x, 0, 1); // wish I could get rid of these (maybe I can?)
      t_y = constrain(t_y, 0, 1);
      int sp_x = (int) (start_sp.x + t_x * pulled_w);
      int sp_y = (int) (start_sp.y + t_y * pulled_h);
      
      if ((sp.data.pixels[sp_x + sp.w * sp_y] & 0xFF000000) == 0) // is this pixel transparent?
        continue;
      if (check_zd) {
        int zd_value = sp.zd_data.pixels[sp_x + sp.w * sp_y] & 0xFF;
        float depth  = d + K * (sp.zd_offset - zd_value);
        if (zd.frame[sc_y][sc_x] <= depth) // is this pixel occluded?
          continue;
        zd.frame[sc_y][sc_x] = depth; // update depth buffer
        zd.min = min(depth, zd.min);
        zd.max = max(depth, zd.max);
      }
      
      fb.frame[sc_y][sc_x] = sp.data.pixels[sp_x + sp.w * sp_y]; // add sprite color to frame buffer
    }
  }
  updatePixels();
}

/**
 * Draws (adds to frame buffer) the specified tile <t>.
 */
void drawTile(Tile t)
{
  Sprite sp = sprite_map.get(t.sprite_name);
  PVector gc = worldToGrid(t.pos);                              // grid coordinate of this prop's position
  PVector tl = PVector.add(gc, new PVector(-sp.w / 2, -sp.h));  // top-left grid coordinate of this prop's sprite
  tl = new PVector(floor(tl.x), floor(tl.y));                   // align to world grid
  
  if (camera.inView(tl.x, tl.y, sp.w, sp.h))
    drawSprite(sp, tl, distanceFromCameraPlane(t.pos), false);
}

/**
 * Draws (adds to frame buffer) the specified prop <p>.
 */
void drawProp(Prop p)
{
  Sprite sp = sprite_map.get(p.sprite_name);
  PVector gc = worldToGrid(p.pos);                              // grid coordinate of this prop's position
  PVector tl = PVector.add(gc, new PVector(-sp.w / 2, -sp.h));  // top-left grid coordinate of this prop's sprite
  tl = new PVector(floor(tl.x), floor(tl.y));                   // align to world grid
  
  if (camera.inView(tl.x, tl.y, sp.w, sp.h))
    drawSprite(sp, tl, distanceFromCameraPlane(p.pos), true);
}

/**
 * Applies the global directional light as defined in the lighting JSON by
 * calculating which pixels aren't occluded in the direction of the light.
 * Updates the light buffer accordingly.
 */
void applyGlobalDirectionalLight(DepthBuffer zd, LightBuffer lb)
{
  PVector grid_dir = worldToGrid(directional_light_dir);         // gc
  float zslope = distanceFromCameraPlane(directional_light_dir); // delta z / wu
  float slope  = abs(grid_dir.y / grid_dir.x);
  int x_dir    = sign(grid_dir.x);
  int y_dir    = sign(grid_dir.y);
  float zslope_x = zslope / (grid_dir.x * camera.z);
  float zslope_y = zslope / (grid_dir.y * camera.z);
  int check_distance = (int) (camera.z * LIGHTING_CHECK_DISTANCE /*/ abs(zslope)*/);
  
  for (int target_y = 0; target_y < lb.h; ++target_y) {
    for (int target_x = 0; target_x < lb.w; ++target_x) {
      float target_depth = zd.frame[target_y][target_x];
      boolean occluded = false;
      int j = 0;
      
      // Choose between two for loops, one incrementing x and the other
      // increment y. Basically this is just rasterizing a line. This
      // should probably be separated out into its own function that
      // returns a list of screen coordinates to check.
      if (slope < 1) {
        for (int i = 1; i < check_distance; ++i) {
          float other_coord = slope * i;
          if (round(other_coord) != j)
            ++j;
          int polled_x = target_x + x_dir * i;
          int polled_y = target_y + y_dir * j;
          
          if ( // check if out of bounds
            polled_x < 0 ||
            polled_x >= SCREEN_WIDTH ||
            polled_y < 0 ||
            polled_y >= SCREEN_HEIGHT
          ) {
            break;
          }
          
          float polled_depth = zd.frame[polled_y][polled_x];
          float lower_bound  = target_depth + zslope_x * (i - 0.5);
          float upper_bound  = lower_bound  + zslope_x * (i + 0.5);
          if (
            (polled_depth >= lower_bound && polled_depth <  upper_bound) ||
            (polled_depth <  lower_bound && polled_depth >= upper_bound)
          ) { // something occludes the target pixel
            occluded = true;
            break;
          }
        }
      } else {
        for (int i = 1; i < check_distance; ++i) {
          float other_coord = (1 / slope) * (i - 0) + 0;
          if ((int) round(other_coord) != j)
        ++j;
          int polled_y = target_y + y_dir * i;
          int polled_x = target_x + x_dir * j;
          
          if ( // don't check out of bounds
            polled_x < 0 ||
            polled_x >= SCREEN_WIDTH ||
            polled_y < 0 ||
            polled_y >= SCREEN_HEIGHT
          ) {
            break;
          }
          
          float polled_depth = zd.frame[polled_y][polled_x];
          float lower_bound  = target_depth + zslope_y * (i - 0.5);
          float upper_bound  = lower_bound  + zslope_y * (i + 0.5);
          if (
            (polled_depth >= lower_bound && polled_depth <  upper_bound) ||
            (polled_depth <  lower_bound && polled_depth >= upper_bound)
          ) { // something occludes the target pixel
            occluded = true;
            break;
          }
        }
      }
      
      if (!occluded) { // this pixel is in the light
        lb.frame[target_y][target_x][0] += directional_light[0];
        lb.frame[target_y][target_x][1] += directional_light[1];
        lb.frame[target_y][target_x][2] += directional_light[2];
      }
    }
  }
}

/**
 * Reads the per-pixel lighting data from <lb> and applies it to
 * the per-pixel albedos from <fb>.
 */
void applyLightToFrame(FrameBuffer fb, LightBuffer lb)
{
  for (int y = 0; y < fb.h; ++y) {
    for (int x = 0; x < fb.w; ++x) {
      color albedo = fb.frame[y][x];
      // convert <albedo> into a float[3] color representation
      float[] rgb_albedo = {(float) (albedo >> 16 & 0xFF) / 255, (float) (albedo >> 8 & 0xFF) / 255, (float) (albedo & 0xFF) / 255};
      // multiply the albedo color by the lighting color
      color new_pixel_color = color(
        (int) (255 * rgb_albedo[0] * lb.frame[y][x][0]),
        (int) (255 * rgb_albedo[1] * lb.frame[y][x][1]),
        (int) (255 * rgb_albedo[2] * lb.frame[y][x][2])
      );
      
      fb.frame[y][x] = new_pixel_color;
    }
  }
}

/* ----- SETUP ----- */

// mutable globals
JSONObject json;

FrameBuffer fb;
DepthBuffer zd;
LightBuffer lb;
HashMap<String, Sprite> sprite_map;
ArrayList<Tile> tiles;
ArrayList<Prop> props;
Camera camera;
float[] ambient_light;         // color
float[] directional_light;     // color
PVector directional_light_dir; // wc, normalized

// unused unless you uncomment light source rotation (in keyPressed())
float azimuth;
float elevation;

// flags
boolean zdepth;
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
  
  // initialize mutable globals
  fb = new FrameBuffer();
  zd = new DepthBuffer();
  lb = new LightBuffer();
  camera = new Camera(new PVector(0, 0), 1);
  ambient_light = new float[3];
  directional_light = new float[3];
  
  // unused unless you uncomment light source rotation (in keyPressed())
  azimuth   = 110 * PI / 180;
  elevation = 35  * PI / 180;
  
  // initialize data
  initFromJSON("data/sprites.json");
  initFromJSON("data/tiles.json");
  initFromJSON("data/props.json");
  initFromJSON("data/lighting.json");
  
  // initialize flags
  zdepth  = false;
  debug   = false;
}

/* ----- INPUT ----- */

void keyPressed()
{
  if (key == CODED) {
    float x, y, z;
    switch (keyCode) {
      /* uncomment this vvv stuff to allow for spinning the light source around */
      /*case LEFT:  azimuth += 0.01;
                  x = cos(azimuth) * cos(elevation);
                  y = sin(elevation);
                  z = sin(azimuth) * cos(elevation);
                  directional_light_dir = new PVector(x, y, z); // wc
                  break;
      case RIGHT: azimuth -= 0.01;
                  x = cos(azimuth) * cos(elevation);
                  y = sin(elevation);
                  z = sin(azimuth) * cos(elevation);
                  directional_light_dir = new PVector(x, y, z); // wc
                  break;*/
      default: break;
    }
  } else {
    switch (key) {
      case 'w': camera.moveCamera(new PVector( 0, -3 / camera.z)); break; // WASD move the camera around
      case 'a': camera.moveCamera(new PVector(-3 / camera.z,  0)); break;
      case 's': camera.moveCamera(new PVector( 0,  3 / camera.z)); break;
      case 'd': camera.moveCamera(new PVector( 3 / camera.z,  0)); break;
      case '=': camera.setZoom(camera.z * 2); break;                      // + and - zoom the camera in and out
      case '-': camera.setZoom(camera.z * 0.5); break;
      case 'i': initFromJSON("data/sprites.json");  break;                // different hotkeys for reloading JSON-based data
      case 't': initFromJSON("data/tiles.json");    break;
      case 'p': initFromJSON("data/props.json");    break;
      case 'l': initFromJSON("data/lighting.json"); break;
      case 'z': zdepth = !zdepth; break;                                  // switch to zdepth view
      default: break;
    }
  }
}

/* ----- DRAW  ----- */

void draw()
{
  fb.clear();
  zd.clear();
  lb.clear();
  
  // add everything to the relevant buffers
  for (int i = 0; i < tiles.size(); ++i) {
    drawTile(tiles.get(i));
  }
  for (int i = 0; i < props.size(); ++i) {
    drawProp(props.get(i));
  }
  
  // calculate lighting
  applyGlobalDirectionalLight(zd, lb);
  applyLightToFrame(fb, lb);
  
  // draw
  if (zdepth) {
    zd.draw();
  } else {
    fb.draw();
  }
}
