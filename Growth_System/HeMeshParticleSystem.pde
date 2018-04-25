class HeMeshParticleSystem //<>// //<>//
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
    boolean initial = true; //for setting initial conditions
    boolean locked;
    FloatList restLength;
    FloatList multiplier;
    ArrayList tempAcceleration;

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
        restLength = new FloatList();
        multiplier = new FloatList();
      }

      PVector tempVelocity = new PVector();
      for (int i = 0; i < outgoingHalfEdges.size(); i++)
      {
        HeVertex vertex = v.get(e.get(outgoingHalfEdges.get(i)).v1);
        float distance = PVector.dist(position, vertex.position);

        if (initial) 
        {
          restLength.append(distance); //to set the inital rest length
          float heightRatio = position.z / maxHeight;
          multiplier.append((abs(position.z - vertex.position.z) < 0.01) ? 1.0 + 0.01 * heightRatio :  1.0);
        }

        if (frameCount % 5 == 0) restLength.set(i, restLength.get(i) * multiplier.get(i));
        //restLength.set(i, distance * multiplier.get(i));
        //float restLength = distance * multiplier.get(i);
        float displacement = distance - restLength.get(i);
        acceleration = PVector.sub(vertex.position, position);
        acceleration.normalize();
        acceleration.mult(k * displacement * 0.5 / mass);
        tempVelocity.add(acceleration);
        //PVector delta = PVector.sub(vertex.position, position);
        //delta.normalize();
        //delta.mult(displacement * 0.5);
        //tempVelocity.add(delta);
      }
      //using tempVelocity to be able to divide the final velocity by the sum
      //weight of the weights of each force applied by each neighboring vertex
      tempVelocity.mult(1.0 / (float) outgoingHalfEdges.size());
      velocity.add(tempVelocity);
      initial = false;
      //velocity.mult(damping); ?!
    }

    void Move()
    {
      position.add(velocity);
    }

    void ResetTempAcceleration()
    {
      tempAcceleration = new ArrayList<PVector>();
    }

    void Move2()
    {
      acceleration = new PVector();
      for (int i = 0; i < tempAcceleration.size(); i++)
        acceleration.add((PVector) tempAcceleration.get(i));
      acceleration.mult(1.0 / (float) tempAcceleration.size());
      velocity.add(acceleration);
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
        int j = (i == 2) ? 0 : i + 1;
        HalfEdge tempE = new HalfEdge(faceV[i], faceV[j], faceIndex);
        e.add(tempE);
        faceE[i] = e.size() - 1;
        v.get(faceV[i]).AddOutgoingHalfEdge(e.size() - 1);

        int k = (i == 0) ? 2 : i - 1;
        HalfEdge tempE2 = new HalfEdge(faceV[i], faceV[k], faceIndex);
        e.add(tempE2);
        faceE[i] = e.size() - 1;
        v.get(faceV[i]).AddOutgoingHalfEdge(e.size() - 1);
      }

      //for (int i = 0; i < faceE.length; i++)
      //{
      //  e.get(faceE[i]).SetNextEdge((i + 1) % faceE.length);
      //  e.get(faceE[i]).SetPrevEdge((i - 1) % faceE.length);
      //}
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
    boolean initial = true;
    float restLength;
    float multiplier;
    PVector velocity;
    PVector acceleration;

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

    float EdgeLength()
    {
      PVector p0 = v.get(v0).position;
      PVector p1 = v.get(v1).position;
      return dist(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z);
    }

    void React()
    {
      float distance = PVector.dist(v.get(v0).position, v.get(v1).position);
      if (initial) 
      {
        restLength = distance; //to set the inital rest length
        multiplier = ((abs(v.get(v0).position.z - v.get(v1).position.z) <0.1) ? 1.1 :  1.0);
        initial = false;
      }
      restLength *= multiplier;
      //restLength = distance * multiplier;
      float displacement = distance - restLength;
      acceleration = PVector.sub(v.get(v1).position, v.get(v0).position);
      //acceleration = new PVector (9, 0, 0);
      //println(distance + " " +  restLength);
      acceleration.normalize();
      acceleration.mult(k * displacement * 0.5 / mass);
      //acceleration.mult(100);
      //velocity.mult(damping); ?!
      //acceleration = new PVector(1, 0, 0);
      v.get(v0).tempAcceleration.add(acceleration);
      acceleration.mult(-1);
      v.get(v1).tempAcceleration.add(acceleration);
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
    //for (int i = 0; i < v.size(); i++)
    //  v.get(i).ResetTempAcceleration();
    //for (int i = 0; i < e.size(); i++)
    //  e.get(i).React();
    //for (int i = 0; i < v.size(); i++)
    //  v.get(i).Move2();

    for (int i = 0; i < v.size(); i++)
      v.get(i).React();
    for (int i = 0; i < v.size(); i++)
      if (!v.get(i).locked) v.get(i).Move();
  }

  void CheckEdges()
  {
    for (int i = 0; i < e.size(); i++)
      if (e.get(i).EdgeLength() > maxLength)
      {
        //add new vertex
        PVector p0 = v.get(e.get(i).v0).position;
        PVector p1 = v.get(e.get(i).v1).position;
        PVector p = PVector.add(p0, p1);
        p.mult(0.5);
        v.add(new HeVertex(p));
        int vIndex = v.size() - 1;
      }
  }

  void Display()
  {
    pushStyle();
    //strokeWeight(0.5);
    //fill(80);
    //for (int i = 0; i < f.size(); i++)
    //  f.get(i).Display();

    strokeWeight(2);
    stroke(0, 100, 100);
    for (int i = 0; i < e.size(); i++)
      e.get(i).Display();

    strokeWeight(6);
    for (int i = 0; i < v.size(); i++)
    {
      if (v.get(i).locked) stroke(30);
      else stroke(50, 100, 100);
      v.get(i).Display();
    }
    popStyle();
  }
}
