final class ParticleFilterGReeeeN extends AbstractParticleFilter {
  public ParticleFilterGReeeeN(int n, double variance, PImage initImage) {
    super(n, variance, initImage);
  }

  public ParticleFilterGReeeeN(int n, double variance, int x, int y) {
    super(n, variance, x, y);
  }

  @Override
  protected double likelihood(int x, int y, PImage image) {
    final int width = 4;
    final int height = 4;

    float[] w = new float[width * height];
    int count = 0;
    int index = 0;
    float w_max = 0.0;
    for (int j = y - height / 2; j < y + height / 2; j++) {
      for (int i = x - width / 2; i < x + width / 2; i++) {
        if (isInImage(i, j, image) && isGReeeeN(image.get(i, j))) {
          count++;
          color c = image.get(i, j);
          float d = sqrt(
            pow(100.0 - hue(c), 2)
            + pow(100.0 - saturation(c), 2) 
            + pow(128.0 - brightness(c), 2)
          );
          
          // sqrt((100 - 255)^2 + (100 - 255)^2 + (128-255)^2) = 254
          w[index] = 254.0 - d;
        } else {
          w[index] = 0.0;
        }
        
        index++;
      }
    }

    Arrays.sort(w);
    
    if (count == 0) {
      return 0.0001;
    } else {
      return w[width * height - 1];
    }
  }

  private boolean isInImage(int x, int y, PImage image) {
    return (0 <= x && x < (int) image.width && 0 <= y && y < (int) image.height);
  }

  private boolean isGReeeeN(color c) {
    return(
      (hue(c) > 80.0 && hue(c) < 120.0) &&
      (saturation(c) > 50.0 && saturation(c) < 150.0) &&
      (brightness(c) > 85.0 && brightness(c) < 170.0)
    );
  }
}

