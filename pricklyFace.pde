import oscP5.*;
OscP5 oscP5;

// our FaceOSC tracked face dat
Face face = new Face();
float faceScale = 1; // default - no resizing of face
ArrayList<PVector> faceOutline = new ArrayList<PVector>();
int numPoints = 100;
float initialPrickliness = 0.2;
float prickliness = initialPrickliness;
float maxPrickliness = 0.7;
float minPrickliness = 0;

float closeness = 0.3;
float maxCloseness = 0.5;
float minCloseness = 0.2;

void setup() {
  // default size is 640 by 480
  int defaultWidth = 640;
  int defaultHeight = 480;

  faceScale = 1; // shrink by half

  int realWidth = (int)(defaultWidth * faceScale);
  int realHeight = (int)(defaultHeight * faceScale);
  size(realWidth, realHeight, OPENGL);

  frameRate(10);

  oscP5 = new OscP5(this, 8338);
}

void draw() {  
  background(255);
  noStroke();

  updatePrickliness();

  if (face.found > 0) {

    // draw such that the center of the face is at 0,0
    translate(face.posePosition.x*faceScale, face.posePosition.y*faceScale);

    // scale things down to the size of the tracked face
    // then shrink again by half for convenience
    
    closeness = map(prickliness, minPrickliness, maxPrickliness, maxCloseness, minCloseness);
    scale(face.poseScale*closeness);

    // rotate the drawing based on the orientation of the face
    rotateY (0 - face.poseOrientation.y); 
    rotateX (0 - face.poseOrientation.x); 
    // rotateZ (    face.poseOrientation.z); 

    float fill = map(prickliness, minPrickliness, maxPrickliness, 0, 240);
    fill = 240 - fill;
    fill((int)fill);
    
    // drawEyes();
    // drawMouth();
    // print(face.toString());

    faceOutline = new ArrayList<PVector>();
    getFaceOutlinePoints();
    drawOutline();
    
    /*if (face.isBlinking()) {
      println("BLINKED");
    }

    face.lastEyeHeight = face.eyeLeft;
    face.lastEyebrowHeight = face.eyeRight;
    */
  }
}

// OSC CALLBACK FUNCTIONS

void oscEvent(OscMessage m) {
  face.parseOSC(m);
}

void drawOutline() {
  float x = 0;
  float y = 0;

  if (faceOutline.size() != (numPoints + 1)) {
    getFaceOutlinePoints();
    return;
  }
  else {
    beginShape();
    for (int i=0; i <= numPoints; i++) {
      x = faceOutline.get(i).x;
      y = faceOutline.get(i).y;
      vertex(x, y);
    }  
    endShape();
  }

}

void updatePrickliness() {
  float antiPrickliness = 0;
  int transitionTime = 30000;

  if (!face.isSmiling()) {
    prickliness = constrain(face.timeSinceSmile, 0, transitionTime);
    prickliness = map(prickliness, 0, transitionTime, minPrickliness, maxPrickliness);
  }
  
  antiPrickliness = constrain(face.smilingTime, 0, transitionTime*3);
  antiPrickliness = -1 * map(antiPrickliness, 0, transitionTime*3, minPrickliness, maxPrickliness);
  
  prickliness = prickliness + antiPrickliness;
  constrain(prickliness, minPrickliness, maxPrickliness);
  if (prickliness < 0) {
    prickliness = 0;
  }
}

void getFaceOutlinePoints() {
  int xCenter = 0;
  int yCenter = 0;
  
  for (int i=0; i <= numPoints; i++) {
    float radius = 30;
  
    // iterate and draw points around circle
    float theta = 0;
    float x;
    float y; 
    float oldRadius = -1;
  
    theta = map(i, 0, numPoints, 0, 2*PI);
  
    if (i%2 == 0) {
      oldRadius = radius;
      radius = radius * random(1+prickliness, 1+(prickliness*2));
    }
  
    x = radius*cos(theta) + xCenter;
    y = radius*sin(theta) + yCenter;
  
    if (i == numPoints +1) {
      PVector firstPoint = faceOutline.get(0);
      PVector circlePoint = new PVector(firstPoint.x, firstPoint.y);
      faceOutline.add(circlePoint);
    } 
    else {
      PVector circlePoint = new PVector(x, y);
      faceOutline.add(circlePoint);
    }
  
    if (oldRadius > 0) {
      radius = oldRadius;
      oldRadius = -1;
    }
  }
}

void drawEyes() {
  int distanceFromCenterOfFace = 14;
  int heightOnFace = -4;
  int eyeWidth = 6;
  int eyeHeight = 4;
  ellipse(-1*distanceFromCenterOfFace, face.eyeLeft * heightOnFace, eyeWidth, eyeHeight);
  ellipse(distanceFromCenterOfFace, face.eyeRight * heightOnFace, eyeWidth, eyeHeight);
}

void drawMouth() {
  float mouthWidth = 30;
  int heightOnFace = 14;
  int mouthHeightFactor = 3;

  float mLeftCornerX = 0;
  float mLeftCornerY = heightOnFace;

  float pointX = mLeftCornerX + ((mouthWidth/2));

  float mouthHeight = face.mouthHeight * mouthHeightFactor;
  ellipse(mLeftCornerX, mLeftCornerY, mouthWidth, mouthHeight);
}

