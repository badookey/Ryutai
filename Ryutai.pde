/**
 * Created for the UTS Subject Interactive Media (
 * Using the following Libraries:
 *
 * Leap Motion library for Processing:
 * Copyright 2013-2016, Darius Morawiec
 * 
 * Beads | Written by Ollie Bown, with contributions from Ben Porter, Benito, Aengus Martin, Neil Smith and Evan Merz. 
 * It also uses some code from other Java projects including MEAP and JASS.
 *
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 * Built with Processing 3.3.6 | https://processing.org/
 */


/* TO USE:
*  Plug in leap motion 
*  Move hands around on screen to create rainbow liquid!
*  MODIFY CONSTRAINT PARAMETER IN CODE IF FPS IS VERY LOW - try 10 as a basic constraint
*  Touch the bubbles with the liquid to play a gong sound!
*/

/* INTENTION:
*  This project is intended as a Proof of Concept for a fluid simulation with the leap motion
*  The fluid simulation also needs to have dynamic music/sound effects played with interaction from the user
*  This project prooves that it is possible to have a leap controlled fluid simulation with dynamic sounds
*/

import de.voidplus.leapmotion.*; //leap motion

import beads.*; //beads

import com.thomasdiewald.pixelflow.java.DwPixelFlow; //PixelFlow
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D; //PixelFlow

