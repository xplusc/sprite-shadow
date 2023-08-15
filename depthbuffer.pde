final float INF = 1.0 / 0.0; // floating-point infinity

class DepthBuffer {
  float[][] frame;
  int w, h;        // su
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
    min = distanceFromCameraPlane(gridToWorld(screenToGrid(new PVector(0, SCREEN_HEIGHT - 1)))); // x-value doesn't matter
    max = distanceFromCameraPlane(gridToWorld(screenToGrid(new PVector(0, 0))));
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        float depth = max - ((float) y / (h - 1)) * (max - min);
        frame[y][x] = depth;
      }
    }
  }
  
  //void setPixel(PVector pos, float depth)
  //{
  //  // align to DepthBuffer grid
  //  int x = floor(pos.x);
  //  int y = floor(pos.y);
    
  //  if (
  //    x >= 0 &&
  //    x <  w &&
  //    y >= 0 &&
  //    y <  h
  //  ) {
  //    frame[y][x] = depth;
  //    min = min(depth, min);
  //    max = max(depth, max);
  //  }
  //}
  
  //void addImage(PImage i, int x_pos, int y_pos, int depth_offset)
  //{
  //  float bottom_edge = y_pos + i.height;
  //  float bottom_edge_depth = distanceFromCameraPlane(screenToWorld(new PVector(x_pos * PIXEL_SCALE, bottom_edge * PIXEL_SCALE)));
  //  loadPixels();
  //  for (int y = 0; y < i.height; ++y) {
  //    for (int x = 0; x < i.width; ++x) {
  //      if (((i.pixels[x + i.width * y] >> 8) & 0xFF) > 0) {
  //        if (
  //          x + x_pos >= 0 &&
  //          x + x_pos <  w &&
  //          y + y_pos >= 0 &&
  //          y + y_pos <  h
  //        ) {
  //          //if (x == 48 && y == 106) {
  //          //  print("(" + x + ", " + y + "), " + (depth_offset - ((sp.pixels[x + sp.width * y] & 0xFF00) >> 8)) + ", "); // run
  //          //  println(frame[y + y_pos][x + x_pos]); // rise
  //          //}
  //          float depth = bottom_edge_depth + K * (depth_offset - (i.pixels[x + i.width * y] & 0xFF));
  //          min = min(depth, min);
  //          max = max(depth, max);
  //          frame[y + y_pos][x + x_pos] = depth;
  //        }
  //      }
  //    }
  //  }
  //  updatePixels();
  //}
  
  void draw()
  {
    float range = max - min;
    //println("max: ", max, ", min: ", min);
    //println("range: ", range);
    
    loadPixels();
    for (int y = 0; y < SCREEN_HEIGHT; ++y) {
      for (int x = 0; x < SCREEN_WIDTH; ++x) {
        //println("frame[db_y][db_x]: ", frame[db_y][db_x], ", - min: ", frame[db_y][db_x] - min, ", / range: ", (frame[db_y][db_x] - min) / range);
        pixels[SCREEN_WIDTH * y + x] = color(255 * (1 - (frame[y][x] - min) / range));
      }
    }
    updatePixels();
  }
}
