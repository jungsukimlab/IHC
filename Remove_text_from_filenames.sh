#!/bin/bash

# ============================
# User-configurable variables
# Change the TARGER_DIR to your desire directory/folder
# write the part of the text (TEXT_TO_REMOVE) that you want to remove
# ============================

# Directory containing the files
TARGET_DIR="/Volumes/KimLab_MRI5/SAA_KI_ASPA_MBP_NeuN_20260116/Raw_4_Channel_Merge/WT_SAA_KI_VEHICLE"

# Text to remove from filenames (must match exactly)
TEXT_TO_REMOVE="Slide 1-4_TileScan 2_"

# ============================
# Script logic
# ============================

# Check directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory does not exist: $TARGET_DIR"
    exit 1
fi

cd "$TARGET_DIR" || exit 1

echo "Preview of changes:"
echo "-------------------"

# Dry run: show what will be renamed
for file in *; do
    new_name="${file//$TEXT_TO_REMOVE/}"
    if [[ "$file" != "$new_name" ]]; then
        echo "  $file  ->  $new_name"
    fi
done

echo
read -p "Proceed with renaming? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

# Perform renaming
for file in *; do
    new_name="${file//$TEXT_TO_REMOVE/}"
    if [[ "$file" != "$new_name" ]]; then
        mv -i -- "$file" "$new_name"
    fi
done

echo "Done."
