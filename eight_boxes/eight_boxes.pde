/*
- This application shows the backend of the prototype developed for
Researcher's Night at NTNU. 
- The application creates eight boxes and counts how many points are
located within each. When the box fills up with enough points an
event can be executed.
- The concept is based on examples from "Making things see, by Greg Borenstein"

setup() is called once when the application starts.
draw() is called everytime the application updates (usually 30 times/sec)
This application requires SimpleOpenNI to be installed on the system:
https://code.google.com/p/simple-openni/
*/

import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;
int boxSize = 400;
PVector[] boxCenters;

void setup(){
  size(800, 600, OPENGL);
  
  //Retrieve depth points from the kinect
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  kinect.enableDepth();
  kinect.alternativeViewPointDepthToImage();
  
//Placing the boxes like a "numpad"
//From the kinect's perspective: x-right, y-up, z-straight ahead
  boxCenters = new PVector[8];
  boxCenters[0] = new PVector(-600,-300,1800); 
  boxCenters[1] = new PVector(-600,-300,2300); 
  boxCenters[2] = new PVector(-600,-300,2800); 
  boxCenters[3] = new PVector(-200,-300,1800); 
  boxCenters[4] = new PVector(-200,-300,2800); 
  boxCenters[5] = new PVector(200,-300,1800); 
  boxCenters[6] = new PVector(200,-300,2300); 
  boxCenters[7] = new PVector(200,-300,2800);  
}

void draw(){
  background(0);
  kinect.update();
  
  //Accessing the depth points from the kinect
  PVector[] depthPoints = kinect.depthMapRealWorld();
  PImage rgbImage = kinect.rgbImage();
  
  //translate and rotate the pointcloud for display purposes 
  translate(width/2, height*2.5, -800);
  rotateX(radians(160));
  
  //Counting the number of depth points located inside each box
  int[] numDepthPointsInBox = new int[8];
  
  for (int i=0; i<depthPoints.length; i+=3){
    stroke(rgbImage.pixels[i]);
    PVector currentPoint = depthPoints[i];
    
    for(int j=0; j<boxCenters.length; j++){
      if (currentPoint.x > boxCenters[j].x - boxSize/2
      && currentPoint.x < boxCenters[j].x + boxSize/2){
        if (currentPoint.y > boxCenters[j].y - boxSize/2
        && currentPoint.y < boxCenters[j].y + boxSize/2){
          if (currentPoint.z > boxCenters[j].z - boxSize/2
          && currentPoint.z < boxCenters[j].z + boxSize/2){
            numDepthPointsInBox[j]++;
          }
        } 
      }
    }
    point(currentPoint.x, currentPoint.y, currentPoint.z);
  }
    
  for(int i=0; i<boxCenters.length; i++){
    float boxAlpha = map(numDepthPointsInBox[i],0,500,0,255);
    translate(boxCenters[i].x,boxCenters[i].y,boxCenters[i].z);
    stroke(0,0,255);
    fill(0,0,255, boxAlpha);
    box(boxSize);
    translate(-boxCenters[i].x,-boxCenters[i].y,-boxCenters[i].z);
  }
  translate(-width/2, -height/2, 1000);
}
