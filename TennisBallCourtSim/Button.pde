class Button {
  String label; 
  float x, y, w, h;
  Button(String label, float x, float y, float w, float h) {
    this.label=label; this.x=x; this.y=y; this.w=w; this.h=h;
  }
  void draw() {
    stroke(200); fill(30); rect(x, y, w, h, 8);
    fill(230); textAlign(CENTER, CENTER); text(label, x+w/2, y+h/2);
  }
  boolean hit(float mx, float my) { return (mx>=x && mx<=x+w && my>=y && my<=y+h); }
}
