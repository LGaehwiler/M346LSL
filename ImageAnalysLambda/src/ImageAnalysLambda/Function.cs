/*
Projekt: M346 Image Analys Lambda
Datei: Function.cs
Autor: Semir Dehari, Luis Strunk, Lionel Gähwiler
Datum: 22.12.2025
*/
using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.Lambda.Core;
using Amazon.Lambda.S3Events;
using Amazon.Rekognition;
using Amazon.Rekognition.Model;
using Amazon.S3;

// Gibt an, welcher JSON-Serializer für die Lambda verwendet wird
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ImageAnalysLambda;

/// <summary>
/// Hauptklasse der Lambda-Funktion.
/// Diese Klasse wird von AWS Lambda instanziert.
/// </summary>
public class Function
{
    // Client für AWS Rekognition (Personenerkennung)
    private readonly IAmazonRekognition _rekClient;

    // Client für AWS S3 (lesen & schreiben von Dateien)
    private readonly IAmazonS3 _s3Client;

    // Name des Output-Buckets (aus Environment Variable)
    private readonly string _oBucket;

    /// <summary>
    /// Standard-Konstruktor.
    /// Wird von AWS Lambda verwendet.
    /// Erstellt automatisch die AWS Clients.
    /// </summary>
    public Function()
        : this(new AmazonRekognitionClient(), new AmazonS3Client())
    {
    }

    /// <summary>
    /// Konstruktor mit Dependency Injection.
    /// </summary>
    public Function(IAmazonRekognition rekognitionClient, IAmazonS3 s3Client)
    {
        _rekClient = rekognitionClient;
        _s3Client = s3Client;

        // Liest den Namen des Output-Buckets aus der Environment Variable
        _oBucket = Environment.GetEnvironmentVariable("O_BUCKET") ?? string.Empty;
    }

    /// <summary>
    /// Haupteinstiegspunkt der Lambda-Funktion.
    /// Wird automatisch ausgelöst, wenn ein Objekt in den Input-S3-Bucket hochgeladen wird.
    /// </summary>
    /// <param name="s3Event">Das S3-Event mit Informationen zum hochgeladenen Objekt.</param>
    /// <param name="context">Lambda-Kontext (Logging, Request-ID, etc.).</param>
    public async Task FunctionHandler(S3Event s3Event, ILambdaContext context)
    {
        // Sicherheitsprüfung: Output-Bucket muss gesetzt sein
        if (string.IsNullOrWhiteSpace(_oBucket))
        {
            context.Logger.LogError("Environment variable O_BUCKET is not set. Aborting.");
            return;
        }

        // Verarbeitung aller S3-Event-Einträge (meist nur einer)
        foreach (var record in s3Event.Records)
        {
            // Name des Input-Buckets
            var bucketName = record.S3.Bucket.Name;

            // Dateiname des hochgeladenen Bildes
            var objectKey = record.S3.Object.Key;

            context.Logger.LogInformation($"New image received: Bucket={bucketName}, Key={objectKey}");

            try
            {
                // Rekognition-Request vorbereiten
                // Das Bild liegt in einem S3-Bucket
                var request = new RecognizeCelebritiesRequest
                {
                    Image = new Image
                    {
                        S3Object = new Amazon.Rekognition.Model.S3Object
                        {
                            Bucket = bucketName,
                            Name = objectKey
                        }
                    }
                };

                // AWS Rekognition aufrufen (Prominenten-Erkennung)
                var response = await _rekClient.RecognizeCelebritiesAsync(request);

                // Ergebnisobjekt zusammenstellen
                var result = new
                {
                    // Infos zum analysierten Bild
                    SourceImage = new
                    {
                        Bucket = bucketName,
                        Key = objectKey
                    },

                    // Liste erkannter Prominenter
                    Celebrities = response.CelebrityFaces.ConvertAll(c => new
                    {
                        c.Name,                 // Name der Person
                        c.MatchConfidence,      // Erkennungswahrscheinlichkeit
                        c.Id,                   // Rekognition-ID
                        Urls = c.Urls,          // Referenz-URLs     
                    }),

                    // Anzahl nicht erkannter Gesichter
                    UnrecognizedFaces = response.UnrecognizedFaces.Count,

                    // Bildausrichtung (z. B. gedreht)
                    OrientationCorrection = response.OrientationCorrection,

                    // Zeitpunkt der Verarbeitung
                    ProcessedAtUtc = DateTime.UtcNow
                };

                // Ergebnis als formatiertes JSON serialisieren
                var json = JsonSerializer.Serialize(
                    result,
                    new JsonSerializerOptions { WriteIndented = true }
                );

                // Dateiname ohne Endung ermitteln
                var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(objectKey);

                // JSON-Dateiname erzeugen
                var outputKey = $"{fileNameWithoutExtension}.json";

                // JSON-Ergebnis in den Output-Bucket schreiben
                await _s3Client.PutObjectAsync(new Amazon.S3.Model.PutObjectRequest
                {
                    BucketName = _oBucket,
                    Key = outputKey,
                    ContentBody = json,
                    ContentType = "application/json"
                });

                context.Logger.LogInformation(
                    $"Analysis successfully written to: Bucket={_oBucket}, Key={outputKey}");
            }
            catch (Exception ex)
            {
                // Fehlerbehandlung: Fehler wird geloggt, Lambda stürzt nicht komplett ab
                context.Logger.LogError($"Error processing object {bucketName}/{objectKey}: {ex}");
            }
        }
    }
}
