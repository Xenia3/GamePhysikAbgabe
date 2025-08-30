void startSimulationRaw() {
  float h   = sliderHeight.value;
  float v   = sliderSpeed.value;
  float ang = sliderAngle.value;
  float sp  = sliderSpin.value;

  ball.setLaunch(v, ang, h, sp);
  ball.firstBounceDone  = false;
  ball.secondBounceDone = false;

  countdownActive = false;

  state = SimState.RUNNING;
  cam.targetZoom = 1.0f; 
}
