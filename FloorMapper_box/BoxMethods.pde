void box(){
  switch (activeBox){
    case 0:
      map.outerRotate(radians(-rotation));
      map.zoomToLevel(16);
      map.panTo(new Location(63.416, 10.407));
      rotation = 0;
      break;
    case 1:
      map.panLeft();
      break;
    case 2:
      map.outerRotate(radians(-20));
      rotation-=20;
      break;
    case 3:
      map.panDown();
      break;
    case 4:
      map.panUp();
      break;
    case 5:
      println(5);
      break;
    case 6:
      map.panRight();
      break;
    case 7:
      map.outerRotate(radians(20));
      rotation+=20;
      break;
  }
}

