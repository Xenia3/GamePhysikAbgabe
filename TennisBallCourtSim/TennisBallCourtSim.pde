// Konstanten & Globale Variablen 
final int CANVAS_W = 800;
final int CANVAS_H = 800;

final float COURT_LENGTH_M = 23.77f;
final float NET_X_M = COURT_LENGTH_M * 0.5f;
final float NET_H_M = 0.914f;
final float BALL_R_M = 0.033f;     // ~3.3 cm
final float G = 9.81f;
final float BALL_MASS_KG = 0.057f; // ~57 g

// Darstellung
final float VIEW_MARGIN_PX = 120;
final float WORLD_W_M = COURT_LENGTH_M;
final float SCALE_PX_PER_M = (CANVAS_W - 160) / WORLD_W_M;

// Farben
final int BG_COL   = color(4, 12, 10);
final int BALL_COL = color(230, 255, 0);
final int LINE_COL = color(255);
final int TEXT_COL = color(240);
final int RED      = color(220, 50, 47);

// Court-Farben
final int CLAY_COL  = #EC5E18; // Roland Garros
final int GRASS_COL = #A9AB6D; // Wimbledon
final int HARD_COL  = #5479C8; // US Open

// Ballgröße (Durchmesser) in Pixel
final float BALL_DRAW_DIAM_PX = 10;

// Bounce-Softening
final float I_FACTOR = 2.0f/3.0f;         // ≈ 2/3 mR^2
final float TANGENTIAL_STICK_BLEND = 0.3f;// Anteil des Sticking-Impulses
final float FRICTION_SCALE = 0.05f;       // skaliert Coulomb

// Simulationsstatus
enum SimState { PENDING, RUNNING, POST1_ZOOMOUT, POST2_WAIT }
SimState state = SimState.PENDING;

// Kamera + Flyback-Flag
Camera cam = new Camera();
boolean camFlyback = false;

// Courts
Court clay  = new Court("Roland Garros (Clay)", CLAY_COL, 0.80f, 0.24f, 0.20f);
Court grass = new Court("Wimbledon (Grass)",    GRASS_COL, 0.72f, 0.14f, 0.30f);
Court hard  = new Court("US Open (Hard)",       HARD_COL,  0.82f, 0.18f, 0.15f);
Court currentCourt = clay;

// Countdown
boolean countdownActive = false;
int countdownSec = 5;
int countdownStartMillis = 0;

// Vorherige Wurf Stats
boolean hasPrevStats = false;
float prevSpeed = 0, prevAngleDeg = 0, prevSpin = 0, prevPeak = 0, prevBounceX = 0;

// UI 
Slider sliderHeight, sliderSpeed, sliderAngle, sliderSpin;
Button okButton;
PFont uiFont;

// Ball 
Ball ball;

// Settings
void settings() { size(CANVAS_W, CANVAS_H); }

// Setup
void setup() {
  surface.setTitle("Game Physik – Tennis Court Simulation");
  uiFont = createFont("Inter", 16, true);
  textFont(uiFont);

  float sx = 40, sy = 120, sw = width - 80, sh = 28, gap = 52;
  sliderHeight = new Slider("Abwurfhöhe [m]",                       sx, sy + 0*gap, sw, sh, 0.2f, 2.5f, 1.2f);
  sliderSpeed  = new Slider("Abwurfgeschwindigkeit [m/s] | [km/h]", sx, sy + 1*gap, sw, sh, 8.0f, 28.0f, 20.0f);
  sliderAngle  = new Slider("Abwurfwinkel [°]",                     sx, sy + 2*gap, sw, sh, 5.0f, 35.0f, 14.0f);
  sliderSpin   = new Slider("Ballrotation (Spin) [rad/s]",     sx, sy + 3*gap, sw, sh, -50.0f, 15.0f, 0.0f);

  okButton = new Button("OK", width/2f - 50, sy + 4*gap, 100, 36);

  ball = new Ball();
  resetToPending();
}

// Draw
void draw() {
  background(BG_COL);

  // Kamera Ziele je nach State
  if (state == SimState.RUNNING) {
    cam.targetX = ball.x; 
    cam.targetY = 0; 
    cam.targetZoom = 1.0f;
  } else if (state == SimState.POST1_ZOOMOUT || state == SimState.POST2_WAIT) {
    cam.targetX = constrain(ball.x, COURT_LENGTH_M*0.25f, COURT_LENGTH_M*0.75f);
    cam.targetY = 0; 
    cam.targetZoom = 0.65f;
  } else { // PENDING
    cam.targetX = 0; 
    cam.targetY = 0; 
    cam.targetZoom = 1.0f;
  }

  // weichere Rückfahrt in Pending
  float lp = 0.08f, lz = 0.02f; 
  if (state == SimState.PENDING && camFlyback) {
    lp = 0.05f; 
    lz = 0.02f; 
    if (abs(cam.x - cam.targetX) < 0.02f &&
        abs(cam.y - cam.targetY) < 0.02f &&
        abs(cam.zoom - cam.targetZoom) < 0.01f) {
      camFlyback = false;
    }
  }
  cam.update(lp, lz);

  pushMatrix();
  applyCamera();
  drawCourt();
  drawNet();

  if (hasPrevStats) drawPrevBounceRay();

  float dt = 1.0f / 60.0f;
  if (state == SimState.RUNNING || state == SimState.POST1_ZOOMOUT) {
    ball.step(dt);
    if (state == SimState.RUNNING && ball.firstBounceDone) {
      state = SimState.POST1_ZOOMOUT;
    } else if (state == SimState.POST1_ZOOMOUT && ball.secondBounceDone) {
      state = SimState.POST2_WAIT;
    }
  }

  if (state == SimState.PENDING) updateBallAtLauncherTip();

  drawBall();
  if (ball.firstBounceDone) drawBounceRay();
  popMatrix();

  drawTopBar();
  drawStatusText();
  if (state == SimState.PENDING) {
    drawSliders();
    okButton.draw();
    drawCourtSwitchHint();
  }
  if (ball.firstBounceDone) drawMetrics();

  if ((state == SimState.POST1_ZOOMOUT || state == SimState.POST2_WAIT) && hasPrevStats) {
    drawPrevStatsOverlay();
  }

  if (countdownActive) drawCountdownAndMaybeReset();
}

// State Helpers
void resetToPending() {
  state = SimState.PENDING;
  if (ball != null) ball.resetToMachine();

  cam.targetZoom = 1.0f;
  cam.targetX = 0;
  cam.targetY = 0;
  camFlyback = true;

  countdownActive = false;
  countdownSec = 5;
}

// User Input
void mousePressed() {
  if (state == SimState.PENDING) {
    sliderHeight.mousePressed(); 
    sliderSpeed.mousePressed();
    sliderAngle.mousePressed();  
    sliderSpin.mousePressed();
    if (okButton.hit(mouseX, mouseY)) startSimulationRaw();
  }
}
void mouseDragged() {
  if (state == SimState.PENDING) {
    sliderHeight.mouseDragged(); 
    sliderSpeed.mouseDragged();
    sliderAngle.mouseDragged();  
    sliderSpin.mouseDragged();
  }
}
void mouseReleased() {
  if (state == SimState.PENDING) {
    sliderHeight.mouseReleased(); 
    sliderSpeed.mouseReleased();
    sliderAngle.mouseReleased();  
    sliderSpin.mouseReleased();
  }
}
void keyPressed() {
  if (key == '1') currentCourt = clay;
  else if (key == '2') currentCourt = grass;
  else if (key == '3') currentCourt = hard;
}
