int cols, rows;
int scl = 20;
int w=1600;
int h=1200;
float[][] terrain;

float rotX=PI/3;
float rotZ, scaleFactor;

ArrayList<Raindrop> rd;
ArrayList<Cloud> cd;
int widths = 1600, heights = 1200;
int xMax, yMax;
int xMin, yMin;
int raindropMax = 500;
int targetRaindrop = 500;
int scale = 1;
int margin = 50;
int cloudCount = 1000;
int r = 0, g = 255, b = 255;
float waterLevel;
float waterBottom = -140;
float sinkRate = 0.11;
float cloudHeight = 700;

boolean cloudFlags = true;
Timer timer;

class Cloud
{
  float x, y;
  float z;

  Cloud()
  {
    this.x = random(xMin, xMax);
    this.y = random(yMin, yMax);
    this.z = cloudHeight + random(-10, 10);
  }

  void cloudy(float h)
  {
    z = h;
    pushMatrix();
    fill(50, 80);
    translate(x, y, z);
    box(random(160, 120), random(60, 80), random(10, 60));
    popMatrix();
  }
}
class Raindrop
{
  float speed = 6;
  float tale = random(40, 120);
  float rainSize = random(1, 4);
  float gravity = rainSize/10;
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
      waterLevel += (rainSize/100) * (tale/75);
    }

    if (dropFlags)
    {
      pushMatrix();
      fill(r, g, b, 128);
      translate(x, y, z);
      z -= speed;
      speed += gravity;
      box(rainSize, rainSize, tale);
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
  boolean isRun = true;
  void run()
  {
    while (isRun)
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

  boolean isRun()
  {
    return isRun;
  }

  void timerStop()
  {
    isRun = false;
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

          if (targetRaindrop <= raindropMax)
          {
            raindropMax = targetRaindrop;
          }
        }
        if (targetRaindrop <= raindropMax)
        {
          raindropMax -= (raindropMax-targetRaindrop)/10;

          if (targetRaindrop >= raindropMax)
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
        if (waterLevel < waterBottom)
        {
          waterLevel = waterBottom;
        }
        if (waterLevel > cloudHeight-50)
        {
          waterLevel = cloudHeight-50;
        }
        sleep(10);
      }
      catch(InterruptedException e)
      {
        e.printStackTrace();
      }
    }
  }
}

void setup() {
  size(1200, 900, P3D);
  cols=w/scl;
  rows=h/scl;
  terrain = new float[cols][rows];
  textSize(margin);
  lights();

  xMax = widths/2 - 1;
  xMin = -(widths/2);
  yMax = heights/2 - 1;
  yMin = -(heights/2);
  waterLevel = waterBottom;
  cd = new ArrayList<Cloud>();
  rd = new ArrayList<Raindrop>();
  for (int i=0; i<raindropMax; i++)
  {
    rd.add(new Raindrop(random(xMin, xMax-1)*scale, random(yMin, yMax-1)*scale, cloudHeight));
  }

  for (int i=0; i<cloudCount; i++)
  {
    cd.add(new Cloud());
  }
  Sink sink = new Sink();
  DropReduce reduce = new DropReduce();
  timer = new Timer();
  
  sink.start();
  reduce.start();
  timer.timerStop();
}

float flying=1;

