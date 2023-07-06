final float INF = 1.0 / 0.0; // floating-point infinity

class DepthBuffer {
  float[][] frame;
  int w;
  int h;
  float min;
  float max;
  
  DepthBuffer()
  {
    w = SCREEN_WIDTH;
    h = SCREEN_HEIGHT;
    frame = new float[h][w];
    min =  INF;
    max = -INF;
  }
  
  void clear()
  {
    min =  INF;
    max = -INF;
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        float depth = distanceFromCameraPlane(screenToWorld(new PVector(x, y)));
        min = min(depth, min);
        max = max(depth, max);
        frame[y][x] = depth;
      }
    }
  }
  
  void setPixel(PVector pos, float depth)
  {
    // get PIXEL_SCALE grid-aligned screen coordinates
    int screen_x = (int) PIXEL_SCALE * (int) (pos.x / PIXEL_SCALE);
    int screen_y = (int) PIXEL_SCALE * (int) (pos.y / PIXEL_SCALE);
    
    for (int y = 0; y < PIXEL_SCALE; ++y) {
      for (int x = 0; x < PIXEL_SCALE; ++x) {
        if (
          x + screen_x >= 0 &&
          x + screen_x <  w &&
          y + screen_y >= 0 &&
          y + screen_y <  h
        ) {
          frame[y + screen_y][x + screen_x] = depth;
          min = min(depth, min);
          max = max(depth, max);
        }
      }
    }
  }
  
  void draw()
  {
    float range = max - min;
    //println("max: ", max, ", min: ", min);
    //println("range: ", range);
    loadPixels();
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        //println("frame[y][x]: ", frame[y][x], ", - min: ", frame[y][x] - min, ", / range: ", (frame[y][x] - min) / range);
        pixels[w * y + x] = color(255 * (1 - (frame[y][x] - min) / range));
      }
    }
    updatePixels();
  }
}
