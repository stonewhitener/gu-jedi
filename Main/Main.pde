// Size
final static int WINDOW_WIDTH = 640;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

// Variables for instances
Kinect kinect;
ParticleFilterRed particleFilterRed;
ParticleFilterYellow particleFilterYellow;

PVector jointPos3D = new PVector();
PVector jointPos2D = new PVector();

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
  particleFilterRed = new ParticleFilterRed(500, 13.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);
  particleFilterYellow = new ParticleFilterYellow(500, 13.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);

  // Set frame rate
  frameRate(20);

  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  //PImage videoImage = kinect.rgbImage();
  //PImage distanceImage = kinect.distanceImage();
  PImage noBackgroundImage = kinect.noBackgroundImage();
  //PImage userImage = null;
  //if (kinect.getNumberOfUsers() > 0) {
  // userImage = kinect.userImage(1);
  //}
  PImage jediImage = loadImage("background.jpg");

  kinect.drawUsers(jediImage);

  // Main Display
  image(jediImage, 0, 0, 640, 480);

  // Sub Display
  //image(videoImage, 640, 0, 320, 240);
  //image(distanceImage, 640, 240, 320, 240);
  //image(noBackgroundImage, 960, 0, 320, 240);
  //if (kinect.getNumberOfUsers() > 0) {
  //  image(userImage, 960, 240);
  //}

  // Update particles
  particleFilterRed.update(noBackgroundImage);
  particleFilterRed.drawParticles(color(255, 0, 0), 2);
  particleFilterRed.drawRectangle(color(255, 0, 0), 2, 30, 30);

  particleFilterYellow.update(noBackgroundImage);
  particleFilterYellow.drawParticles(color(255, 0, 0), 2);
  particleFilterYellow.drawRectangle(color(255, 0, 0), 2, 30, 30);

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
          new PVector(average.x, average.y), 
          new PVector(jointPos2D.x, jointPos2D.y)
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

        println(average.x);
        println(average.y);
      }
      
      // Draw about user 2
      if (particleFilterRed.isConvergent(60) && userList[i] == 2) {  
        Particle average = particleFilterRed.measure();

        Line saberLine = new Line(
          new PVector(average.x, average.y), 
          new PVector(jointPos2D.x, jointPos2D.y)
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
