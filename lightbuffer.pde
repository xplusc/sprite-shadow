class LightBuffer {
  float[][][] frame; // colors as float[3]s
  int w, h;          // su
  
  LightBuffer()
  {
    w = SCREEN_WIDTH;
    h = SCREEN_HEIGHT;
    frame = new float[h][w][3];
    
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        frame[y][x][0] = 0;
        frame[y][x][1] = 0;
        frame[y][x][2] = 0;
      }
    }
  }
  
  void clear()
  {
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {
        frame[y][x][0] = ambient_light[0];
        frame[y][x][1] = ambient_light[1];
        frame[y][x][2] = ambient_light[2];
      }
    }
  }
  
  /**
   * Adds the float[3] representation of a color to the already
   * existing element at frame[y][x]. Compiler may inline this.
   */
  void addToElement(int x, int y, float[] rgb)
  {
    frame[y][x][0] = rgb[0];
    frame[y][x][1] = rgb[1];
    frame[y][x][2] = rgb[2];
  }
}
