import SimpleOpenNI.*;

class Kinect extends SimpleOpenNI {
  private final static int IMAGE_WIDTH = 640;
  private final static int IMAGE_HEIGHT = 480;

  // Max distance (= 2^13 - 1) 
  // Reference: https://msdn.microsoft.com/en-us/library/hh973078.aspx 
  private final static int MAX_DISTANCE = 8191; 


  private boolean isEnableDistanceImage = false;
  private PImage distanceImage;

  private boolean isEnableNoBackgroundImage = false;
  private PImage noBackgroundImage;
  
  private boolean isEnableUserImages = false;
  private PImage[] userImages;
  

  public Kinect(PApplet applet) {
    super(applet);
  }


  public void enableDistanceImage() {
    isEnableDistanceImage = true;
  }
  
  public void enableNoBackgroundImage() {
    isEnableNoBackgroundImage = true;
  }
  
  public void enableUserImages() {
    isEnableUserImages = true;
  }


  @Override
  public void update() {
    super.update();

    if (isEnableDistanceImage) {
      updateDistanceImage();
    }
    if (isEnableNoBackgroundImage) {
      updateNoBackgroundImage();
    }
    if (isEnableUserImages) {
      updateUserImages();
    }
  }


  public PImage distanceImage() {
    return distanceImage;
  }
  
  public PImage noBackgroundImage() {
    return noBackgroundImage;
  }
  
  public PImage userImage(int userId) {
    if (userId == 0) return null;
    
    return userImages[userId];
  }


  private void updateDistanceImage() {
    distanceImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
    int depthMap[] = depthMap();
    for (int y = 0; y < IMAGE_HEIGHT; y++) { 
      for (int x = 0; x < IMAGE_WIDTH; x++) {
        int pixel = x + y * IMAGE_WIDTH;
        int c = 255 - 255 * depthMap[pixel] / MAX_DISTANCE; 
        distanceImage.set(x, y, color(c, c, c));
      }
    }
  }

  private void updateNoBackgroundImage() {
    noBackgroundImage = createImage(rgbWidth(), rgbHeight(), RGB);
    
    for (int y = 0; y < rgbHeight(); y++) {
      for (int x = 0; x < rgbWidth(); x++) {
        int pixel = x + y * rgbWidth();
        if (userMap()[pixel] > 0) {
          noBackgroundImage.set(x, y, rgbImage().get(x, y));
        }
      }
    }
  }

  private void updateUserImages() {
    int[] max_x = new int[getNumberOfUsers() + 1];
    int[] min_x = new int[getNumberOfUsers() + 1];
    int[] max_y = new int[getNumberOfUsers() + 1];
    int[] min_y = new int[getNumberOfUsers() + 1];

    Arrays.fill(max_x, 0);
    Arrays.fill(min_x, IMAGE_WIDTH);
    Arrays.fill(max_y, 0);
    Arrays.fill(min_y, IMAGE_HEIGHT);

    for (int y = 0; y < IMAGE_HEIGHT; y++) {
      for (int x = 0; x < IMAGE_WIDTH; x++) {
        int pixel = x + y * IMAGE_WIDTH;
        for (int i = 1; i <= getNumberOfUsers (); i++) {
          if (i == userMap()[pixel]) {
            if (max_x[i] < x) max_x[i] = x;
            if (min_x[i] > x) min_x[i] = x;
            if (max_y[i] < y) max_y[i] = y;
            if (min_y[i] > y) min_y[i] = y;
          }
        }
      }
    }

    userImages = new PImage[getNumberOfUsers() + 1];
    Arrays.fill(userImages, null);

    for (int i = 1; i <= getNumberOfUsers(); i++) {
      userImages[i] = createImage(max_x[i] - min_x[i] + 1, max_y[i] - min_x[i] + 1, RGB);
      for (int y = min_y[i]; y <= max_y[i]; y++) {
        for (int x = min_x[i]; x <= max_x[i]; x++) {
          int pixel = x + y * IMAGE_WIDTH;
          if (i == userMap()[pixel]) {
            userImages[i].set(x - min_x[i], y - min_y[i], rgbImage().get(x, y));
          }
        }
      }
    }
  }
  
}
