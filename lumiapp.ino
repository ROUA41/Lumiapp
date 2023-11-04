#include <WiFi.h>
#include <WebServer.h>

#define PIN_RED    23 // GPIO23
#define PIN_GREEN  22 // GPIO22
#define PIN_BLUE   21 // GPIO21

const char* ssid = "ooredooBAA949";
const char* password = "916C937E69";

WebServer server(80);
bool isLEDOn = false; // Variable pour suivre l'état de la LED
String currentColor; // Couleur actuelle de la LED (représentée en RRGGBB)

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }

  Serial.println("Connected to WiFi");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  pinMode(PIN_RED, OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BLUE, OUTPUT);

  server.on("/on", handleLEDOn);
  server.on("/color", handleColorChange);

  server.begin();
}

void loop() {
  server.handleClient();
}

void handleLEDOn() {
  String color = server.arg("color");

  // Allumer ou éteindre la LED avec la couleur spécifiée
  isLEDOn = (color != "000000"); // Vérifiez si la couleur est différente de "000000" (pas de couleur)
  setColor(color, isLEDOn);

  server.send(200, "text/plain", "LED turned on with color: " + color);
}

void handleColorChange() {
  String color = server.arg("color");
  isLEDOn = (color != "000000"); // Vérifiez si la couleur est différente de "000000" (pas de couleur)
  setColor(color, isLEDOn);
  server.send(200, "text/plain", "LED color changed to: " + color);
}

void setColor(String hexColor, bool isLEDOn) {
  if (isLEDOn) {
    // Utiliser les sous-chaînes de l'hexColor pour obtenir les valeurs RVB
    uint8_t r = strtoul(hexColor.substring(0, 2).c_str(), NULL, 16);
    uint8_t g = strtoul(hexColor.substring(2, 4).c_str(), NULL, 16);
    uint8_t b = strtoul(hexColor.substring(4, 6).c_str(), NULL, 16);
    analogWrite(PIN_RED, r);
    analogWrite(PIN_GREEN, g);
    analogWrite(PIN_BLUE, b);
  } else {
    // Éteindre la LED en définissant toutes les broches RVB à LOW
    analogWrite(PIN_RED, 0);
    analogWrite(PIN_GREEN, 0);
    analogWrite(PIN_BLUE, 0);
  }
}
