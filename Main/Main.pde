import processing.video.*;

import SimpleOpenNI.*;
import gab.opencv.*;


// Size
final int WINDOW_WIDTH = 1280;
final int WINDOW_HEIGHT = 480;
final int IMAGE_WIDTH = 640;
final int IMAGE_HEIGHT = 480;

// Max distance (= 2^13 - 1) 
// Reference: https://msdn.microsoft.com/en-us/library/hh973078.aspx 
final int MAX_DISTANCE = 8191; 

// Variables for instances
SimpleOpenNI kinect;
ParticleFilter particleFilter;


void setup() {
  // Set window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // Wait for a Kinect
  while (true) {
    if (SimpleOpenNI.deviceCount() > 0) {
      break;
    }
  }

  // Initialize Kinect
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser();
  kinect.setMirror(true);
  kinect.alternativeViewPointDepthToImage();
  
  // Initialize particle filter
  particleFilter = new ParticleFilter(2000, 13.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);

  // Set frame rate
  frameRate(30);
  background(0);
}

void draw() {
  kinect.update();

  PImage distanceImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB); 
  int depthMap[] = kinect.depthMap(); 
  for (int j = 0; j < IMAGE_HEIGHT; j++) { 
    for (int i = 0; i < IMAGE_WIDTH; i++) { 
      int c = 255 - 255 * depthMap[j * IMAGE_WIDTH + i] / MAX_DISTANCE; 
      distanceImage.set(i, j, color(c, c, c));
    }
  } 


  // Images
  PImage depthImage = kinect.depthImage();
  PImage videoImage = kinect.rgbImage();
  PImage backgroundLessImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
  PImage pfImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
  PImage jediImage = loadImage("background.jpg");

  // backgroundLessImage create
  int max_x = 0;
  int min_x = IMAGE_WIDTH;
  int max_y = 0;
  int min_y = IMAGE_HEIGHT;
  int[] userMap = kinect.userMap();
  for (int y = 0; y < IMAGE_HEIGHT; y++) {
    for (int x = 0; x < IMAGE_WIDTH; x++) {
      int i = x + y * IMAGE_WIDTH;
      if (userMap[i] > 0) {
        backgroundLessImage.set(x, y, videoImage.get(x, y));
        jediImage.set(x, y, videoImage.get(x, y));
        
        if (max_x < x) max_x = x;
        if (min_x > x) min_x = x;
        if (max_y < y) max_y = y;
        if (min_y > y) min_y = y;
      }
    }
  }

  // 
  for (int y=0; y<IMAGE_HEIGHT; y++) {
    for (int x=0; x<IMAGE_WIDTH; x++) {
      if ((max_x > x) && (min_x < x) && (max_y > y) && (min_y < y)) {
        pfImage.set(x, y, videoImage.get(x, y));
      }
    }
  }


  // Main Display
  image(jediImage, 0, 0, 640, 480);

  // Sub Display
  image(videoImage, 640, 0, 320, 240);
  image(depthImage, 640, 240, 320, 240);
  image(backgroundLessImage, 960, 0, 320, 240);
  image(pfImage, 960, 240, 320, 240);
  

  // Update particles
  particleFilter.update(backgroundLessImage);
  particleFilter.drawParticles(color(255, 0, 0), 2);
  particleFilter.drawRectangle(color(255, 0, 0), 2, 30, 30);
}

