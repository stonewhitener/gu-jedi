import processing.video.*;

import SimpleOpenNI.*;
import gab.opencv.*;


// Size
final int WINDOW_WIDTH = 1280;
final int WINDOW_HEIGHT = 480;
final int IMAGE_WIDTH = 640;
final int IMAGE_HEIGHT = 480;

// A threashold to eliminate background
final int THREASHOLD = 180;


// Variables for instances
SimpleOpenNI kinect;
LowPassFilter lowPassFilter;


void setup() {
  // Set window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // Wait for a Kinect
  while (true) {
    if (SimpleOpenNI.deviceCount() > 0) {
      break;
    }
  }

  // Initialize the Kinect
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.setMirror(true);
  kinect.alternativeViewPointDepthToImage();

  // Initialize the low-pass filter
  lowPassFilter = new LowPassFilter();

  // Set frame rate
  frameRate(30);
}

void draw() {
  background(0);

  kinect.update();

  // Images
  PImage depthImage = kinect.depthImage();
  PImage videoImage = kinect.rgbImage();
  PImage backLessDepthImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
  PImage jediImage = loadImage("background.jpg");

  // Eliminate background
  colorMode(HSB);
  for (int j = 0; j < IMAGE_HEIGHT; j++) {
    for (int i = 0; i < IMAGE_WIDTH; i++) {
      if (brightness(depthImage.get(i, j)) > THREASHOLD) {
        backLessDepthImage.set(i, j, depthImage.get(i, j));
        jediImage.set(i, j, videoImage.get(i, j));
      }
    }
  }
  colorMode(RGB);

  // Create a OpenCV instance to process images
  OpenCV opencv = new OpenCV(this, backLessDepthImage);

  // Find edges
  opencv.findCannyEdges(20, 75);

  /**
   * Find lines with Hough line detection
   * Arguments are: threshold, minLengthLength, maxLineGap
   */
  ArrayList<gab.opencv.Line> lines = opencv.findLines(100, 200, 20);


  // Main Display
  image(jediImage, 0, 0, 640, 480);

  // Sub Display
  image(videoImage, 640, 0, 320, 240);
  image(depthImage, 640, 240, 320, 240);
  image(backLessDepthImage, 960, 0, 320, 240);
  image(opencv.getOutput(), 960, 240, 320, 240);


  /**
   * Draw a line which has a maximum length 
   */
  float maxDistance = 0;
  int indexMax = -1;

  // Select the line which has a maximum length
  for (int i = 0; i < lines.size (); i++) {
    float distance = sqrt(pow((lines.get(i).start.x - lines.get(i).end.x), 2) + pow((lines.get(i).start.y - lines.get(i).end.y), 2));

    if (maxDistance < distance) {
      maxDistance = distance;
      indexMax = i;
    }
  }

  // No line found
  if (indexMax == -1) {
    return;
  }

  // Low-pass filter
  Line line = lowPassFilter.getFiltered(lines.get(indexMax).start, lines.get(indexMax).end);

  // Draw a lightsaber
  PImage lightSaber = loadImage("lightsaber_blue.png");
  pushMatrix();
  translate((line.start.x + line.end.x) / 2, (line.start.y + line.end.y) / 2);
  rotate(line.radian());
  imageMode(CENTER);
  lightSaber.resize((int) maxDistance, 0);
  image(lightSaber, 0, 0);
  imageMode(CORNER);
  translate(-(line.start.x + line.end.x) / 2, -(line.start.y + line.end.y) / 2);
  popMatrix();
}

