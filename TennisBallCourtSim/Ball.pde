class Ball {
  float x, y, vx, vy, spin;
  boolean firstBounceDone = false;
  boolean secondBounceDone = false;

  float bounce1Speed, bounce1AngleDeg, bounce1NewPeak;
  float bounce1X; 
  float preVmag, postVmag, preSpin, postSpin;

  // Visueller Rotationswinkel für die Ball Naht
  float theta = 0.0f;

  Ball() { resetToMachine(); }

  void resetToMachine() {
    float defaultH = 1.2f;
    float startH = (sliderHeight != null) ? sliderHeight.value : defaultH;

    x = 0.0f;
    y = max(0.0f, startH);
    vx = 0; vy = 0;
    spin = (sliderSpin != null) ? sliderSpin.value : 80.0f;

    firstBounceDone = false;
    secondBounceDone = false;
    bounce1Speed = 0;
    bounce1AngleDeg = 0;
    bounce1NewPeak = 0;
    bounce1X = 0;
    preVmag = postVmag = 0;
    preSpin = postSpin = spin;

    theta = 0.0f;
  }

  // Start an der Dreiecksspitze (+ Ballradius in Wurfrichtung)
  void setLaunch(float speed, float angleDeg, float height, float spinRad) {
    float ang = radians(angleDeg);
    x = BALL_R_M * cos(ang);
    y = height + BALL_R_M * sin(ang);
    vx = max(0.1f, speed * cos(ang));
    vy = speed * sin(ang);
    spin = spinRad;
  }

  void step(float dt) {
    // Flug (einfacher Magnus nur auf Y)
    float kMagnus = 0.015f;
    float aMagnusY = kMagnus * spin * vx;

    vy += (aMagnusY - G) * dt;
    x  += vx * dt;
    y  += vy * dt;

    // visuelle Rotation
    theta += spin * dt;
    if (theta > TWO_PI)  theta -= TWO_PI;
    if (theta < -TWO_PI) theta += TWO_PI;

    if (!firstBounceDone && x + BALL_R_M > NET_X_M && x - BALL_R_M < NET_X_M) {
      float netTop = NET_H_M + BALL_R_M;
      if (y < netTop) { y = netTop; vy = abs(vy)*0.3f; vx *= 0.6f; }
    }

    // Boden-Kontakt: softened impulse-based bounce
    if (y - BALL_R_M <= 0.0f) {
      y = BALL_R_M;

      float vx_in = vx;
      float vy_in = vy;
      float spin_in = spin;

      float m = BALL_MASS_KG;
      float R = BALL_R_M;
      float I = I_FACTOR * m * R * R;
      float e = currentCourt.eNormal;
      float mu = currentCourt.muTangent;

      float vn_in = min(vy_in, 0);
      float Jn = (vn_in < 0) ? -(1 + e) * m * vn_in : 0;

      vy += Jn / m;

      float vt_in = vx_in - spin_in * R;
      float denom = (1.0f/m) + (R*R)/I;
      float Jt_stick = -vt_in / denom;
      Jt_stick *= TANGENTIAL_STICK_BLEND;
      float Jt_max = FRICTION_SCALE * mu * abs(Jn);
      float Jt = constrain(Jt_stick, -Jt_max, Jt_max);

      vx   = vx_in + Jt / m;
      spin = spin_in - (Jt * R) / I;
      spin *= (1.0f - currentCourt.spinLoss);

      if (!firstBounceDone) {
        firstBounceDone = true;

        preVmag  = sqrt(vx_in*vx_in + vy_in*vy_in);
        postVmag = sqrt(vx*vx + vy*vy);
        preSpin  = spin_in;
        postSpin = spin;

        bounce1Speed    = postVmag;
        bounce1AngleDeg = degrees(atan2(vy, vx));
        bounce1NewPeak  = max(0, (vy*vy) / (2.0f * G));
        bounce1X        = x;

        countdownSec = 10;
        countdownStartMillis = millis();
        countdownActive = true;
      } else if (!secondBounceDone) {
        secondBounceDone = true;
      }
    }
  }
}
