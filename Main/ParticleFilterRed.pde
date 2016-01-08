final class ParticleFilterRed extends AbstractParticleFilter {
  public ParticleFilterRed(int n, double variance, PImage initImage) {
    super(n, variance, initImage);
  }
  
  public ParticleFilterRed(int n, double variance, int x, int y) {
    super(n, variance, x, y);
  }

  @Override
  protected double likelihood(int x, int y, PImage image) {
    final int width = 10;
    final int height = 10;

    int count = 0;
    for (int j = y - height / 2; j < y + height / 2; j++) {
      for (int i = x - width / 2; i < x + width / 2; i++) {
        if (isInImage(i, j, image) && isRed(image.get(i, j))) {
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

  private boolean isRed(color c) {
    return(
      (hue(c) > 230.0 && hue(c) < 255.0) &&
      (saturation(c) > 160.0 && saturation(c) < 210.0) && 
      (brightness(c) > 75.0 && brightness(c) < 100.0)
    );
  }
}

