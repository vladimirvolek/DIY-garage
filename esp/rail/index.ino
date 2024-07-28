// int PUL = 25; // define Pulse pin
// int DIR = 26; // define Direction pin
// int ENA = 27; // define Enable Pin

// void setup()
// {
//   pinMode(PUL, OUTPUT);
//   pinMode(DIR, OUTPUT);
//   pinMode(ENA, OUTPUT);
// }

// void loop()
// {
//   // Forward steps
//   digitalWrite(ENA, LOW); // Enable the motor by setting ENA to LOW
//   digitalWrite(DIR, LOW); // Set direction to forward
//   for (int i = 0; i < 6400; i++)
//   {
//     digitalWrite(PUL, HIGH);
//     delayMicroseconds(50);
//     digitalWrite(PUL, LOW);
//     delayMicroseconds(50);
//   }

//   // Backward steps
//   digitalWrite(ENA, LOW);  // Enable the motor by setting ENA to LOW
//   digitalWrite(DIR, HIGH); // Set direction to backward
//   for (int i = 0; i < 6400; i++)
//   {
//     digitalWrite(PUL, HIGH);
//     delayMicroseconds(50);
//     digitalWrite(PUL, LOW);
//     delayMicroseconds(50);
//   }
// }

// int END_1 = 22;
// int END_2 = 23;

// void setup()
// {
//   pinMode(END_1, INPUT_PULLUP);
//   pinMode(END_2, INPUT_PULLUP);

//   pinMode(STEPPER, LOW)

//       Serial.begin(9600);
// }

// void loop()
// {

//   if (digitalRead(END_1) == LOW)
//   {
//     // Serial.println("End stop triggered, LOW");
//   }
//   else
//   {
//     Serial.println("End stop 1 triggered, HIGH");
//   }

//   if (digitalRead(END_2) == LOW)
//   {
//     // Serial.println("End stop triggered, LOW");
//   }
//   else
//   {
//     Serial.println("End stop 2 triggered, HIGH");
//   }
// }

// #include <AccelStepper.h>
// #include <Preferences.h>
// #include <WiFi.h>
// #include <PubSubClient.h>

// Preferences preferences;

// #define DIR_PIN 2
// #define STEP_PIN 3
// #define END_STOP_LEFT_PIN 4
// #define END_STOP_RIGHT_PIN 5

// #define END_STOP_DEFAULT_STATE LOW
// #define STEP_COUNT_KEY "step_count"
// #define HOMING_DIRECTION_KEY "homing_dir"
// #define LAST_DIRECTION_KEY "last_dir"

// AccelStepper stepper(AccelStepper::DRIVER, STEP_PIN, DIR_PIN);

// long currentPosition = 0;
// long maxPosition = 0;
// bool movingRight = true;
// char lastHomingDirection;
// bool continueMovement = false;

// // WiFi credentials
// const char *ssid = "your_SSID";
// const char *password = "your_PASSWORD";

// // MQTT broker settings
// const char *mqtt_server = "your_mqtt_broker_address";
// const int mqtt_port = 1883;
// const char *mqtt_user = "your_mqtt_username";     // if needed
// const char *mqtt_password = "your_mqtt_password"; // if needed

// WiFiClient espClient;
// PubSubClient client(espClient);

// void setup()
// {
//   Serial.begin(115200);

//   pinMode(END_STOP_LEFT_PIN, INPUT_PULLUP);
//   pinMode(END_STOP_RIGHT_PIN, INPUT_PULLUP);

//   preferences.begin("stepper", false);

//   stepper.setMaxSpeed(1000);
//   stepper.setAcceleration(500);

//   // Connect to WiFi
//   setup_wifi();

//   // Connect to MQTT
//   client.setServer(mqtt_server, mqtt_port);
//   client.setCallback(callback);

//   while (!client.connected())
//   {
//     reconnect();
//   }

//   // Retrieve the last saved position and direction from non-volatile storage
//   currentPosition = preferences.getLong(STEP_COUNT_KEY, 0);
//   lastHomingDirection = preferences.getChar(HOMING_DIRECTION_KEY, 'L');
//   movingRight = preferences.getBool(LAST_DIRECTION_KEY, true);
//   stepper.setCurrentPosition(currentPosition);

//   // Move to the saved position
//   stepper.moveTo(currentPosition);
//   while (stepper.distanceToGo() != 0)
//   {
//     stepper.run();
//   }

