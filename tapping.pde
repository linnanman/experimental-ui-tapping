import ketai.sensors.*;

KetaiSensor sensor;
ArrayList<Double> previousSizes = new ArrayList<Double>();
double averageAcc = 0.0;
boolean calibrating = true;
int previousMilliseconds = 0;
boolean tapped = false;

void setup()
{
  sensor = new KetaiSensor(this);
  sensor.setDelayInterval(10);
  sensor.start();
  orientation(LANDSCAPE);
  textAlign(CENTER, CENTER);
  textSize(36);
}

void draw()
{
  background(0, 0, 0);
  if (calibrating) {
    text("Calibrating...", 0, 0, width, height);
  } else {
    if (tapped) {
      text("Tap!", 0, 0, width, height);
      if (millis() - previousMilliseconds > 120) {
        tapped = false;
      }
    }
  }
}

void onAccelerometerEvent(float x, float y, float z)
{
  double size = z;
  if (calibrating) {
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
    if (Math.abs(size - averageAcc) > 2.0) {
      if (!tapped) {
        tapped = true;
        previousMilliseconds = millis();
      }
    }
  }
}