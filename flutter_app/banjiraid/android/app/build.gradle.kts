import java.io.File
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

val repoSecretsFile = rootProject.file("../../../local-secrets/firebase.properties")
val fallbackLocalPropertiesFile = rootProject.file("local.properties")
val googleServicesTemplateFile = file("google-services.template.json")
val googleServicesJsonFile = file("google-services.json")

fun loadProperties(propsFile: File): Properties {
    val props = Properties()
    propsFile.inputStream().use { props.load(it) }
    return props
}

fun resolveFirebaseApiKey(): String {
    val keyFromSecrets = if (repoSecretsFile.exists()) {
        loadProperties(repoSecretsFile).getProperty("FIREBASE_API_KEY")
    } else {
        null
    }

    val keyFromLocalProperties = if (fallbackLocalPropertiesFile.exists()) {
        loadProperties(fallbackLocalPropertiesFile).getProperty("FIREBASE_API_KEY")
    } else {
        null
    }

    return (keyFromSecrets ?: keyFromLocalProperties ?: System.getenv("FIREBASE_API_KEY"))?.trim().orEmpty()
}

tasks.register("generateGoogleServicesJson") {
    inputs.file(googleServicesTemplateFile)
    outputs.file(googleServicesJsonFile)

    doLast {
        if (!googleServicesTemplateFile.exists()) {
            throw GradleException("Missing template: ${googleServicesTemplateFile.path}")
        }

        val key = resolveFirebaseApiKey()
        if (key.isEmpty()) {
            throw GradleException(
                "FIREBASE_API_KEY is missing. Add it to local-secrets/firebase.properties, android/local.properties, or env var FIREBASE_API_KEY."
            )
        }

        val marker = "__FIREBASE_API_KEY__"
        val template = googleServicesTemplateFile.readText()
        if (!template.contains(marker)) {
            throw GradleException("google-services.template.json must contain the marker __FIREBASE_API_KEY__")
        }

        googleServicesJsonFile.writeText(template.replace(marker, key))
    }
}

tasks.matching { it.name.endsWith("GoogleServices") }.configureEach {
    dependsOn("generateGoogleServicesJson")
}

android {
    namespace = "com.example.banjiraid"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.banjiraid"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
