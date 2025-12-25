# ==============================================================================
# OCEAN PATH - Keystore Generation Script (PowerShell)
# ==============================================================================
# This script generates a JKS keystore for signing Android applications.
# 
# SECURITY NOTICE:
# - This script does NOT collect any system information, IP address, or location data.
# - This script does NOT auto-fill any values.
# - All inputs are manually provided by the user.
# - Generated keystore should NEVER be committed to version control.
# ==============================================================================

$ErrorActionPreference = "Stop"

# Get the script's directory for file operations
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  OCEAN PATH - Android Keystore Generator" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will generate a JKS keystore for signing your Android application." -ForegroundColor Yellow
Write-Host "Please provide your company/organization details below." -ForegroundColor Yellow
Write-Host ""
Write-Host "SECURITY NOTICE:" -ForegroundColor Green
Write-Host "  - This script does NOT collect system information or personal data." -ForegroundColor Green
Write-Host "  - All values are provided manually by you." -ForegroundColor Green
Write-Host "  - Never commit the generated keystore to version control." -ForegroundColor Green
Write-Host ""

# ==============================================================================
# USER INPUT - Company Details (7+ fields as required)
# ==============================================================================

Write-Host "--- Company/Organization Details ---" -ForegroundColor Magenta
Write-Host ""

