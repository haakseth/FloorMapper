/*
Simple version of skeleton tracking based prototype of FloorMapper.
When a user is tracked over the map, a "looking glass" appears, displaying
aerial imagery under his left foot. 
The user is then able to pan the map by swiping his right arm.

TODO: 
-Remove dead code.
-Testing.
*/

import processing.opengl.*;
import SimpleOpenNI.*;
import codeanticode.glgraphics.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;

SimpleOpenNI kinect;
int rotation = 0;
int userID;
int activeGesture;

UnfoldingMap map;
UnfoldingMap map2;//for the looking glass
//start center point for looking glass, default outside of the window, then follow user
float mapZoomX = -300; 
float mapZoomY = -300;

SkeletonPoser panPose; //pose object

PVector leftHand, prevLeftHand, rightHand, leftHandXZ, rightHandXZ, differenceVector;
PImage manHand, panIcon, rotateIcon, markerIcon, zoomIcon;

//count how many times draw() has been called, to run certain commands only every 60 run or so, for debugging
int runNo = 0;

//variables for keeping coordinates of joints
float rightHandX0, rightHandZ0, leftHandX0, leftHandZ0;
float[] rightFootXs = new float[]{0,0,0,0,0};
float[] rightFootZs = new float[]{0,0,0,0,0};
float[] rightHandXs = new float[]{0,0,0,0,0};
float[] rightHandZs = new float[]{0,0,0,0,0};

void setup(){
  size(800, 600, GLConstants.GLGRAPHICS);
  prevLeftHand = new PVector();
  runNo+=1;//brukes for å skrive debugmeldinger til konsollen
  activeGesture = 0;   

  map = new UnfoldingMap(this,mapZoomX,mapZoomY,1600,1200, new Microsoft.RoadProvider());
  map.setTweening(true);
  map.outerRotate(radians(180));//Flip map upside down at launch because the user is usually turned against the projector and kinect
  map.zoomToLevel(15);
  map.panTo(new Location(63.43, 10.395));
  map.setZoomRange(13, 18);
  
  map2 = new UnfoldingMap(this,mapZoomX,mapZoomY,150,150, new Microsoft.AerialProvider());
  map2.setTweening(true);
  map2.outerRotate(radians(180));
  map2.zoomAndPanTo(new Location(63.43, 10.395), 15);
  map2.setZoomRange(13,18);
  
  MapUtils.createDefaultEventDispatcher(this, map, map2);
  
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(false);
  
                    
  //pose for panning the map, left hand above shoulder (SKEL_RIGHT_HAND=left hand)
  panPose = new SkeletonPoser(kinect);
  panPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, PoseRule.BELOW,
                    SimpleOpenNI.SKEL_RIGHT_HIP);
  panPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.BELOW,
                    SimpleOpenNI.SKEL_LEFT_HIP);
                    
  //Pose for rotating and zooming the map
  rotationPose = new SkeletonPoser(kinect);
  rotationPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, PoseRule.BELOW,
                    SimpleOpenNI.SKEL_RIGHT_HIP);
  rotationPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.BELOW,
                    SimpleOpenNI.SKEL_LEFT_HIP);
}

void draw(){
  background(0);
  frame.setTitle("FloorMapper");
  map.draw();
  map2.draw();
  
  kinect.update();
  runNo+=1;
  
  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  
  if(userList.size()>0){//Når brukere blir sporet
    userID = userList.get(0);
    if(kinect.isTrackingSkeleton(userID)){
      //Access coordinates of hands:
      leftHand = new PVector();
      rightHand = new PVector();
      kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
      kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
      rightHandXZ = new PVector(rightHand.x, rightHand.z);
      leftHandXZ = new PVector(leftHand.x, leftHand.z);
      
      //For enkel versjon, fjerner kontrollpanel og lar lupe og panning være aktiv
      lookingGlass();
      panPoseListener();  
    }
    
  }
  else{//When no users are tracked
    activeGesture=0;
    moveOverlay(-300,-300);
  }
  
  if(lastLocation!=null){
    lastPos = lastMarker.getScreenPosition(map);
    ellipse(lastPos.x, lastPos.y, 50, 50);
  } 
  
}

private void moveOverlay(int x, int y) {
  // Move the small map to mouse position, but center it around it
  mapZoomX = x - map2.mapDisplay.getWidth() / 2;
  mapZoomY = y - map2.mapDisplay.getHeight() / 2;
  map2.move(mapZoomX, mapZoomY);

  // Read geo location of the mouse position from the background map
  Location locationOnOverviewMap = map.getLocationFromScreenPosition(x, y);
  // Pan the small map toward that location
  map2.panTo(locationOnOverviewMap);
}
