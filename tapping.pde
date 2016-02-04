import ketai.sensors.*;

int ALERT_LIMIT = 4;
int DAMPENING_MILLISECONDS = 120;

KetaiSensor sensor;
ArrayList<Double> previousSizes = new ArrayList<Double>();
double averageAcc = 0.0;
boolean calibrating = true;

int previousMilliseconds = 0;
boolean tapped = false;

boolean newSecond = false;
int tapsPerSecond = 0;
boolean alert = false;

PImage logo;

void setup()
{
  logo = loadImage("logo.png");
  sensor = new KetaiSensor(this);
  sensor.setDelayInterval(10);
  sensor.start();
  textAlign(CENTER, CENTER);
  textSize(36);
  
  // Start timer thread, runs every 1000 milliseconds
  thread("timer");
}

void draw()
{
  background(0, 0, 0);
  imageMode(CENTER);
  image(logo, width / 2, height / 4);
  if (alert == true) {
    // Tempo limit achieved, alert!
    text("Alert!", 0, 0, width, height);
    return;
  }
  if (calibrating) {
    text("Calibrating...", 0, 0, width, height);
  } else {
    if (tapped) {
      text("Tap!", 0, 0, width, height);
      if (millis() - previousMilliseconds > DAMPENING_MILLISECONDS) {
        tapped = false;
      }
    }
  }
  if (newSecond == true) {
    newSecond = false;
    if (tapsPerSecond > ALERT_LIMIT) {
      alert = true;
    }
    tapsPerSecond = 0;
    thread("timer");
  }
}

void timer() {
  delay(1000);
  newSecond = true;
}

void onAccelerometerEvent(float x, float y, float z)
{
  double size = z;
  if (calibrating) {
    // Calibrate accelerometer
    if (previousSizes.size() >= 50) {
      calibrating = false;
    }
    previousSizes.add(size);
    double sum = 0.0;
    for (double sizeSample : previousSizes) {
      sum += sizeSample;
    }
    averageAcc = sum / previousSizes.size();
  } else {
    if (Math.abs(size - averageAcc) > 1.9) {
      if (!tapped) {
        tapped = true;
        previousMilliseconds = millis();
        ++tapsPerSecond;
      }
    }
  }
}