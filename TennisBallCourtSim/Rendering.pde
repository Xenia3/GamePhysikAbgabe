void applyCamera() {
  translate(width/2f, height - VIEW_MARGIN_PX);
  scale(cam.zoom);
  translate(-cam.x * SCALE_PX_PER_M, 0);
}

void drawCourt() {
  noStroke();
  fill(currentCourt.courtColor);
  float x0 = worldToScreenX(0);
  float x1 = worldToScreenX(COURT_LENGTH_M);
  float y0 = worldToScreenY(0);
  rectMode(CORNER);
  rect(x0, y0, x1 - x0, 6);

  stroke(LINE_COL);
  strokeWeight(2);
  line(worldToScreenX(0),            worldToScreenY(0), worldToScreenX(0),            worldToScreenY(-0.25f));
  line(worldToScreenX(COURT_LENGTH_M),worldToScreenY(0), worldToScreenX(COURT_LENGTH_M),worldToScreenY(-0.25f));

  stroke(200, 200);
  line(worldToScreenX(NET_X_M), worldToScreenY(0), worldToScreenX(NET_X_M), worldToScreenY(-0.25f));
}

void drawNet() {
  stroke(220);
  strokeWeight(3);
  float sx   = worldToScreenX(NET_X_M);
  float yTop = worldToScreenY(NET_H_M);
  float yBot = worldToScreenY(0);
  line(sx, yBot, sx, yTop);
  strokeWeight(2);
}

// Vorherige Abpralllinie (grau)
void drawPrevBounceRay() {
  stroke(180, 180);
  strokeWeight(2);
  float dirAng = radians(prevAngleDeg);
  float x0 = worldToScreenX(prevBounceX);
  float y0 = worldToScreenY(0);
  float len = 200;
  float x1 = x0 + cos(-dirAng) * len;
  float y1 = y0 + sin(-dirAng) * len;
  line(x0, y0, x1, y1);
  noStroke();
  fill(180, 180);
  ellipse(x0, y0, 6, 6);
}

// Aktuelle Abpralllinie (rot)
void drawBounceRay() {
  stroke(RED);
  strokeWeight(2);
  float dirAng = radians(ball.bounce1AngleDeg);
  float x0 = worldToScreenX(ball.bounce1X);
  float y0 = worldToScreenY(0);
  float x1 = x0 + cos(-dirAng) * 200;
  float y1 = y0 + sin(-dirAng) * 200;
  line(x0, y0, x1, y1);
}

// Ball + Dreieck (Launcher)
void drawBall() {
  if (state == SimState.PENDING) {
    pushMatrix();
    translate(worldToScreenX(0), worldToScreenY(sliderHeight.value));
    float ang = radians(sliderAngle.value);
    rotate(-ang);
    fill(80, 180);
    stroke(220, 180);
    strokeWeight(1.5f);
    triangle(0, 0, -28, -10, -28, 10);
    popMatrix();
  }

  float rPhysPx  = BALL_R_M * SCALE_PX_PER_M;
  float rDrawPx  = max(rPhysPx, BALL_DRAW_DIAM_PX/2f);
  float sx = worldToScreenX(ball.x);
  float sy = worldToScreenY(ball.y);

  noStroke();
  fill(BALL_COL);
  ellipse(sx, sy, 2*rDrawPx, 2*rDrawPx);

  // schwarze diagonale Naht 
  pushMatrix();
  translate(sx, sy);
  rotate(ball.theta);
  stroke(0);
  strokeWeight(max(2.0f, rDrawPx * 0.18f));
  strokeCap(ROUND);
  float d = rDrawPx * 0.7f;
  line(-d, -d, d, d);
  popMatrix();
}

// Ball an der Dreiecksspitze
void updateBallAtLauncherTip() {
  float ang = radians(sliderAngle.value);
  ball.x = BALL_R_M * cos(ang);
  ball.y = sliderHeight.value + BALL_R_M * sin(ang);
  ball.vx = 0;
  ball.vy = 0;
  ball.spin = sliderSpin.value;
}

// UI-Texte
void drawTopBar() {
  fill(TEXT_COL);
  textAlign(CENTER, TOP);
  textSize(20);
  text(currentCourt.name, width/2f, 16);
  textSize(16);
}

