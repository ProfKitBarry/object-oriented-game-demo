//racing game from a C++ tutorial: https://www.youtube.com/watch?v=KkMZI5Jbf18 

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

ControlIO control;
ControlDevice stick;

//racing game from a C++ tutorial: https://www.youtube.com/watch?v=KkMZI5Jbf18 

//set some road variables, scaled from 0 to 1
//we'll use them to multiply by canvas size so they scale to the screen
float middlePoint = 0.5;
float targetCurvature; //the curvature of the current track section
float trackCurveDifference; //for lerping the track to curve

float deltaTime = 0.0002;

float carPosition = 0; //this is the car's L/R position from -1 to 1
float carDistance = 0; //this is the car's position along the track (Y-ish)
float carSpeed = 0;
boolean gasPedle = false;
boolean brakePedle = false;
boolean steerLeft = false;
boolean steerRight = false;
float steering;
float gas;
float brake;

//using PVector to store the track
//x: curvature for this section: -1 is max Left, +1 is max Right
//y: distance of this section
//and making a list of all the track sections
ArrayList<PVector> trackSections = new ArrayList<PVector>(); 
int currentSection = 0; //which section the car is currently on
float currentDistance = 0; //position on current section
float currentCurvature; //current value of track curvature based on the track section
float trackCurvature; //racing line curvature
float carCurvature = 0; //player position on the track

//set some colors
color grassColor;
color lightGrass = color(0, 255, 0);
color darkGrass = color(0, 155, 0);
color rumbleColor;
color lightRumble = color(255, 0, 0);
color darkRumble = color(255, 255, 255);
color roadColor = color(170, 170, 170);

