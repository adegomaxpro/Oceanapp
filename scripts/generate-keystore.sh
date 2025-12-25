#!/bin/bash
# ==============================================================================
# OCEAN PATH - Keystore Generation Script (Bash)
# ==============================================================================
# This script generates a JKS keystore for signing Android applications.
# 
# SECURITY NOTICE:
# - This script does NOT collect any system information, IP address, or location data.
# - This script does NOT auto-fill any values.
# - All inputs are manually provided by the user.
# - Generated keystore should NEVER be committed to version control.
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}================================================================================${NC}"
echo -e "${CYAN}  OCEAN PATH - Android Keystore Generator${NC}"
echo -e "${CYAN}================================================================================${NC}"
echo ""
echo -e "${YELLOW}This script will generate a JKS keystore for signing your Android application.${NC}"
echo -e "${YELLOW}Please provide your company/organization details below.${NC}"
echo ""
echo -e "${GREEN}SECURITY NOTICE:${NC}"
echo -e "${GREEN}  - This script does NOT collect system information or personal data.${NC}"
echo -e "${GREEN}  - All values are provided manually by you.${NC}"
echo -e "${GREEN}  - Never commit the generated keystore to version control.${NC}"
echo ""

# ==============================================================================
# USER INPUT - Company Details (7+ fields as required)
# ==============================================================================

echo -e "${MAGENTA}--- Company/Organization Details ---${NC}"
echo ""

# 1. Common Name (CN) - Company/App Name
read -p "1. Common Name (CN) - Your company or app name: " common_name
if [ -z "$common_name" ]; then
    echo -e "${RED}Error: Common Name is required.${NC}"
    exit 1
fi

# 2. Organizational Unit (OU)
read -p "2. Organizational Unit (OU) - Department (e.g., Mobile Development): " org_unit
if [ -z "$org_unit" ]; then
    echo -e "${RED}Error: Organizational Unit is required.${NC}"
    exit 1
fi

# 3. Organization (O)
read -p "3. Organization (O) - Company/Organization name: " organization
if [ -z "$organization" ]; then
    echo -e "${RED}Error: Organization is required.${NC}"
    exit 1
fi

# 4. City/Locality (L)
read -p "4. City/Locality (L) - City name: " city
if [ -z "$city" ]; then
    echo -e "${RED}Error: City is required.${NC}"
    exit 1
fi

# 5. State/Province (ST)
read -p "5. State/Province (ST) - State or province name: " state
if [ -z "$state" ]; then
    echo -e "${RED}Error: State/Province is required.${NC}"
    exit 1
fi

