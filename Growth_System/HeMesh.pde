class HeMeshParticleSystem //<>//
{
  ArrayList<HeVertex> v = new ArrayList<HeVertex>();
  ArrayList<HalfEdge> e = new ArrayList<HalfEdge>();
  ArrayList<HeFace> f = new ArrayList<HeFace>();

  HeMeshParticleSystem(ArrayList<PVector> vertices, ArrayList<int[]> faceIndices)
  {
    for (int i = 0; i < vertices.size(); i++)
      v.add(new HeVertex(vertices.get(i)));
    for (int i = 0; i < faceIndices.size(); i++)
      f.add(new HeFace(faceIndices.get(i), i));
  }

  class HeVertex
  {
    PVector position;
    PVector velocity;
    PVector acceleration;
    IntList outgoingHalfEdges;
    FloatList rest;
    boolean initial = true; //for setting initial conditions
    boolean locked;
    FloatList increase;

    HeVertex(PVector p)
    {
      position = p;
      velocity = new PVector();
      outgoingHalfEdges = new IntList();
    }

    void AddOutgoingHalfEdge(int edge)
    {
      outgoingHalfEdges.append(edge);
    }

    void React()
    {
      if (initial)
      {
        rest = new FloatList();
        increase = new FloatList();
      }

      for (int i = 0; i < outgoingHalfEdges.size(); i++)
      {
        HeVertex vertex = v.get(e.get(i).v1);
        float distance = PVector.dist(position, vertex.position);

        if (initial) 
        {
          rest.append(distance); //to set the inital rest length
          increase.append((position.z == 0 && vertex.position.z == 0) ? 1.001 : 1);
        }

        rest.set(i, rest.get(i) * increase.get(i));
        float displacement = distance - rest.get(i);
        acceleration = PVector.sub(vertex.position, position);
        acceleration.normalize();
        acceleration.mult(k * displacement / mass);
        velocity.add(acceleration);
      }

      initial = false;
      velocity.mult(damping);
    }

    void Move()
    {
      position.add(velocity);
    }

    void Display()
    {
      point(position.x, position.y, position.z);
    }
  }

  class HeFace
  {
    int[] faceV;
    int[] faceE;

    HeFace(int[] vertices, int faceIndex)
    {
      faceV = vertices;
      faceE = new int[faceV.length];
      for (int i = 0; i < faceV.length; i++)
      {
        int j = (i + 1) % faceV.length;
        HalfEdge tempE = new HalfEdge(faceV[i], faceV[j], faceIndex);
        e.add(tempE);
        faceE[i] = e.size() - 1;
        v.get(faceV[i]).AddOutgoingHalfEdge(e.size() - 1);
      }

      for (int i = 0; i < faceE.length; i++)
      {
        e.get(faceE[i]).SetNextEdge((i + 1) % faceE.length);
        e.get(faceE[i]).SetPrevEdge((i - 1) % faceE.length);
      }
    }

    void Display()
    {
      beginShape();
      for (int i = 0; i < faceV.length; i++)
      {
        PVector vector = v.get(faceV[i]).position;
        vertex(vector.x, vector.y, vector.z);
      }
      endShape(CLOSE);
    }
  }

  class HalfEdge
  {
    int v0;
    int v1;
    int ePrev;
    int eNext;
    int fIndex;

    HalfEdge(int vStart, int vEnd, int f)
    {
      v0 = vStart;
      v1 = vEnd;
      fIndex = f;
    }

    void SetNextEdge(int next)
    {
      eNext = next;
    }

    void SetPrevEdge(int prev)
    {
      ePrev = prev;
    }

    void Display()
    {
      HeVertex vertex0 = v.get(v0);
      HeVertex vertex1 = v.get(v1);
      line(vertex0.position.x, vertex0.position.y, vertex0.position.z, vertex1.position.x, vertex1.position.y, vertex1.position.z);
    }
  }

  void Update()
  {
    for (int i = 0; i < v.size(); i++)
      v.get(i).React();
    for (int i = 0; i < v.size(); i++)
      v.get(i).Move();
    //if (!v.get(i).locked) v.get(i).Move();
  }

  void Display()
  {
    pushStyle();
    strokeWeight(0.5);
    fill(80);
    for (int i = 0; i < f.size(); i++)
      f.get(i).Display();

    strokeWeight(6);
    for (int i = 0; i < v.size(); i++)
    {
      if (v.get(i).locked) stroke(30);
      else stroke(50, 100, 100);
      if (i == 0) stroke(0, 100, 100);
      if (i == 1) stroke(10, 100, 100);
      v.get(i).Display();
    }
    popStyle();
  }
}
