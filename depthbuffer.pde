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
    min = INF;
    max = -INF;
  }
  
  void clear()
  {
    min = 0.0;
    max = 0.0;
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        float depth = distanceFromCameraPlane(screenToWorld(new PVector(x, y)));
        min = min(depth, min);
        max = max(depth, max);
        frame[y][x] = depth;
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
