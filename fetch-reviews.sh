#!/bin/bash
# Henter Google-anmeldelser for Bolli Motor AS via Places API
#
# OPPSETT:
# 1. Gå til https://console.cloud.google.com/
# 2. Opprett et prosjekt (eller velg eksisterende)
# 3. Aktiver "Places API" under APIs & Services > Library
# 4. Opprett en API-nøkkel under APIs & Services > Credentials
# 5. Lim inn nøkkelen nedenfor og kjør:  bash fetch-reviews.sh

API_KEY="${1:-DIN_API_NOKKEL_HER}"

if [ "$API_KEY" = "DIN_API_NOKKEL_HER" ]; then
  echo ""
  echo "Bruk:  bash fetch-reviews.sh DIN_API_NOKKEL"
  echo ""
  echo "Slik får du en API-nøkkel:"
  echo "  1. Gå til https://console.cloud.google.com/"
  echo "  2. Opprett prosjekt → Aktiver 'Places API'"
  echo "  3. Credentials → Create API Key"
  echo ""
  exit 1
fi

echo "Søker etter Bolli Motor AS..."

# Steg 1: Finn Place ID
SEARCH_RESULT=$(curl -s "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=Bolli+Motor+AS+Lyngstad&inputtype=textquery&fields=place_id,name,formatted_address&key=$API_KEY")

PLACE_ID=$(echo "$SEARCH_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['candidates'][0]['place_id'])" 2>/dev/null)

if [ -z "$PLACE_ID" ]; then
  echo "Fant ikke Bolli Motor AS. API-respons:"
  echo "$SEARCH_RESULT"
  exit 1
fi

echo "Funnet! Place ID: $PLACE_ID"
echo ""

# Steg 2: Hent detaljer med anmeldelser
DETAILS=$(curl -s "https://maps.googleapis.com/maps/api/place/details/json?place_id=$PLACE_ID&fields=name,rating,user_ratings_total,reviews&reviews_sort=newest&language=no&key=$API_KEY")

# Lagre rå JSON
echo "$DETAILS" > /Users/oscarnaas/bolli-motor-forslag/reviews.json
echo "Rå JSON lagret i reviews.json"
echo ""

# Vis anmeldelsene lesbart
python3 -c "
import json, sys

with open('/Users/oscarnaas/bolli-motor-forslag/reviews.json') as f:
    data = json.load(f)

result = data.get('result', {})
print(f\"Bedrift: {result.get('name', 'Ukjent')}\")
print(f\"Rating: {result.get('rating', '?')} / 5 ({result.get('user_ratings_total', '?')} anmeldelser)\")
print('=' * 60)

for i, review in enumerate(result.get('reviews', []), 1):
    print(f\"\n--- Anmeldelse {i} ---\")
    print(f\"Navn: {review.get('author_name', 'Anonym')}\")
    print(f\"Stjerner: {'★' * review.get('rating', 0)}{'☆' * (5 - review.get('rating', 0))}\")
    print(f\"Tid: {review.get('relative_time_description', '')}\")
    print(f\"Tekst: {review.get('text', '(ingen tekst)')}\")
"
