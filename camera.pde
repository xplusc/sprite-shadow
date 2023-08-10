class Camera {
  PVector c;            // gc
  PVector tl;           // top-left corner, gc
  float   z;
  private float   w, h; // gu

  Camera(PVector center, float zoom)
  {
    c  = center;
    z  = zoom;
    h  = SCREEN_HEIGHT / z;
    w  = SCREEN_WIDTH  / z;
    tl = PVector.add(c, new PVector(-w / 2, -h / 2));
  }
  
  void setZoom(float zoom)
  {
    z  = zoom;
    h  = SCREEN_HEIGHT / z;
    w  = SCREEN_WIDTH  / z;
    tl = PVector.add(c, new PVector(-w / 2, -h / 2));
  }
  
  /**
   * Adds <delta> to the camera's position.
   */
  void moveCamera(PVector delta)
  {
    c  = PVector.add(c, delta);
    tl = PVector.add(c, new PVector(-w / 2, -h / 2));
  }
  
  /**
   * Returns true if the rectangle defined by the top left corner (<x>, <y>), width <w>, 
   * and height <h> is contained within the camera's bounding box.
   */
  boolean inView(float x, float y, float w, float h)
  {
    return
      x + w >= tl.x          &&
      x     <  tl.x + this.w &&
      y + h >= tl.y          &&
      y     <  tl.y + this.h;
  }
  
  /**
   * Returns true if the point (<x>, <y>) is contained within the camera's bounding box.
   */
  boolean inView(float x, float y)
  {
    return
      x >= tl.x          &&
      x <  tl.x + this.w &&
      y >= tl.y          &&
      y <  tl.y + this.h;
  }
}
