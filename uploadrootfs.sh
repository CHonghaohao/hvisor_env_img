#!/bin/bash

# Configuration parameters
SOURCE_FILE="rootfs1.ext4"     # Source file to compress
VOLUME_SIZE="1024m"            # Set volume size variable
TAG_NAME="v2025.03.04"         # Release tag name
RELEASES_NAME="v2025.03.04"
REPO_NAME="CHonghaohao/hvisor_env_img"      # GitHub repository name (format: owner/repo)
ZIP_PARTS=("rootfs1.zip.001" "rootfs1.zip.002" "rootfs1.zip.003") # Split archive files array
IMAGE_FILE="Image"      # Release tag name  # linux Image file name

# Color definitions
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'  # No Color

# ------------------ Split archives ------------------ #
# Check and install 7zip if needed
if ! command -v 7za &> /dev/null; then
    echo -e "${BLUE}Installing p7zip-full...${NC}"
    sudo apt-get update -qq && sudo apt-get install -y p7zip-full || {
        echo -e "${RED}Failed to install p7zip-full! Please install manually:\nsudo apt install p7zip-full${NC}"
        exit 1
    }
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: Source file $SOURCE_FILE not found!${NC}"
    exit 1
fi

# Create split archives if they don't exist
if [ ! -f "${ZIP_PARTS}" ]; then
    echo -e "${BLUE}Creating split archives from $SOURCE_FILE...${NC}"
    7za a -tzip -v${VOLUME_SIZE} "rootfs1.zip" "$SOURCE_FILE" || {
        echo -e "${RED}Compression failed! Possible reasons:\n1. Insufficient disk space\n2. Corrupted source file${NC}"
        exit 1
    }
    echo -e "${GREEN}Successfully created split archives:\n$(ls -lh rootfs1.zip.*)${NC}"
else
    echo -e "${YELLOW}Existing split archives found, skipping compression${NC}"
fi

# ------------------ Upload split archives and Image ------------------ #
# Initialize Git repository (if not exists)
if [ ! -d .git ]; then
    git init
    git remote add origin "https://github.com/$REPO_NAME.git"
fi

# Verify split archive files
for file in "${ZIP_PARTS[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: File $file does not exist!"
    exit 1
  fi
done

# check if Image file exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo -e "${RED}Error: Image file $IMAGE_FILE not found!${NC}"
    exit 1
fi

# Create Git tag (if not exists)
if ! git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
  git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
  git push origin "$TAG_NAME"
fi

# Create or update Release
gh release create "$TAG_NAME" \
  --title "$RELEASES_NAME" \
  --notes "Contains roofs1.zip split archives and Image" \
  "${ZIP_PARTS[@]}" "$IMAGE_FILE" || {
  echo "Appending files to existing Release..."
  gh release upload "$TAG_NAME" "${ZIP_PARTS[@]}"
}

# Verify upload results
all_files=("${ZIP_PARTS[@]}" "$IMAGE_FILE")
for file in "${all_files[@]}"; do
  if ! gh release view "$TAG_NAME" --repo "$REPO_NAME" --json assets | grep -q "$file"; then
    echo -e "${RED}File $file upload failed! Please retry manually${NC}"
    exit 1
  fi
done

echo -e "${GREEN}All split archive files have been successfully uploaded to Release $TAG_NAME${NC}"