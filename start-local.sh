#!/bin/bash
# Lädt Umgebungsvariablen aus .env und startet Backstage
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "✅ Umgebungsvariablen aus .env geladen."
else
  echo "⚠️ Keine .env Datei gefunden!"
fi

yarn start
