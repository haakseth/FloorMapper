/*
This is the prototype developed in time for Researcher's Night 2012.
The application is based on the interactive hotboxes presented in "Eight Boxes",
when enough points are found within a box, its event is executed.
*/

import processing.opengl.*;
import SimpleOpenNI.*;
import codeanticode.glgraphics.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;

SimpleOpenNI kinect;
int boxSize = 300;
PVector[] boxCenters;
float[] boxAlphas;
boolean[] wasJustInBox;
boolean[] isInBox;
int activeBox = -1;
int rotation = 0;

de.fhpotsdam.unfolding.Map map;

void setup(){
  size(800, 600, GLConstants.GLGRAPHICS);
  frameRate(5);

  map = new de.fhpotsdam.unfolding.Map(this);
  MapUtils.createDefaultEventDispatcher(this, map);
  
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  kinect.enableDepth();
  kinect.alternativeViewPointDepthToImage();
  
  //For kinecten: x-høyre, y-opp, z-rett fram
  boxCenters = new PVector[8];
  boxCenters[0] = new PVector(-600,-300,1800); 
  boxCenters[1] = new PVector(-600,-300,2300); 
  boxCenters[2] = new PVector(-600,-300,2800); 
  boxCenters[3] = new PVector(-200,-300,1800); 
  boxCenters[4] = new PVector(-200,-300,2800); 
  boxCenters[5] = new PVector(200,-300,1800); 
  boxCenters[6] = new PVector(200,-300,2300); 
  boxCenters[7] = new PVector(200,-300,2800); 
  
  boxAlphas = new float[]{0,0,0,0,0,0,0,0};
  wasJustInBox = new boolean[]{false,false,false,false,false,false,false,false};
  isInBox = new boolean[]{false,false,false,false,false,false,false,false};
  
}

void draw(){
  background(0);
  frame.setTitle("FloorMapper");
  map.draw();
  
  kinect.update();
  int[] numDepthPointsInBox = new int[8];
  PImage rgbImage = kinect.rgbImage();
  
  // prepare to draw centered in x-y
  // pull it 1000 pixels closer on z 
  translate(width/2, height/2, -1000);
  // flip the point cloud vertically:
  rotateX(radians(180));
  
  //move center of rotation
  //to inside the point cloud
  translate(0,0,2400);
  rotateY(radians(-10));
  rotateX(radians(-40));
  translate(0,0,-2400);
  stroke(255);
  
  PVector[] depthPoints = kinect.depthMapRealWorld();
  
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
  }

  for(int i=0; i<boxCenters.length; i++){
    boxAlphas[i] = map(numDepthPointsInBox[i],0,500,0,255);
    translate(boxCenters[i].x,boxCenters[i].y,boxCenters[i].z);
    stroke(0,0,255);
    fill(0,0,255, boxAlphas[i]);
    box(boxSize);
    translate(-boxCenters[i].x,-boxCenters[i].y,-boxCenters[i].z);
    isInBox[i] = (boxAlphas[i]>150);
    if(isInBox[i]){
      activeBox = i;
      box();
    }
    wasJustInBox[i]=isInBox[i];
  }
  translate(-width/2, -height/2, 1000);
}
