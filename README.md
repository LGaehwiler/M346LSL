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
1. GIT Repository clonen
```
git clone https://github.com/LGaehwiler/M346LSL.git
```