# 1. Common Name (CN) - Company/App Name
$commonName = Read-Host "1. Common Name (CN) - Your company or app name"
if ([string]::IsNullOrWhiteSpace($commonName)) {
    Write-Host "Error: Common Name is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 2. Organizational Unit (OU)
$orgUnit = Read-Host "2. Organizational Unit (OU) - Department (e.g., Mobile Development)"
if ([string]::IsNullOrWhiteSpace($orgUnit)) {
    Write-Host "Error: Organizational Unit is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 3. Organization (O)
$organization = Read-Host "3. Organization (O) - Company/Organization name"
if ([string]::IsNullOrWhiteSpace($organization)) {
    Write-Host "Error: Organization is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 4. City/Locality (L)
$city = Read-Host "4. City/Locality (L) - City name"
if ([string]::IsNullOrWhiteSpace($city)) {
    Write-Host "Error: City is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 5. State/Province (ST)
$state = Read-Host "5. State/Province (ST) - State or province name"
if ([string]::IsNullOrWhiteSpace($state)) {
    Write-Host "Error: State/Province is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 6. Country Code (C)
$country = Read-Host "6. Country Code (C) - Two-letter code (e.g., US, UK, NG, DE)"
$country = $country.Trim().ToUpper()
if ([string]::IsNullOrWhiteSpace($country) -or $country.Length -ne 2) {
    Write-Host "Error: Country Code must be exactly 2 letters (e.g., NG for Nigeria, US for United States)." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 7. Email Address
$email = Read-Host "7. Email Address - Contact email for the certificate"
if ([string]::IsNullOrWhiteSpace($email)) {
    Write-Host "Error: Email Address is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "--- Keystore Credentials ---" -ForegroundColor Magenta
Write-Host ""

# Key Alias
$keyAlias = Read-Host "8. Key Alias - Unique identifier for the key (e.g., oceanpath-release)"
if ([string]::IsNullOrWhiteSpace($keyAlias)) {
    Write-Host "Error: Key Alias is required." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Keystore Password (hidden input)
Write-Host "9. Keystore Password - Password for the keystore file (min 6 characters)"
$keystorePasswordSecure = Read-Host -AsSecureString
$keystorePassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePasswordSecure))
if ([string]::IsNullOrWhiteSpace($keystorePassword) -or $keystorePassword.Length -lt 6) {
    Write-Host "Error: Keystore Password must be at least 6 characters." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Key Password (hidden input)
Write-Host "10. Key Password - Password for the key itself (min 6 characters)"
$keyPasswordSecure = Read-Host -AsSecureString
$keyPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPasswordSecure))
if ([string]::IsNullOrWhiteSpace($keyPassword) -or $keyPassword.Length -lt 6) {
    Write-Host "Error: Key Password must be at least 6 characters." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Validity Period
$validityYears = Read-Host "11. Validity Period (years) - Recommended: 25 for Play Store [25]"
if ([string]::IsNullOrWhiteSpace($validityYears)) {
    $validityYears = "25"
}
$validityDays = [int]$validityYears * 365

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  Generating Keystore..." -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# GENERATE KEYSTORE
# ==============================================================================

# Use absolute path in script directory
$keystoreFile = Join-Path $scriptDir "oceanpath-release.jks"
$dname = "CN=$commonName, OU=$orgUnit, O=$organization, L=$city, ST=$state, C=$country, EMAILADDRESS=$email"

Write-Host "Keystore will be created at: $keystoreFile" -ForegroundColor Gray
Write-Host "Distinguished Name: $dname" -ForegroundColor Gray
Write-Host ""

# Check if keytool is available
try {
    $keytoolCheck = Get-Command keytool -ErrorAction Stop
    Write-Host "Found keytool at: $($keytoolCheck.Source)" -ForegroundColor Gray
} catch {
    Write-Host "Error: 'keytool' command not found." -ForegroundColor Red
    Write-Host "Please ensure Java JDK is installed and added to PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "To install Java JDK:" -ForegroundColor Yellow
    Write-Host "  - Download from: https://adoptium.net/" -ForegroundColor Yellow
    Write-Host "  - Or run: winget install Microsoft.OpenJDK.17" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Remove existing keystore if present
if (Test-Path $keystoreFile) {
    Write-Host "Removing existing keystore file..." -ForegroundColor Yellow
    Remove-Item $keystoreFile -Force
}

# Generate the keystore using Start-Process for better error handling
Write-Host "Running keytool to generate keystore..." -ForegroundColor Yellow
Write-Host ""

try {
    $keytoolProcess = Start-Process -FilePath "keytool" -ArgumentList @(
        "-genkeypair",
        "-v",
        "-keystore", "`"$keystoreFile`"",
        "-alias", "`"$keyAlias`"",
        "-keyalg", "RSA",
        "-keysize", "2048",
        "-validity", "$validityDays",
        "-storetype", "JKS",
        "-dname", "`"$dname`"",
        "-storepass", "`"$keystorePassword`"",
        "-keypass", "`"$keyPassword`""
    ) -NoNewWindow -Wait -PassThru

    if ($keytoolProcess.ExitCode -ne 0) {
        throw "Keytool failed with exit code $($keytoolProcess.ExitCode)"
    }
} catch {
    Write-Host "Error generating keystore: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Country code must be exactly 2 letters (e.g., NG, US, UK)" -ForegroundColor Yellow
    Write-Host "  - Passwords must be at least 6 characters" -ForegroundColor Yellow
    Write-Host "  - Special characters in inputs may cause issues" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify keystore was created
if (-not (Test-Path $keystoreFile)) {
    Write-Host "Error: Keystore file was not created at: $keystoreFile" -ForegroundColor Red
    Write-Host "Please check the keytool output above for errors." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$fileInfo = Get-Item $keystoreFile
Write-Host ""
Write-Host "Keystore generated successfully!" -ForegroundColor Green
Write-Host "  File: $keystoreFile" -ForegroundColor Gray
Write-Host "  Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
Write-Host ""

# ==============================================================================
# ENCODE TO BASE64
# ==============================================================================

Write-Host "Encoding keystore to Base64..." -ForegroundColor Yellow

try {
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystoreFile)
    $base64Keystore = [Convert]::ToBase64String($keystoreBytes)
    Write-Host "Base64 encoding complete. Length: $($base64Keystore.Length) characters" -ForegroundColor Gray
} catch {
    Write-Host "Error reading keystore file: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  GITHUB SECRETS CONFIGURATION" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "  Settings > Secrets and variables > Actions > New repository secret" -ForegroundColor Yellow
Write-Host ""
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray

Write-Host ""
Write-Host "SECRET NAME: OCEANPATH_KEYSTORE_BASE64" -ForegroundColor Green
Write-Host "VALUE:" -ForegroundColor White
Write-Host $base64Keystore -ForegroundColor Gray
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "SECRET NAME: OCEANPATH_KEYSTORE_PASSWORD" -ForegroundColor Green
Write-Host "VALUE: $keystorePassword" -ForegroundColor Gray
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "SECRET NAME: OCEANPATH_KEY_ALIAS" -ForegroundColor Green
Write-Host "VALUE: $keyAlias" -ForegroundColor Gray
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "SECRET NAME: OCEANPATH_KEY_PASSWORD" -ForegroundColor Green
Write-Host "VALUE: $keyPassword" -ForegroundColor Gray
Write-Host ""

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# SAVE TO FILE (Optional)
# ==============================================================================

$saveToFile = Read-Host "Would you like to save the secrets to a file for backup? (y/n)"
if ($saveToFile -eq "y" -or $saveToFile -eq "Y") {
    $secretsFile = Join-Path $scriptDir "github-secrets-BACKUP-DELETE-AFTER-USE.txt"
    @"
================================================================================
OCEAN PATH - GitHub Secrets Backup
================================================================================
IMPORTANT: Delete this file after adding secrets to GitHub!
           NEVER commit this file to version control!
================================================================================

OCEANPATH_KEYSTORE_BASE64:
$base64Keystore

OCEANPATH_KEYSTORE_PASSWORD:
$keystorePassword

OCEANPATH_KEY_ALIAS:
$keyAlias

OCEANPATH_KEY_PASSWORD:
$keyPassword

================================================================================
"@ | Out-File -FilePath $secretsFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "Secrets saved to: $secretsFile" -ForegroundColor Yellow
    Write-Host "WARNING: Delete this file after adding secrets to GitHub!" -ForegroundColor Red
}

# ==============================================================================
# CLEANUP
# ==============================================================================

Write-Host ""
$deleteKeystore = Read-Host "Delete the local keystore file? (recommended for security) (y/n)"
if ($deleteKeystore -eq "y" -or $deleteKeystore -eq "Y") {
    Remove-Item $keystoreFile -Force
    Write-Host "Keystore file deleted." -ForegroundColor Green
} else {
    Write-Host "Keystore saved as: $keystoreFile" -ForegroundColor Yellow
    Write-Host "WARNING: Do NOT commit this file to version control!" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Add all 4 secrets to GitHub repository" -ForegroundColor White
Write-Host "  2. Push your code to trigger the build workflow" -ForegroundColor White
Write-Host "  3. Download signed APK/AAB from GitHub Actions artifacts" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
