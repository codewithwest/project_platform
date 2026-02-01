#include <WiFi.h>
#include <WiFiUdp.h>

WiFiUDP udp;
const int DNS_PORT = 53;

// Your home WiFi
const char *ssid = "";
const char *password = "";

// Domain → IP mapping table
typedef struct
{
  const char *domain;
  IPAddress ip;
} DomainMap;

DomainMap domainList[] = {
    {"jenkins.west", IPAddress(192, 168, 1, 20)},
    {"proxmox.west", IPAddress(192, 168, 100, 31)},
    {"argo.west", IPAddress(192, 168, 1, 1)}};

int domainCount = sizeof(domainList) / sizeof(domainList[0]);

IPAddress fallbackIP(192, 168, 1, 100);

// Extract domain name from DNS query packet
String readDomainName(uint8_t *buffer, int &index)
{
  String domain = "";
  while (true)
  {
    uint8_t len = buffer[index++];
    if (len == 0)
      break;

    for (int i = 0; i < len; i++)
    {
      domain += (char)buffer[index++];
    }
    domain += ".";
  }
  domain.remove(domain.length() - 1); // remove trailing dot
  return domain;
}

// Choose the IP for a given domain
IPAddress resolveDomain(const String &d)
{
  for (int i = 0; i < domainCount; i++)
  {
    if (d.equalsIgnoreCase(domainList[i].domain))
    {
      return domainList[i].ip;
    }
  }
  return fallbackIP;
}

void setup()
{
  Serial.begin(115200);
  delay(500);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(300);
    Serial.print(".");
  }
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  Serial.println("\nConnected!");

  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  udp.begin(DNS_PORT);
  Serial.println("DNS server running...");
}

void loop()
{
  int packetSize = udp.parsePacket();
  if (!packetSize)
    return;

  uint8_t packet[512];
  udp.read(packet, 512);

  int index = 12; // start of domain name in DNS query
  String domain = readDomainName(packet, index);

  Serial.print("DNS Query: ");
  Serial.println(domain);

  IPAddress ip = resolveDomain(domain);

  // build DNS response
  uint8_t response[512];
  memcpy(response, packet, packetSize);

  // set response flags: QR=1, Opcode=0, AA=1, TC=0, RD=1, RA=1
  response[2] = 0x81;
  response[3] = 0x80;

  // Answer count = 1
  response[7] = 1;

  // Write answer section
  int pos = packetSize;

  // pointer to domain name (0xC0 0x0C)
  response[pos++] = 0xC0;
  response[pos++] = 0x0C;

  // Type A
  response[pos++] = 0x00;
  response[pos++] = 0x01;

  // Class IN
  response[pos++] = 0x00;
  response[pos++] = 0x01;

  // TTL
  response[pos++] = 0x00;
  response[pos++] = 0x00;
  response[pos++] = 0x00;
  response[pos++] = 10;

  // data length = 4 bytes
  response[pos++] = 0x00;
  response[pos++] = 0x04;

  // write IP
  response[pos++] = ip[0];
  response[pos++] = ip[1];
  response[pos++] = ip[2];
  response[pos++] = ip[3];

  udp.beginPacket(udp.remoteIP(), udp.remotePort());
  udp.write(response, pos);
  udp.endPacket();

  Serial.print(" → Replied: ");
  Serial.println(ip);
}
