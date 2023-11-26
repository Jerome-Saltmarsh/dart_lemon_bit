#!/bin/bash

# Read the current version from the file
current_version=$(cat version.txt)

# Increment the version number
new_version=$(echo $current_version | awk -F. -v OFS=. '{++$NF; print}')

# Write the new version back to the file
echo $new_version > version.txt

echo "Version incremented. New version: $new_version"

# Add the changes to Git
git add -u
git add *

# Commit the changes with the new version number
git commit -m "$new_version"

git push

echo "yes"
