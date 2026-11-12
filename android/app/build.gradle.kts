import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (kept out of git) names the upload
// keystore. See https://docs.flutter.dev/deployment/android#sign-the-app
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.healthylife.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications (java.time APIs on older Android).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.healthylife.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
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
            // The upload key when key.properties exists. Without it a release
            // build fails (see the check below) unless it was asked for on
            // purpose with -PallowDebugSigning=true: an internal test build
            // signed with the debug key, which Google Play refuses.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// A release build never falls back to the debug key silently.
val allowDebugSigning =
    (project.findProperty("allowDebugSigning") as String?)?.toBoolean() ?: false

gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any { task ->
        task.project == project &&
            (task.name.startsWith("assemble") || task.name.startsWith("bundle") ||
                task.name.startsWith("package")) &&
            task.name.contains("Release")
    }
    if (buildsRelease && !keystorePropertiesFile.exists()) {
        if (!allowDebugSigning) {
            throw GradleException(
                "Release signing is not set up: android/key.properties is missing.\n" +
                    "Create it (storeFile, storePassword, keyAlias, keyPassword) " +
                    "to sign with the upload key.\n" +
                    "For an internal test build signed with the DEBUG key, " +
                    "pass -PallowDebugSigning=true."
            )
        }
        logger.warn(
            "\n" +
                "WARNING ============================================================\n" +
                "WARNING  This RELEASE build is signed with the DEBUG key.\n" +
                "WARNING  (-PallowDebugSigning=true, android/key.properties missing)\n" +
                "WARNING  Internal testing only. Google Play will refuse it.\n" +
                "WARNING ============================================================\n"
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
