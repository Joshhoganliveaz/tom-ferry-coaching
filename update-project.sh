#!/bin/bash
# Update a project in the tracker from anywhere
# Usage: ~/Projects/Tom\ Ferry\ Coaching/update-project.sh <slug> key=value [key=value ...]
#
# Examples:
#   update-project.sh str-analyzer status=shipped deployedUrl=https://stranalyzer.vercel.app
#   update-project.sh idea-pipeline status=shipped currentVersion=1.1
#   update-project.sh contract-summary-template accessUrl="https://docs.google.com/..."
#
# Valid keys: status, currentVersion, deployedUrl, accessUrl, deployedDate, adoption, autonomy
# Status values: shipped, in_progress, parking_lot

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [ $# -lt 2 ]; then
  echo "Usage: update-project.sh <slug> key=value [key=value ...]"
  echo ""
  echo "Examples:"
  echo "  update-project.sh str-analyzer status=shipped"
  echo "  update-project.sh idea-pipeline deployedUrl=https://example.com"
  echo ""
  echo "Available slugs:"
  node -e "
    const d = JSON.parse(require('fs').readFileSync('projects.json','utf8'));
    d.projects.forEach(p => console.log('  ' + p.slug + ' (' + p.status + ')'));
  "
  exit 1
fi

SLUG="$1"
shift

# Build the update JS dynamically
UPDATES=""
COMMIT_PARTS=""
for arg in "$@"; do
  KEY="${arg%%=*}"
  VALUE="${arg#*=}"
  # null handling
  if [ "$VALUE" = "null" ]; then
    UPDATES="$UPDATES p['$KEY'] = null;"
  else
    UPDATES="$UPDATES p['$KEY'] = '$VALUE';"
  fi
  COMMIT_PARTS="$COMMIT_PARTS $KEY=$VALUE"
done

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('projects.json', 'utf8'));
const p = data.projects.find(p => p.slug === '$SLUG');
if (!p) { console.error('Project not found: $SLUG'); process.exit(1); }
$UPDATES
data.lastUpdated = new Date().toISOString().split('T')[0];
fs.writeFileSync('projects.json', JSON.stringify(data, null, 2) + '\n');
console.log('Updated ' + p.name + ':$COMMIT_PARTS');
"

# Sync inline data
node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('projects.json', 'utf8'));
const html = fs.readFileSync('index.html', 'utf8');
fs.writeFileSync('index.html', html.replace(/const PROJECT_DATA = .*?;/, 'const PROJECT_DATA = ' + JSON.stringify(data) + ';'));
console.log('Inline data synced');
"

# Commit and push
git add projects.json index.html
git commit -m "update($SLUG):$COMMIT_PARTS"
git push origin main

echo "Pushed and live in ~60s"
