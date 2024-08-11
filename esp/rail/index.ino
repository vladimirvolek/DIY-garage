int PUL = 25;
int DIR = 26;
int ENA = 27;

int END_LEFT = 23;
int END_RIGHT = 22;

int pulseCount = 0;
int maxPulseCount = 0;
int hranice = 1000;
String smer = "leva"; // Initial direction is left
bool isCalibrated = false;

void setup()
{
  pinMode(PUL, OUTPUT);
  pinMode(DIR, OUTPUT);
  pinMode(ENA, OUTPUT);

  pinMode(END_LEFT, INPUT_PULLUP);
  pinMode(END_RIGHT, INPUT_PULLUP);

  digitalWrite(ENA, LOW); // Enable the motor driver

  Serial.begin(9600);
  digitalWrite(DIR, HIGH); // Start by moving left
}

void calibrate()
{
  if (digitalRead(END_LEFT) == HIGH)
  {
    // Hit left end stop, reset pulse count and move right
    Serial.println("Narazili jsme na koncak vlevo");
    pulseCount = 0;
    digitalWrite(DIR, LOW); // Change direction to right
    smer = "prava";
  }

  if (digitalRead(END_RIGHT) == HIGH)
  {
    // Hit right end stop, set max pulse count and prepare to move left
    Serial.println("Narazili jsme na koncak vpravo");
    maxPulseCount = pulseCount;
    Serial.print("Max Pulse Count: ");
    Serial.println(maxPulseCount);
    pulseCount = maxPulseCount; // Reset to max pulse count for accurate movement
    digitalWrite(DIR, HIGH);    // Change direction to left
    smer = "leva";
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
    if (pulseCount >= (maxPulseCount - hranice))
    {
      // Reverse direction to left when approaching the right threshold
      smer = "leva";
      digitalWrite(DIR, HIGH);
    }
    else if (pulseCount <= hranice)
    {
      // Reverse direction to right when approaching the left threshold
      smer = "prava";
      digitalWrite(DIR, LOW);
    }
  }

  // Move the motor
  digitalWrite(PUL, HIGH);
  delayMicroseconds(200);
  digitalWrite(PUL, LOW);
  delayMicroseconds(200);

  // Increment or decrement pulse count based on direction
  if (smer == "prava")
  {
    pulseCount++;
  }
  else
  {
    pulseCount--;
  }
}
