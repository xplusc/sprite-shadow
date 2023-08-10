class Sprite {
  PImage data;
  PImage zd_data;
  String name;
  int zd_offset;
  int w, h;       // gu
  
  Sprite(PImage pi, PImage zd, String n, int off)
  {
    data = pi;
    zd_data = zd;
    name = n;
    zd_offset = off;
    w = pi.width;
    h = pi.height;
  }
}
