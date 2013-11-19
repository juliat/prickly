import oscP5.*;
OscP5 oscP5;

// our FaceOSC tracked face dat
Face face = new Face();
float faceScale = 1; // default - no resizing of face
ArrayList<PVector> faceOutline = new ArrayList<PVector>();

void setup() {
  // default size is 640 by 480
  int defaultWidth = 640;
  int defaultHeight = 480;
  
  faceScale = 0.5; // shrink by half
  
  int realWidth = (int)(defaultWidth * faceScale);
  int realHeight = (int)(defaultHeight * faceScale);
  size(realWidth, realHeight, OPENGL);
  
  frameRate(30);

  oscP5 = new OscP5(this, 8338);
}

void draw() {  
  background(255);
  stroke(0);

  if (face.found > 0) {
    
    // draw such that the center of the face is at 0,0
    translate(face.posePosition.x*faceScale, face.posePosition.y*faceScale);
    
    // scale things down to the size of the tracked face
    // then shrink again by half for convenience
    scale(face.poseScale*0.5);
    
    // rotate the drawing based on the orientation of the face
    rotateY (0 - face.poseOrientation.y); 
    rotateX (0 - face.poseOrientation.x); 
    rotateZ (    face.poseOrientation.z); 
    
    noFill();
    drawOutline();
    drawEyes();
    drawMouth();
    print(face.toString());
    
    if (face.isSmiling()) {
      println("SMILING");
    }
    if (face.isBlinking()) {
      println("BLINKED");
    }
    
    face.lastEyeHeight = face.eyeLeft;
    face.lastEyebrowHeight = face.eyeRight;
    println("lastEyeHeight " + face.lastEyeHeight);
    println("lastEyebrowHeight " + face.lastEyebrowHeight);
  }
}

// OSC CALLBACK FUNCTIONS

void oscEvent(OscMessage m) {
  face.parseOSC(m);
}

void drawOutline() {
  int xCenter = 0;
  int yCenter = 0;
  float radius = 35;
  int numPoints = 60;
  
  // iterate and draw points around circle
  float theta = 0;
  float x;
  float y; 
  float oldRadius = -1;
  
 
  beginShape();
  for (int i=0; i <= numPoints; i++) {
    println("faceOutline Len: ");
    print(faceOutline.size());
    println("");
    
    if (faceOutline.size() < 1) {
      theta = map(i, 0, numPoints, 0 , 2*PI);
     
      if (i%2 == 0) {
        oldRadius = radius;
        radius = radius * random(1.1, 1.2);
      }
      x = radius*cos(theta) + xCenter;
      y = radius*sin(theta) + yCenter;
      PVector circlePoint = new PVector(x, y);
      faceOutline.add(circlePoint);
      
      if (oldRadius > 0) {
        radius = oldRadius;
        oldRadius = -1;
      }
    }
    else {
      x = faceOutline.get(i).x;
      y = faceOutline.get(i).y;
    
    vertex(x,y);
    // ellipse(x, y, 3, 3);
    }
  }
  endShape();
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

