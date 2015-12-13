// Size
final static int WINDOW_WIDTH = 1280;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

// Variables for instances
Kinect kinect;
ParticleFilter particleFilter;


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
  kinect.enableDistanceImage();
  kinect.enableNoBackgroundImage();
  kinect.enableUserImages();
  kinect.setMirror(false);
  kinect.alternativeViewPointDepthToImage();
  
  // Initialize particle filter
  particleFilter = new ParticleFilter(500, 13.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);

  // Set frame rate
  frameRate(20);
  
  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  PImage videoImage = kinect.rgbImage();
  PImage distanceImage = kinect.distanceImage();
  PImage noBackgroundImage = kinect.noBackgroundImage();
  PImage userImage = null;
  if (kinect.getNumberOfUsers() > 0) {
    userImage = kinect.userImage(1);
  }
  PImage jediImage = loadImage("background.jpg");
  
  
  kinect.writeUser(1, jediImage);
  

  // Main Display
  image(jediImage, 0, 0, 640, 480);

  // Sub Display
  image(videoImage, 640, 0, 320, 240);
  image(distanceImage, 640, 240, 320, 240);
  image(noBackgroundImage, 960, 0, 320, 240);
  if (kinect.getNumberOfUsers() > 0) {
    image(userImage, 960, 240);
  }

  // Update particles
  particleFilter.update(noBackgroundImage);
  particleFilter.drawParticles(color(255, 0, 0), 2);
  particleFilter.drawRectangle(color(255, 0, 0), 2, 30, 30);
}

