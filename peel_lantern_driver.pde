boolean doSerial = true;

boolean drawTransformed = false;
boolean rearView = false;

import processing.serial.*;

import gifAnimation.*;

import javax.media.opengl.*;
import processing.opengl.*;

int updateMode = 1; 

int maxX = 36;
int maxY = 35;

Serial port;

// lantern frame buffer
PGraphics lfb;

PImage led;

PFont font;

Gif anim;

GL gl;




void setup() {
  size(500, 500, OPENGL);
  frameRate(30);
  if (doSerial && Serial.list().length>0) {
    println(Serial.list());
    String serial = Serial.list()[0];
    port = new Serial(this, serial, 500000);
    String[] params = {"/bin/stty","crtscts","-F",serial};
    exec(params);
  }
  
  gl = ((PGraphicsOpenGL)g).gl;

  font = loadFont("Impact-35.vlw");

  lfb = createGraphics(maxX, maxY, JAVA2D);

  led = loadImage("diffuse.png");

  //anim = new Gif(this,"imagesspiral.gif");
  //anim = new Gif(this,"cycle.gif");
  //anim = new Gif(this,"7seg.gif");
  //anim = new Gif(this,"Yoyo_cropped.gif");
  anim = new Gif(this,"registration.gif");


  anim.play();
}

void draw() {
  updateLanternFrameBuffer();

  background(0);

  if(!drawTransformed) drawLantern(width, height);

  lfb.loadPixels();
  if(!rearView) flipYPixels(lfb);
  lfb.updatePixels();

  swapPixels(lfb,18,0,32,0,4,maxY);
  swapPixels(lfb,23,0,27,0,4,maxY);
  for(int y=0;y<maxY;y+=9) {
    flipXPixels(lfb,0,y+0,18,4);
    flipXPixels(lfb,0,y+4,18,4);
    swapPixels(lfb,18,y+0,18,y+4,18,4);  
   
  }
  lfb.updatePixels();

  if(drawTransformed) drawLantern(width, height);

  sendLantern();

  fill(255);

  textAlign(LEFT,TOP);
  String debugText = "fps:"+frameRate+"\n";
  debugText+="t: drawTransformed="+drawTransformed+"\n";
  debugText+="f: rearView="+rearView+"\n";
  text(debugText,5,5);
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

void sendLantern() {
  if (port==null) return;
  byte[] data = new byte[32*32*3];
  int i = 0;
  for (int y = 0; y<maxY; y++) {
    for (int x = 0; x<maxX; x++) {
      if ((x+5)%9!=0 && (y+1)%9!=0) {
        color p = lfb.pixels[y*maxX+x];
        data[i++] = (byte)blue(p);
        data[i++] = (byte)green(p);
        data[i++] = (byte)red(p);
      }
    }
  }
  port.write(data);
}

color getPixel(PGraphics pg, int x, int y) {
  return pg.pixels[y*pg.width+x];
}

void setPixel(PGraphics pg, int x, int y, color p) {
  pg.pixels[y*pg.width+x] = p;
}

void swapPixels(PGraphics pg, int x1, int y1, int x2, int y2, int w, int h) {
  for(int y=0;y<h;y++) {
    for(int x=0;x<w;x++) {
      color p = getPixel(pg,x1+x,y1+y);
      setPixel(pg,x1+x,y1+y,getPixel(pg,x2+x,y2+y));
      setPixel(pg,x2+x,y2+y,p);
    }
  }
}

void flipYPixels(PGraphics pg) {
  flipYPixels(pg,0,0,pg.width,pg.height);
}

void flipYPixels(PGraphics pg, int x, int y, int w, int h) {
  for(int yi=0;yi<h;yi++) {
    for(int xi=0;xi<w/2;xi++) {
      color p = getPixel(pg,x+xi,y+yi);
      int fxi = w-(xi+1);
      int fyi = yi;
      setPixel(pg,x+xi,y+yi,getPixel(pg,x+fxi,y+fyi));
      setPixel(pg,x+fxi,y+fyi,p);
    }
  }
}

void flipXPixels(PGraphics pg) {
  flipXPixels(pg,0,0,pg.width,pg.height);
}

void flipXPixels(PGraphics pg, int x, int y, int w, int h) {
  for(int yi=0;yi<h/2;yi++) {
    for(int xi=0;xi<w;xi++) {
      color p = getPixel(pg,x+xi,y+yi);
      int fxi = xi;//pg.width-(x+1);
      int fyi = h-(yi+1);//pg.height-(y+1);
      setPixel(pg,x+xi,y+yi,getPixel(pg,x+fxi,y+fyi));
      setPixel(pg,x+fxi,y+fyi,p);
    }
  }
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

void keyReleased() {
    switch(key) {
    case 'f': rearView=!rearView;
        break;
    case 't': drawTransformed=!drawTransformed;
        break;
    }
}

void fontTest() {
  String message = "Hackerspace Adelaide";
  lfb.beginDraw();
  lfb.textFont(font, 35);
  lfb.textAlign(LEFT, TOP);
  //lfb.noSmooth();
  lfb.background(0);
  //lfb.stroke(255);
  lfb.colorMode(HSB);
  lfb.fill((millis()/10)%255,255,255);
  int x = int((millis()/50) % int(lfb.textWidth(message)+(maxX)));
  lfb.text(message, maxX-x, 4/*(frameCount/8.0 % lfb.height*2) -lfb.height*/);
  lfb.endDraw();
}



void scanLines() {
  float mult = 20;
  int x1 = int(millis()/(3*mult)) % maxX;
  int x2 = int(millis()/(7*mult)) % maxX;
  int x3 = int(millis()/(13*mult)) % maxX;
  int y1 = int(millis()/(17*mult)) % maxY;
  int y2 = int(millis()/(11*mult)) % maxY;
  int y3 = int(millis()/(5*mult)) % maxY;
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
