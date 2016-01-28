import java.util.Map;
import java.util.Iterator;

// Size
final static int WINDOW_WIDTH = 640;
final static int WINDOW_HEIGHT = 480;
final static int IMAGE_WIDTH = 640;
final static int IMAGE_HEIGHT = 480;

final static double THREATHOLD = 60.0;

// Variables for instances
Kinect kinect;
ParticleFilterYellow particleFilterYellow;
ParticleFilterGReeeeN particleFilterGReeeeN;

int handVecListSize = 20;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();

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
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  kinect.setMirror(true);

  // Initialize particle filter
  particleFilterYellow = new ParticleFilterYellow(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);
  particleFilterGReeeeN = new ParticleFilterGReeeeN(1000, 120.0, IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2);

  // Set background color black
  background(0);
}

void draw() {
  kinect.update();

  // Images
  PImage rgbImage = kinect.rgbImage();
  PImage jediImage = loadImage("background.jpg");

  // Draw users
  kinect.drawUsers(jediImage);

  // Main Display
  image(rgbImage, 0, 0, 640, 480);

  // Sub Display
  //  image(, 640, 0, 320, 240);
  //  image(, 640, 240, 320, 240);
  //  image(, 960, 0, 320, 240);
  //  image(, 960, 240, 320, 480);


  // Update particles
  particleFilterYellow.update(rgbImage);
  particleFilterYellow.drawParticles(color(255, 0, 0), 2);

  particleFilterGReeeeN.update(rgbImage);
  particleFilterGReeeeN.drawParticles(color(0, 255, 0), 2);


  // Update particle filter's variance
  Particle pYellow = particleFilterYellow.measure();
  double likelihoodYellow = particleFilterYellow.likelihood(pYellow.x, pYellow.y, rgbImage);
  //  println(likelihoodYellow);
  if (likelihoodYellow > 230) {
    //println("Yellow is convergent.");
    particleFilterYellow.variance = 13.0;
  } else {
    //println("Yellow is not convergent");
    particleFilterYellow.variance = 80.0;
  }

  Particle pGReeeeN = particleFilterGReeeeN.measure();
  double likelihoodGReeeeN = particleFilterGReeeeN.likelihood(pGReeeeN.x, pGReeeeN.y, rgbImage);
  //  println(likelihoodGReeeeN);
  if (likelihoodGReeeeN > 200) {
    //println("GReeeeN is convergent.");
    particleFilterGReeeeN.variance = 13.0;
  } else {
    //println("GReeeeN is not convergent");
    particleFilterGReeeeN.variance = 80.0;
  }

  // Draw lightsaber
  if (particleFilterGReeeeN.isConvergent(60.0)) {
    Particle averageGReeeeN = particleFilterGReeeeN.measure();
    if (handPathList.size() > 0)  
    {    
      Iterator itr = handPathList.entrySet().iterator();     
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();      
      Iterator itrVec = vecList.iterator(); 
      p = (PVector) itrVec.next(); 

      kinect.convertRealWorldToProjective(p, p2d);
      Line saberLine = new Line(
      new PVector(averageGReeeeN.x, averageGReeeeN.y), 
      new PVector(p2d.x, p2d.y)
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

    if (particleFilterYellow.isConvergent(60.0)) {
      Particle averageYellow = particleFilterYellow.measure();
      if (handPathList.size() > 1)  
      {        
        Iterator itr = handPathList.entrySet().iterator(); 
        Map.Entry mapEntry = (Map.Entry)itr.next(); 
        int handId =  (Integer)mapEntry.getKey();
        ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
        PVector p;
        PVector p2d = new PVector();      
        Iterator itrVec = vecList.iterator(); 
        p = (PVector) itrVec.next(); 
        p = (PVector) itrVec.next();

        kinect.convertRealWorldToProjective(p, p2d);
        Line saberLine = new Line(
        new PVector(averageYellow.x, averageYellow.y), 
        new PVector(p2d.x, p2d.y)
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
// hand events

void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId, vecList);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );

  ArrayList<PVector> vecList = handPathList.get(handId);
  if (vecList != null)
  {
    vecList.add(0, pos);
    if (vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1);
  }
}

void onLostHand(SimpleOpenNI curContext, int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  int handId = kinect.startTrackingHand(pos);
  println("hand stracked: " + handId);
}

