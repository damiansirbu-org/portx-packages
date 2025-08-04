#!/bin/bash
# PORTX Package ZIP Creation Script
# Uses 7za with maximum compression for optimal binary file compression

# Use 7za64 from build/tools directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SEVENZIP="$SCRIPT_DIR/../tools/7za64.exe"

echo "🔧 Using 7za: $SEVENZIP"

# Check if 7za64 exists
if [[ ! -f "$SEVENZIP" ]]; then
    echo "❌ 7za64 not found at: $SEVENZIP"
    exit 1
fi

# Look for packages in portx-packages directory (source packages with VERSION.md)
PACKAGES_SOURCE="$SCRIPT_DIR/../../packages"

if [[ ! -d "$PACKAGES_SOURCE" ]]; then
    echo "❌ Source packages directory not found: $PACKAGES_SOURCE"
    exit 1
fi

cd "$PACKAGES_SOURCE" || exit 1

# Create releases directory structure  
mkdir -p "$SCRIPT_DIR/../../releases/windows-amd64"

# Function to validate package requirements
validate_package() {
    local package_dir="$1"
    local errors=0
    
    # Check for at least 1 .exe file
    if ! find "$package_dir" -name "*.exe" -type f | head -1 | grep -q .; then
        echo "   ❌ Missing: No .exe files found"
        ((errors++))
    fi
    
    # Check for VERSION.md
    if [[ ! -f "$package_dir/VERSION.md" ]]; then
        echo "   ❌ Missing: VERSION.md"
        ((errors++))
    fi
    
    # Check for package-manual.md
    if [[ ! -f "$package_dir/package-manual.md" ]]; then
        echo "   ❌ Missing: package-manual.md"
        ((errors++))
    fi
    
    return $errors
}

# Function to create ZIP for a package
create_package_zip() {
    local package_dir="$1"
    
    if [[ ! -d "$package_dir" ]]; then
        echo "❌ Package directory '$package_dir' not found"
        return 1
    fi
    
    echo "📦 Validating $package_dir..."
    
    # Validate package requirements
    if ! validate_package "$package_dir"; then
        echo "❌ Package '$package_dir' validation failed - skipping compression"
        return 1
    fi
    
    echo "✅ Package validation passed"
    echo "📦 Compressing $package_dir..."
    
    # Read version from VERSION.md
    local version="1.0.0"  # default version
    if [[ -f "$package_dir/VERSION.md" ]]; then
        version=$(cat "$package_dir/VERSION.md" | tr -d '\r\n' | head -1)
        echo "   📋 Version: $version"
    else
        echo "   ⚠️  No VERSION.md found, using default: $version"
    fi
    
    # Create directory structure: releases/windows-amd64/package_name/package_name-version-x64-windows.zip
    local releases_dir="$SCRIPT_DIR/../../releases/windows-amd64/$package_dir"
    mkdir -p "$releases_dir"
    
    local zip_filename="${package_dir}-${version}-x64-windows.zip"
    
    # Use 64-bit 7za64 to create ZIP files with maximum compression
    # -tzip: Create ZIP format (not 7z)
    # -mx9: Maximum compression level
    # -mmt: Use multiple threads
    echo "   Running: $SEVENZIP a -tzip -mx9 -mmt $releases_dir/${zip_filename} $package_dir/"
    "$SEVENZIP" a -tzip -mx9 -mmt "$releases_dir/${zip_filename}" "$package_dir/"
    
    if [[ $? -eq 0 ]]; then
        # Get compressed size
        local size=$(du -h "$releases_dir/${zip_filename}" | cut -f1)
        echo "✅ Created $releases_dir/${zip_filename} ($size)"
    else
        echo "❌ Failed to compress $package_dir (exit code: $?)"
        return 1
    fi
}

echo "🚀 Starting PORTX package compression..."
echo "Using 64-bit 7za64 with maximum ZIP compression"
echo

# Get all package directories
for dir in */; do
    # Skip the _zip directory itself
    if [[ "$dir" == "_zip/" ]]; then
        continue
    fi
    
    # Remove trailing slash
    package_name="${dir%/}"
    
    create_package_zip "$package_name"
done

echo
echo "📊 Compression Summary:"
echo "Total packages: $(ls -1d */ | wc -l)"
echo "Compressed archives: $(find "$SCRIPT_DIR/../../releases/windows-amd64" -name "*.zip" 2>/dev/null | wc -l)"
echo "Total compressed size: $(du -sh "$SCRIPT_DIR/../../releases/windows-amd64" 2>/dev/null | cut -f1 || echo "0")"
echo
echo "✨ Package compression complete!"