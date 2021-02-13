#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Fonts/FreeSans9pt7b.h>
#include <ESP8266WiFi.h>

#include <DHT.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
// SCL and SDA pins should be: D1 and D2 (NodeMCU)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

WiFiClient client = WiFiClient();
#define DHT_PIN 12
#define DHT_TYPE DHT22

DHT dht = DHT(DHT_PIN, DHT_TYPE);

const int BUTTON_PIN = 13;
const int LED_PIN = 2;

bool IS_DOWN = false;
bool IS_CONNECTED = false;
bool LED = false;

void setup() {
    Serial.begin(115200);

    pinMode(LED_PIN, OUTPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP); 
    dht.begin();
    display.begin(SSD1306_SWITCHCAPVCC, 0x3C);

    WiFi.begin((char*)"SSID", (char*)"PASSWORD");
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print("...\n");
    }

    digitalWrite(LED_PIN, HIGH);
    display.clearDisplay();
    display.setTextColor(WHITE);
    display.setTextSize(1);
    display.setCursor(5, 5);
    display.println("READY TO CONNECT");
    display.display();
}

void loop() {
    int BUTTON_STATE = digitalRead(BUTTON_PIN);
    
    if (BUTTON_STATE == HIGH && IS_DOWN == false) {
        IS_DOWN = true;

        if (!client.connected()) {
            client.connect((char*)"IP_HOST", (uint16_t)6020);
            client.print("hello from esp 8266");
        }
        else {
            client.print("disconnected");
            client.stop();
        }
    }
    if (BUTTON_STATE == LOW && IS_DOWN == true) {
        IS_DOWN = false;
    }


    if (client.connected()) {
        char buffer[1024];
        String sentence = "";
        int id = 0;

        bool hasRead = false;
      
        if (client.available() > 0) {
            char c = (char)client.read();
            buffer[id] = c;
            id++;
            hasRead = true;
        }

        if (hasRead) {
            sentence += String((char)buffer[0]);
         

            if (sentence == "l") {
                if (LED) {
                    digitalWrite(LED_PIN, LOW);
                    display.clearDisplay();
                    display.setTextColor(WHITE);
                    display.setTextSize(1);
                    display.setCursor(5, 5);
                    display.println("LED OFF");
                    display.display();
                }
                else {
                    digitalWrite(LED_PIN, HIGH);
                    display.clearDisplay();
                    display.setTextColor(WHITE);
                    display.setTextSize(1);
                    display.setCursor(5, 5);
                    display.println("LED ON");
                    display.display();
                }
                LED = !LED;
            }
        }
    }
}