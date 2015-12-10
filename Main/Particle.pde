class Particle {
  public int x;
  public int y;
  public double weight;

  public Particle(int x, int y, double weight) {
    this.x = x;
    this.y = y;
    this.weight = weight;
  }

  Particle clone() {
    return new Particle(x, y, weight);
  }
}