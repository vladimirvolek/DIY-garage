#include <AccelStepper.h>
#include <Preferences.h>

Preferences preferences;

#define DIR_PIN 2
#define STEP_PIN 3
#define END_STOP_LEFT_PIN 4
#define END_STOP_RIGHT_PIN 5

#define END_STOP_DEFAULT_STATE LOW
#define STEP_COUNT_KEY "step_count"

AccelStepper stepper(AccelStepper::DRIVER, STEP_PIN, DIR_PIN);

long currentPosition = 0;
long maxPosition = 0;
bool movingRight = true;

void setup()
{
  Serial.begin(115200);

  pinMode(END_STOP_LEFT_PIN, INPUT_PULLUP);
  pinMode(END_STOP_RIGHT_PIN, INPUT_PULLUP);

  preferences.begin("stepper", false);

  stepper.setMaxSpeed(1000);
  stepper.setAcceleration(500);

  // Prompt user for homing direction
  Serial.println("Homing direction? (L for left, R for right)");
  while (!Serial.available())
    ;
  char homingDirection = Serial.read();

  if (homingDirection == 'L' || homingDirection == 'l')
  {
    homeMotorLeft();
  }
  else if (homingDirection == 'R' || homingDirection == 'r')
  {
    homeMotorRight();
  }
  else
  {
    Serial.println("Invalid input, defaulting to home left.");
    homeMotorLeft();
  }

  // Retrieve the last saved position from non-volatile storage
  currentPosition = preferences.getLong(STEP_COUNT_KEY, 0);
  stepper.setCurrentPosition(currentPosition);

  // Move to the saved position
  stepper.moveTo(currentPosition);
  while (stepper.distanceToGo() != 0)
  {
    stepper.run();
  }

  // Determine the max position by moving to the right end stop
  determineMaxPosition();
}

void loop()
{
  if (movingRight)
  {
    stepper.moveTo(maxPosition);

    if (digitalRead(END_STOP_RIGHT_PIN) == LOW)
    {
      stepper.setCurrentPosition(maxPosition);
      movingRight = false;
      savePosition();
    }
  }
  else
  {
    stepper.moveTo(0);
    if (digitalRead(END_STOP_LEFT_PIN) == LOW)
    {
      stepper.setCurrentPosition(0);
      movingRight = true;
      savePosition();
    }
  }

  stepper.run();

  currentPosition = stepper.currentPosition();
}

void savePosition()
{
  preferences.putLong(STEP_COUNT_KEY, currentPosition);
}

// moving to the left
void homeMotorLeft()
{
  stepper.setSpeed(-500);

  while (digitalRead(END_STOP_LEFT_PIN) != LOW)
  {
    stepper.runSpeed();
  }

  stepper.setCurrentPosition(0);

  savePosition();
}

void homeMotorRight()
{
  // Move to right end stop to home the motor
  stepper.setSpeed(500);
  while (digitalRead(END_STOP_RIGHT_PIN) != LOW)
  {
    stepper.runSpeed();
  }
  maxPosition = stepper.currentPosition();
  stepper.setCurrentPosition(maxPosition);
  savePosition();
}

// Move to right end stop to determine max position
void determineMaxPosition()
{
  stepper.setSpeed(500);

  while (digitalRead(END_STOP_RIGHT_PIN) != LOW)
  {
    stepper.runSpeed();
  }

  maxPosition = stepper.currentPosition();

  // Return to left end stop to start
  stepper.setSpeed(-500);

  while (digitalRead(END_STOP_LEFT_PIN) != LOW)
  {
    stepper.runSpeed();
  }

  stepper.setCurrentPosition(0);

  savePosition();
}
