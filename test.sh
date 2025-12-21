#!/usr/bin/env bash
set -euo pipefail

# ========================================
# Env-Datei laden
# ========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "FEHLER: Env-Datei nicht gefunden. Bitte zuerst init.sh ausführen."
  exit 1
fi

source "$ENV_FILE"

# ========================================
# Testbild
# ========================================
DEFAULT_IMAGE="$REPO_ROOT/test-data/test.jpg"
IMAGE_PATH="${1:-$DEFAULT_IMAGE}"

if [ ! -f "$IMAGE_PATH" ]; then
    echo "FEHLER: Bild '$IMAGE_PATH' existiert nicht."
    echo "Verwendung: ./test.sh /pfad/zum/bild.jpg"
    exit 1
fi

FILE_NAME=$(basename "$IMAGE_PATH")
BASE_NAME="${FILE_NAME%.*}"
OUTPUT_JSON="${BASE_NAME}.json"

echo "==> Lade Bild in Input-Bucket:"
echo "    s3://$INPUT_BUCKET/$FILE_NAME"
aws s3 cp "$IMAGE_PATH" "s3://$INPUT_BUCKET/$FILE_NAME" --region "$AWS_REGION"

echo "Upload abgeschlossen. Warte auf Lambda-Analyse..."

# ========================================
# Ergebnis abwarten
# ========================================
MAX_TRIES=20
SLEEP=3
COUNT=0

while [ $COUNT -lt $MAX_TRIES ]; do
    if aws s3 ls "s3://$OUTPUT_BUCKET/$OUTPUT_JSON" --region "$AWS_REGION" >/dev/null 2>&1; then
        echo "Analyse abgeschlossen."
        break
    fi
    COUNT=$((COUNT + 1))
    sleep $SLEEP
done

if [ $COUNT -ge $MAX_TRIES ]; then
    echo "FEHLER: Kein Ergebnis im Output-Bucket gefunden."
    exit 1
fi

# ========================================
# Ergebnis herunterladen
# ========================================
RESULT_DIR="$REPO_ROOT/results"
mkdir -p "$RESULT_DIR"
LOCAL_JSON="$RESULT_DIR/$OUTPUT_JSON"

aws s3 cp "s3://$OUTPUT_BUCKET/$OUTPUT_JSON" "$LOCAL_JSON" --region "$AWS_REGION"

echo
echo "======================================="
echo "Analyse-Ergebnis gespeichert unter:"
echo "$LOCAL_JSON"
echo "======================================="

# ========================================
# Erkannte Personen anzeigen
# ========================================
if command -v jq >/dev/null 2>&1; then
    echo "Erkannte Personen:"
    jq -r '.Celebrities[].Name' "$LOCAL_JSON" || echo "Keine Personen erkannt."
else
    echo "Hinweis: jq nicht installiert – zeige Roh-JSON:"
    cat "$LOCAL_JSON"
fi
