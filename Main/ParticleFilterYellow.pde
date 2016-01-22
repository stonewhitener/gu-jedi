final class ParticleFilterYellow extends AbstractParticleFilter {
  public ParticleFilterYellow(int n, double variance, PImage initImage) {
    super(n, variance, initImage);
  }
  
  public ParticleFilterYellow(int n, double variance, int x, int y) {
    super(n, variance, x, y);
  }

  @Override
  protected double likelihood(int x, int y, PImage image) {
    final int width = 10;
    final int height = 10;

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
    return(
      (hue(c) > 30.0 && hue(c) < 40.0) &&
      (saturation(c) > 150.0 && saturation(c) < 190.0) && 
      (brightness(c) > 130.0 && brightness(c) < 190.0)
    );
  }
}

