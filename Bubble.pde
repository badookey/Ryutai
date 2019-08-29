class Ball {
  
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  boolean shouldDisplay = true;
  int id;
  int[] rgb;
  Ball[] others;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin, int[] colours) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
    rgb = colours;
  } 
  
  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      if (others[i] != null){
        float dx = others[i].x - x;
        float dy = others[i].y - y;
        float distance = sqrt(dx*dx + dy*dy);
        float minDist = others[i].diameter/2 + diameter/2;
        if (distance < minDist && others[i].shouldDisplay) { 
          float angle = atan2(dy, dx);
          float targetX = x + cos(angle) * minDist;
          float targetY = y + sin(angle) * minDist;
          float ax = (targetX - others[i].x) * spring;
          float ay = (targetY - others[i].y) * spring;
          vx -= ax;
          vy -= ay;
          others[i].vx += ax;
          others[i].vy += ay;
        }
      }  
    }
  }
  boolean collideWithHand(){
    for (Hand hand : leap.getHands()) {
      for (int i = id; i < numBalls; i++) {
      float dx = hand.getPosition().x - x;
      float dy = hand.getPosition().y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = handBallDiameter + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - hand.getPosition().x) * spring;
        float ay = (targetY - hand.getPosition().y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
        this.pop();
        return true;
        }
      } 
    }
    return false;
  }
  public Ball[] getOthers(){
    return others;
  }
  void pop(){
    this.shouldDisplay = false;
    //others.remove(this); 
    System.out.println("popped bubble: " + id);
    String audioFileName = dataPath("") + "/HeavyGong.aif";
    SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
    Gain g = new Gain(ac, 2, 0.2+random(0.5));
    g.addInput(player);
    Glide glide = new Glide(ac,1);
    glide.setValue(random(0.8,1.5));
    player.setPitch(glide);
    ac.out.addInput(g);
  }
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      vx *= friction; 
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > height) {
      y = height - diameter/2;
      vy *= friction; 
    } 
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }
  
  void display() {
    if (shouldDisplay){
      fill(rgb[0],rgb[1],rgb[2], rgb[3]);
      ellipse(x, y, diameter, diameter);
    }
  }
}
/* BIBLIOGRAPHY
  *  Peters, K., Bouncy Bubbles, viewed 27/09/2017, <https://processing.org/examples/bouncybubbles.html>
  */