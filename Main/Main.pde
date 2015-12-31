import gab.opencv.*;

// Size
final static int WINDOW_WIDTH = 1280;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

// Variables for instances
Kinect kinect;


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
  kinect.setMirror(false);
  kinect.alternativeViewPointDepthToImage();
  
  // Set frame rate
  frameRate(30);
  
  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  PImage videoImage = kinect.rgbImage();
  PImage depthImage = kinect.depthImage();
  PImage noBackgroundDepthImage = kinect.noBackgroundDepthImage();
  PImage jediImage = loadImage("background.jpg");
  
  // Draw user
  kinect.drawUsers(jediImage);
  
  // Detect edges
  OpenCV opencv = new OpenCV(this, noBackgroundDepthImage);
  opencv.findCannyEdges(20, 75);

  // Main Display
  image(jediImage, 0, 0, 640, 480);

  // Sub Display
  image(videoImage, 640, 0, 320, 240);
  image(depthImage, 640, 240, 320, 240);
  image(noBackgroundDepthImage, 960, 0, 320, 240);
  image(opencv.getOutput(), 960, 240, 320, 240);

  // Find lines
  ArrayList<gab.opencv.Line> lines = opencv.findLines(100, 30, 20);
  
  /**
   * Select a line which has a maximum length 
   */
  float maxDistance = 0;
  int indexMax = -1;
  for (int i = 0; i < lines.size (); i++) {
    float length = sqrt(pow((lines.get(i).start.x - lines.get(i).end.x), 2) + pow((lines.get(i).start.y - lines.get(i).end.y), 2));

    if (maxDistance < length) {
      maxDistance = length;
      indexMax = i;
    }
  }
  
  /**
   * Draw a lightsaber by using a line which has a maximum length
   */
  if (indexMax == -1) {
    return;
  }
  
  Line maxLine = new Line(
    new PVector(lines.get(indexMax).start.x, lines.get(indexMax).start.y),
    new PVector(lines.get(indexMax).end.x, lines.get(indexMax).end.y)
  );
  
  PImage lightSaber = loadImage("lightsaber_blue.png");
  pushMatrix();
  translate((maxLine.start.x + maxLine.end.x) / 2, (maxLine.start.y + maxLine.end.y) / 2);
  rotate((float) maxLine.radian);
  imageMode(CENTER);
  lightSaber.resize((int) maxDistance, 0);
  image(lightSaber, 0, 0);
  imageMode(CORNER);
  translate(- (maxLine.start.x + maxLine.end.x) / 2, - (maxLine.start.y + maxLine.end.y) / 2);
  popMatrix();
}

