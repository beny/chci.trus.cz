#!/bin/bash
# build_and_deploy.sh
# A script to build the project and deploy updated documentation to GitHub

set -e  # Exit immediately if a command exits with a non-zero status

echo "🚀 Starting build..."
ignite build

echo "🧹 Cleaning old docs..."
rm -rf docs/

echo "📦 Moving new build to docs/..."
mv Build docs

echo "📄 Copying CNAME file..."
cp CNAME docs/CNAME

echo "📬 Committing and pushing changes..."
git add -A
if git diff --cached --quiet; then
    echo "✅ Nothing changed, nothing to commit."
    exit 0
fi
git commit -m "Update links [skip ci]"
git push

echo "✅ Deployment complete!"

