int daysInYear = 62; // Two months (October and November)
float[] screenTime = new float[daysInYear];
String[] location = new String[daysInYear];
String[][] apps = new String[daysInYear][5];
float[][] appUsage = new float[daysInYear][5];

float angleX = 0, angleY = 0, zoom = -800; // Camera control
int selectedData = -1; // Track selected data point
boolean isDragging = false;
boolean isViewingPieChart = false; // State to switch between views
PVector dragStart;

void setup() {
  size(1000, 800, P3D);
  generateSampleData();
}

void draw() {
  background(30);
  lights();
  
  if (!isViewingPieChart) {
    // 3D Bar Chart View
    translate(width / 2, height / 2, zoom);
    rotateX(angleX);
    rotateY(angleY);
    
    draw3DVisualization();
    
    // Highlight selected data
    if (selectedData >= 0) {
      highlightSelectedBar();
    }
  } else {
    // Pie Chart View
    drawPieChart(selectedData);
    drawBackButton();  // Make sure this function is called to draw the back button
  }
}


void generateSampleData() {
  String[] sampleApps = {"Instagram", "YouTube", "WhatsApp", "TikTok", "Browser"};
  for (int i = 0; i < daysInYear; i++) {
    screenTime[i] = random(1, 8); // Random screen time (1-8 hours)
    location[i] = random(1) > 0.5 ? "University" : "Home";
    for (int j = 0; j < 5; j++) {
      apps[i][j] = sampleApps[j];
      appUsage[i][j] = random(0.2, 1.5); // Random usage time (0.2-1.5 hours)
    }
  }
}

void draw3DVisualization() {
  int daysInMonth = 31; // Number of days in October and November
  float radius = 250;  // Radius of the circular layout for each month
  String[] months = {"October", "November"};
  
  for (int month = 0; month < 2; month++) {
    pushMatrix();
    translate((month * 2 - 1) * radius * 3, 0, 0); // Arrange months side by side
    
    // Month label
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(20);
    text(months[month], 0, -radius - 50);
    
    for (int day = 0; day < daysInMonth; day++) {
      int index = month * daysInMonth + day;
      if (index >= daysInYear) break; // End of data check
      
      pushMatrix();
      float barHeight = map(screenTime[index], 0, 8, 10, 200);
      float barRadius = 15; // Bar thickness
      
      // Calculate daily position (clockwise, starting from the top)
      float dailyAngle = map(day, 0, daysInMonth, -HALF_PI, TWO_PI - HALF_PI);
      float xPos = cos(dailyAngle) * radius;
      float yPos = sin(dailyAngle) * radius;
      translate(xPos, yPos, barHeight / 2);
      
      // Color based on location
      fill(location[index].equals("University") ? color(100, 150, 255) : color(255, 150, 100));
      noStroke();
      box(barRadius, barRadius, barHeight);
      
      // Add day label
      pushMatrix();
      translate(0, 0, barHeight / 2 + 20);
      rotateX(HALF_PI); // Align labels upright
      rotateZ(-dailyAngle); // Rotate to keep text upright
      fill(255);
      textSize(12);
      textAlign(CENTER, CENTER);
      text("Day " + (day + 1), 0, 0);
      popMatrix();
      
      // Check if mouse clicked
      if (mousePressed && mouseButton == LEFT && !isViewingPieChart) {
        PVector screenPos = new PVector(screenX(0, 0, 0), screenY(0, 0, 0));
        if (dist(mouseX, mouseY, screenPos.x, screenPos.y) < 20) { // Refined click detection
          selectedData = index;
          isViewingPieChart = true;
          break;
        }
      }
      popMatrix();
    }
    popMatrix();
  }
}

void highlightSelectedBar() {
  int daysInMonth = 31;
  float radius = 250;
  
  int month = selectedData / daysInMonth;
  int day = selectedData % daysInMonth;
  
  pushMatrix();
  translate((month * 2 - 1) * radius * 3, 0, 0);
  float barHeight = map(screenTime[selectedData], 0, 8, 10, 200);
  float dailyAngle = map(day, 0, daysInMonth, -HALF_PI, TWO_PI - HALF_PI);
  translate(cos(dailyAngle) * radius, sin(dailyAngle) * radius, barHeight / 2);
  noFill();
  stroke(255, 255, 0);
  strokeWeight(3);
  box(20, 20, barHeight + 10);
  popMatrix();
}

