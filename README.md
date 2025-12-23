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

### AWS Voraussetzungen
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
- **AWS CLI**


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
### Test 1 (Default-Bild):
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

### Fazit vom Test 1
Der erste Test wurde erfolgreich durchgeführt. Die hochgeladene Bilddatei wurde korrekt von der AWS Lambda Funktion verarbeitet und an den AWS Rekognition Service übergeben. AWS Rekognition erkannte die bekannte Person "Donald Trump" und lieferte eine hohe Wahrscheinlichkeit von 99.99568 %.

### Test 2 (eigenes Bild):
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

### Fazit vom Test 2
Der zweite Test wurde erfolgreich durchgeführt. Die hochgeladene Bilddatei wurde korrekt von der AWS Lambda Funktion verarbeitet und an den AWS Rekognition Service übergeben. AWS Rekognition erkannte die bekannte Person "Cristiano Ronaldo" und lieferte eine hohe Wahrscheinlichkeit von 99.99505 %.

## Reflexion
**Semir:**  
Projekt M346 – Wir hatten den Auftrag einen Cloud basierten Face Rekognition Service zu entwickeln, der mithilfe von AWS S3 Buckets, Lambda Funktion und Rekognition bekannte Persönlichkeiten auf hochgeladenen Bildern automatisch erkennt und die Ergebnisse als JSON-Datei speichert.
Zu Beginn hatten wir Schwierigkeiten, den Projektauftrag vollständig zu verstehen, was auch damit zusammenhing, dass mir der Einstieg in das Modul generell schwerfiel und viele Konzepte zunächst unklar waren. Dadurch fühlte ich mich am Anfang oft überfordert und unsicher. Durch Unterstützung von anderen Teams und dem Lehrer wurde der Ablauf klarer, wobei mir besonders der persönliche Austausch im Team geholfen hat, da komplexe Inhalte auf diese Weise deutlich verständlicher erklärt werden konnten.
Die technische Umsetzung verlief anfangs gut, jedoch traten beim Deployen der Lambda Funktion wiederholt Fehler auf, wodurch das init Skript abbrach. Diese anhaltenden Probleme führten dazu, dass meine anfängliche Motivation mit der Zeit nachliess und ich mich zunehmend verloren fühlte. Rückblickend hätte ich in dieser Phase früher um Hilfe bitten und konsequenter am Projekt dranbleiben sollen.
Nach mehreren erfolglosen Lösungsversuchen entschied ich mich, das Projekt neu aufzusetzen. Diese Entscheidung war im Nachhinein sinnvoll, da ich dadurch einen klareren Überblick über die Projektstruktur gewinnen konnte. Beim zweiten Versuch funktionierte die Inbetriebnahme und auch das test Skript einwandfrei, was mich sehr freute und mir neue Motivation gab.
Trotz der Tatsache, konnte ich aus diesem Projekt wichtige persönliche und organisatorische Erkenntnisse mitnehmen. Ich habe gelernt, wie wichtig Unterstützung im Team ist und dass es sinnvoll ist, Aufgaben entsprechend den Stärken und Schwächen der Teammitglieder zu verteilen. Zudem habe ich erkannt, dass es hilfreich ist, sich regelmässig mit Mitschülern auszutauschen, um einen besseren Überblick zu erhalten oder auf Probleme aufmerksam gemacht zu werden, die man selbst vielleicht übersehen hätte.
Für zukünftige Projekte wäre es sinnvoll, früher zu beginnen, um mehr Zeit für die Fehlersuche, eine bessere Zusammenarbeit im Team und eine strukturiertere Arbeitsweise zu ermöglichen

