class Court {
  String name;
  int courtColor;
  float eNormal, muTangent, spinLoss;
  Court(String name, int col, float e, float mu, float spinLoss) {
    this.name = name;
    this.courtColor = col;
    this.eNormal = e;
    this.muTangent = mu;
    this.spinLoss = spinLoss;
  }
}
