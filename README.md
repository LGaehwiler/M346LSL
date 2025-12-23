# Projekt M346
## Projektübersicht
### Ziele
- Bereitstellung eines FaceRecognition-Services mit AWS Rekognition (Celebrity Recognition)
- Automatische Analyse von Fotos über zwei S3-Buckets (Input/Output)
- Bereitstellung im AWS Learner Lab über ein Script
- Versionierung aller Dateien im Git-Repository
- Dokumentation inkl. Testprotokollen in Markdown

### Lösungskonzept
Zuerst wird ein Bild in den definierten S3 Input Bucket hochgeladen. Dieser Upload löst automatisch eine AWS Lambda Funktion aus. Die Lambda Funktion liest das Bild aus dem Input Bucket und übergibt es an den AWS Rekognition Service zur Analyse. Rekognition erkennt bekannte Person auf dem Bild und liefert die Ergebnisse an die Lambda Funktion zurück. Anschliessend bereitet die Lambda Funktion die Analyseergebnisse auf und speichert sie als JSON Datei im S3 Output Bucket.

### Aufbau
- Übersicht der AWS-Komponente
  - S3 Input Bucket (face-bucket-in)
  - Lambda Funktion
  - AWS Rekognition
  - S3 Output Bucket (face-bucket-out)

## Projektstruktur
```
M346_Projekt/
├── ImageAnalysLambda/
│      └── src/
│           └── ImageAnalysLambda/
│                   ├── Function.cs
│                   ├── ImageAnalysLambda.csproj
│                   ├── Readme.md
│                   └── aws-lambda-tools-defaults.json
│
├── ImageAnalysLambda/
│      └── test/
│           └── ImageAnalysLambda/
│                   ├── FunctionTest.cs
│                   └── ImageAnalysLambda.Tests.csproj
│
├── test/
│     ├── test
│     └── Trump.jpg
│
├── init.sh
├── test.sh
├── Readme.md
└── M346_Projekt.docx
```


## Voraussetzungen
### Linux VM
- Linux VM Ubuntu
- Firewall (Internetzugang)

### Visual Studio Code (C#)
Diese Punkte (Packages) müssen in Visual Studio Code installiert werden
- using System;
- using System.IO;
- using System.Text.Json;
- using System.Threading.Tasks;
- using Amazon.Lambda.Core;
- using Amazon.Lambda.S3Events;
- using Amazon.Rekognition;
- using Amazon.Rekognition.Model;
- using Amazon.S3;

### AWS CLI
- AWS Account
- Konfiguriertes AWS CLI Profil:
```bash
aws configure
```
- IAM Rolle LabRole

### Amazon Lambda Tools
- Amazon.Lambda.Tools, sollten eigentlich automatisch vom init.sh Skript installiert werden

### Benötigte Software
- **.NET SDK 8.0**
- **jq**, nur für schön formatierte Ausgabe


## Installation / Inbetriebnahme
Die Installation / Inbetriebnahme und die Tests basiert auf einer Linux VM!

**1. GIT Repository clonen**
```
git clone https://github.com/LGaehwiler/M346LSL.git
cd M346LSL
```
Bitte beachten Sie, dass für die Ausführung des Projekts die AWS CLI installiert ```aws configure``` sein muss. Zusätzlich wird das .NET SDK in der Version 8.0 benötigt, damit das Lambda‑Projekt korrekt gebaut und deployt werden kann. Ausserdem sollten die Amazon.Lambda.Tools installiert sein, was normalerweise über den Befehl ```dotnet tool install -g Amazon.Lambda.Tools``` erfolgt. Falls dieses Tool noch nicht vorhanden ist, wird es automatisch durch das Skript init.sh installiert. Für eine übersichtliche und formattierte Darstellung von JSON‑Ausgaben wird ausserdem empfohlen, das Tool jq zu installieren.

**2. Skripte ausführbar machen**
```
chmod +x init.sh
chmod +x test.sh
```

**3. Initialisierung starten**
```
./init.sh
```

Beim init.sh passiert genau folgendes:
1. Voraussetzungen prüfen und Tools installieren
2. AWS Region konfigurieren
3. S3 Buckets erstellen
4. Lambda Funktion deployen
5. Berechtigung für S3 setzen
6. S3 Trigger einrichten
7. .env Datei erstellen

Am Schluss erscheint eine Zusammenfassung des init.sh mit:
- Speicherort der .env Datei
- Der Region
- Der Name des Input Bucket
- Der Name des Output Bucket
- Lambda Name
- Lambda ARN


## Verwendung / Tests ##
**Mit Default-Bild ausführen**
```
./test.sh
```

**Mit eigenem Bild ausführen**
```
./test.sh Pfad/zu/deinem/Bild.jpg
```

Beim test.sh passiert genau folgendes:
1. Lädt die Konfiguration aus der .env Datei
2. Prüft ob Default Bild vorhanden
3. Lädt das Bild in den S3 Input Bucket hoch
4. Lambda Funktion wird ausgeführt
5. Prüft, ob das JSON Ergebnis im Output Bucket existiert
6. Lädt das Ergebnis lokal herunter
7. Gibt die erkannte Person aus

## Ergebnis / Output ##
**Test Nummer 1 (Default-Bild):**
```
{
  "SourceImage": {
    "Bucket": "face-bucket-in-vmadmin-1766478728",
    "Key": "Trump.jpg"
  },
  "Celebrities": [
    {
      "Name": "Donald Trump",
      "MatchConfidence": 99.99568,
      "Id": "I4ma5e",
      "Urls": [
        "www.wikidata.org/wiki/Q22686",
        "www.imdb.com/name/nm0874339"
      ]
    }
  ],
  "UnrecognizedFaces": 0,
  "OrientationCorrection": null,
  "ProcessedAtUtc": "2025-12-23T08:33:03.004996Z"
}
```

### Testergebnis
T1: Trump.jpg --> "Donald Trump" ekrannt 

### Testprotokoll
**Testperson:** Semir Dehari  
**Datum:** 23.12.2025  
**Uhrzeit:** 08:30 - 08:35 Uhr  
**System:** Linux Ubuntu VM

**Test Nummer 2 (eigenes Bild):**
```
{
  "SourceImage": {
    "Bucket": "face-bucket-in-vmadmin-1766478728",
    "Key": "Ronaldo.jpg"
  },
  "Celebrities": [
    {
      "Name": "Cristiano Ronaldo",
      "MatchConfidence": 99.99505,
      "Id": "2we3qf",
      "Urls": [
        "www.wikidata.org/wiki/Q11571",
        "www.imdb.com/name/nm1860184"
      ]
    }
  ],
  "UnrecognizedFaces": 0,
  "OrientationCorrection": null,
  "ProcessedAtUtc": "2025-12-23T08:33:49.6238481Z"
}
```

### Testergebnis
T2: Ronaldo.jpg --> "Cristiano Ronaldo" erkannt

### Testprotokoll
**Testperson:** Semir Dehari  
**Datum:** 23.12.2025  
**Uhrzeit:** 08:30 - 08:35 Uhr  
**System:** Linux Ubuntu VM
