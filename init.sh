#!/usr/bin/env bash
set -euo pipefail

# ========================================
# Repo-Verzeichnis
# ========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ========================================
# Konfiguration
# ========================================
AWS_REGION="${AWS_REGION:-us-east-1}"
LAMBDA_NAME="${LAMBDA_NAME:-Image-Analys-Lambda}"
ROLE_NAME="${ROLE_NAME:-LabRole}"

# Bucket-Namen müssen global einzigartig sein
SUFFIX="$(whoami)-$(date +%s)"
INPUT_BUCKET="${INPUT_BUCKET:-face-bucket-in-$SUFFIX}"
OUTPUT_BUCKET="${OUTPUT_BUCKET:-face-bucket-out-$SUFFIX}"

# Lambda-Projektpfad repo-relativ
PROJECT_DIR="$REPO_ROOT/M346_Projekt/ImageAnalysLambda/src/ImageAnalysLambda"

# Env-Datei für test.sh
ENV_FILE="$REPO_ROOT/.env"

echo "==> Repo-Root: $REPO_ROOT"
echo "==> Region:    $AWS_REGION"
echo "==> Input-Bucket:  $INPUT_BUCKET"
echo "==> Output-Bucket: $OUTPUT_BUCKET"
echo "==> Lambda:        $LAMBDA_NAME"

# ========================================
# Voraussetzungen prüfen
# ========================================
command -v aws >/dev/null 2>&1 || { echo "FEHLER: aws CLI fehlt"; exit 1; }
command -v dotnet >/dev/null 2>&1 || { echo "FEHLER: dotnet SDK fehlt"; exit 1; }

# ========================================
# dotnet tools PATH & Amazon.Lambda.Tools
# ========================================
export PATH="$PATH:$HOME/.dotnet/tools"

if ! command -v dotnet-lambda >/dev/null 2>&1; then
  echo "==> Installiere Amazon.Lambda.Tools (dotnet-lambda) ..."
  dotnet tool install -g Amazon.Lambda.Tools >/dev/null
fi

# ========================================
# Region setzen
# ========================================
aws configure set region "$AWS_REGION"
echo "Region gesetzt auf $AWS_REGION"

# ========================================
# S3 Buckets prüfen/erstellen
# ========================================
for BUCKET in "$INPUT_BUCKET" "$OUTPUT_BUCKET"; do
    if aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; then
        echo "Bucket $BUCKET existiert bereits."
    else
        echo "Bucket $BUCKET existiert nicht, erstelle..."
        aws s3 mb "s3://$BUCKET" --region "$AWS_REGION"
    fi
done

# ========================================
# Lambda deployen
# ========================================
echo "Deploy der Lambda-Funktion $LAMBDA_NAME..."
cd "$PROJECT_DIR"

dotnet lambda deploy-function "$LAMBDA_NAME" \
  --function-role "$ROLE_NAME" \
  --region "$AWS_REGION" \
  --environment-variables "O_BUCKET=$OUTPUT_BUCKET"

# ========================================
# Lambda ARN holen
# ========================================
LAMBDA_ARN=$(aws lambda get-function \
  --function-name "$LAMBDA_NAME" \
  --region "$AWS_REGION" \
  --query 'Configuration.FunctionArn' \
  --output text)
echo "Lambda ARN: $LAMBDA_ARN"

# ========================================
# Lambda Berechtigung für S3 setzen
# ========================================
STATEMENT_ID="s3invoke-$(echo -n "$INPUT_BUCKET" | tr -cd 'a-zA-Z0-9' | tail -c 32)"
aws lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --region "$AWS_REGION" \
  --statement-id "$STATEMENT_ID" \
  --action lambda:InvokeFunction \
  --principal s3.amazonaws.com \
  --source-arn "arn:aws:s3:::$INPUT_BUCKET" \
  >/dev/null 2>&1 || echo "Berechtigung existiert bereits."

# ========================================
# S3 Trigger setzen
# ========================================
aws s3api put-bucket-notification-configuration \
  --bucket "$INPUT_BUCKET" \
  --notification-configuration "{
    \"LambdaFunctionConfigurations\": [
      {\"LambdaFunctionArn\": \"$LAMBDA_ARN\", \"Events\": [\"s3:ObjectCreated:*\"]}
    ]
  }"

# ========================================
# Env-Datei für test.sh schreiben
# ========================================
cat > "$ENV_FILE" <<EOF
AWS_REGION=$AWS_REGION
INPUT_BUCKET=$INPUT_BUCKET
OUTPUT_BUCKET=$OUTPUT_BUCKET
LAMBDA_NAME=$LAMBDA_NAME
LAMBDA_ARN=$LAMBDA_ARN
EOF

echo
echo "========================================"
echo "Init abgeschlossen!"
echo "Env-Datei: $ENV_FILE"
echo "Region:    $AWS_REGION"
echo "Input Bucket:     $INPUT_BUCKET"
echo "Output Bucket:    $OUTPUT_BUCKET"
echo "Lambda Name:      $LAMBDA_NAME"
echo "Lambda ARN:       $LAMBDA_ARN"
echo "========================================"