void drawPieChart(int index) {
  float totalUsage = 0;
  for (int j = 0; j < 5; j++) {
    totalUsage += appUsage[index][j];
  }
  
  float angleStart = 0;
  String[] pieColors = {"#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", "#9966FF"};
  
  translate(width / 2, height / 2);
  textAlign(CENTER);
  textSize(20);
  fill(255);
  text("App Usage for Day " + (index % 31 + 1) + " (" + (index < 31 ? "October" : "November") + ")", 0, -200);
  
  for (int j = 0; j < 5; j++) {
    float angleEnd = angleStart + (appUsage[index][j] / totalUsage) * TWO_PI;
    fill(unhex(pieColors[j].substring(1)));
    arc(0, 0, 300, 300, angleStart, angleEnd, PIE);
    
    // Label
    fill(255);
    float midAngle = (angleStart + angleEnd) / 2;
    float labelX = cos(midAngle) * 180;
    float labelY = sin(midAngle) * 180;
    textSize(12);
    text(apps[index][j] + ": " + nf(appUsage[index][j], 1, 2) + " hrs", labelX, labelY);
    
    angleStart = angleEnd;
  }
}

void drawBackButton() {
  fill(200, 50, 50);  // Red color for the back button
  rectMode(CENTER);
  rect(width / 2, height - 50, 150, 40, 10); // Position button at the center-bottom
  
  fill(255);  // White color for the text
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Back", width / 2, height - 50);  // Text inside the button
}


void mouseClicked() {
  if (isViewingPieChart) {
    // Check if back button was clicked
    if (mouseX > width / 2 - 75 && mouseX < width / 2 + 75 &&
        mouseY > height - 70 && mouseY < height - 30) {
      isViewingPieChart = false;  // Hide the pie chart and go back to 3D chart view
      selectedData = -1;  // Reset selected data when going back
    }
  }
  
  // Handle click on 3D chart for selecting data (not in pie chart view)
  if (!isViewingPieChart && selectedData == -1) {
    // Loop through the bars to see if any were clicked
    int daysInMonth = 31;
    float radius = 250;
    String[] months = {"October", "November"};
    
    for (int month = 0; month < 2; month++) {
      for (int day = 0; day < daysInMonth; day++) {
        int index = month * daysInMonth + day;
        if (index >= daysInYear) break; // End of data check
        
        // Calculate daily position for click detection
        float dailyAngle = map(day, 0, daysInMonth, -HALF_PI, TWO_PI - HALF_PI);
        float xPos = cos(dailyAngle) * radius;
        float yPos = sin(dailyAngle) * radius;
        
        // Use a simplified distance check from mouse click to 3D position
        PVector screenPos = new PVector(screenX(xPos, yPos, 0), screenY(xPos, yPos, 0));
        if (dist(mouseX, mouseY, screenPos.x, screenPos.y) < 20) { // Refined click detection
          selectedData = index;
          isViewingPieChart = true;  // Switch to pie chart view
          break;  // Stop the loop once a selection is made
        }
      }
    }
  }
}



void mouseDragged() {
  if (isDragging) {
    PVector delta = new PVector(mouseX, mouseY).sub(dragStart);
    angleX += delta.y * 0.01;
    angleY += delta.x * 0.01;
    dragStart = new PVector(mouseX, mouseY); // Update drag start
  }
}

void mousePressed() {
  dragStart = new PVector(mouseX, mouseY);
  isDragging = true;
}

void mouseReleased() {
  isDragging = false;
}

void mouseWheel(MouseEvent event) {
  float zoomAmount = event.getCount() * 50; // Adjust zoom speed
  zoom += zoomAmount; // Update zoom level
  zoom = constrain(zoom, -1500, -200); // Prevent extreme zoom in/out
}
