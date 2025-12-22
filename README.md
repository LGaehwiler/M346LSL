# Projekt M346
## Projektübersicht
### Ziele
- Bereitstellung eines FaceRecognition-Services mit AWS Rekognition (Celebrity Recognition)
- Automatische Analyse von Fotos über zwei S3-Buckets (Input/Output)
- Bereitstellung im AWS Learner Lab über ein Script
- Versionierung aller Dateien im Git-Repository
- Dokumentation inkl. Testprotokollen in Markdown

### Ablauf
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
- Voraussetzungen prüfen und Tools installieren
- AWS Region konfigurieren
- S3 Buckets erstellen
- Lambda Funktion deployen
- Berechtigung für S3 setzen
- S3 Trigger einrichten
- .env Datei erstellen

Am Schluss erscheint eine Zusammenfassung des init.sh mit:
- Speicherort der .env Datei
- Der Region
- Der Name des Input Bucket
- Der Name des Output Bucket
- Lambda Name
- Lambda ARN

## Verwendung / Tests ##