# 6. Country Code (C)
read -p "6. Country Code (C) - Two-letter code (e.g., US, UK, DE): " country
if [ -z "$country" ] || [ ${#country} -ne 2 ]; then
    echo -e "${RED}Error: Country Code must be exactly 2 letters.${NC}"
    exit 1
fi

# 7. Email Address
read -p "7. Email Address - Contact email for the certificate: " email
if [ -z "$email" ]; then
    echo -e "${RED}Error: Email Address is required.${NC}"
    exit 1
fi

echo ""
echo -e "${MAGENTA}--- Keystore Credentials ---${NC}"
echo ""

# 8. Key Alias
read -p "8. Key Alias - Unique identifier for the key (e.g., oceanpath-release): " key_alias
if [ -z "$key_alias" ]; then
    echo -e "${RED}Error: Key Alias is required.${NC}"
    exit 1
fi

# 9. Keystore Password (hidden input)
echo -n "9. Keystore Password - Password for the keystore file (min 6 characters): "
read -s keystore_password
echo ""
if [ -z "$keystore_password" ] || [ ${#keystore_password} -lt 6 ]; then
    echo -e "${RED}Error: Keystore Password must be at least 6 characters.${NC}"
    exit 1
fi

# 10. Key Password (hidden input)
echo -n "10. Key Password - Password for the key itself (min 6 characters): "
read -s key_password
echo ""
if [ -z "$key_password" ] || [ ${#key_password} -lt 6 ]; then
    echo -e "${RED}Error: Key Password must be at least 6 characters.${NC}"
    exit 1
fi

# 11. Validity Period
read -p "11. Validity Period (years) - Recommended: 25 for Play Store [25]: " validity_years
validity_years=${validity_years:-25}
validity_days=$((validity_years * 365))

echo ""
echo -e "${CYAN}================================================================================${NC}"
echo -e "${CYAN}  Generating Keystore...${NC}"
echo -e "${CYAN}================================================================================${NC}"
echo ""

# ==============================================================================
# GENERATE KEYSTORE
# ==============================================================================

keystore_file="oceanpath-release.jks"
dname="CN=$common_name, OU=$org_unit, O=$organization, L=$city, ST=$state, C=$country, EMAILADDRESS=$email"

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}Error: 'keytool' command not found.${NC}"
    echo -e "${RED}Please ensure Java JDK is installed and added to PATH.${NC}"
    exit 1
fi

# Remove existing keystore if present
if [ -f "$keystore_file" ]; then
    rm -f "$keystore_file"
fi

# Generate the keystore
keytool -genkeypair -v \
    -keystore "$keystore_file" \
    -alias "$key_alias" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$validity_days" \
    -storetype JKS \
    -dname "$dname" \
    -storepass "$keystore_password" \
    -keypass "$key_password" 2>/dev/null

# Verify keystore was created
if [ ! -f "$keystore_file" ]; then
    echo -e "${RED}Error: Keystore file was not created.${NC}"
    exit 1
fi

echo -e "${GREEN}Keystore generated successfully!${NC}"
echo ""

# ==============================================================================
# ENCODE TO BASE64
# ==============================================================================

echo -e "${YELLOW}Encoding keystore to Base64...${NC}"

# Cross-platform base64 encoding
if [[ "$OSTYPE" == "darwin"* ]]; then
    base64_keystore=$(base64 -i "$keystore_file")
else
    base64_keystore=$(base64 -w 0 "$keystore_file")
fi

echo ""
echo -e "${CYAN}================================================================================${NC}"
echo -e "${CYAN}  GITHUB SECRETS CONFIGURATION${NC}"
echo -e "${CYAN}================================================================================${NC}"
echo ""
echo -e "${YELLOW}Add the following secrets to your GitHub repository:${NC}"
echo -e "${YELLOW}  Settings > Secrets and variables > Actions > New repository secret${NC}"
echo ""
echo -e "${GRAY}--------------------------------------------------------------------------------${NC}"

echo ""
echo -e "${GREEN}SECRET NAME: OCEANPATH_KEYSTORE_BASE64${NC}"
echo -e "VALUE:"
echo -e "${GRAY}$base64_keystore${NC}"
echo ""

echo -e "${GRAY}--------------------------------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}SECRET NAME: OCEANPATH_KEYSTORE_PASSWORD${NC}"
echo -e "VALUE: ${GRAY}$keystore_password${NC}"
echo ""

echo -e "${GRAY}--------------------------------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}SECRET NAME: OCEANPATH_KEY_ALIAS${NC}"
echo -e "VALUE: ${GRAY}$key_alias${NC}"
echo ""

echo -e "${GRAY}--------------------------------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}SECRET NAME: OCEANPATH_KEY_PASSWORD${NC}"
echo -e "VALUE: ${GRAY}$key_password${NC}"
echo ""

echo -e "${CYAN}================================================================================${NC}"
echo ""

# ==============================================================================
# SAVE TO FILE (Optional)
# ==============================================================================

read -p "Would you like to save the secrets to a file for backup? (y/n): " save_to_file
if [ "$save_to_file" = "y" ] || [ "$save_to_file" = "Y" ]; then
    secrets_file="github-secrets-BACKUP-DELETE-AFTER-USE.txt"
    cat > "$secrets_file" << EOF
================================================================================
OCEAN PATH - GitHub Secrets Backup
================================================================================
IMPORTANT: Delete this file after adding secrets to GitHub!
           NEVER commit this file to version control!
================================================================================

OCEANPATH_KEYSTORE_BASE64:
$base64_keystore

OCEANPATH_KEYSTORE_PASSWORD:
$keystore_password

OCEANPATH_KEY_ALIAS:
$key_alias

OCEANPATH_KEY_PASSWORD:
$key_password

================================================================================
EOF
    
    echo ""
    echo -e "${YELLOW}Secrets saved to: $secrets_file${NC}"
    echo -e "${RED}WARNING: Delete this file after adding secrets to GitHub!${NC}"
fi

# ==============================================================================
# CLEANUP
# ==============================================================================

echo ""
read -p "Delete the local keystore file? (recommended for security) (y/n): " delete_keystore
if [ "$delete_keystore" = "y" ] || [ "$delete_keystore" = "Y" ]; then
    rm -f "$keystore_file"
    echo -e "${GREEN}Keystore file deleted.${NC}"
else
    echo -e "${YELLOW}Keystore saved as: $keystore_file${NC}"
    echo -e "${RED}WARNING: Do NOT commit this file to version control!${NC}"
fi

echo ""
echo -e "${CYAN}================================================================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${CYAN}================================================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add all 4 secrets to GitHub repository"
echo "  2. Push your code to trigger the build workflow"
echo "  3. Download signed APK/AAB from GitHub Actions artifacts"
echo ""