void drawStatusText() {
  fill(TEXT_COL);
  textAlign(CENTER, TOP);
  if (state == SimState.PENDING)           text("Simulation Pending.  \nWaiting for User Input.", width/2f, 48);
  else if (state == SimState.RUNNING)      text("Simulation Running.  \nHitting Ground Soon.",    width/2f, 48);
  else if (state == SimState.POST1_ZOOMOUT)text("Simulation Running.  \nBall Hitting Ground.",    width/2f, 48);
  else                                     text("Simulation Finished.  \nRestarting Soon…",        width/2f, 48);
}

void drawSliders() {
  sliderHeight.draw();
  sliderSpeed.draw();
  sliderAngle.draw();
  sliderSpin.draw();
}

void drawCourtSwitchHint() {
  if (state != SimState.PENDING) return;
  fill(TEXT_COL);
  textAlign(LEFT, TOP);
  textSize(16);
  float x = 50;
  float y = okButton.y + okButton.h + 16;
  text("Press 1 for Clay",  x, y);
  text("Press 2 for Grass", x, y + 22);
  text("Press 3 for Hard",  x, y + 44);
}

// Metriken
void drawMetrics() {
  String s1 = "Speed after bounce: " + nf(ball.bounce1Speed, 0, 2) + " m/s  (" + nf(ball.bounce1Speed * 3.6f, 0, 1) + " km/h)";
  String s2 = "Rebound angle: " + nf(ball.bounce1AngleDeg, 0, 1) + "°";
  String s3 = "Spin (now): " + nf(ball.postSpin, 0, 1) + " rad/s";
  String s4 = "New peak: " + nf(ball.bounce1NewPeak, 0, 2) + " m";

  textAlign(RIGHT, BOTTOM); fill(240);
  text(s1, width - 20, height - 68);
  text(s2, width - 20, height - 52);
  text(s3, width - 20, height - 36);
  text(s4, width - 20, height - 20);

  float dv = (ball.preVmag > 0) ? (ball.preVmag - ball.postVmag) : 0;
  float dspin = (ball.preSpin - ball.postSpin);
  textAlign(LEFT, BOTTOM);
  text("Losses:  Δv=" + nf(dv, 0, 2) + " m/s  (" + nf(dv * 3.6f, 0, 1) + " km/h),  Δspin=" + nf(dspin, 0, 1) + " rad/s", 20, height - 20);
}

// Vorherige Wurf Stats (Overlay)
void drawPrevStatsOverlay() {
  float cx = width/2f;
  float yTop = height/2f - 200;
  fill(180);
  textAlign(CENTER, TOP);
  textSize(14);
  text("Vorheriger Wurf", cx, yTop);
  String l1 = "v nach Bounce: " + nf(prevSpeed, 0, 2) + " m/s (" + nf(prevSpeed*3.6f, 0, 1) + " km/h)";
  String l2 = "Winkel: " + nf(prevAngleDeg, 0, 1) + "°   Spin: " + nf(prevSpin, 0, 1) + " rad/s   Peak: " + nf(prevPeak, 0, 2) + " m";
  text(l1, cx, yTop + 18);
  text(l2, cx, yTop + 36);
}

// Countdown + Reset
void drawCountdownAndMaybeReset() {
  int elapsed = millis() - countdownStartMillis;
  int remain = max(0, countdownSec - floor(elapsed / 1000f));
  fill(255, 230);
  textAlign(CENTER, CENTER);
  textSize(64);
  text(str(remain), width/2f, height/2f);
  textSize(16);

  if (remain <= 0) {
    savePrevStats();
    resetToPending();
  }
}

// Vorherige Metriken sichern
void savePrevStats() {
  prevSpeed    = ball.bounce1Speed;
  prevAngleDeg = ball.bounce1AngleDeg;
  prevSpin     = ball.postSpin;
  prevPeak     = ball.bounce1NewPeak;
  prevBounceX  = ball.bounce1X;
  hasPrevStats = true;
}

// Welt->Bildschirm
float worldToScreenX(float xM) { return xM * SCALE_PX_PER_M; }
float worldToScreenY(float yM) { return -yM * SCALE_PX_PER_M; }
