import java.util.*;

abstract class AbstractParticleFilter {
  private Particle[] particles;
  private Random random;
  public double variance;
  
  public int NUM_SPECTATORS = 0;
  
  /**
   * @param n number of particles
   * @param variance variance of gaussian random
   * @param initImage image for deciding initialize particles position
   */
  public AbstractParticleFilter(int n, double variance, PImage initImage) {
    this.particles = new Particle[n];
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(0, 0, 0.0);
    }
    
    this.variance = variance;
    this.random = new Random(System.currentTimeMillis());

    init(initImage);
  }
  
  /**
   * @param n number of particles
   * @param variance variance of gaussian random
   * @param x initial position of particles
   * @param y initial position of particles
   */
  public AbstractParticleFilter(int n, double variance, int x, int y) {
    this.particles = new Particle[n];
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(x, y, 0.0);
    }
    
    this.variance = variance;
    this.random = new Random(System.currentTimeMillis());
  }

  // Implement this method
  abstract protected double likelihood(int x, int y, PImage image);

  public void update(PImage image) {
    resample();
    predict(image);
    weight(image);
  }

  public void drawParticles(color c, int weight) {
    stroke(c);
    strokeWeight(weight);

    for (int i = 0; i < particles.length; i++) {
      point(particles[i].x, particles[i].y);
    }
  }

  public void drawRectangle(color c, int weight, int width, int height) {
    Particle result = measure();

    final int top = result.y - height / 2;
    final int bottom = result.y + height / 2;
    final int left = result.x - width / 2;
    final int right = result.x + width / 2;

    stroke(c);
    strokeWeight(weight);

    line(left, top, right, top);
    line(left, bottom, right, bottom);
    line(left, top, left, bottom);
    line(right, top, right, bottom);
  }

  private void init(PImage image) {
    //----------------------------------------------------------------
    //println("image size: " + image.width + ", " + image.height);
    //----------------------------------------------------------------
    Particle maxParticle = new Particle(0, 0, 0.0);
    for (int j = 0; j < image.height; j++) {
      for (int i = 0; i < image.width; i++) {
        double weight = likelihood(i, j, image);
        if (weight > maxParticle.weight) {
          maxParticle = new Particle(i, j, weight);
        }
      }
    }

    //----------------------------------------------------------------
    //println("max weight: " + maxParticle.weight);
    //println("at (" + maxParticle.x + ", " + maxParticle.y + ")");
    //----------------------------------------------------------------

    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(maxParticle.x, maxParticle.y, maxParticle.weight);
    }
  }

  private void resample() {
    Double[] weights = new Double[particles.length];

    weights[0] = particles[0].weight;
    for (int i = 1; i < particles.length; i++) {
      weights[i] = weights[i - 1] + particles[i].weight;
    }

    Particle[] tmpParticles = new Particle[particles.length];
    for (int i = 0; i < tmpParticles.length; i++) {
      tmpParticles[i] = particles[i].clone();
    }

    for (int i = 0; i < particles.length; i++) {
      double weight = random.nextDouble() * weights[weights.length - 1];
      int n = 0;
      while (weights[++n] < weight);
      particles[i] = tmpParticles[n].clone();
      particles[i].weight = 1.0;
    }
  }

  private void predict(PImage image) {
    for (int i = 0; i < particles.length - NUM_SPECTATORS; i++) {
      double vx = random.nextGaussian() * variance;
      double vy = random.nextGaussian() * variance;
      //----------------------------------------------------------------
      //println("v[" + i + "] = (" + (int) vx + ", " + (int) vy + ")");
      //----------------------------------------------------------------

      particles[i].x += (int) vx;
      particles[i].y += (int) vy;

      if (particles[i].x < 0) {
        particles[i].x = 0;
      } else if (particles[i].x > image.width - 1) {
        particles[i].x = image.width - 1;
      }

      if (particles[i].y < 0) {
        particles[i].y = 0;
      } else if (particles[i].y > image.height - 1) {
        particles[i].y = image.height - 1;
      }

      //----------------------------------------------------------------
      //println("p[" + i + "] = (" + particles[i].x + ", " + particles[i].y + ")");
      //----------------------------------------------------------------
    }
    for (int i = particles.length - NUM_SPECTATORS; i < particles.length; i++) {
      double vx = (random.nextDouble() * 2.0 - 1.0) * variance;
      double vy = (random.nextDouble() * 2.0 - 1.0) * variance;
      //----------------------------------------------------------------
      //println("v[" + i + "] = (" + (int) vx + ", " + (int) vy + ")");
      //----------------------------------------------------------------

      particles[i].x += (int) vx;
      particles[i].y += (int) vy;

      if (particles[i].x < 0) {
        particles[i].x = 0;
      } else if (particles[i].x > image.width - 1) {
        particles[i].x = image.width - 1;
      }

      if (particles[i].y < 0) {
        particles[i].y = 0;
      } else if (particles[i].y > image.height - 1) {
        particles[i].y = image.height - 1;
      }

      //----------------------------------------------------------------
      //println("p[" + i + "] = (" + particles[i].x + ", " + particles[i].y + ")");
      //----------------------------------------------------------------
    }
  }

  private void weight(PImage image) {
    double sumWeight = 0.0;
    for (int i = 0; i < particles.length; i++) {
      particles[i].weight = likelihood(particles[i].x, particles[i].y, image);
      sumWeight += particles[i].weight;
    }

    for (int i = 0; i < particles.length; i++) {
      particles[i].weight /= sumWeight;
      //----------------------------------------------------------------
      //println("p[" + i + "].weight = " + particles[i].weight);
      //----------------------------------------------------------------
    }
  }

  public Particle measure() {
    double x = 0.0;
    double y = 0.0;
    double weight = 0.0;

    for (int i = 0; i < particles.length - NUM_SPECTATORS; i++) {
      x += particles[i].x * particles[i].weight;
      y += particles[i].y * particles[i].weight;
      weight += particles[i].weight;
    }

    return new Particle((int) (x / weight), (int) (y / weight), 1.0);
  }

  public boolean isConvergent(double threshold) {
    double d = 0.0;
    Particle average = measure();
    
    for(int i = 0; i < particles.length - NUM_SPECTATORS; i++) {
      d += sqrt(
        pow(particles[i].x - average.x, 2)
        + pow(particles[i].y - average.y, 2)
      );
    }
    
    d = d / (particles.length - NUM_SPECTATORS);
    
    if (d < threshold) {
      return true;
    } else {
      return false;
    }
  }

}
