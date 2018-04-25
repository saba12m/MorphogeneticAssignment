PMatrix3D eye, camera;
PVector horizontalMovementDirection;
float k = 1.0;
float mass = 1000.0;
//float damping = 0.9;
int radius = 400;
float l = 100;
float maxLength;
int subdivs = 12;
int hSubdivs = 12;
int h = 100;
float hDamping = 0.96;
float maxHeight = h * (hSubdivs - 1);
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
  initialize();
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
  //debug();
  popMatrix();
}

void initialize()
{
  if (cylinderMode) constructCylindricalMesh();
  else constructPlanarMesh();
}

void constructPlanarMesh()
{
  ArrayList<PVector> initVertices = new ArrayList<PVector>();
  ArrayList<int[]> initFaces = new ArrayList<int[]>();
  float length = (l * (subdivs - 1)) / 2;
  for (int i = 0; i < hSubdivs; i++)
  {
    float increment = (i % 2) * l / 2;
    for (int j = 0; j < subdivs; j++)
      initVertices.add(new PVector(-length + l * j + increment, length - l * j - increment, h * i * pow(hDamping, i)));
  }

  for (int i = 0; i < hSubdivs - 1; i++)
    for (int j = 0; j < subdivs - 1; j++)
    {
      initFaces.add(new int[] {i + j * subdivs, i + 1 + j * subdivs, i + subdivs + (j % 2) + j * subdivs});
      initFaces.add(new int[] {i + ((j + 1) % 2) + j * subdivs, i + subdivs + 1 + j * subdivs, i + subdivs + j * subdivs});
    }
  mesh = new HeMeshParticleSystem(initVertices, initFaces);
  for (int i = 0; i < subdivs; i++)
    mesh.v.get(i).locked = true;
  maxLength = l * 1.5;
}

void constructCylindricalMesh()
{
  ArrayList<PVector> initVertices = new ArrayList<PVector>();
  ArrayList<int[]> initFaces = new ArrayList<int[]>();
  float div = PI * 2 / subdivs;
  for (int i = 0; i < hSubdivs; i++)
  {
    float rotation = i * (div / 2);
    for (int j = 0; j < subdivs; j++)
      initVertices.add(new PVector(radius * cos(j * div + rotation), radius * sin(j * div+ rotation), h * i * pow(hDamping, i)));
  }

  for (int i = 0; i < hSubdivs - 1; i++)
    for (int j = 0; j < subdivs; j++)
    {
      initFaces.add(new int[] {j + i * subdivs, j + (i + 1) * subdivs, (j - 1 + subdivs) % subdivs + (i + 1) * subdivs});
      initFaces.add(new int[] {j + i * subdivs, (j + 1) % subdivs  + i * subdivs, j + (i + 1) * subdivs});
    }
  mesh = new HeMeshParticleSystem(initVertices, initFaces);

  for (int i = 0; i < subdivs; i++)
    mesh.v.get(i).locked = true;

  for (int i = 0; i < subdivs; i++)
  {
    PVector tempV = mesh.v.get(mesh.v.size() - 1 - i).position.copy();
    tempV.normalize();
    tempV.z = 0;
    float vMag = (noise(0.05 * i) - 0.5) * 10;
    tempV.mult(vMag);
    mesh.v.get(mesh.v.size() - 1 - i).velocity = tempV;
  }

  maxLength = dist(initVertices.get(0).x, initVertices.get(0).y, initVertices.get(0).z, initVertices.get(1).x, initVertices.get(1).y, initVertices.get(1).z);
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

void debug()
{
  ArrayList vectors = new ArrayList<PVector>();
  float div = PI * 2 / subdivs;
  for (int i = 0; i < hSubdivs; i++)
    for (int j = 0; j < subdivs; j++)
    {
      float rotation = i * (div / 2);
      vectors.add(new PVector(radius * cos(j * div + rotation), radius * sin(j * div+ rotation), h * i));
    }
  for (int i = 0; i < hSubdivs - 1; i++)
    for (int j = 0; j < subdivs; j++)
    {
      if (i == 0 && j == 0)
      {
        PVector p1 = (PVector) vectors.get(j + i * subdivs);
        PVector p2 = (PVector) vectors.get(j + (i + 1) * subdivs);
        PVector p3 = (PVector) vectors.get((j - 1 + subdivs) % subdivs + (i + 1) * subdivs);
        strokeWeight(3);
        stroke(0, 100, 100);
        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
        stroke(30, 100, 100);
        line(p2.x, p2.y, p2.z, p3.x, p3.y, p3.z);   
        stroke(60, 100, 100);
        line(p3.x, p3.y, p3.z, p1.x, p1.y, p1.z);

        strokeWeight(9);
        stroke(0, 100, 100);
        point(p1.x, p1.y, p1.z);
        stroke(30, 100, 100);
        point(p2.x, p2.y, p2.z);
        stroke(60, 100, 100);
        point(p3.x, p3.y, p3.z);

        p1 = (PVector) vectors.get(j + i * subdivs);
        p2 = (PVector) vectors.get((j + 1) % subdivs  + i * subdivs);
        p3 = (PVector) vectors.get(j + (i + 1) * subdivs);
        strokeWeight(6);
        stroke(0, 100, 100, 50);
        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
        stroke(30, 100, 100, 50);
        line(p2.x, p2.y, p2.z, p3.x, p3.y, p3.z);   
        stroke(60, 100, 100, 50);
        line(p3.x, p3.y, p3.z, p1.x, p1.y, p1.z);

        strokeWeight(18);
        stroke(0, 100, 100, 50);
        point(p1.x, p1.y, p1.z);
        stroke(30, 100, 100, 50);
        point(p2.x, p2.y, p2.z);
        stroke(60, 100, 100, 50);
        point(p3.x, p3.y, p3.z);
      }
    }
}
