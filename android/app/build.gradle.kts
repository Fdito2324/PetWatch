plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "1.8.22"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fernandovidal"

    compileSdk = 35 // ✅ Define un número específico

    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // ✅ Java 17 es más compatible
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.fernandovidal"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// 🔹 Elimina la sección `dependencies` con `classpath`, ya que no pertenece aquí

flutter {
    source = "../.."
}
