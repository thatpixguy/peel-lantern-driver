import gifAnimation.*;

import javax.media.opengl.*;
import processing.opengl.*;

int updateMode = 2; 

int maxX = 36;
int maxY = 34;

// lantern frame buffer
PGraphics lfb;

PImage led;

PFont font;

Gif anim;

GL gl;

//int updateMode;



void setup() {
  size(500, 500, OPENGL);
  frameRate(30);

  gl = ((PGraphicsOpenGL)g).gl;

  //updateMode = 2;

  font = loadFont("Impact-35.vlw");

  lfb = createGraphics(maxX, maxY, JAVA2D);

  led = loadImage("diffuse.png");

  //anim = new Gif(this,"imagesspiral.gif");
  //anim = new Gif(this,"cycle.gif");
  anim = new Gif(this,"7seg.gif");


  anim.play();
}

void draw() {
  updateLanternFrameBuffer();

  background(0);


  drawLantern(width, height);

  fill(255);

  textAlign(LEFT,TOP);
  text("fps:"+frameRate,5,5);
}

// symetrical random
float srandom(float high) {
  return random(-high, high);
}

void drawPixel(PGraphics pg, int b, float x, float y, float sx, float sy) {
  if (b>0)
    blend(pg, 0, 0, 64, 64, 
    int(x-sx/2.0), int(y-sy/2.0), int(sx), int(sy), ADD);
}

void drawLantern(float w, float h) {
  float xPitch = w/(maxX+1.0);
  float yPitch = h/(maxY+1.0);

  float pointSize = 1.5;
  float randomFactor = 0.05;

  lfb.loadPixels();

  randomSeed(0);



  imageMode(CENTER);

  noStroke();
  
  // additive blending
  gl.glBlendFunc(GL.GL_SRC_ALPHA,GL.GL_ONE);
  
  int i=0;
  for (int y = 0; y<maxY; y++) {
    for (int x = 0; x<maxX; x++, i++) {
      color p = lfb.pixels[i];
      
      int c = int(red(p));
      tint(c, 0, 0);
      float rx=xPitch*(x+1)+srandom(xPitch*pointSize*randomFactor);
      float ry=yPitch*(y+1)+srandom(yPitch*pointSize*randomFactor);
            
      if ((x+5)%9!=0 && (y+1)%9!=0) {

        image(led,
          rx,ry,
          xPitch*pointSize, 
          yPitch*pointSize);

      }

      c = int(green(p));
      tint(0, c, 0);
      rx=xPitch*(x+1)+srandom(xPitch*pointSize*randomFactor);
      ry=yPitch*(y+1)+srandom(yPitch*pointSize*randomFactor);
            
      if ((x+5)%9!=0 && (y+1)%9!=0) {
   
        image(led,
          rx,ry,
          xPitch*pointSize, 
          yPitch*pointSize);

      }
       
      c = int(blue(p));
      tint(0, 0, c);
      rx=xPitch*(x+1)+srandom(xPitch*pointSize*randomFactor);
      ry=yPitch*(y+1)+srandom(yPitch*pointSize*randomFactor);
            
      if ((x+5)%9!=0 && (y+1)%9!=0) {

        image(led,
          rx,ry,
          xPitch*pointSize, 
          yPitch*pointSize);

      }
      

    }
  }
  
  // reset gl blending
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
  gl.glBlendEquation(GL.GL_FUNC_ADD);	    	  
 
}

void maskLanternFrameBuffer() {
  lfb.beginDraw();
  lfb.stroke(0);
  for (int x=4;x<maxX;x+=9) {
    lfb.line(x, 0, x, maxY);
  }
  for (int y=8;y<maxY;y+=9) {
    lfb.line(0, y, maxX, y);
  }
  lfb.endDraw();
}



void updateLanternFrameBuffer() {
  switch(updateMode%3) {
  case 0:
    scanLines();
    break;
  case 1:
    fontTest();
    break;
  case 2:
    gifTest();
    break;
  }
}

void fontTest() {
  String message = "HackerSpace Adelaide... FORMAT...";
  lfb.beginDraw();
  lfb.textFont(font, 35);
  lfb.textAlign(LEFT, TOP);
  //lfb.noSmooth();
  lfb.background(0);
  lfb.stroke(255);
  int x = int((frameCount/2) % int(lfb.textWidth(message)+(maxX)));
  lfb.text(message, maxX-x, -4/*(frameCount/8.0 % lfb.height*2) -lfb.height*/);
  lfb.endDraw();
}

void scanLines() {
  int x1 = frameCount/3 % maxX;
  int x2 = frameCount/7 % maxX;
  int x3 = frameCount/13 % maxX;
  int y1 = frameCount/17 % maxY;
  int y2 = frameCount/11 % maxY;
  int y3 = frameCount/5 % maxY;
  lfb.beginDraw();
  lfb.background(0);

  int alpha=255;

  lfb.stroke(255, 0, 0, alpha);
  lfb.line(x1, 0, x1, maxY);
  lfb.line(0, y1, maxX, y1);

  lfb.stroke(0, 255, 0, alpha);
  lfb.line(x2, 0, x2, maxY);
  lfb.line(0, y2, maxX, y2);

  lfb.stroke(0, 0, 255, alpha);
  lfb.line(x3, 0, x3, maxY);
  lfb.line(0, y3, maxX, y3);

  lfb.endDraw();
}

void gifTest() {
  lfb.beginDraw();
  lfb.colorMode(HSB);
  //lfb.tint(frameCount%255,255,255);
  lfb.image(anim,0,0,lfb.width,lfb.height);
  lfb.endDraw();
}
