# Projekt M346
## Ablauf
Zuerst wird ein Bild in den definierten S3 Input Bucket hochgeladen. Dieser Upload löst automatisch eine AWS Lambda Funktion aus. Die Lambda Funktion liest das Bild aus dem Input Bucket und übergibt es an den AWS Rekognition Service zur Analyse. Rekognition erkennt bekannte Person auf dem Bild und liefert die Ergebnisse an die Lambda Funktion zurück. Anschliessend bereitet die Lambda Funktion die Analyseergebnisse auf und speichert sie als JSON Datei im S3 Output Bucket.

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

## Ziele
- Entwicklung eines Face Recognition Services mit zwei S3 Buckets und einer AWS Lambda Funktion
- Erkennung bekannter Personennamen auf Fotos und Speicherung der Analyse als JSON im Output Bucket
- Automatische Einrichtung des Services über ein Init Skript
- Versionierung aller Dateien in einem Git Repository
- Test des Services inklusive Testskript und Screenshot
