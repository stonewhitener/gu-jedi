// Size
final static int WINDOW_WIDTH = 640;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

final static double THREATHOLD = 60.0;

// Variables for instances
Kinect kinect;

// Elbow and hand's position vectors
PVector rightElbow3d = new PVector();
PVector rightElbow2d = new PVector();
PVector rightHand3d = new PVector();
PVector rightHand2d = new PVector();
//PVector leftElbow3d = new PVector();
//PVector leftElbow2d = new PVector();
//PVector leftHand3d = new PVector();
//PVector leftHand2d = new PVector();


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
  
  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  PImage rgbImage = kinect.rgbImage();
  PImage noBackgroundImage = kinect.noBackgroundImage();
  PImage jediImage = loadImage("background.jpg");

  // Draw users
  kinect.drawUsers(jediImage);

  // Main Display
  image(jediImage, 0, 0, 640, 480);
  
  // Sub Display
//  image(, 640, 0, 320, 240);
//  image(, 640, 240, 320, 240);
//  image(, 960, 0, 320, 240);
//  image(, 960, 240, 320, 480);

  

  // Draw lightsaber
  int[] userList = kinect.getUsers();
  for (int i=0; i<userList.length; i++) {
    if (kinect.isTrackingSkeleton(userList[i])) {
//      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow3d);
//      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHand3d);
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow3d);
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHand3d);
//      kinect.convertRealWorldToProjective(leftElbow3d, leftElbow2d);
//      kinect.convertRealWorldToProjective(leftHand3d, leftHand2d);
      kinect.convertRealWorldToProjective(rightElbow3d, rightElbow2d);
      kinect.convertRealWorldToProjective(rightHand3d, rightHand2d);

      // Draw about user 1
      if (userList[i] == 1) {
        Line saberLine = new Line(
          new PVector(
            rightHand2d.x - (rightHand2d.x - rightElbow2d.x) * 0.5, 
            rightHand2d.y - (rightHand2d.y - rightElbow2d.y) * 0.5
          ),
          new PVector(
            rightHand2d.x + (rightHand2d.x - rightElbow2d.x) * 4.0,
            rightHand2d.y + (rightHand2d.y - rightElbow2d.y) * 4.0
          )
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
      else if (userList[i] == 2) {
        Line saberLine = new Line(
          new PVector(
            rightHand2d.x - (rightHand2d.x - rightElbow2d.x) * 0.5, 
            rightHand2d.y - (rightHand2d.y - rightElbow2d.y) * 0.5
          ),
          new PVector(
            rightHand2d.x + (rightHand2d.x - rightElbow2d.x) * 4.0,
            rightHand2d.y + (rightHand2d.y - rightElbow2d.y) * 4.0
          )
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
