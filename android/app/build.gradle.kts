plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties

// Load environment variables from .env, preferring project root then android/ fallback
val envProps = Properties()
val projectRootEnv = File(rootDir.parentFile ?: rootDir, ".env")
val androidDirEnv = File(rootDir, ".env")
val envFile = if (projectRootEnv.exists()) projectRootEnv else androidDirEnv

if (envFile.exists()) {
    envFile.forEachLine { line ->
        if (line.isNotBlank() && !line.trim().startsWith("#")) {
            val parts = line.split("=", limit = 2)
            if (parts.size == 2) {
                val (key, value) = parts
                envProps[key.trim()] = value.trim()
            }
        }
    }
}

android {
    namespace = "com.campus_connect.geca"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.campus_connect.geca"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            val googleMapsApiKey = envProps.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
            resValue("string", "google_maps_key", googleMapsApiKey)
        }
        getByName("release") {
            val googleMapsApiKey = envProps.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
            resValue("string", "google_maps_key", googleMapsApiKey)
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
