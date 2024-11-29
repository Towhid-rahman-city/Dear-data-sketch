import processing.sound.*;

// Sound files for different step ranges
SoundFile lowStepSound;
SoundFile moderateStepSound;
SoundFile highStepSound;

// Step count data for October (31 days) and November (30 days)
int[] octoberSteps = {
  3500, 8000, 5000, 12000, 7000, 4000, 9000, 11000, 5000, 10000,
  8000, 13000, 3000, 7500, 12000, 7000, 6000, 8000, 11000, 10000,
  6000, 9500, 4000, 8000, 11000, 9000, 7000, 5000, 8000, 10000,
  5000
};

int[] novemberSteps = {
  7000, 12000, 9000, 11000, 5000, 9500, 10000, 6000, 8000, 10000,
  13000, 4000, 9000, 7000, 6000, 8000, 11000, 5000, 12000, 7000,
  5000, 11000, 9000, 8000, 9500, 6000, 12000, 7000, 8000, 10000
};

// Month display parameters
String[] octoberDates = generateDates("October", 31);
String[] novemberDates = generateDates("November", 30);

void setup() {
  size(1400, 600);
  
  // Load sound files
  lowStepSound = new SoundFile(this, "lowStep.mp3");
  moderateStepSound = new SoundFile(this, "moderateStep.mp3");
  highStepSound = new SoundFile(this, "highStep.mp3");
  
  noStroke();
}

void draw() {
  background(255);

  // Display October data
  displayStepData(octoberDates, octoberSteps, width / 4, height / 2, 40);
  
  // Display November data
  displayStepData(novemberDates, novemberSteps, width * 3 / 4, height / 2, 40);
}

// Function to display step data
void displayStepData(String[] dates, int[] steps, float xOffset, float yOffset, float daySpacing) {
  for (int i = 0; i < dates.length; i++) {
    int stepCount = steps[i];
    String date = dates[i];
    
    // Map step count to circle size (larger circles for more steps)
    float circleSize = map(stepCount, 3000, 13000, 20, 100);  // map step count to circle size
    
    // Set color based on step count (red for fewer steps, green for more)
    float colorValue = map(stepCount, 3000, 13000, 255, 0);  // Red to Green
    fill(colorValue, 255 - colorValue, 0, 150);  // RGB for transition from red to green
    
    // Calculate the position based on the index, in rows of 7
    float x = xOffset + (i % 7) * daySpacing;
    float y = yOffset + (i / 7) * daySpacing;

    // Draw the circle
    ellipse(x, y, circleSize, circleSize);
    
    // Show the date and step count when hovering over the circle
    if (dist(mouseX, mouseY, x, y) < circleSize / 2) {
      textAlign(CENTER);
      fill(0);
      textSize(12);
      text(date + ": " + stepCount + " steps", mouseX, mouseY);
    }

    // Play sound when clicking on a circle
    if (dist(mouseX, mouseY, x, y) < circleSize / 2 && mousePressed) {
      playStepSound(stepCount);
    }
  }
}

// Generate an array of dates for the month
String[] generateDates(String month, int daysInMonth) {
  String[] dates = new String[daysInMonth];
  for (int i = 0; i < daysInMonth; i++) {
    dates[i] = month + " " + (i + 1);
  }
  return dates;
}

// Function to play sound based on the step count
void playStepSound(int steps) {
  if (steps <= 6000) {
    lowStepSound.play();  // Play sound for low steps
  } else if (steps <= 10000) {
    moderateStepSound.play();  // Play sound for moderate steps
  } else {
    highStepSound.play();  // Play sound for high steps
  }
}
