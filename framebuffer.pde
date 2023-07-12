class FrameBuffer {
  color[][] frame;
  int w;
  int h;
  
  FrameBuffer()
  {
    w = (int) (SCREEN_WIDTH  / PIXEL_SCALE);
    h = (int) (SCREEN_HEIGHT / PIXEL_SCALE);
    frame = new color[h][w];
    
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        frame[y][x] = color(0);
      }
    }
  }
  
  void clear()
  {
    //loadPixels();
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        //print("(" + x + ", " + y + ")\n");
        //pixels[w * y + x] = color(255 * y / h);
        frame[y][x] = color(0);
      }
    }
    //updatePixels();
  }
  
  void setPixel(PVector pos, color c)
  {
    // align to FrameBuffer grid
    int x = (int) pos.x;
    int y = (int) pos.y;
    //println("sc: (", screen_x, ", ", screen_y, ")");
    if (
      x >= 0 &&
      x <  w &&
      y >= 0 &&
      y <  h
    ) {
      frame[y][x] = c;
    }
  }
  
  void addSprite(PImage sp, int x_pos, int y_pos)
  {
    loadPixels();
    for (int y = 0; y < sp.height; ++y) {
      for (int x = 0; x < sp.width; ++x) {
        //println();
        //println(sp.width);
        //println(sp.height);
        //println(sp_x);
        //println(sp_y);
        //println(sp_x + sp.width * sp_y);
        if ((sp.pixels[x + sp.width * y] & 0x000000FF) > 0) {
          if (
            x + x_pos >= 0 &&
            x + x_pos <  w &&
            y + y_pos >= 0 &&
            y + y_pos <  h
          ) {
            frame[y + y_pos][x + x_pos] = sp.pixels[x + sp.width * y];
          }
        }
      }
    }
    updatePixels();
  }
  
  void draw()
  {
    loadPixels();
    for (int y = 0; y < h * PIXEL_SCALE; ++y) {
      for (int x = 0; x < w * PIXEL_SCALE; ++x) {
        //print("xy:    (" + x + ", " + y + ")\n");
        int fb_x = (int) (x / PIXEL_SCALE);
        int fb_y = (int) (y / PIXEL_SCALE);
        //print("fb_xy: (" + fb_x + ", " + fb_y + ")\n");
        //println(fb_x + w * fb_y);
        //print("frame[fb_y][fb_x]: " + frame[fb_y][fb_x] + "\n");
        pixels[w * (int) PIXEL_SCALE * y + x] = frame[fb_y][fb_x];
      }
    }
    updatePixels();
  }
}
