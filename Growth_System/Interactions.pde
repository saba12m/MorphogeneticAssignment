void mouseDragged()
{
  if (mouseButton == RIGHT) //rotation in space
  {
    float rotZ = 0.005 * (mouseX - pmouseX);
    eye.rotateZ(rotZ);
    horizontalMovementDirection.rotate(rotZ);
    float rotXY = 0.001 * (mouseY - pmouseY);
    eye.rotateX(rotXY);
    eye.rotateY(-rotXY);
  } else if (mouseButton == CENTER) //movement in space
  {
    float transXY = (mouseX - pmouseX);
    float transZ = (mouseY - pmouseY);
    eye.translate(-transXY, transXY, transZ);
  }
}

void mouseWheel(MouseEvent event)
{
  float sc = 1.05;
  float e = event.getCount();
  float factor = 0.2;
  if (e > 0)
  {
    //to make it zoom towards the mouse cursor
    eye.translate(-factor * (width / 2 - mouseX), factor * (width / 2 - mouseX), 0);
    for (int i = 0; i < e; i++)  eye.scale(1 / sc);
  } else if (e < 0)
  {
    eye.translate(factor * (width / 2 - mouseX), -factor * (width / 2 - mouseX), 0);
    for (int i = 0; i < abs(e); i++)  eye.scale(sc);
  }
}

void keyPressed()
{
  if (key == 's') screenCapture(); //save captures
  if (key == 'r') initialize(); //reset
  if (key == 'm')
  {
    cylinderMode = !cylinderMode;
    setup();
  }
  if (key == 'p') cameraPosition = 'p';
  if (key == 't') cameraPosition = 't';
  if (key == 'l') cameraPosition = 'l';
  if (key == 'c') //camera reset
  {
    eye = new PMatrix3D();
    horizontalMovementDirection = new PVector(-1, 1, 0);
  }
}

void screenCapture()
{
  saveFrame("images/#####.png");
}
