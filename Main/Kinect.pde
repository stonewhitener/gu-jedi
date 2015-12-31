import SimpleOpenNI.*;

class Kinect extends SimpleOpenNI {
  private final static int IMAGE_WIDTH = 640;
  private final static int IMAGE_HEIGHT = 480;

  // Max distance = 2^13 - 1
  // Reference: https://msdn.microsoft.com/en-us/library/hh973078.aspx 
  private final static int MAX_DISTANCE = 8191; 


  public Kinect(PApplet parent) {
    super(parent);
  }
  
  
  public PImage drawUsers(PImage image) {
    if (image == null) return null;
    
    image.resize(rgbWidth(), rgbHeight());
    
    int[] userMap = userMap();
    for (int y = 0; y < rgbHeight(); y++) {
      for (int x = 0; x < rgbWidth(); x++) {
        int pixel = x + y * rgbWidth();
        if (userMap[pixel] > 0) {
          image.set(x, y, rgbImage().get(x, y));
        }
      }
    }
    
    return image;
  }
  
  public PImage drawUser(int userId, PImage image) {
    if (image == null) return null;
    if (userId > 7 || userId < 1) return image;
    if (getNumberOfUsers() < 1) return image;
    
    image.resize(rgbWidth(), rgbHeight());
    
    int[] userMap = userMap();
    for (int y = 0; y < rgbHeight(); y++) {
      for (int x = 0; x < rgbWidth(); x++) {
        int pixel = x + y * rgbWidth();
        if (userMap[pixel] == userId) {
          image.set(x, y, rgbImage().get(x, y));
        }
      }
    }
    
    return image;
  }


  public PImage distanceImage() {
    PImage distanceImage = createImage(IMAGE_WIDTH, IMAGE_HEIGHT, RGB);
    int depthMap[] = depthMap();
    for (int y = 0; y < IMAGE_HEIGHT; y++) { 
      for (int x = 0; x < IMAGE_WIDTH; x++) {
        int pixel = x + y * IMAGE_WIDTH;
        float c = 255.0 - 255.0 * (float) depthMap[pixel] / (float) MAX_DISTANCE; 
        distanceImage.set(x, y, color(c, c, c));
      }
    }
    
    return distanceImage;
  }

  public PImage noBackgroundImage() {
    PImage noBackgroundImage = createImage(rgbWidth(), rgbHeight(), RGB);
    int[] userMap = userMap();
    for (int y = 0; y < rgbHeight(); y++) {
      for (int x = 0; x < rgbWidth(); x++) {
        int pixel = x + y * rgbWidth();
        if (userMap[pixel] > 0) {
          noBackgroundImage.set(x, y, rgbImage().get(x, y));
        }
      }
    }
    
    return noBackgroundImage;
  }
  
  public PImage noBackgroundDepthImage() {
    PImage noBackgroundImage = createImage(rgbWidth(), rgbHeight(), RGB);
    int[] userMap = userMap();
    for (int y = 0; y < rgbHeight(); y++) {
      for (int x = 0; x < rgbWidth(); x++) {
        int pixel = x + y * rgbWidth();
        if (userMap[pixel] > 0) {
          noBackgroundImage.set(x, y, depthImage().get(x, y));
        }
      }
    }
    
    return noBackgroundImage;
  }

  public PImage userImage(int userId) {
    final int numOfUsers = getNumberOfUsers();
    int[] max_x = new int[numOfUsers + 1];
    int[] min_x = new int[numOfUsers + 1];
    int[] max_y = new int[numOfUsers + 1];
    int[] min_y = new int[numOfUsers + 1];

    Arrays.fill(max_x, 0);
    Arrays.fill(min_x, IMAGE_WIDTH);
    Arrays.fill(max_y, 0);
    Arrays.fill(min_y, IMAGE_HEIGHT);

    // Calculate userImage's positions
    int[] userMap = userMap();
    for (int y = 0; y < IMAGE_HEIGHT; y++) {
      for (int x = 0; x < IMAGE_WIDTH; x++) {
        int pixel = x + y * IMAGE_WIDTH;
        for (int i = 1; i <= numOfUsers; i++) {
          if (i == userMap[pixel]) {
            if (max_x[i] < x) max_x[i] = x;
            if (min_x[i] > x) min_x[i] = x;
            if (max_y[i] < y) max_y[i] = y;
            if (min_y[i] > y) min_y[i] = y;
          }
        }
      }
    }

    PImage[] userImages = new PImage[numOfUsers + 1];
    Arrays.fill(userImages, null);

    for (int i = 1; i <= numOfUsers; i++) {
      userImages[i] = createImage(max_x[i] - min_x[i] + 1, max_y[i] - min_y[i] + 1, RGB);
      for (int y = min_y[i]; y <= max_y[i]; y++) {
        for (int x = min_x[i]; x <= max_x[i]; x++) {
          int pixel = x + y * IMAGE_WIDTH;
          if (i == userMap[pixel]) {
            userImages[i].set(x - min_x[i], y - min_y[i], rgbImage().get(x, y));
          }
        }
      }
    }
    
    return userImages[userId];
  }
  
}
