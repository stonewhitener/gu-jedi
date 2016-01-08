// Size
final static int WINDOW_WIDTH = 1280;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

// Variables for instances
Kinect kinect;
ParticleFilter particleFilter;
int handVecListSize = 20;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
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
  
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
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
  boolean Convergence;
  
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
  if(handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();
      
        stroke(userClr[ (handId - 1) % userClr.length ]);
        noFill(); 
        strokeWeight(1);        
        Iterator itrVec = vecList.iterator(); 
        beginShape();
          while( itrVec.hasNext() ) 
          { 
            p = (PVector) itrVec.next(); 
            
            kinect.convertRealWorldToProjective(p,p2d);
            vertex(p2d.x,p2d.y);
          }
        endShape();   
  
        stroke(userClr[ (handId - 1) % userClr.length ]);
        strokeWeight(4);
        p = vecList.get(0);
        kinect.convertRealWorldToProjective(p,p2d);
        point(p2d.x,p2d.y);
    }        
  }
  Convergence = particleFilter.isConvergent();
  if(Convergence == true) {
    int[] userList = kinect.getUsers();
    for(int i=0;i<userList.length;i++){
      if(kinect.isTrackingSkeleton(userList[i])){
        Particle average = particleFilter.measure();
        kinect.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND,jointPos3D);
        kinect.drawLimb(userList[i], SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
        kinect.convertRealWorldToProjective(jointPos3D, jointPos2D);
        float angle;
        angle=atan2((average.y-jointPos2D.y),(average.x-jointPos2D.x));
        angle=degrees(angle);
        pushMatrix();
        translate((average.x + jointPos2D.x) / 2, (average.y + jointPos2D.y) / 2);
        rotate(angle);
        imageMode(CENTER);
        PImage lightSaber = loadImage("lightsaber_blue.png");
        lightSaber.resize((int) sqrt(pow((float)jointPos2D.x - (float)average.x,2.0)+pow((float)jointPos2D.y - (float)average.y,2.0)), 0);
        image(lightSaber, 0, 0);
        imageMode(CORNER);
        translate(-(average.x + jointPos2D.x) / 2, -(average.y + jointPos2D.y) / 2);
        popMatrix();
        println(average.x);
        println(average.y);
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
  //println("onVisibleUser - userId: " + userId);
}
