// user-tracking callbacks. source: Making Things See, by Greg Borenstein

void onNewUser(int userId) {
  if(kinect.loadCalibrationDataSkeleton(userId,"calibration.skel")){
    kinect.startTrackingSkeleton(userId);
    println("Load calibration from file.");
  }
  else{
    println("Can't load calibration file.");
    println("start pose detection");
    kinect.startPoseDetection("Psi", userId);
  }
      

}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
    
  } 
  else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}
