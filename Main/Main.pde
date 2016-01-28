// Size
final static int WINDOW_WIDTH = 1280;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

final static double THREATHOLD = 60.0;

// Variables for instances
Kinect kinect;
ParticleFilterYellow particleFilterYellow;
ParticleFilterGReeeeN particleFilterGReeeeN;

PVector jointPos3D = new PVector();
PVector jointPos2D = new PVector();

PImage backgroundImage;
boolean isFirst = true;

void setup() {
  // Set window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // Wait for a Kinect
  while (true) {
    if (Kinect.deviceCount() > 0) {
      break;
    }
  }

  // Initialize Kinect
  kinect = new Kinect(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // Initialize particle filter
  particleFilterYellow = new ParticleFilterYellow(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);
  particleFilterGReeeeN = new ParticleFilterGReeeeN(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);
  
  // Init background image
  backgroundImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);

  // Set frame rate
//  frameRate(20);

  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  PImage rgbImage = kinect.rgbImage();
  PImage noBackgroundImage = kinect.noBackgroundImage();
  PImage jediImage = loadImage("background.jpg");

//  // Create background image
//  if (isFirst) {
//    for (int y = 0; y < IMAGE_WIDTH; y++) {
//      for (int x = 0; x < IMAGE_HEIGHT; x++) {
//        backgroundImage.set(x, y, rgbImage.get(x, y));
//      }
//    }
//    
//    isFirst = false;
//  }

  // Draw users
  kinect.drawUsers(jediImage);
  
  // Get diff image
//  PImage diffImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
//  for (int y = 0; y < IMAGE_WIDTH; y++) {
//    for (int x = 0; x < IMAGE_HEIGHT; x++) {
//      color c1 = rgbImage.get(x, y);
//      color c2 = backgroundImage.get(x, y);
//      if (abs(red(c1) - red(c2)) > 32 || abs(green(c1) - green(c2)) > 32 || abs(blue(c1) - blue(c2)) > 32) {
//        diffImage.set(x, y, c1);
//      } else {
//        diffImage.set(x, y, color(0, 0, 0));
//      }
//    }
//  }

  // Main Display
  image(rgbImage, 0, 0, 640, 480);

  // Sub Display
//  image(, 640, 0, 320, 240);
//  image(, 640, 240, 320, 240);
//  image(, 960, 0, 320, 240);
//  image(, 960, 240, 320, 480);


  // Update particles
  particleFilterYellow.update(rgbImage);
//  particleFilterYellow.drawParticles(color(255, 0, 0), 2);
  
  particleFilterGReeeeN.update(rgbImage);
  particleFilterGReeeeN.drawParticles(color(0, 255, 0), 2);
  

  // Update particle filter's variance
  Particle pYellow = particleFilterYellow.measure();
  double likelihoodYellow = particleFilterYellow.likelihood(pYellow.x, pYellow.y, rgbImage);
//  println(likelihoodYellow);
  if (likelihoodYellow > 230) {
//    println("Yellow is convergent.");
    particleFilterYellow.variance = 13.0;
  } else {
//    println("Yellow is not convergent");
    particleFilterYellow.variance = 80.0;
  }
  
  Particle pGReeeeN = particleFilterGReeeeN.measure();
  double likelihoodGReeeeN = particleFilterYellow.likelihood(pGReeeeN.x, pGReeeeN.y, rgbImage);
  println(likelihoodGReeeeN);
  if (likelihoodGReeeeN > 200) {
    println("GReeeeN is convergent.");
    particleFilterGReeeeN.variance = 13.0;
  } else {
    println("GReeeeN is not convergent");
    particleFilterGReeeeN.variance = 80.0;
  }

  // Draw lightsaber
  int[] userList = kinect.getUsers();
  for (int i=0; i<userList.length; i++) {
    if (kinect.isTrackingSkeleton(userList[i])) {
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, jointPos3D);
      kinect.drawLimb(userList[i], SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
      kinect.convertRealWorldToProjective(jointPos3D, jointPos2D);

      // Draw about user 1
      if (particleFilterYellow.isConvergent(60) && userList[i] == 1) {
        Particle average = particleFilterYellow.measure();

        Line saberLine = new Line(
          new PVector(jointPos2D.x, jointPos2D.y),
          new PVector(average.x, average.y)
        );

        pushMatrix();
        translate((saberLine.start.x + saberLine.end.x) / 2, (saberLine.start.y + saberLine.end.y) / 2);
        rotate((float) saberLine.radian);
        imageMode(CENTER);
        PImage lightSaber = loadImage("lightsaber_red.png");
        lightSaber.resize((int) saberLine.length, 0);
        image(lightSaber, 0, 0);
        imageMode(CORNER);
        translate(-(saberLine.start.x + saberLine.end.x) / 2, -(saberLine.start.y + saberLine.end.y) / 2);
        popMatrix();
      }
      
      // Draw about user 2
      if (particleFilterGReeeeN.isConvergent(60) && userList[i] == 2) {
        Particle average = particleFilterGReeeeN.measure();

        Line saberLine = new Line(
          new PVector(jointPos2D.x, jointPos2D.y),
          new PVector(average.x, average.y)
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
      
    }
  }
  


}


void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  println("onVisibleUser - userId: " + userId);
}
