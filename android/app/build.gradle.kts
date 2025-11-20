plugins {
    id("com.android.application")
    id("kotlin-android")

    // Plugin de Flutter
    id("dev.flutter.flutter-gradle-plugin")

    // Plugin de Google Services (Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.citas_medicas_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Necesario para flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.citas_medicas_app"
        minSdk = flutter.minSdkVersion     // Firebase requiere minSdk 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")

    // Desugaring necesario (por notificaciones)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
