int PUL = 25;
int DIR = 26;
int ENA = 27;

int END_LEFT = 23;
int END_RIGHT = 22;

int pulseCount = 0;
int maxPulseCount = 0;
int edge_gap = 1000;
String direction = "left";
bool isCalibrated = false;

void setup()
{
  pinMode(PUL, OUTPUT);
  pinMode(DIR, OUTPUT);
  pinMode(ENA, OUTPUT);

  pinMode(END_LEFT, INPUT_PULLUP);
  pinMode(END_RIGHT, INPUT_PULLUP);

  // Enable the motor driver
  digitalWrite(ENA, LOW);

  Serial.begin(9600);

  // Start by moving left
  digitalWrite(DIR, HIGH);
}

void calibrate()
{
  if (digitalRead(END_LEFT) == HIGH)
  {
    Serial.println("Narazili jsme na koncak vlevo");
    pulseCount = 0;
    digitalWrite(DIR, LOW);
    direction = "right";
  }

  if (digitalRead(END_RIGHT) == HIGH)
  {
    maxPulseCount = pulseCount;
    pulseCount = maxPulseCount;

    digitalWrite(DIR, HIGH);

    direction = "left";
    isCalibrated = true;
  }
}

void loop()
{
  if (!isCalibrated)
  {
    calibrate();
  }
  else
  {
    // Normal operation after calibration
    if (pulseCount >= (maxPulseCount - edge_gap))
    {
      // Reverse direction to left when approaching the right threshold
      direction = "left";
      digitalWrite(DIR, HIGH);
    }
    else if (pulseCount <= edge_gap)
    {
      // Reverse direction to right when approaching the left threshold
      direction = "right";
      digitalWrite(DIR, LOW);
    }
  }

  // Move the motor
  digitalWrite(PUL, HIGH);
  delayMicroseconds(300);
  digitalWrite(PUL, LOW);
  delayMicroseconds(300);

  // Increment or decrement pulse count based on direction
  if (direction == "right")
  {
    pulseCount++;
  }
  else
  {
    pulseCount--;
  }
}
