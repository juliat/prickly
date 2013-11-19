import oscP5.*;
OscP5 oscP5;

// our FaceOSC tracked face dat
Face face = new Face();
float faceScale = 1; // default - no resizing of face

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

void drawEyes() {
  int distanceFromCenterOfFace = 20;
  int heightOnFace = -9;
  int eyeWidth = 11;
  int eyeHeight =7;
  ellipse(-1*distanceFromCenterOfFace, face.eyeLeft * heightOnFace, eyeWidth, eyeHeight);
  ellipse(distanceFromCenterOfFace, face.eyeRight * heightOnFace, eyeWidth, eyeHeight);
}

void drawMouth() {
  float mouthWidth = 40;
  int heightOnFace = 14;
  int mouthHeightFactor = 3;
  
  float mLeftCornerX = 0;
  float mLeftCornerY = heightOnFace;
 
  float pointX = mLeftCornerX + ((mouthWidth/2));
  
  float mouthHeight = face.mouthHeight * mouthHeightFactor;
  ellipse(mLeftCornerX, mLeftCornerY, mouthWidth, mouthHeight);
}