void draw() {
  background(120, 85, 0);
  translate(575, 400);
  rotateX(rotX);
  rotateZ(rotZ);
  scale(0.35 + scaleFactor);

  if (cloudFlags)
  {
    for (int i=0; i<cloudCount; i++)
    {
      cd.get(i).cloudy(cloudHeight);
    }
  }

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

  pushMatrix();
  beginShape(QUADS);
  // 1
  //fill(0, 255, 255, 50);
  fill(r, g, b, 128);
  vertex(xMin-1, yMin-1, waterBottom);
  vertex(xMin-1, yMax-20, waterBottom);
  vertex(xMin-1, yMax-20, waterLevel);
  vertex(xMin-1, yMin-1, waterLevel);

  // 2
  vertex(xMin-1, yMin-1, waterBottom);
  vertex(xMax-20, yMin-1, waterBottom);
  vertex(xMax-20, yMax-20, waterBottom);
  vertex(xMin-1, yMax-20, waterBottom);

  // 3
  vertex(xMin-1, yMax-20, waterBottom);
  vertex(xMax-20, yMax-20, waterBottom);
  vertex(xMax-20, yMax-20, waterLevel);
  vertex(xMin-1, yMax-20, waterLevel);

  // 4
  vertex(xMin-1, yMin-1, waterBottom);
  vertex(xMax-20, yMin-1, waterBottom);
  vertex(xMax-20, yMin-1, waterLevel);
  vertex(xMin-1, yMin-1, waterLevel);

  // 5
  vertex(xMax-20, yMin-1, waterBottom);
  vertex(xMax-20, yMax-20, waterBottom);
  vertex(xMax-20, yMax-20, waterLevel);
  vertex(xMax-20, yMin-1, waterLevel);

  // 6
  vertex(xMin-1, yMin-1, waterLevel);
  vertex(xMax-20, yMin-1, waterLevel);
  vertex(xMax-20, yMax-20, waterLevel);
  vertex(xMin-1, yMax-20, waterLevel);
  endShape();
  popMatrix();

  fill(0, 255, 255);
  text("cloudheight >> " + cloudHeight + "pixels", xMin, margin*15);
  text("raindrop >> " + raindropMax + "drops", xMin, margin*16);
  text("targetdrop >> " + targetRaindrop + "drops", xMin, margin*17);
  text("waterlevel >> " + (waterLevel+(-waterBottom)) + "pixels", xMin, margin*18);
  text("sink >> " + sinkRate * 100 + "pixels/sec", xMin, margin*19);
  text("key >> " + key, xMin, margin*20);
  text("keyCode >> " + keyCode, xMin, margin*21);

  float yoff=flying;
  for (int y=0; y<rows; y++) {
    float xoff=0;
    for (int x=0; x<cols; x++) {
      terrain[x][y]=map(noise(xoff, yoff), 0, 1, -200, 200);
      xoff +=0.2;
    }
    yoff +=0.2;
  }

  noStroke();

  for (int y=0; y<rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x=0; x<cols; x++) {
      fill(0, 128-terrain[x][y], 0);
      vertex(x*scl-800, y*scl-600, terrain[x][y]); 
      vertex(x*scl-800, (y+1)*scl-600, terrain[x][y+1]);
    }

    endShape();
  }

  beginShape(TRIANGLE_STRIP);
  for (int x=0; x<cols; x++)
  {
    fill(0, 128-terrain[x][0], 0);
    vertex(x*scl-800, -600, waterBottom);
    vertex(x*scl-800, -600, terrain[x][0]);
  }
  endShape();
  
  beginShape(TRIANGLE_STRIP);
  for (int x=0; x<cols; x++)
  {
    fill(0, 128-terrain[x][0], 0);
    vertex(x*scl-800, 580, waterBottom);
    vertex(x*scl-800, 580, terrain[x][rows-1]);
  }
  endShape();
}
void mouseDragged() { //Added
  rotZ -= (mouseX - pmouseX) * 0.01;
  rotX -= (mouseY - pmouseY) * 0.01;
}
void mouseWheel(MouseEvent event) { //Added
  float e = event.getCount();
  scaleFactor += e/10;
}
void keyPressed()
{
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
    sinkRate += 0.01;
  }
  if (key == 'd')
  {
    sinkRate -= 0.01;
  }
  if (key == 'r')
  {
    cloudHeight += 20;
  }
  if (key == 'f')
  {
    cloudHeight -= 20;
  }
  if (key == 'q')
  {
    if (timer.isRun)
    {
      timer.timerStop();
    } else
    {
      timer = new Timer();
      timer.start();
    }
  }
  if (key == 'c')
  {
    cloudFlags = !cloudFlags;
  }
}
