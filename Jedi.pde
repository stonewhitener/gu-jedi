import processing.video.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import gab.opencv.*;

Kinect kinect;
Capture camera;

int numDevices = 0;

int IMAGE_WIDTH = 640;
int IMAGE_HEIGHT = 480;

void setup() {
  size(1280, 480);

  kinect = new Kinect(this);
  kinect.activateDevice(0);
  kinect.initDepth();
  kinect.initVideo();
  kinect.enableColorDepth(false);

  frameRate(10);
}

void draw() {
  background(0);


  colorMode(HSB);

  PImage depthImage = kinect.getDepthImage();
  PImage videoImage = kinect.getVideoImage();

  PImage backLessDepthImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);

  for (int i = 0; i < IMAGE_WIDTH; i++) {
    for (int j = 0; j < IMAGE_HEIGHT; j++) {
      if (!(brightness(depthImage.get(i, j)) < 140)) {
        backLessDepthImage.set(i, j, depthImage.get(i, j));
      }
    }
  }

  colorMode(RGB);

  OpenCV opencv = new OpenCV(this, backLessDepthImage);
  opencv.findCannyEdges(20, 75);

  // Find lines with Hough line detection
  // Arguments are: threshold, minLengthLength, maxLineGap
  ArrayList<Line> lines = opencv.findLines(100, 30, 20);

  image(videoImage, 0, 0, 640, 480);
  image(videoImage, 640, 0, 320, 240);
  image(depthImage, 640, 240, 320, 240);
  image(backLessImage, 960, 0, 320, 240);
  image(opencv.getOutput(), 960, 240, 320, 240);
  strokeWeight(3);

  /* draw average line */
  //if (lines.size() != 0) {
  //  int start_x_total = 0;
  //  int start_y_total = 0;
  //  int end_x_total = 0;
  //  int end_y_total = 0;

  //  for (Line line : lines) {
  //    // lines include angle in radians, measured in double precision
  //    // so we can select out vertical and horizontal lines
  //    // They also include "start" and "end" PVectors with the position
  //    stroke(0, 255, 0);
  //    start_x_total += line.start.x;
  //    start_y_total += line.start.y;
  //    end_x_total += line.end.x;
  //    end_y_total += line.end.y;
  //  }
  //  line(
  //    start_x_total / lines.size(), 
  //    start_y_total / lines.size(), 
  //    end_x_total / lines.size(), 
  //    end_y_total / lines.size()
  //    );
  //}

  /* drow lines */
  //for (Line line : lines) {
  //  // lines include angle in radians, measured in double precision
  //  // so we can select out vertical and horizontal lines
  //  // They also include "start" and "end" PVectors with the position
  //  stroke(0, 255, 0);
  //  line(line.start.x, line.start.y, line.end.x, line.end.y);
  //}

  /* drow line which has maximum length */
  double maxEuqlidDistance = 0;
  int indexOfMax = -1;
  for (int i = 0; i < lines.size(); i++) {
    // lines include angle in radians, measured in double precision
    // so we can select out vertical and horizontal lines
    // They also include "start" and "end" PVectors with the position
    stroke(0, 255, 0);

    double euqlidDistance = pow((lines.get(i).start.x - lines.get(i).end.x), 2) + pow((lines.get(i).start.y - lines.get(i).end.y), 2);

    if (maxEuqlidDistance < euqlidDistance) {
      maxEuqlidDistance = euqlidDistance;
      indexOfMax = i;
    }
  }

  if (indexOfMax != -1) {
    line(
      lines.get(indexOfMax).start.x, 
      lines.get(indexOfMax).start.y, 
      lines.get(indexOfMax).end.x, 
      lines.get(indexOfMax).end.y
    );
    
  }
}