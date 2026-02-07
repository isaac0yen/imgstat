#!/bin/bash
PACKAGE_NAME="imagestat"
VERSION="1.0"
ARCH="all"
DEB_DIR="${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "Building .deb package for $PACKAGE_NAME..."

# Create directory structure
mkdir -p "$DEB_DIR/usr/local/bin"
mkdir -p "$DEB_DIR/DEBIAN"

# Determine source file (handle rename)
if [ -f "imagestat" ]; then
    cp imagestat "$DEB_DIR/usr/local/bin/$PACKAGE_NAME"
elif [ -f "imgstat.sh" ]; then
    cp imgstat.sh "$DEB_DIR/usr/local/bin/$PACKAGE_NAME"
else
    echo "Error: Source script not found (looked for 'imagestat' and 'imgstat.sh')."
    exit 1
fi

chmod 755 "$DEB_DIR/usr/local/bin/$PACKAGE_NAME"

# Create control file
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Allowed-Architectures: all
Maintainer: User <user@example.com>
Depends: imagemagick, wget
Description: Image dimensions scanner and renamer
 Recursively scans directories for images and renames them to include their 
 dimensions (e.g., image-800x600.jpg). Ignores heavy directories like node_modules.
EOF

# Build package
dpkg-deb --build "$DEB_DIR"

# Cleanup
mv "${DEB_DIR}.deb" "${PACKAGE_NAME}.deb" 2>/dev/null || true
rm -rf "$DEB_DIR"

echo "Build complete: ${PACKAGE_NAME}.deb"
echo "Install with: sudo apt install ./$PACKAGE_NAME.deb"
