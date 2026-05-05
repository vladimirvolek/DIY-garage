// Stepper driver pins
const int PUL = 25;
const int DIR = 26;
const int ENA = 27;

// Endstop pins (active HIGH via INPUT_PULLUP + switch to VCC,
// or wire as needed and flip ENDSTOP_ACTIVE below)
const int END_LEFT = 23;
const int END_RIGHT = 22;
const int ENDSTOP_ACTIVE = HIGH;

// DIR pin levels — verify against your wiring
const int DIR_LEFT = HIGH;
const int DIR_RIGHT = LOW;

// Motion tuning
const unsigned int PULSE_HALF_PERIOD_US = 300; // step rate
const long EDGE_GAP = 1000;                    // pulses kept away from endstops in normal run
const long MIN_TRAVEL = 4 * EDGE_GAP;          // sanity: rail must be longer than this
const int DEBOUNCE_READS = 4;                  // consecutive reads required to accept endstop
const unsigned int DEBOUNCE_DELAY_US = 50;

enum Direction
{
  LEFT,
  RIGHT
};

enum State
{
  CALIB_SEEK_LEFT,  // moving left until END_LEFT triggers
  CALIB_SEEK_RIGHT, // moving right until END_RIGHT triggers, counting pulses
  RUNNING,          // bouncing between EDGE_GAP and maxPulseCount - EDGE_GAP
  FAULT             // motor disabled, halted
};

long pulseCount = 0;
long maxPulseCount = 0;
Direction direction = LEFT;
State state = CALIB_SEEK_LEFT;

void setMotorEnabled(bool on)
{
  // Most common drivers: ENA LOW = enabled. Flip if your driver differs.
  digitalWrite(ENA, on ? LOW : HIGH);
}

void setDirection(Direction d)
{
  direction = d;
  digitalWrite(DIR, d == LEFT ? DIR_LEFT : DIR_RIGHT);
}

bool endstopTriggered(int pin)
{
  for (int i = 0; i < DEBOUNCE_READS; i++)
  {
    if (digitalRead(pin) != ENDSTOP_ACTIVE)
      return false;
    delayMicroseconds(DEBOUNCE_DELAY_US);
  }
  return true;
}

void enterFault(const char *reason)
{
  setMotorEnabled(false);
  state = FAULT;
  Serial.print("FAULT: ");
  Serial.println(reason);
}

void stepOnce()
{
  digitalWrite(PUL, HIGH);
  delayMicroseconds(PULSE_HALF_PERIOD_US);
  digitalWrite(PUL, LOW);
  delayMicroseconds(PULSE_HALF_PERIOD_US);

  if (direction == RIGHT)
    pulseCount++;
  else
    pulseCount--;
}

void setup()
{
  pinMode(PUL, OUTPUT);
  pinMode(DIR, OUTPUT);
  pinMode(ENA, OUTPUT);
  pinMode(END_LEFT, INPUT_PULLUP);
  pinMode(END_RIGHT, INPUT_PULLUP);

  Serial.begin(9600);
  delay(50);

  // Wiring sanity: both endstops active at boot is impossible in a healthy rig.
  if (endstopTriggered(END_LEFT) && endstopTriggered(END_RIGHT))
  {
    enterFault("both endstops active at boot");
    return;
  }

  setMotorEnabled(true);
  setDirection(LEFT);
  state = CALIB_SEEK_LEFT;
  Serial.println("Calibrating: seeking left endstop");
}

void loop()
{
  if (state == FAULT)
  {
    delay(1000);
    return;
  }

  bool leftHit = endstopTriggered(END_LEFT);
  bool rightHit = endstopTriggered(END_RIGHT);

  // Both endstops simultaneously → wiring/mechanical fault
  if (leftHit && rightHit)
  {
    enterFault("both endstops active");
    return;
  }

  switch (state)
  {
  case CALIB_SEEK_LEFT:
    if (leftHit)
    {
      pulseCount = 0;
      setDirection(RIGHT);
      state = CALIB_SEEK_RIGHT;
      Serial.println("Left endstop hit; seeking right endstop");
    }
    break;

  case CALIB_SEEK_RIGHT:
    if (rightHit)
    {
      maxPulseCount = pulseCount;
      Serial.print("Right endstop hit; travel = ");
      Serial.print(maxPulseCount);
      Serial.println(" pulses");

      if (maxPulseCount < MIN_TRAVEL)
      {
        enterFault("travel too short for EDGE_GAP");
        return;
      }

      setDirection(LEFT);
      state = RUNNING;
      Serial.println("Calibrated; running");
    }
    else if (leftHit)
    {
      // Should have left END_LEFT already; stuck switch or backwards motor.
      enterFault("left endstop still active while seeking right");
      return;
    }
    break;

  case RUNNING:
    // Endstop hit during normal run = lost steps / mechanical slip.
    if ((leftHit && direction == LEFT) || (rightHit && direction == RIGHT))
    {
      Serial.println("Unexpected endstop during run; recalibrating");
      setDirection(LEFT);
      state = CALIB_SEEK_LEFT;
      return;
    }

    if (direction == RIGHT && pulseCount >= maxPulseCount - EDGE_GAP)
    {
      setDirection(LEFT);
    }
    else if (direction == LEFT && pulseCount <= EDGE_GAP)
    {
      setDirection(RIGHT);
    }
    break;

  default:
    break;
  }

  stepOnce();
}
