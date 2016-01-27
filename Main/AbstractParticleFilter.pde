import java.util.*;

abstract class AbstractParticleFilter {
  private List<Particle> particles;
  private Random random;
  public double variance;
  
  private AbstractParticleFilter(int n, double variance) {
    this.particles = new ArrayList<Particle>();
    this.variance = variance;
    this.random = new Random(System.currentTimeMillis());
  }
  
  /**
   * @param n number of particles
   * @param variance variance of gaussian random
   * @param initImage image for deciding initialize particles position
   */
  public AbstractParticleFilter(int n, double variance, PImage initImage) {
    this(n, variance);
    
    for (int i = 0; i < n; i++) {
      this.particles.add(new Particle(0, 0, 0.0));
    }

    init(initImage);
  }
  
  /**
   * @param n number of particles
   * @param variance variance of gaussian random
   * @param x initial position of particles
   * @param y initial position of particles
   */
  public AbstractParticleFilter(int n, double variance, int x, int y) {
    this(n, variance);
    
    for (int i = 0; i < n; i++) {
      this.particles.add(new Particle(x, y, 0.0));
    }
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

    for (int i = 0; i < particles.size(); i++) {
      point(particles.get(i).x, particles.get(i).y);
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



    for (int i = 0; i < particles.size(); i++) {
      particles.set(i, new Particle(maxParticle.x, maxParticle.y, maxParticle.weight));
    }
  }

  private void resample() {
    List<Double> weights = new ArrayList<Double>();

    weights.add(particles.get(0).weight);
    for (int i = 1; i < particles.size(); i++) {
      weights.add(weights.get(i - 1) + particles.get(i).weight);
    }

    List<Particle> tmpParticles = new ArrayList<Particle>();
    for (int i = 0; i < particles.size(); i++) {
      tmpParticles.add(particles.get(i).clone());
    }

    for (int i = 0; i < particles.size(); i++) {
      double weight = random.nextDouble() * weights.get(weights.size() - 1);
      int n = 0;
      while (weights.get(++n) < weight);
      particles.set(i, tmpParticles.get(n).clone());
      particles.get(i).weight = 1.0;
    }
  }

  private void predict(PImage image) {
    for (int i = 0; i < particles.size(); i++) {
      double vx = random.nextGaussian() * variance;
      double vy = random.nextGaussian() * variance;
      //----------------------------------------------------------------
      //println("v[" + i + "] = (" + (int) vx + ", " + (int) vy + ")");
      //----------------------------------------------------------------

      particles.get(i).x += (int) vx;
      particles.get(i).y += (int) vy;

      if (particles.get(i).x < 0) {
        particles.get(i).x = 0;
      } else if (particles.get(i).x > image.width - 1) {
        particles.get(i).x = image.width - 1;
      }

      if (particles.get(i).y < 0) {
        particles.get(i).y = 0;
      } else if (particles.get(i).y > image.height - 1) {
        particles.get(i).y = image.height - 1;
      }

      //----------------------------------------------------------------
      //println("p[" + i + "] = (" + particles.get(i).x + ", " + particles.get(i).y + ")");
      //----------------------------------------------------------------
    }
  }

  private void weight(PImage image) {
    double sumWeight = 0.0;
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).weight = likelihood(particles.get(i).x, particles.get(i).y, image);
      sumWeight += particles.get(i).weight;
    }

    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).weight /= sumWeight;
      //----------------------------------------------------------------
      //println("p[" + i + "].weight = " + particles.get(i).weight);
      //----------------------------------------------------------------
    }
  }

  public Particle measure() {
    double x = 0.0;
    double y = 0.0;
    double weight = 0.0;

    for (int i = 0; i < particles.size(); i++) {
      x += particles.get(i).x * particles.get(i).weight;
      y += particles.get(i).y * particles.get(i).weight;
      weight += particles.get(i).weight;
    }

    return new Particle((int) (x / weight), (int) (y / weight), 1.0);
  }
  
  public boolean isConvergent(double threshold) {
    double d = 0.0;
    Particle average = measure();
    
    for(int i = 0; i < particles.size(); i++) {
      d += sqrt(
        pow(particles.get(i).x - average.x, 2)
        + pow(particles.get(i).y - average.y, 2)
      );
    }
    
    d = d / particles.size();
    
    if (d < threshold) {
      return true;
    } else {
      return false;
    }
  }
  
}