import processing.core.*; //Processing
import processing.opengl.PGraphics2D; //Processing's openGL
  
  LeapMotion leap; //leap object
  
  AudioContext ac; //beads audiocontext
  
  //PVector GongRange = new PVector(200,200); //was going to have the gong trigger in a square in the top right of the screen
  PVector previousLeftHandPos = new PVector(0,0);
  PVector previousRightHandPos = new PVector(0,0);
  
  // fluid simulation
  DwFluid2D fluid;
  
  // render targets
  PGraphics2D pg_fluid;
  
  //Bubbles and bubble-physics options
  int numBalls = 10;
  float spring = 0.05;
  float gravity = 0.005;
  float friction = -0.9;
  float handBallDiameter = 20;
  Ball[] balls = new Ball[numBalls];

  
  public void settings() {
    size(800, 880, P2D);
  }
  
  public void setup() {
    // initialize leap //Source Morawiec, D (2013) LM_1_Basics.
    leap = new LeapMotion(this).allowGestures(); //gestures were initially going to trigger gongs.
    
    //initialize audio context
    ac = new AudioContext();
    setupClockMusic();
    ac.start();
    
    //  PixelFlow library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();
    
    // fluid simulation
    fluid = new DwFluid2D(context, width, height, 1);
    fluid.param.dissipation_velocity = 0.70f;
    fluid.param.dissipation_density  = 0.99f;

    // adding callback data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData(){
      public void update(DwFluid2D fluid) {
          drawFluid(fluid);
      }
    });
   
    // render-target
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    
    //REMOVED INITIAL BUBBLES
    //Create initial bubbles
    //for (int i = 0; i < numBalls; i++) {
    //  balls[i] = new Ball(random(width), random(height), random(30, 70), i, balls,assignColour());
    //}
    
    //set framerate to leap framerate so program is not bottlenecked
    frameRate(leap.getFrameRate());
  }
  public void setupClockMusic(){
    Clock clock = new Clock(ac, 700);
 clock.addMessageListener(
  new Bead() {
    int pitch;
     public void messageReceived(Bead message) {
        Clock c = (Clock)message;
        if(c.isBeat()) {
          if(random(1) < 0.5) return;
          pitch = Pitch.forceToScale((int)random(10), Pitch.dorian);
          float freq = Pitch.mtof(pitch + getpreviousRightHandPos().y / 15 + (int)random(32));
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SINE);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0));
          g.addInput(wp);
          ac.out.addInput(g);
          ((Envelope)g.getGainEnvelope()).addSegment(0.1, random(200));
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(7000), new KillTrigger(g));
       }
     }
   }
 );
 ac.out.addDependent(clock);
}
 public void playGong() {
   //Source: Beads - Lesson04_SamplePlayer.
   
   if (shouldPlayGong()) {
     //The below file is an edited version of the sound effect found here https://freesound.org/people/jorickhoofd/sounds/177872/
     //The original sound is licensed under creative commons 3.0, created by the user jorickhoofd on freesound.org and uploaded on February 11, 2013.
     //See the following link for access to the creative commons license https://creativecommons.org/licenses/by/3.0/
    String audioFileName = dataPath("") + "/HeavyGong.aif";
    SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
    Gain g = new Gain(ac, 2, 0.2+random(0.5));
    g.addInput(player);
    ac.out.addInput(g);
    //ac.start();
   }
 }
 
 int startTime = millis(); //global variables used by shouldPlayGong()
 int constraintSeconds = 2; //amount of seconds until another gong can be played
 
 public boolean shouldPlayGong(){
   //constrains the gong to playing every constraintSecond - e.g only 1 gong can play every 2 seconds
   if ((millis()-startTime)/1000 % 60 >= constraintSeconds){ // if elapsed time in seconds  is >= the constraint
     startTime = millis();
     return true;
   }
   return false;
 }
 //assigns a colour to a bubble, each is based off of UTS's new branding.
 int[] assignColour() {
  int random = (int) random(4);
  int[] i = new int[4];
  i[3] = (int)random(50,130);
  switch (random) {
    case 0: i[0] = 255; i[1] = 255; i[2] = 255; return i;
    case 1: i[0] = 0; i[1] = 0; i[2] = 255; return i;
    case 2: i[0] = 150; i[1] = 150; i[2] = 150; return i;
    case 3: i[0] = 255; i[1] = 0; i[2] = 0; return i;
    default: i[0] = 150; i[1] = 150; i[2] = 150; return i;
  }
}
 //renders fluid on the screen based on hand movement
 public void drawFluid(DwFluid2D fluid){
   //Source Diewald, T. (2016) Fluid_GetStarted.
   
   //THIS VARIABLE IS KEY TO INCREASING FPS ON LOWER-END COMPUTERS
      int constraint = 10;
   
     float lpx, lpy, lvx, lvy, rpx, rpy, rvx, rvy, radius, vscale;
     
      PVector lprevpos = new PVector(0,0);
      PVector rprevpos = new PVector(0,0);
       
      if(leftHandExists() && !leftIsLimited(leap.getLeftHand().getPosition(), constraint)){
        
        Hand leftHand = leap.getLeftHand();

        vscale = 15;
        
        //left hand positional variables
        lpx     = leftHand.getPosition().x;
        lpy     = height-leftHand.getPosition().y;
        lprevpos = getpreviousLeftHandPos();
        lvx     = (lpx - lprevpos.x) * +vscale;
        lvy     = (leftHand.getPosition().y - lprevpos.y) * -vscale;
        
        //left hand velocity
        radius = 10;
        fluid.addVelocity(lpx,lpy, radius, lvx, lvy);
        fluid.addVelocity(lpx,lpy, radius, lvx, lvy);
        fluid.addTemperature(lpx,lpy,10,1);
        fluid.addDensity(lpx, lpy, 10, random(1.0), random(1.0), random(1.0), 1.0f);
        previousLeftHandPos = leftHand.getPosition();
      } 
      if (rightHandExists() && !rightIsLimited(leap.getRightHand().getPosition(), constraint)) {
        
        Hand rightHand = leap.getRightHand();
        
        vscale = 15;
        
        //right hand positional variables
        rpx     = rightHand.getPosition().x;
        rpy     = height-rightHand.getPosition().y;
        rprevpos = getpreviousRightHandPos();
        rvx     = (rpx - rprevpos.x) * +vscale;
        rvy     = (rightHand.getPosition().y - rprevpos.y) * -vscale;        
       
        radius = 30;
        fluid.addVelocity(rpx, rpy, 14, rvx, rvy);
        fluid.addVelocity(rpx, rpy, 20, rvx, rvy);
        fluid.addTemperature(rpx,rpy,10,1);
        fluid.addDensity(rpx, rpy, 10, random(1.0), random(1.0), random(1.0), 1.0f);
        previousRightHandPos = rightHand.getPosition();
      }
 }
 
    public PVector getpreviousLeftHandPos(){
    if (previousLeftHandPos == null)
      return new PVector(0,0);
    else
     return previousLeftHandPos;  
  }
    public PVector getpreviousRightHandPos(){
    if (previousRightHandPos == null)
      return new PVector(0,0);
    else
     return previousRightHandPos;  
  }
  public boolean leftHandExists(){
   if (leap.getLeftHand() == null){
     return false;
   }
  return true;
  }
  public boolean rightHandExists(){
   if (leap.getRightHand() == null){
     return false;
   }
  return true;
  }
  public boolean leftIsLimited(PVector handPos, int constraint){
    //artificial constaint so every fps =/= a fluid update which can RIP your GPU to shreds
    if (handPos == null)
      return true;
    if (handPos.x - previousLeftHandPos.x <= constraint && handPos.x - previousLeftHandPos.x >= -constraint)
      if (handPos.y - previousLeftHandPos.y <= constraint && handPos.y - previousLeftHandPos.y >= -constraint)
        return true;
   return false; 
  }
   public boolean rightIsLimited(PVector handPos, int constraint ){ 
     //artificial constaint so every fps =/= a fluid update which can RIP your GPU to shreds
     if (handPos == null)
      return true;
    if (handPos.x - previousRightHandPos.x <= constraint && handPos.x - previousRightHandPos.x >= -constraint)
     if (handPos.y - previousRightHandPos.y <= constraint && handPos.y - previousRightHandPos.y >= -constraint)
        return true;
   return false; 
  }
  Ball[] removeBallfromArray(Ball removeball){
 Ball[] newBalls = new Ball[balls.length]; 
 for (int i = 0; i < balls.length; i++){
   if (balls[i] == removeball){
    newBalls[i] = null;
   } else {
    newBalls[i] = balls[i]; 
   }
 }
 return newBalls;
}
  public void tryPlayGong() {
    //gong is played whenever it hits the edges of the sketch
    int threshold = 10;
   for (Hand hand : leap.getHands()) {
    if (hand.getPosition().x > 0 && hand.getPosition().x < threshold|| hand.getPosition().x > width - threshold && hand.getPosition().x < width) 
     playGong(); 
    else if (hand.getPosition().y > 0 && hand.getPosition().y < threshold|| hand.getPosition().y > height && hand.getPosition().y < height) 
     playGong(); 
   }
  }
  public void drawBalls() {
    noStroke();
   for (Ball ball : balls) {
    if (ball != null) {
      fill(255);
      ball.collide();
      if (ball.collideWithHand())
        balls = removeBallfromArray(ball);
      ball.move();
      ball.display();  
    }
  }
    //for (Hand hand : leap.getHands()){
    //  fill(255, 100, 100);
    //  ellipse(hand.getPosition().x, hand.getPosition().y, handBallDiameter, handBallDiameter);
    //} 
  }
  public void createBalls() {
   //1 in 500 chance to create one every frame.
    //if ((int)random(500) == 1){
      for (int i = 0; i< balls.length; i++){
        if (makeBall(i))
          break;
      }
   //}
  }
  public boolean makeBall(int index) {
    if (balls[index] == null){
       //balls[index] = new Ball(random(width), height, random(30, 70), index, balls,assignColour());
       balls[index] = new Ball(random(width), 0, random(30, 70), index, balls,assignColour());
       return true;
    }
    return false;
  }
  public void draw() {    
    //Source: Diewald, T (2016) - Fluid_GetStarted
    
    // update simulation
    fluid.update();
    
    // clear render target
    pg_fluid.beginDraw();
    pg_fluid.background(0);
    pg_fluid.endDraw();

    // render fluid stuff
    fluid.renderFluidTextures(pg_fluid, 0);

    // display
    image(pg_fluid, 0, 0);
    
    //draw the balls and calculate their related functions
    drawBalls();
    
    //Generate new Balls
    createBalls();
    
    tryPlayGong();
  }
  
  
  
  /* BIBLIOGRAPHY
  *  Beads, (unknown date), Lesson04_SamplePlayer. [Computer Program] http://www.beadsproject.net/ 
  *  Diewald, T. (2016) Fluid_GetStarted. [Computer Program] http://thomasdiewald.com/blog/
  *  Jorickhoofd, (2013) Heavy gong. [Sound file] https://freesound.org/people/jorickhoofd/sounds/177872/
  *  Morawiec, D (2013) LM_1_Basics. [Computer Program] https://github.com/nok/leap-motion-processing
  */
  