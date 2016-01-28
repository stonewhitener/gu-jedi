final class ParticleFilterRed extends AbstractParticleFilter {
  public ParticleFilterRed(int n, double variance, PImage initImage) {
    super(n, variance, initImage);
  }
  
  public ParticleFilterRed(int n, double variance, int x, int y) {
    super(n, variance, x, y);
  }

  @Override
  protected double likelihood(int x, int y, PImage image) {
    // not implemented yet
    return 0.0001;
  }
  
}

