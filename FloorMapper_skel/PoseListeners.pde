void panPoseListener(){
  if(panPose.check(userID)){
    panMap();
  }
}

void panMap(){  
  if(prevLeftHand.x!=0 && (prevLeftHand.x-leftHand.x>70)){
    map.panLeft();map2.panLeft();
  }
  if(prevLeftHand.x!=0 && (leftHand.x-prevLeftHand.x>70)){
    map.panRight();map2.panRight();
  }
  if(prevLeftHand.x!=0 && (prevLeftHand.z-leftHand.z>70)){
    map.panDown();map2.panDown();
  }
  if(prevLeftHand.x!=0 && (leftHand.z-prevLeftHand.z>70)){
    map.panUp();map2.panUp();
  }
  prevLeftHand = leftHand;
}

void lookingGlass(){
  PVector rightFoot = new PVector();
  kinect.getJointPositionSkeleton(userID,SimpleOpenNI.SKEL_RIGHT_FOOT,rightFoot);
  float smoothX = smoothValues(rightFootXs, rightFoot.x);
  float smoothZ = smoothValues(rightFootZs, rightFoot.z);
  //map the foot's x and z coordinates to match screen size
  moveOverlay((int)map(smoothX,-800,800,0,800), (int)map(smoothZ,2500,4000,600,0));
  
}

//Method that averages over the last 5 input values, helps smooth the motion of the loupe
float smoothValues(float[] vals,float newVal){
  //check if input array has 5 values
  if(vals.length!=5){
    return -1.0;
  }
  //last in, last out
  vals[0]=vals[1];vals[1]=vals[2];vals[2]=vals[3];vals[3]=vals[4];
  vals[4] = newVal;
  return (vals[0]+vals[1]+vals[2]+vals[3]+vals[4])/5;
}