void setup(){
  size(400, 400);
  
  surface.setTitle("Testing joystick input");
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a joystick that matches the configuration file. To match with any 
  // connected device remove the call to filter.
  stick = control.filter(GCP.STICK).getMatchedDevice("Audio Racer");
  if (stick == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
  // Setup a function to trap events for this button
  //stick.getButton("GAS").plug(this, "gas", ControlIO.ON_RELEASE);
  //stick.getButton("BRAKE").plug(this, "brake", ControlIO.ON_RELEASE);
  
  noStroke();
  rectMode(CENTER);
  textSize(20);
  createTrack();
}

// Poll for user input called from the draw() method.
public void getUserInput() {
  steering = map(stick.getSlider("STEERING").getValue(), -1, 1, -1, 1);
  gas = map(stick.getSlider("GAS").getValue(), 0, 1, 0, 1);
  brake = map(stick.getSlider("BRAKE").getValue(), 0, 1, 0, 1);
}

//Event handler for the GAS button
void gas(){
  getUserInput();
}

//Event handler for the BRAKE button
void brake(){
  getUserInput();
}

void draw(){
  getUserInput();
  updatePlayer();
  drawBackground();
  drawRoad();
  drawPlayer();
}

void keyPressed(){
  if(key == 'w' || key == 'W' || keyCode == UP){
    gasPedle = true;
  }
  if(key == 's' || key == 'S' || keyCode == DOWN){
    brakePedle = true;
  }
  if(key == 'a' || key == 'A' || keyCode == LEFT){
    steerLeft = true;
  }
  if(key == 'd' || key == 'D' || keyCode == RIGHT){
    steerRight = true;
  }
}

void keyReleased(){
  if(key == 'w' || key == 'W' || keyCode == UP){
    gasPedle = false;
  }
  if(key == 's' || key == 'S' || keyCode == DOWN || key == ' '){
    brakePedle = false;
  } 
  if(key == 'a' || key == 'A' || keyCode == LEFT){
    steerLeft = false;
  }
  if(key == 'd' || key == 'D' || keyCode == RIGHT){
    steerRight = false;
  }
}

void updatePlayer(){
  //gas & brake
  if(gasPedle == true){
    carSpeed += 20 * deltaTime;
  } else {
    carSpeed -= 15 * deltaTime;
  }
  if(brakePedle == true){
    carSpeed -= 30 * deltaTime;
  }
  //steering
  if(steerLeft == true){
    carCurvature -= 100 * deltaTime;
  }
  if(steerRight == true){
    carCurvature += 100 * deltaTime;
  }
  //joystick steering
  carCurvature += steering * 100 * deltaTime;
  carSpeed += gas * 20 * deltaTime;
  carSpeed -= brake * 30 * deltaTime;
  
  //if we're off the track, slow us down because dirt
  if(abs(carCurvature - trackCurvature) >= 0.8){
    carSpeed -=50 * deltaTime;
  }
  carPosition = carCurvature - trackCurvature;
  carPosition = constrain(carPosition, -1, 1);
  
  carSpeed = constrain(carSpeed, 0, 1);
  carDistance += 10 * carSpeed;
  //keep track of our distance on this section
  currentDistance += 10 * carSpeed;
}


void createTrack(){
  trackSections.add(new PVector(0, 50)); //add a short straight section to be start/finish line
  trackSections.add(new PVector(0, 500));
  trackSections.add(new PVector(1, 1000));
  trackSections.add(new PVector(0, 2000));
  trackSections.add(new PVector(-1, 500));
  trackSections.add(new PVector(0, 1000));
  trackSections.add(new PVector(-1, 1000));
  trackSections.add(new PVector(1, 1000));
  trackSections.add(new PVector(0, 1000));
}

void drawBackground(){
  //draw the sky and parallax hills
  background(170, 240, 255);
  fill(170, 210, 255);
  rect(width/2, height/2 - height/8, width, height/4);
  fill(170, 180, 255);
  rect(width/2, height/2 - height/16, width, height/8);
}

void drawRoad(){
    //fill(0);
    //text(trackSections.get(currentSection).y - currentDistance, width/2, 20);
    //text(trackSections.get(currentSection).x - trackSections.get((currentSection + 1) % trackSections.size()).x, width/2, 40);
  
  //figure out what section of the track we're on
  if(currentDistance >= trackSections.get(currentSection).y){
    currentDistance -= trackSections.get(currentSection).y;
    currentSection += 1;
    currentSection = currentSection % trackSections.size();
    targetCurvature = trackSections.get(currentSection).x;
  }
  
  
  trackCurveDifference = (targetCurvature - currentCurvature) * deltaTime * carSpeed;
  currentCurvature += trackCurveDifference; //lerp towards the section curvature
      
  trackCurvature += currentCurvature * deltaTime * carSpeed;
  fill(10, 140, 0);
  //draw some hills in the upper half of the screen
  for(int x = 0; x < width; x++){
    int hillHeight = int(sin(x * 0.015 + trackCurvature + 600) * 45);
    for(int y = (height/2) - hillHeight; y < height / 2; y++){
      //draw the pixel
      rect(x, y, 1, 1);
    }
    
    hillHeight = int(sin(x * 0.01 + trackCurvature) * 40);
    for(int y = (height/2) - hillHeight; y < height / 2; y++){
      //draw the pixel
      rect(x, y, 1, 1);
    }
  }
  
  //draw the lower half of the screen, the current track section and false perspective
  for(int y = 0; y < height/2; y++){
      
    float perspective = y / (height * 0.5);
    float roadWidth = 0.1 + perspective * 0.8;
    float rumbleWidth = roadWidth * 0.15;
    
    trackCurveDifference = (targetCurvature - currentCurvature) * deltaTime * carSpeed;
    currentCurvature += trackCurveDifference; //lerp towards the section curvature
    //use this to set the road's midpoint that everything is drawn relative to
    middlePoint = 0.5 + currentCurvature * pow(1 - perspective, 3);
    
    trackCurvature += currentCurvature * deltaTime * carSpeed;
    
    
    //work out where grass/rumble/road starts and ends
    float leftGrass = (middlePoint - roadWidth/2 - rumbleWidth) * width;
    float leftRumble = (middlePoint - roadWidth/2) * width;
    float rightGrass = (middlePoint + roadWidth/2 + rumbleWidth) * width;
    float rightRumble = (middlePoint + roadWidth/2) * width;
    
    for(int x = 0; x < width; x++){
      
      //y is looping from 0 to half the height; we want to draw to the bottom half of the screen
      int row = width/2 + y;
      
      //get our color-banding maths: using the sin of our perspective cubed
      //this will be -1 to 1, and we'll test it against 0 to flip our banding colors
      float banding = sin(20 * pow(1 - perspective, 3) + carDistance * 0.1);
      
      if(banding > 0) {
        grassColor = lightGrass;
      } else {
        grassColor = darkGrass;
      }
      
      //same again but a different frequency sin curve to get the rumble strip banding
      banding = sin(80 * pow(1 - perspective, 3) + carDistance * 0.1);
      if(banding > 0) {
        rumbleColor = lightRumble;
      } else {
        rumbleColor = darkRumble;
      }
      
      //get the color
      if(x >= 0 && x < leftGrass) {
        fill(grassColor);
      }
      if(x >= leftGrass && x < leftRumble) {
        fill(rumbleColor);
      }
      if(x >= leftRumble && x < rightRumble) {
        fill(roadColor);
      }
      if(x >= rightRumble && x < rightGrass) {
        fill(rumbleColor);
      }
      if(x >= rightGrass && x < width) {
        fill(grassColor);
      }
      //draw the pixel
      rect(x, row, 1, 1);
    }
  }
  
}

void drawPlayer(){
  //draw the player's car
  float position = width/2 + (width * carPosition)/2;
  fill(170);
  rect(position + steering * 25, height - 80, 20, 10);
  fill(200);
  rect(position + steering * 15, height - 65, 35, 20);
  fill(255);
  rect(position, height - 40, 50, 30);
  //draw brake lights
  if(brakePedle == true){
    fill(255,0,0);
    rect(position - 10, height - 35, 10, 10);
    rect(position + 10, height - 35, 10, 10);
  }
  
  fill(255,0,0,brake*255);
  rect(position - 10, height - 35, 10, 10);
  rect(position + 10, height - 35, 10, 10);
  
  //draw dirt
    if(abs(carCurvature - trackCurvature) >= 0.8){
    fill(0, 100);
    rect(position - 20, height - 15, 20, 30);
    rect(position + 20, height - 15, 20, 30);
  }
}
