class FrameBuffer {
  color[][] frame;
  int w;
  int h;
  
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
    loadPixels();
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        //print("(" + x + ", " + y + ")\n");
        //pixels[w * y + x] = color(255 * y / h);
        frame[y][x] = color(0);
      }
    }
    updatePixels();
  }
  
  void addSprite(PImage sp, int x_pos, int y_pos)
  {
    loadPixels();
    for (int y = 0; y < sp.height * PIXEL_SCALE; ++y) {
      for (int x = 0; x < sp.width * PIXEL_SCALE; ++x) {
        int sp_x = floor(x / PIXEL_SCALE);
        int sp_y = floor(y / PIXEL_SCALE);
        /*println();
        println(sp.width);
        println(sp.height);
        println(sp_x);
        println(sp_y);
        println(sp_x + sp.width * sp_y);*/
        if ((sp.pixels[sp_x + sp.width * sp_y] & 0x000000FF) > 0) {
          if (
            x + x_pos >= 0 &&
            x + x_pos < SCREEN_WIDTH &&
            y + y_pos >= 0 &&
            y + y_pos < SCREEN_HEIGHT
          ) {
            frame[y + y_pos][x + x_pos] = sp.pixels[sp_x + sp.width * sp_y];
          }
        }
      }
    }
    updatePixels();
  }
  
  void draw()
  {
    loadPixels();
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        //print("(" + x + ", " + y + ")\n");
        //pixels[w * y + x] = color(255 * y / h);
        pixels[w * y + x] = frame[y][x];
      }
    }
    updatePixels();
  }
}
