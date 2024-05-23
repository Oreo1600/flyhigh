/* Fly High : Extension of the classic Flappy Bird
It has total three modes. First one is classic pillar mode. Second mode has two lasers covering part of the screen. 
Third mode has arrows shooting from left side of the screen.
In laser mode, getting in between two lasers earns extra score.
*/

// Note: In order to run the program, FlyHigh.pde needs to be in a folder where there are no other pde files.
// MOUSE CLICK TO JUMP

import java.util.*;

// Global Variables
int sHeight = 600; // Height of the canvas
int sWidth = 1000; // Width of the canvas
Player player; // Reference to the player object
boolean end = false; // Game state changer variable, if this is true, the game is stopped and retry button appears
boolean overButton = false; // Used to check if the mouse is over the button
List<Obstacle> obstacles; // List/Array of the obstacles - abstract class object, obstacles can be Pillars, Laser, Arrow 
float score = 0; // Game score
int speed = 5; // Game speed, utlimately used to move the obstacles.
int currentObstacle = 0; // Tracker for current obstacle mode.
int obstacleChangeInt = 1; // This boolean is used to randomly change the obstacle mode after three of the modes are cleared.
int treeX1 = 1020; int treeX2 = 1520; int treeX3 = 2020; // Tree initial positions out of screen on left side.
int treeY; int treeHeight; // TreeY and treeHeight is changed after drawing each tree. Makes the code more flexible.
int treeSpeed = 2; // Speed of the tree, slower than the speed of the obstacles.
int highscore = 0; // Highscore variable
void setup() 
{
    size(1000, 600); // Size of the canvas
    background(#87CEEB); // Cyan background color

    player = new Player(); // Initializing the player in the setup method. 
    obstacles = new ArrayList<Obstacle>(); // Obstacle array/list is initialized. Major difference between List and Array is that we do not need to give length when declaring List.
}
void ObstacleStateManager() // This method watches over the Obstacle Mode.
{
    // if the score is more than a certain amount and the currentObstacle is not the same as the one that is about to change, then we change the obstacle mode.
    /*Obstacle values:
      Pillar = 1
      Laser = 2
      Arrow = 3
    */
    if (score < 10 && currentObstacle != 1) { 
        currentObstacle = 1; // give value of the current obstacle mode
        for(int i = 0; i < 1050; i += 350) // Initializes Pillar objects to obstacle list
        {      
            obstacles.add(new Pillar(1020 + i));
        }
    }
    else if (score > 10 && score < 25 && currentObstacle != 2) { // If the score is above 10 and below 25, initialize Laser objects to obstacle list
        currentObstacle = 2;
        obstacles.add(new Laser(1020));
        obstacles.add(new Laser(1620));
        obstacles.add(new Laser(2220));
    }
    else if (score > 25 && score < 45 && currentObstacle != 3) { // If the score is above 25 and below 45, initialize Arrow objects to obstacle list
        currentObstacle = 3;
        obstacles.add(new Arrow(1020));
        obstacles.add(new Arrow(1020));
        obstacles.add(new Arrow(1020));
        obstacles.add(new Arrow(1020));
    }
    else if(score > 45){ // If the score is above 45 then randomly choose the obstacle mode
        
        if (score > obstacleChangeInt)
        {           
            obstacleChangeInt = (int)score + (int)random(10,20);
            int obstacleType = (int)random(1,2);
            if(obstacleType != currentObstacle)
            {
                if(obstacleType == 0)
                {
                    currentObstacle = 1;
                    for(int i = 0; i < 1050; i += 350)
                    {      
                        obstacles.add(new Pillar(1020 + i));
                    }
                }
                else if(obstacleType == 1)
                {
                    currentObstacle = 2;
                    obstacles.add(new Laser(1020));
                    obstacles.add(new Laser(1520));
                    obstacles.add(new Laser(2020));
                }
                else if(obstacleType == 2)
                {
                    currentObstacle = 3;
                    obstacles.add(new Arrow(1020));
                    obstacles.add(new Arrow(1020));
                    obstacles.add(new Arrow(1020));
                    obstacles.add(new Arrow(1020));
                }
            }
        }
    }
} // Since all Pillar, Laser and Arrow extends the abstract class Obstacle, objects of all three classes can be assigned to a parent Obstacle class.
void draw() 
{
    
    background(#87CEEB);     
    fill(255, 255, 0);ellipse(sWidth/2, 50, 100,100); // drawing sun 
    
    //Tree 1
    treeY = 400; treeHeight = 200; // These variables are changed and used in all trees.
    fill(139, 69, 19); rect(treeX1, treeY, treeHeight / 10, treeHeight); // Trunk, Brown color
    fill(34, 139, 34); ellipse(treeX1 + treeHeight / 20, treeY, treeHeight / 2, treeHeight / 2); // Leaves, Green color
    treeX1 -= treeSpeed; if (treeX1 < - 100) treeX1 = 1100; // Moving tree from left to right slower than the speed of obstacles. If it goes outside the screen on left side, bring it on right side out of screen.
    
    //Tree 2
    treeY = 300; treeHeight = 300;
    fill(139, 69, 19);rect(treeX2, treeY, treeHeight / 10, treeHeight);
    fill(34, 139, 34); ellipse(treeX2 + treeHeight / 20, treeY, treeHeight / 2, treeHeight / 2);
    treeX2 -= treeSpeed; if (treeX2 < - 100) treeX2 = 1100;
    
    //Tree 3
    treeY = 350; treeHeight = 250;
    fill(139, 69, 19);rect(treeX3, treeY, treeHeight / 10, treeHeight);
    fill(34, 139, 34); ellipse(treeX3 + treeHeight / 20, treeY, treeHeight / 2, treeHeight / 2);
    treeX3 -= treeSpeed; if (treeX3 < - 100) treeX3 = 1100;

    if(!end) speed = 5 + (int)(score / 6); // 5 is the base speed, it is further increased based on the score. As score increases, the speed increases.
    ObstacleStateManager(); // Call to the obstacle manager method.

    player.drawPlayer(); // calling drawPlayer() method of player object. It draws the rect, two triangles and wings of the bird, values changes repetitively
    player.GameOver(); // This method checks if the player has moved above or below the screen
    
    if(player.jumpTime < frameCount) { 
            player.yWingOffset = 0;
        } // When we press jump, the wings are flipped vertically, this if statement flips it back normal after few frames.
        
        for(int i = 0; i < obstacles.size(); i++){ // This for loop iterates through the obstacles list and moves each one.
            Obstacle obstacle = obstacles.get(i);
            obstacle.ObstacleMove();
            // if the obstacle is Pillers or Arrows, the endPoint is (which is the place from which the obstacle is cleared off the list) -100 and for laser it is -600.
            int endPoint = obstacle.type == 1 || obstacle.type == 3 ? -100 : -600;  // Laser obstacle needs more space off the screen to make the spacing equal. 
            if (obstacle.type != currentObstacle && obstacle.xPos < endPoint) { 
                obstacles.remove(i);
                i--; // decreasing i to account for the cleared obstacle
            } // if the obstacle that is next in list not same as current obstacle, and obstacle has moved out of screen, we remove it from the list and begin next obstacle mode.
    }
    player.Move(); // Moving the player
    player.gravity(); // giving the player physics when jumping  
        
    //Displaying the score
    fill(255); // White color
    textSize(32);
    text("Score: " + (int)score, 10, 50); // Displaying the score at position (10, 50)
    text("Highscore: " + highscore, 10, 80); // Displaying the highscore at position (10, 80)
    if (end) { // If the end is true, then the player must have crashed into obstacle or gone out of screen.
        color c; // This color object is used to give hovor effect to the button.
        if(buttonHoverCheck()) { c = #005b99; } // If the button is hovered then we are assigning it a darker blue color.
        else { c = #007acc;} // if the button is not hovered light blue is assigned.
        player.End(c); // This method draws text and button etc. 
        speed = 0; // resetting the speed
        treeSpeed = 0; // resetting the tree speed
    }
}
boolean buttonHoverCheck() // This method returns true when the mouse is over the given coordinates
{
    if (overRect(width/2 - 100, height/2 - 50, 200, 100)) // overRect() checks if the given parameters are inside the coordinates of button
    {   
        return true;
    }
    else
    {
        return false;
    }
}
void mousePressed() // Called when mouse is pressed
{
    if(buttonHoverCheck() && end) // Pressing the restart button
    {
        end = false; // Making this false allows the draw method to run the code inside of else statement.
        player.Restart(); // Resetting the values.
    }
    if(!end) player.Jump(); // If the mouse is pressed while the game is running then initiate jump method.
}

class Player // Player class takes care of the player movement, wing animation.
{
    float xPos, yPos; // Location of the player
    float ySpeed; // Vertical speed of the player
    int yWingOffset = 0; // Used to flip the wings
    int jumpTime; // stores the time when the jump was pressed
    Player() // Player constructor does not accepts any parameters
    {
        // Initial values
        xPos = 50;
        yPos = 300;
    }
    void drawPlayer()
    {
        fill(#FFD700); rect(xPos, yPos, 70, 40); // Body
        fill(0); circle(xPos + 60, yPos + 10, 9); // Eye
        fill(#FF8C00); triangle(xPos + 71, yPos + 16, xPos+106, yPos+26, xPos+ 68, yPos+26); // Beak 1
        triangle(xPos + 71, yPos + 36, xPos+106, yPos+26, xPos+ 68, yPos+26); // Beak 2
        fill(#FFD700); quad(xPos+48, yPos+20, xPos+20, yPos+26, xPos+20,yPos+66 - yWingOffset, xPos + 40, yPos + 70 - yWingOffset); // Wings
        // All the values of the shapes are related to the xPos and yPos, so changing the value of xPos and yPos changes the values of all points of shapes
    }
    void gravity()
    {
        ySpeed += 0.2;  // accumulates speed overtime.
    }
    void Jump()
    {
        yWingOffset = 90; //  flips the wings up
        ySpeed -=7; // Moves the player up
        jumpTime = frameCount + 10; // current frameCount + 10 to flip the wing back normal after 10 frames.
    }
    void Move()
    {
        yPos+=ySpeed;  // changes the player position according the ySpeed value.
    }
    void End(color c) // This method is called when the game is stopped
    {
        
        fill(128, 128, 128, 102); // 40% transparent grey
        rect(0, 0, sWidth, sHeight); // transparent foreground     
        
        fill(#ff0021); textSize(40); text("GAME OVER!",width/2 - 100,200); // Game over text
        
        fill(c); rect(width/2 - 100, height/2 - 50, 200, 100); // Button
        fill(255); textSize(30); text("Try Again?", width/2 - 60, height/2 + 10); // Try again text
    }
    void GameOver() // This method checks if the player has gone above or below screen
    {
        if(yPos > sHeight || yPos < -50) 
        {
            end = true;
        }
    }
    void Restart() // Resetting values when pressed retry button
    {
        if(score > highscore) highscore = (int)score;  
        xPos = 50; // Initial positions
        yPos = 300;
        ySpeed = 0; // Assigning this 0 ensures that the velocity from the previous game does not apply to new game
        player.yWingOffset = 0; // Resets wing offset
        player.jumpTime = 0; // Resets jump time
        score = 0; // Resets score
        obstacles.clear(); // Clears all obstacles
        currentObstacle = 0; // Makes the current obstacle mode pillar
        ObstacleStateManager(); // Generates new obstacles
        treeSpeed = 2;
    }
}

boolean overRect(int x, int y, int width, int height)  // This method checks if the values given in parameters are inside the mouse coordinates
{
  if (mouseX >= x && mouseX <= x+width &&  mouseY >= y && mouseY <= y+height) {
      return true;
    }  else {
      return false;
    }
}



abstract class Obstacle // This is kind of a blueprint class for the child of the Obstacle classes.
{
    int xPos; // X coordinates of the obstacles
    // Y coordinates are not needed here since we do not need to change them.
    boolean scoreIncremented; // This variables ensures that score is only incremented one time.
    public abstract void ObstacleMove(); // Moves the obstacles
    public abstract void CheckCollision(); // Detects collision with the player
    int type; // Type of the obstacle. 1 - Pillar, 2 - Laser, 3 - Arrow.
    
    // Classes that inherits the Obstacle must give body to above two methods. Also, all the classes share three common variables xPos, scoreIncremented, and type.
}
class Pillar extends Obstacle // Pillar class has all the necessay information about the pillar.
{
    Pillar(int _xPos) // Position of the pillar, initially out of the screen value.
    {
        xPos = _xPos;
        type = 1;
    }
    int pillerGap = 300; // initial Gap position between two pillers
    void drawPiller() { // Drawing the pillar
        // First pillar is drawn from the top of the screen till the 100 pixel above pillar gap position. Second rect is additional detail.
        fill(#0870a3); rect(xPos, 0, 50, pillerGap - 100); fill(#054c6f); rect(xPos - 10, pillerGap - 100, 70, 10);
        // Second pillar is drawn 100 pixel below the pillar gap position, and the height of the pillar is height of the screen minus the pillar starting point.
        fill(#0870a3); rect(xPos, pillerGap+100 , 50, sHeight - (pillerGap+100)); fill(#054c6f); rect(xPos - 10, pillerGap + 100, 70, 10);
        fill(255,255,255);
    }
    void Move() {
        xPos -= speed; // Moving pillar to the left.
    }
    public void CheckCollision() {
        if(xPos < player.xPos + 70 && xPos + 50 > player.xPos && (player.yPos < pillerGap - 100 || player.yPos + 40 > pillerGap + 100))
        {
            end = true;
        } // Checking if the xPos is between player xPos and xPos + 50 (which is length of player), same for Y coordinates.
    }
    public void ObstacleMove() {
        if(xPos < -100) // If it goes outside the screen on left, move it to the initial position with random gap position.
        {
            xPos = 1020;
            pillerGap = (int)random(0 + 200, sHeight - 100);
            scoreIncremented = false;
        }       
        else // If it is inside the screen moving the pillar and drawing it while also checking for any collisions.
        {
            Move();
            drawPiller();
            CheckCollision();
        }
        if(xPos < player.xPos && !scoreIncremented) // if the player has passed the pillar, increasing the score.
        {
            score++;
            scoreIncremented = true;
        }
    }
}
class Laser extends Obstacle // Laser class has all details regarding the laser object.
{
    int frontOffseter; // Used to generate random y value in upper half of the screen
    int backOffseter; // Used to generate random y value in below half of the screen

    int yPos1; // First Point of the upper quad
    int yPos2; // Second Point of the upper quad

    int byPos1,byPos2; // First and second point of the below quad

    Laser(int _xPos) // this constructor accepts the x coordinate of the both laser
    {
        xPos = _xPos;
        type = 2;
        initializeValue(); // initializing all the points of the quad
    }
    void initializeValue()
    {
        int frontOffseter = (int)random(10, 270); // assignes random value in upper half with 10 offset.
        int backOffseter = (int)random(sHeight/2 + 30, sHeight - 30); // assigned random value on below half with 30 offset.

        yPos1 = (int)random(frontOffseter - 30, frontOffseter + 30); // random value of the first point of the upper half quad.
        yPos2 = (int)random(frontOffseter - 30, frontOffseter + 30); // random value of the second point of the upper half quad

        byPos1 = (int)random(backOffseter - 30, backOffseter + 30); // random value of the first point of the below half quad
        byPos2 = (int)random(backOffseter - 30, backOffseter + 30); // random value of the second point of the below half quad
    }
    void drawLaser() { // drawing lasers
        fill(#ff8f1e); quad(xPos,yPos1,xPos+400,yPos2,xPos+400,yPos2 + 10, xPos, yPos1 + 10); // First laser in upper half of the screen
        quad(xPos,byPos1,xPos+400,byPos2,xPos+400,byPos2 + 10, xPos, byPos1 + 10); // Second laser in below half of the screen
        fill(255,255,255);
    }
    void Move() {
        xPos -= speed;
    }
    public void CheckCollision() {
    
        if(player.xPos + 70 > xPos && player.xPos < xPos + 400) { // Checking if the player has entered the x position of the laser
            // Checking if the player's y position is within the laser's y range.
            if((player.yPos > yPos1 && player.yPos < yPos1 + 10) || 
               (player.yPos + 40 > yPos2 && player.yPos < yPos2 + 10) ||
               (player.yPos > byPos1 && player.yPos < byPos1 + 10) || 
               (player.yPos + 40 > byPos2 && player.yPos < byPos2 + 10)) {
                end = true;
            }
        }
    }   
    public void ObstacleMove() {
        if(xPos < -600) // Checking if the laser gas gone outside of the screen
        {
            xPos = 1020;
            scoreIncremented = false;
            initializeValue(); // reinitializing values of the quad for random shape
        }       
        else
        {
            Move();
            drawLaser();
            CheckCollision();
        }
        if(player.yPos > yPos1 && player.yPos < byPos1 && xPos < player.xPos && !scoreIncremented) // if the player crosses from between the lasers then increment score by 3
        {
            score = score + 3;
            scoreIncremented = true;
        }
        else if(player.xPos > xPos && !scoreIncremented) { // else increment by 1
            score++;
            scoreIncremented = true;
        }
    }
}
class Arrow extends Obstacle // Arrow class inherits from the Obstacle and has properties of the Arrow objects
{
    int yPos; // yPos of the Arrow

    Arrow(int _xPos) // This constructor initializes the x position of the arrow
    {
        xPos = _xPos;
        type = 3;
    }
    void drawArrow() {
        fill(#808080); rect( xPos,yPos,100,10); // body
        fill(#ff0021); quad(xPos+100,yPos + 9,xPos + 100, yPos, xPos + 114, yPos - 12,xPos + 114 ,yPos + 20); // Tail
        fill(255); triangle(xPos - 24 , yPos + 4, xPos, yPos - 12, xPos, yPos + 18); // Point
        fill(255,255,255);
    }
    void Move() {
        xPos -= speed;
    }
    public void CheckCollision() {
    if(player.xPos + 70 > xPos && player.xPos < xPos + 100) { // Checking if the player has entered the x position of the arrow
        if((player.yPos > yPos && player.yPos < yPos + 10) || (player.yPos + 40 > yPos && player.yPos + 40 < yPos + 10)) {
            end = true;
        }// Checking if the player's y position is within arrow's y range.
    }
    }
    public void ObstacleMove() {
        if(xPos < -100) // Checking if the arrow has gone out of the screen
        {
            xPos = 1020;
            yPos = (int)random(0 + 10, sHeight - 10); // assigining random y position of the screen with 10 offset
            scoreIncremented = false;
        }        
        else
        {
            Move();
            drawArrow();
            CheckCollision();
        }
        if(xPos < player.xPos && !scoreIncremented)
        {
            score = score + 0.25; // Increasing score by .25 because of 4 arrow positioned on the same x axis, resulting in increasing of by each.
            scoreIncremented = true;
        }
    }
}

/* References
https://forum.processing.org/two/discussion/3580/flappy-code.html
https://processing.org/examples/button.html
https://processing.org/reference/color_.html
https://www.w3schools.com/java/java_abstract.asp
https://www.geeksforgeeks.org/list-interface-java-examples/
*/
