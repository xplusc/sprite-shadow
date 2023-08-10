class FrameBuffer {
  color[][] frame;
  int w, h;        // su
  
  FrameBuffer()
  {
    w = SCREEN_WIDTH;
    h = SCREEN_HEIGHT;
    frame = new color[h][w];
    
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        frame[y][x] = color(0);
      }
    }
  }
  
  void clear()
  {
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        //print("(" + x + ", " + y + ")\n");
        //pixels[w * y + x] = color(255 * y / h);
        frame[y][x] = color(0);
      }
    }
  }
  
  //void setPixel(PVector pos, color c)
  //{
  //  // align to FrameBuffer grid
  //  int x = floor(pos.x);
  //  int y = floor(pos.y);
  //  //println("sc: (", screen_x, ", ", screen_y, ")");
  //  if (
  //    x >= 0 &&
  //    x <  w &&
  //    y >= 0 &&
  //    y <  h
  //  ) {
  //    frame[y][x] = c;
  //  }
  //}
  
  //void addImage(PImage i, int x_pos, int y_pos)
  //{
  //  loadPixels();
  //  for (int y = 0; y < i.height; ++y) {
  //    for (int x = 0; x < i.width; ++x) {
  //      //println();
  //      //println(sp.width);
  //      //println(sp.height);
  //      //println(sp_x);
  //      //println(sp_y);
  //      //println(sp_x + sp.width * sp_y);
  //      if ((i.pixels[x + i.width * y] & 0x000000FF) > 0) {
  //        if (
  //          x + x_pos >= 0 &&
  //          x + x_pos <  w &&
  //          y + y_pos >= 0 &&
  //          y + y_pos <  h
  //        ) {
  //          frame[y + y_pos][x + x_pos] = i.pixels[x + i.width * y];
  //        }
  //      }
  //    }
  //  }
  //  updatePixels();
  //}
  
  void draw()
  {
    loadPixels();
    for (int y = 0; y < SCREEN_HEIGHT; ++y) {
      for (int x = 0; x < SCREEN_WIDTH; ++x) {
        //print("xy:    (" + x + ", " + y + ")\n");
        //print("fb_xy: (" + fb_x + ", " + fb_y + ")\n");
        //println(fb_x + w * fb_y);
        //print("frame[fb_y][fb_x]: " + frame[fb_y][fb_x] + "\n");
        pixels[SCREEN_WIDTH * y + x] = frame[y][x];
      }
    }
    updatePixels();
  }
}
