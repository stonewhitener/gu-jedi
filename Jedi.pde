import processing.video.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import SimpleOpenNI.*;
import gab.opencv.*;


final int WINDOW_WIDTH  = 1280;
final int WINDOW_HEIGHT = 480;
final int IMAGE_WIDTH   = 640;
final int IMAGE_HEIGHT  = 480;

// A threashold to eliminate background
final int THREASHOLD = 140;

// Coefficients of low-pass filter
final float CURRENT = 0.1;
final float PREVIOUS = 0.9;


// Variables for instances
Kinect kinect;
Capture camera;

// Keep a line position for low-pass filter
float[] start_x = {0.0, 0.0};
float[] start_y = {0.0, 0.0};
float[] end_x   = {0.0, 0.0};
float[] end_y   = {0.0, 0.0};


void setup() {
  // Set window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // Wait for a Kinect
  while (true) {
    if (Kinect.countDevices() > 0) {
      break;
    }
  }

  // Initialize the Kinect
  kinect = new Kinect(this);
  kinect.activateDevice(0);
  kinect.initDepth();
  kinect.initVideo();
  kinect.enableColorDepth(false);

  // Set frame rate
  frameRate(30);
}

void draw() {
  background(0);

  // Images
  PImage depthImage = kinect.getDepthImage();
  PImage videoImage = kinect.getVideoImage();
  PImage backLessDepthImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
  PImage jediImage = loadImage("background.jpg");

  // Eliminate background
  colorMode(HSB);
  for (int i = 0; i < IMAGE_WIDTH; i++) {
    for (int j = 0; j < IMAGE_HEIGHT; j++) {
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
  ArrayList<Line> lines = opencv.findLines(100, 200, 20);

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
  for (int i = 0; i < lines.size(); i++) {
    // lines include angle in radians, measured in double precision
    // so we can select out vertical and horizontal lines
    // They also include "start" and "end" PVectors with the position
    
    float length = sqrt(pow((lines.get(i).start.x - lines.get(i).end.x), 2) + pow((lines.get(i).start.y - lines.get(i).end.y), 2));

    if (maxDistance < length) {
      maxDistance = length;
      indexMax = i;
    }
  }

  // No lines found
  if (indexMax == -1) {
    return;
  }

  // Low-pass filter
  start_x[0] = CURRENT * lines.get(indexMax).start.x + PREVIOUS * start_x[1];
  start_y[0] = CURRENT * lines.get(indexMax).start.y + PREVIOUS * start_y[1];
  end_x[0] = CURRENT * lines.get(indexMax).end.x + PREVIOUS * end_x[1];
  end_y[0] = CURRENT * lines.get(indexMax).end.y + PREVIOUS * end_y[1];

  // Draw a line
  stroke(0, 255, 0);
  strokeWeight(3);
  line(start_x[0], start_y[0], end_x[0], end_y[0]);
  
  // Calculate line's radian
  float radian = atan((end_y[0] - start_y[0]) / (end_x[0] - start_x[0]));
  
  // Draw a lightsaber
  PImage lightSaber = loadImage("lightsaber_blue.png");
  pushMatrix();
  translate((start_x[0] + end_x[0]) / 2, (start_y[0] + end_y[0]) / 2);
  rotate(radian);
  imageMode(CENTER);
  image(lightSaber, 0, 0, maxDistance, lightSaber.width * (lightSaber.height / maxDistance));
  imageMode(CORNER);
  translate(- (start_x[0] + end_x[0]) / 2, - (start_y[0] + end_y[0]) / 2);
  popMatrix();
  
  // Shift line's position for low-pass filter
  start_x[1] = start_x[0];
  start_y[1] = start_y[0];
  end_x[1] = end_x[0];
  end_y[1] = end_y[0];
}