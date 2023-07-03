class DepthBuffer {
  float[][] frame;
  int w;
  int h;
  
  DepthBuffer()
  {
    w = SCREEN_WIDTH;
    h = SCREEN_HEIGHT;
    frame = new float[h][w];
  }
}
