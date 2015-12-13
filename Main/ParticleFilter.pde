final class ParticleFilter extends AbstractParticleFilter {
  public ParticleFilter(int n, double variance, PImage initImage) {
    super(n, variance, initImage);
  }
  
  public ParticleFilter(int n, double variance, int x, int y) {
    super(n, variance, x, y);
  }

  @Override
  protected double likelihood(int x, int y, PImage image) {
    final int width = 30;
    final int height = 30;

    int count = 0;
    for (int j = y - height / 2; j < y + height / 2; j++) {
      for (int i = x - width / 2; i < x + width / 2; i++) {
        if (isInImage(i, j, image) && isYellow(image.get(i, j))) {
          count++;
        }
      }
    }

    if (count == 0) {
      return 0.0001;
    } else {
      return (double) count / (width * height);
    }
  }

  private boolean isInImage(int x, int y, PImage image) {
    return (0 <= x && x < (int) image.width && 0 <= y && y < (int) image.height);
  }

  private boolean isYellow(color c) {
    return(red(c) > 200.0 && green(c) > 200.0 && blue(c) < 150.0);
  }
}