**Lionel:**  
Das Projekt M346 - FaceRecognition hat mir viele Schwierigkeiten bereitet, da ich es am Anfang überhaupt nicht verstanden habe. Das lag unter anderem daran, dass ich allgemein nicht sehr gut mit dem Modul zurechtgekommen bin. Aus diesem Grund hat hauptsächlich Semir an diesem Projekt gearbeitet, was mir sehr geholfen hat. Am Anfang war ich noch sehr motiviert und habe die ersten Commits gemacht, jedoch hat diese Motivation sehr schnell nachgelassen. Mit der Zeit habe ich vieles nicht mehr verstanden und mich zunehmend verloren gefühlt. Rückblickend hätte ich hier sicher dranbleiben und mir früher Hilfe holen sollen, um alles besser zu verstehen. Deshalb habe ich schlussendlich nicht sehr viel an diesem Projekt gearbeitet, was ich selbst Natürliche nicht gut finde. Trotzdem haben wir Semir dort unterstützt, wo wir konnten, was ich sehr gut fand und auch bei einem nächsten Projekt wieder so machen würde. Ich habe gelernt, dass Unterstützung im Team sehr wichtig ist und dass es einem viel leichter fällt, Dinge zu verstehen, wenn sie persönlich erklärt werden. Fachlich habe ich nicht sehr viel Neues dazugelernt, trotzdem hat mir das Projekt etwas gebracht. Ich habe verstanden, wie wichtig es ist, die Stärken und Schwächen der Teammitglieder zu erkennen und die Aufgaben sinnvoll zu verteilen. Ausserdem denke ich, dass man ein Projekt so früh wie möglich so weit wie möglich voranbringen sollte, da man nie weiss, was noch kommen kann. Ich habe auch gemerkt, dass es hilfreich ist, bei Mitschülern vorbeizuschauen oder sich mit ihnen auszutauschen, um einen besseren Überblick zu erhalten oder auf Dinge aufmerksam gemacht zu werden, auf die man selbst vielleicht nicht geachtet hätte. Zum Schluss habe ich gelernt, dass man sich nicht zu sehr stressen sollte. Am Ende findet sich meistens eine Lösung, und sich Hilfe zu holen ist sehr wichtig.

**Luis:**  
Das Projekt – FaceRecognition im Modul 364 war geprägt von unterschiedlichen Standpunkten im Bereich Verständnis innerhalb des Teams, Hilfestellung von anderen Klassenkameraden, Zeitdruck und vielen Errors, aber auch Teamwork und viel Schweissarbeit.
Vorab muss ich sagen, ich habe das Thema bis zu diesem Zeitpunkt immer noch nicht zu hundert Prozent im Griff. Ich verstehe die Grundlagen und auch sonst hier und da ein wenig, aber noch lange nicht so viel wie beispielsweise Semir. Ich war deshalb auch froh, dass Semir sich in diesem Belang darauf geeinigt hat, eine Art „führende Rolle“ im Projekt anzunehmen. Das war in dem Sinne, dass er daran arbeitete und uns dann Aufgaben oder Ähnliches gab, um ihn dabei zu unterstützen. Dieses Vorgehen war meiner und auch der Meinung des Teams nach die effizienteste Art, dies anzugehen. Ein Beispiel dieser gesteigerten Effizienz wäre, dass wir eine Ansprechperson hatten, wenn es um dieses Projekt ging. Anstatt dass es ein Hin-und-her-Schreiben und Fragen gewesen wäre, wäre es wirklich ein in drei geteiltes Projekt gewesen, hätte die Organisation und auch die Qualität ziemlich sicher darunter gelitten (vor allem, da es nur eines von drei Projekten war und wir dadurch sowieso sehr ausgelastet waren – alles, was es unkomplizierter machte, war willkommen).
Was unserem Team aber auch sehr geholfen hat, war die Hilfe von anderen Klassenkameraden, darunter vor allem Ivan und Mohammad. Sie halfen uns Primär bei der Fehlersuche und gaben uns auch ein paar hilfreiche Tipps, die uns in die richtige Richtung lenkten. Sie halfen uns also nicht direkt dabei, den gesamten Code zu schreiben, sondern eher dabei, unser Verständnis auszubauen.
Über das gesamte Projekt hinweg hatten wir mit «Errors» zu kämpfen, weshalb wir auch einmal von neu anfangen mussten. Das trug zwar dazu bei, unsere Motivation zu schmälern, aber dies konnten wir alles in allem auch bezwingen.
Ich würde sagen, dass wir ein stabiles Projekt abgegeben haben, das seine Vorgaben erfüllt. Ich habe aber trotzdem noch ein paar Verbesserungsvorschläge, damit es beim nächsten Mal auch ohne Zeitstress geht. In unserem Team fehlte von Anfang an ein wenig Wissen zum Thema, das zusammen mit Verwirrung im Bezug auf das Projekt hätte, so nicht vorkommen dürfen, das ist sicher mein grösster Verbesserungsvorschlag. Wir haben zwar durchgehend am Projekt gearbeitet, aber am Ende waren wir dann doch unter Zeitdruck. Was geholfen hätte, wäre, dass wir unsere Planung direkt von Anfang an gemacht hätten, mit klaren Meilensteinen. Ich denke, würden wir jetzt gerade nochmals so ein Projekt machen, hätten wir ganz sicher aus unseren Fehlern gelernt und würden es besser machen.
