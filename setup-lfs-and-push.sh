#!/bin/bash
# PORTX Packages - Git LFS Setup and Push Script
# Activates Git LFS for zip files, commits and pushes all package zips

set -e  # Exit on any error

echo "🚀 PORTX Packages - Git LFS Setup and Push"
echo "==========================================="
echo

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Working directory: $SCRIPT_DIR"
echo

# Check if git lfs is available
if ! command -v git-lfs &> /dev/null; then
    echo "❌ Git LFS not found. Please install Git LFS first."
    exit 1
fi

echo "🔧 Setting up Git LFS for zip files..."

# Initialize Git LFS if not already done
git lfs install

# Track all zip files with Git LFS
git lfs track "*.zip"
git lfs track "packages/_zip/**/*.zip"

# Add .gitattributes file
git add .gitattributes

echo "✅ Git LFS configured for zip files"
echo

# Show LFS tracking status
echo "📋 LFS tracked file patterns:"
git lfs track
echo

# Count zip files
ZIP_COUNT=$(find . -name "*.zip" -type f | wc -l)
echo "📦 Found $ZIP_COUNT zip files to commit"
echo

# Add all files
echo "📝 Adding all files to git..."
git add .

# Show status
echo "📊 Git status:"
git status --short
echo

# Commit with descriptive message
echo "💾 Committing changes..."
git commit -m "Add PORTX package distribution with Git LFS

- Configure Git LFS for *.zip files
- Add 55 PORTX tool packages to releases/windows-amd64/
- Packages include: terraform, k9s, docker-compose, helm, etc.
- All packages properly versioned and organized
- Build scripts for package creation included

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✅ Changes committed successfully"
echo

# Push to remote
echo "🚀 Pushing to remote repository..."
git push origin main

echo
echo "✨ Git LFS setup and push completed successfully!"
echo "📦 All $ZIP_COUNT zip files have been pushed with LFS"
echo