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
        color albedo    = frame[y][x];
        float[] rgb_alb = {(float) (albedo >> 16 & 0xFF) / 255, (float) (albedo >> 8 & 0xFF) / 255, (float) (albedo & 0xFF) / 255};
        color pixel_color = color(
          (int) (255 * rgb_alb[0] * ambient_light[0]),
          (int) (255 * rgb_alb[1] * ambient_light[1]),
          (int) (255 * rgb_alb[2] * ambient_light[2])
        );
        //if ((albedo & 0xFF) > 0) {
        //  println("albedo:  " + albedo);
        //  println("b_alb:   " + (albedo & 0xFF));
        //  println("r_alb / 255: " + ((float) (albedo & 0xFF) / 255));
        //  println("rgb_alb: [ " + rgb_alb[0] + ", " + rgb_alb[1] + ", " + rgb_alb[2] + " ]");
        //  println("rgb_amb: [ " + rgb_amb[0] + ", " + rgb_amb[1] + ", " + rgb_amb[2] + " ]");
        //  println("pixel_color: " + pixel_color);
        //}
        pixels[SCREEN_WIDTH * y + x] = pixel_color;
      }
    }
    updatePixels();
  }
}
