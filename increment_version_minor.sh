#!/bin/bash

# Read the current version from the Dart file
current_version=$(grep -oP "(?<=const version = ').*?(?=')" bleed-common/lib/src/version.dart)

# Increment the version number
new_version=$(echo $current_version | awk -F. -v OFS=. '{$NF++;print}')

# Replace the old version with the new version in the Dart file
sed -i "s/$current_version/$new_version/" bleed-common/lib/src/version.dart

echo "Version number incremented from $current_version to $new_version"

# Add the changes to Git
git add -u
git add *

# Commit the changes with the new version number
git commit -m "$new_version"

# Pause at the end of the script
read -p "Press enter to exit"