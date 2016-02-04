import ketai.sensors.*;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;

Context context;

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
PImage icon;
double latestSize;

MediaPlayer sound;

void setup()
{
  context = this.getActivity().getApplicationContext();
  sound = new MediaPlayer();
  try {
    AssetFileDescriptor afd = context.getAssets().openFd("trainhorn.wav");
    sound.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
    sound.prepare();
  } catch (IOException e) {
    print(e.getMessage());
  }

  latestSize = 0;
  logo = loadImage("logo.png");
  icon = loadImage("fingerprint.png");
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
  fill(255, 255, 255);
  imageMode(CENTER);
  image(icon, width / 2, 3 * height / 4, (int)(100 + 100 * latestSize), (int)(100 + 100 * latestSize));

  image(logo, width / 2, height / 4);
  if (alert == true) {
    // Tempo limit achieved, alert!
    sound.start();
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
  
  latestSize = Math.abs(size - averageAcc);
}