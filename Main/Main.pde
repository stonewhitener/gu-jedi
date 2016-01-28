import processing.video.*;

// Size
final static int WINDOW_WIDTH = 640;
final static int WINDOW_HEIGHT = 360;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 360;


// Variables for instances
Capture cam;

ParticleFilterYellow particleFilterYellow;
ParticleFilterGReeeeN particleFilterGReeeeN;


void setup() {
  // Set window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // Initialize camera
  if (Capture.list().length == 0) {
    println("There are no cameras available for capture.");
    exit();
  }
  
  cam = new Capture(this, Capture.list()[3]);
  cam.start();

  // Initialize particle filter
  particleFilterYellow = new ParticleFilterYellow(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);
  particleFilterGReeeeN = new ParticleFilterGReeeeN(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);

  // Set background color black
  background(0);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }


  // Main Display
  image(cam, 0, 0);//, IMAGE_WIDTH, IMAGE_HEIGHT);

  // Sub Display
  //  image(, 640, 0, 320, 240);
  //  image(, 640, 240, 320, 240);
  //  image(, 960, 0, 320, 240);
  //  image(, 960, 240, 320, 480);


  // Update particles
  particleFilterYellow.update(cam);
  particleFilterYellow.drawParticles(color(255, 0, 0), 2);

  particleFilterGReeeeN.update(cam);
  particleFilterGReeeeN.drawParticles(color(0, 255, 0), 2);


  // Update particle filter's variance
  Particle pYellow = particleFilterYellow.measure();
  double likelihoodYellow = particleFilterYellow.likelihood(pYellow.x, pYellow.y, cam);
  println(likelihoodYellow);
  if (likelihoodYellow > 230) {
    println("Yellow is convergent.");
    particleFilterYellow.variance = 13.0;
  } else {
    println("Yellow is not convergent");
    particleFilterYellow.variance = 80.0;
  }

  Particle pGReeeeN = particleFilterGReeeeN.measure();
  double likelihoodGReeeeN = particleFilterGReeeeN.likelihood(pGReeeeN.x, pGReeeeN.y, cam);
  println(likelihoodGReeeeN);
  if (likelihoodGReeeeN > 200) {
    println("GReeeeN is convergent.");
    particleFilterGReeeeN.variance = 13.0;
  } else {
    println("GReeeeN is not convergent");
    particleFilterGReeeeN.variance = 80.0;
  }

  // Draw lightsaber
  Particle start = pYellow;
  Particle end = pGReeeeN;

  Line saberLine = new Line(
    new PVector(start.x, start.y), 
    new PVector(end.x, end.y)
  );

  pushMatrix();
  translate((saberLine.start.x + saberLine.end.x) / 2, (saberLine.start.y + saberLine.end.y) / 2);
  rotate((float) saberLine.radian);
  imageMode(CENTER);
  PImage lightSaber = loadImage("lightsaber_blue.png");
  lightSaber.resize((int) saberLine.length, 0);
  image(lightSaber, 0, 0);
  imageMode(CORNER);
  translate(-(saberLine.start.x + saberLine.end.x) / 2, -(saberLine.start.y + saberLine.end.y) / 2);
  popMatrix();
}

