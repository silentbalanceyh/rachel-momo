#!/bin/bash

# check input
if [ -z "$1" ]; then
    echo "Usage: ./mvn-version.sh <version>"
    exit 1
fi

NEW_VERSION=$1
echo "Start to update version to $NEW_VERSION..."

# 1. mvn versions:set
mvn versions:set -DnewVersion=$NEW_VERSION

# 2. update properties in pom.xml
# For macOS, use sed -i ''
sed -i '' "s|<rachel-momo.version>.*</rachel-momo.version>|<rachel-momo.version>${NEW_VERSION}</rachel-momo.version>|g" pom.xml
sed -i '' "s|<r2mo.version>.*</r2mo.version>|<r2mo.version>${NEW_VERSION}</r2mo.version>|g" pom.xml

echo "Version updated to $NEW_VERSION successfully."

