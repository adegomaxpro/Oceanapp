import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
val keystorePropertiesFile = rootProject.file("app/key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.oceanpath.goldencrush"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.oceanpath.goldencrush"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // IMPORTANT: Release builds MUST be signed with the release keystore.
            // NO fallback to debug signing - this ensures Play Store builds are always properly signed.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Return null - build will fail with clear error when attempting release build
                null
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Fail fast with clear message when building release without proper signing
gradle.taskGraph.whenReady {
    if (hasTask(":app:assembleRelease") || hasTask(":app:bundleRelease")) {
        if (!keystorePropertiesFile.exists()) {
            throw GradleException(
                "\n" +
                "═══════════════════════════════════════════════════════════════════\n" +
                "  ERROR: Release signing keystore not configured!\n" +
                "═══════════════════════════════════════════════════════════════════\n" +
                "  Release builds MUST be signed with the release keystore.\n" +
                "  Debug signing fallback is NOT allowed for release builds.\n" +
                "\n" +
                "  Expected file: ${keystorePropertiesFile.absolutePath}\n" +
                "\n" +
                "  To fix:\n" +
                "  • Local build: Run scripts/generate-keystore.ps1 and create key.properties\n" +
                "  • CI/CD: Ensure GitHub Secrets are configured correctly\n" +
                "\n" +
                "  See docs/ANDROID_SIGNING.md for detailed instructions.\n" +
                "═══════════════════════════════════════════════════════════════════\n"
            )
        }
    }
}

flutter {
    source = "../.."
}