//   // Determine the max position by moving to the right end stop
//   determineMaxPosition();

//   // Publish initial position
//   publishPosition();
// }

// void loop()
// {
//   if (!client.connected())
//   {
//     reconnect();
//   }
//   client.loop();

//   if (continueMovement)
//   {
//     if (movingRight)
//     {
//       stepper.moveTo(maxPosition);

//       if (digitalRead(END_STOP_RIGHT_PIN) == LOW)
//       {
//         stepper.setCurrentPosition(maxPosition);
//         movingRight = false;
//         savePosition();
//         continueMovement = false;
//       }
//     }
//     else
//     {
//       stepper.moveTo(0);
//       if (digitalRead(END_STOP_LEFT_PIN) == LOW)
//       {
//         stepper.setCurrentPosition(0);
//         movingRight = true;
//         savePosition();
//         continueMovement = false;
//       }
//     }

//     stepper.run();
//     currentPosition = stepper.currentPosition();
//     publishPosition();
//   }
// }

// void savePosition()
// {
//   preferences.putLong(STEP_COUNT_KEY, currentPosition);
//   preferences.putBool(LAST_DIRECTION_KEY, movingRight);
// }

// void homeMotorLeft()
// {
//   stepper.setSpeed(-500);

//   while (digitalRead(END_STOP_LEFT_PIN) != LOW)
//   {
//     stepper.runSpeed();
//   }

//   stepper.setCurrentPosition(0);
//   movingRight = true;

//   savePosition();
//   preferences.putChar(HOMING_DIRECTION_KEY, 'L');
// }

// void homeMotorRight()
// {
//   stepper.setSpeed(500);
//   while (digitalRead(END_STOP_RIGHT_PIN) != LOW)
//   {
//     stepper.runSpeed();
//   }
//   maxPosition = stepper.currentPosition();
//   stepper.setCurrentPosition(maxPosition);
//   movingRight = false;

//   savePosition();
//   preferences.putChar(HOMING_DIRECTION_KEY, 'R');
// }

// void determineMaxPosition()
// {
//   stepper.setSpeed(500);

//   while (digitalRead(END_STOP_RIGHT_PIN) != LOW)
//   {
//     stepper.runSpeed();
//   }

//   maxPosition = stepper.currentPosition();

//   stepper.setSpeed(-500);

//   while (digitalRead(END_STOP_LEFT_PIN) != LOW)
//   {
//     stepper.runSpeed();
//   }

//   stepper.setCurrentPosition(0);

//   savePosition();
// }

// void setup_wifi()
// {
//   delay(10);
//   Serial.println();
//   Serial.print("Connecting to ");
//   Serial.println(ssid);

//   WiFi.begin(ssid, password);

//   while (WiFi.status() != WL_CONNECTED)
//   {
//     delay(500);
//     Serial.print(".");
//   }

//   Serial.println("");
//   Serial.println("WiFi connected");
//   Serial.println("IP address: ");
//   Serial.println(WiFi.localIP());
// }

// void reconnect()
// {
//   while (!client.connected())
//   {
//     Serial.print("Attempting MQTT connection...");
//     if (client.connect("ESP32Client", mqtt_user, mqtt_password))
//     {
//       Serial.println("connected");
//       client.subscribe("stepper/control");
//     }
//     else
//     {
//       Serial.print("failed, rc=");
//       Serial.print(client.state());
//       Serial.println(" try again in 5 seconds");
//       delay(5000);
//     }
//   }
// }

// void callback(char *topic, byte *payload, unsigned int length)
// {
//   String message;
//   for (unsigned int i = 0; i < length; i++)
//   {
//     message += (char)payload[i];
//   }

//   if (message == "left")
//   {
//     movingRight = false;
//     continueMovement = false;
//     stepper.moveTo(0);
//   }
//   else if (message == "right")
//   {
//     movingRight = true;
//     continueMovement = false;
//     stepper.moveTo(maxPosition);
//   }
//   else if (message == "continue")
//   {
//     continueMovement = true;
//   }
//   else if (message == "reset")
//   {
//     homeMotorLeft();
//     continueMovement = true;
//   }
// }

// void publishPosition()
// {
//   String pos = String(currentPosition);
//   client.publish("stepper/position", pos.c_str());
// }
