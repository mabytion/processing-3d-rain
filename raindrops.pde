class Raindrop
{
  float speed = 6;
  float gravity = random(0.1, 0.4);
  float rainSize = random(1, 4);
  float x, y;
  float z;
  boolean dropFlags = true;

  Raindrop(float x, float y, float z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  void drop()
  {
    if (z<waterLevel)
    {
      dropFlags = false;
      waterLevel += rainSize/100;
    }

    if (dropFlags)
    {
      pushMatrix();
      fill(0, 255, 255);
      translate(x, y, z);
      z -= speed;
      speed += gravity;
      box(rainSize);
      popMatrix();
    }
  }

  boolean getDropFlags()
  {
    return dropFlags;
  }
}

class Timer extends Thread
{
  void run()
  {
    while (!isInterrupted())
    {
      try
      {
        targetRaindrop = (int)random(-800, 800);
        if (targetRaindrop < 0)
        {
          targetRaindrop = 0;
        }
        sleep(5000);
      }
      catch(InterruptedException e)
      {
        e.printStackTrace();
      }
    }
  }
}

class DropReduce extends Thread
{
  void run()
  {
    while (!isInterrupted())
    {
      try
      {
        if (targetRaindrop > raindropMax)
        {
          raindropMax += (targetRaindrop-raindropMax)/10;
          
          if(targetRaindrop <= raindropMax)
          {
            raindropMax = targetRaindrop;
          }
        }
        if (targetRaindrop <= raindropMax)
        {
          raindropMax -= (raindropMax-targetRaindrop)/10;
          
          if(targetRaindrop >= raindropMax)
          {
            raindropMax = targetRaindrop;
          }
        }
        sleep(200);
      }
      catch(InterruptedException e)
      {
        e.printStackTrace();
      }
    }
  }
}

class Sink extends Thread
{
  void run()
  {
    while (!isInterrupted())
    {
      try
      {
        waterLevel -= sinkRate;
        if (waterLevel < 0)
        {
          waterLevel = 0;
        }
        if (waterLevel > 500)
        {
          waterLevel = 500;
        }
        sleep(100);
      }
      catch(InterruptedException e)
      {
        e.printStackTrace();
      }
    }
  }
}

float CameraX = 800;
float CameraY = 1500;
float CameraZ = 300;

ArrayList<Raindrop> rd;
int xMax = 1000, yMax = 1000;
int xMin = 0, yMin = 0;
int raindropMax = 1;
int targetRaindrop = 1;
int scale = 1;
float waterLevel = 0;
float sinkRate = 0.2;
float cloudHeight = 500;

Timer timer = new Timer();

void setup()
{
  fullScreen(P3D);
  //size(2000, 1200, P3D);
  lights();
  textSize(50);

  rd = new ArrayList<Raindrop>();
  for (int i=0; i<raindropMax; i++)
  {
    rd.add(new Raindrop(random(xMin, xMax-1)*scale, random(yMin, yMax-1)*scale, cloudHeight));
  }

  Sink sink = new Sink();
  DropReduce reduce = new DropReduce();
  sink.start();
  timer.start();
  reduce.start();
}

void draw()
{
  background(200);
  camera(CameraX, CameraY, CameraZ, 500, 500, 0.0, 0.0, 0.0, -1.0);

  try
  {
    for (int i=0; i<raindropMax; i++)
    {
      if (!rd.get(i).getDropFlags())
      {
        rd.remove(i);
        rd.add(new Raindrop(random(xMin, xMax-1)*scale, random(yMin, yMax-1)*scale, cloudHeight));
      } else
      {
        rd.get(i).drop();
      }
    }
  }
  catch(IndexOutOfBoundsException e)
  {
    for (int i=rd.size(); i<raindropMax; i++)
    {
      rd.add(new Raindrop(random(xMin, xMax-1)*scale, random(yMin, yMax-1)*scale, cloudHeight));
    }
  }

  //translate(xMax/2, yMax/2, waterlevel/2);
  //box(xMax, yMax, waterlevel);
  
  //  ┌─┐          ─────
  //  │3│         / 6  /│
  //┌─┼─┼─┬─┐    ┌────┐5│
  //│1│2│5│6│    │ 4  │/
  //└─┼─┼─┴─┘    └────┘
  //  │4│
  //  └─┘
  
  pushMatrix();
  beginShape(QUADS);
  // 1
  vertex(0, 0, 0);
  vertex(0, yMax, 0);
  vertex(0, yMax, waterLevel);
  vertex(0, 0, waterLevel);
  
  // 2
  vertex(0, 0, 0);
  vertex(xMax, 0, 0);
  vertex(xMax, yMax, 0);
  vertex(0, yMax, 0);
  
  // 3
  vertex(0, yMax, 0);
  vertex(xMax, yMax, 0);
  vertex(xMax, yMax, waterLevel);
  vertex(0, yMax, waterLevel);
  
  // 4
  vertex(0, 0, 0);
  vertex(xMax, 0, 0);
  vertex(xMax, 0, waterLevel);
  vertex(0, 0, waterLevel);
  
  // 5
  vertex(xMax, 0, 0);
  vertex(xMax, yMax, 0);
  vertex(xMax, yMax, waterLevel);
  vertex(xMax, 0, waterLevel);
  
  // 6
  vertex(0, 0, waterLevel);
  vertex(xMax, 0, waterLevel);
  vertex(xMax, yMax, waterLevel);
  vertex(0, yMax, waterLevel);
  endShape();
  popMatrix();
  
  text("cloudheight >> " + cloudHeight + "pixels", 0, 1050);
  text("raindrop >> " + raindropMax + "drops", 0, 1100);
  text("targetdrop >> " + targetRaindrop + "drops", 0, 1150);
  text("waterlevel >> " + waterLevel + "pixels", 0, 1200);
  text("sink >> " + sinkRate * 10 + "pixels/sec", 0, 1250);
  text("key >> " + key, 0, 1300);
  text("keyCode >> " + keyCode, 0, 1350);
  
}

void keyPressed()
{
  if (keyCode == UP) 
  {
    CameraY -= 100;
  } else if (keyCode == DOWN) 
  {
    CameraY += 100;
  }
  if (keyCode == RIGHT) 
  {
    CameraX += 100;
  }
  if (keyCode == LEFT) 
  {
    CameraX += -100;
  }
  if (key == 'a') 
  {
    CameraZ += 100;
  }
  if (key == 'z') 
  {
    CameraZ += -100;
  }
  if (key == 'w')
  {
    targetRaindrop += 100;
  }
  if (key == 's')
  {
    targetRaindrop -= 100;
  }
  if (key == 'e')
  {
    sinkRate += 0.1;
  }
  if (key == 'd')
  {
    sinkRate -= 0.1;
  }
  if (key == 'r')
  {
    cloudHeight += 20;
  }
  if (key == 'f')
  {
    cloudHeight -= 20;
  }
}
