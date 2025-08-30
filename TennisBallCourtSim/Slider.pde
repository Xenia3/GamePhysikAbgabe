class Slider {
  String label;
  float x, y, w, h;
  float minVal, maxVal, value;
  boolean dragging = false;

  Slider(String label, float x, float y, float w, float h, float minV, float maxV, float startV) {
    this.label = label;
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.minVal = minV; this.maxVal = maxV; this.value = startV;
  }

  void draw() {
    stroke(180); fill(40);
    rect(x, y + h*0.4f, w, h*0.2f, 6);

    float t = map(value, minVal, maxVal, 0, 1);
    float tx = x + t * w;
    noStroke(); fill(200);
    rectMode(CENTER); rect(tx, y + h*0.5f, 14, h, 4); rectMode(CORNER);

    fill(TEXT_COL); textAlign(LEFT, BOTTOM); text(label, x, y - 4);
    textAlign(RIGHT, BOTTOM);
    if (label.contains("Abwurfgeschwindigkeit")) {
      text(nf(value, 0, 2) + " m/s  (" + nf(value * 3.6f, 0, 1) + " km/h)", x + w, y - 4);
    } else {
      text(nf(value, 0, 2), x + w, y - 4);
    }
  }

  void mousePressed() {
    float t = map(value, minVal, maxVal, 0, 1);
    float tx = x + t * w;
    if (mouseX >= tx - 10 && mouseX <= tx + 10 && mouseY >= y && mouseY <= y + h) dragging = true;
  }
  void mouseDragged() {
    if (dragging) {
      float t = constrain((mouseX - x) / w, 0, 1);
      value = lerp(minVal, maxVal, t);
    }
  }
  void mouseReleased() { dragging = false; }
}
