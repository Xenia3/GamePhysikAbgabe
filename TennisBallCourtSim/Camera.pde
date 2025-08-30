class Camera {
  float x, y, zoom;
  float targetX, targetY, targetZoom;
  Camera() {
    x=0; y=0; zoom=1;
    targetX=0; targetY=0; targetZoom=1;
  }
  void update(float lp, float lz) {
    x    = lerp(x,    targetX,    lp);
    y    = lerp(y,    targetY,    lp);
    zoom = lerp(zoom, targetZoom, lz);
  }
}
