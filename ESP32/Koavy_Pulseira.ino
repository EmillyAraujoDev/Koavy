/**
 * Koavy_Pulseira.ino - Firmware para Pulseira Inteligente Koavy
 * Desenvolvido para ESP32.
 * 
 * Funcionalidades:
 * - Conexão Wi-Fi com reconexão automática.
 * - Leitura de Sensor de Batimentos (Simulada para exemplo).
 * - Envio de dados via HTTPS POST para API PHP.
 * - Autenticação via Device Token.
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// Configurações Wi-Fi
const char* ssid = "SUA_REDE_WIFI";
const char* password = "SUA_SENHA_WIFI";

// Configurações API
const char* api_url = "http://143.106.241.4/koavy/api/public/batimentos";
const char* device_token = "COLE_O_TOKEN_JWT_AQUI";

// Pinos
const int SENSOR_PIN = 34; // Exemplo de pino analógico

void setup() {
  Serial.begin(115200);
  
  // Inicializa Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConectado!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // 1. Simulação de leitura de BPM (Substituir pela lógica real do sensor)
    int rawValue = analogRead(SENSOR_PIN);
    float bpm = map(rawValue, 0, 4095, 60, 180); // Simulação
    float saturacao = 98.5; // Simulação

    Serial.printf("BPM Lido: %.2f\n", bpm);

    // 2. Preparar JSON
    StaticJsonDocument<200> doc;
    doc["bpm"] = bpm;
    doc["saturacao"] = saturacao;
    doc["dispositivo_id"] = 1; // ID do dispositivo vinculado no banco

    String requestBody;
    serializeJson(doc, requestBody);

    // 3. Enviar para API
    HTTPClient http;
    http.begin(api_url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "Bearer " + String(device_token));

    int httpResponseCode = http.POST(requestBody);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Resposta da API: " + response);
    } else {
      Serial.print("Erro no envio: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("Wi-Fi desconectado. Tentando reconectar...");
    WiFi.begin(ssid, password);
  }

  // Intervalo de leitura (ajustável)
  delay(5000); 
}
