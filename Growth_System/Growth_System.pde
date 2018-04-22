PMatrix3D eye, camera;
PVector horizontalMovementDirection;
float k = 1.0;
float mass = 1000.0;
float damping = 0.99;
int radius = 400;
float l = 100;
int subdivs = 12;
int hSubdivs = 12;
int h = 100;
char cameraPosition = 'p';
boolean cylinderMode = true;
HeMeshParticleSystem mesh;

void setup()
{
  size(800, 800, P3D);
  colorMode(HSB, 100);
  rectMode(RADIUS);
  horizontalMovementDirection = new PVector(-1, 1, 0);
  eye = new PMatrix3D();
  if (cylinderMode) constructCylindricalHeMesh();
  else constructLinearHeMesh();
}

void draw()
{
  background(100);
  pushMatrix();
  translate(width / 2, height / 2, 0);
  if (cameraPosition == 'p') camera(width * 2, width * 2, width * 2, 0, 0, 0, 0, 0, -1);
  else if (cameraPosition == 't') camera(0.001, 0, width * 2, 0, 0, 0, 0, 0, -1);
  else if (cameraPosition == 'l') camera(width * 2, 0, 0, 0, 0, 0, 0, 0, -1);
  directionalLight(0, 0, 100, -1, -1, -1);
  ambientLight(0, 0, 33);
  camera =  new PMatrix3D(eye);
  camera.invert();
  applyMatrix(camera);
  drawGrid();
  mesh.Update();
  mesh.Display();
  popMatrix();
}

void constructLinearHeMesh()
{
  ArrayList<PVector> initVertices = new ArrayList<PVector>();
  ArrayList<int[]> initFaces = new ArrayList<int[]>();
  float length = (l * (subdivs - 1)) / 2;
  for (int i = 0; i < hSubdivs; i++)
  {
    float increment = (i % 2) * l / 2;
    for (int j = 0; j < subdivs; j++)
      initVertices.add(new PVector(-length + l * j + increment, length - l * j - increment, h * i));
  }

  for (int i = 0; i < hSubdivs - 1; i++)
    for (int j = 0; j < subdivs - 1; j++)
    {
      initFaces.add(new int[] {i + j * subdivs, i + 1 + j * subdivs, i + subdivs + (j % 2) + j * subdivs});
      initFaces.add(new int[] {i + ((j + 1) % 2) + j * subdivs, i + subdivs + 1 + j * subdivs, i + subdivs + j * subdivs});
    }

  mesh = new HeMeshParticleSystem(initVertices, initFaces);
  for (int i = 0; i < subdivs; i++)
  {
    mesh.v.get(mesh.v.size() - 1 - i).locked = true;
    //mesh.v.get(mesh.v.size() - 1 - i).selected = true;
  }
}

void constructCylindricalHeMesh()
{
  ArrayList<PVector> initVertices = new ArrayList<PVector>();
  ArrayList<int[]> initFaces = new ArrayList<int[]>();
  float div = PI * 2 / subdivs;
  for (int i = 0; i < hSubdivs; i++)
  {
    float rotation = i * (div / 2);
    for (int j = 0; j < subdivs; j++)
      initVertices.add(new PVector(radius * cos(j * div + rotation), radius * sin(j * div+ rotation), h * i));
  }

  for (int i = 0; i < hSubdivs - 1; i++)
    for (int j = 0; j < subdivs; j++)
    {
      int jNext = (j + 1) % subdivs  + i * subdivs;
      int jPrev = (j - 1 + subdivs) % subdivs + i * subdivs;
      initFaces.add(new int[] {j + i * subdivs, jNext, j + subdivs + i * subdivs});
      initFaces.add(new int[] {j + i * subdivs, j + subdivs + i * subdivs, jPrev + subdivs});
    }

  mesh = new HeMeshParticleSystem(initVertices, initFaces);
  for (int i = 0; i < subdivs; i++)
  {
    mesh.v.get(mesh.v.size() - 1 - i).locked = true;
  }
}

void drawGrid()
{
  pushMatrix();
  noStroke();
  fill(50, 100, 100, 10);
  rect(0, 0, width, width);
  stroke(0);
  strokeWeight(0.5);
  line(-width, 0, 0, width, 0, 0);
  line(0, -width, 0, 0, width, 0);
  popMatrix();
}
