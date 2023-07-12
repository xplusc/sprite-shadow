final float INF = 1.0 / 0.0; // floating-point infinity

class DepthBuffer {
  float[][] frame;
  int w;
  int h;
  float min;
  float max;
  
  DepthBuffer()
  {
    w = floor(SCREEN_WIDTH  / PIXEL_SCALE);
    h = floor(SCREEN_HEIGHT / PIXEL_SCALE);
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
        float depth = distanceFromCameraPlane(screenToWorld(new PVector(x * PIXEL_SCALE, y * PIXEL_SCALE)));
        min = min(depth, min);
        max = max(depth, max);
        frame[y][x] = depth;
      }
    }
  }
  
  void setPixel(PVector pos, float depth)
  {
    // align to DepthBuffer grid
    int x = floor(pos.x);
    int y = floor(pos.y);
    
    if (
      x >= 0 &&
      x <  w &&
      y >= 0 &&
      y <  h
    ) {
      frame[y][x] = depth;
      min = min(depth, min);
      max = max(depth, max);
    }
  }
  
  void draw()
  {
    float range = max - min;
    //println("max: ", max, ", min: ", min);
    //println("range: ", range);
    loadPixels();
    for (int y = 0; y < SCREEN_HEIGHT; ++y) {
      for (int x = 0; x < SCREEN_WIDTH; ++x) {
        int db_x = floor(x / PIXEL_SCALE) % w;
        int db_y = floor(y / PIXEL_SCALE) % h;
        //println("frame[db_y][db_x]: ", frame[db_y][db_x], ", - min: ", frame[db_y][db_x] - min, ", / range: ", (frame[db_y][db_x] - min) / range);
        pixels[SCREEN_WIDTH * y + x] = color(255 * (1 - (frame[db_y][db_x] - min) / range));
      }
    }
    updatePixels();
  }
}
