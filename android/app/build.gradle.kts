plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Le plugin Flutter Gradle doit être appliqué après les plugins Android et Kotlin.
    id("com.google.gms.google-services") // Services Firebase
}

android {
    namespace = "com.example.glu_trotter"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.glu_trotter"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        resConfigs("en", "fr")
    }

    signingConfigs {
        getByName("debug") {  // Utilise la configuration existante au lieu d'en créer une nouvelle
            storeFile = file("debug.keystore")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug") // Utilisation correcte de getByName()
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (gère les versions automatiquement)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase Services
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Autres dépendances Android
    implementation("androidx.core:core-ktx:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
}
