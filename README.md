Participant: Xenia Semilovsky, 305120502, xesemilovsky@stud.mediadesign.de.

This is a Processing File. Download Processing here: https://processing.org/download 
Start the simulation by clicking on the Play Button in the Processing sketch.

Description of Implemented Physics System:
- Projectile Motion (Gravity, vertical velocity)
- Magnus Effect (Spin Lift, Downforce depending on ball spin direction)
- Ball Ground Collision (Impulse-based bounce system with softened response)
- Net Collision Check
- Rotational Dynamics (Angular velocity, visual seam rotation), affects: magnus force, tangential bounce response, spin decay

Description of Implemented Mechanics:
- Clay (Roland Garros): lower elasticity, high friction
- Grass (Wimbledon): lowest elasticity, least friction
- Hard (US Open): higher elasticity, medium friction
Each court defines: eNormal, muTangent, spinLoss

Kinematic Tracking & State Events:
1. First bounce detection
2. Second bounce detection
3. Previous vs. current stats overlay
4. Velocity & spin losses tracked
5. New flight peak height computed

Camera & Simulation Mechanics:
- Camera follow system: smooth lerp towards ball, zooms out after first bounce
- Simulation States: PENDING -> RUNNING -> POST1_ZOOMOUT -> POST2_WAIT
- Countdown reset system after bounces

Controls:
1 = Clay
2 = Grass
3 = Hard
Adjust sliders. Klick on "OK" to start the simulation. Watch the ball react.
