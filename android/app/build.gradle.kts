import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Загружаем настройки ключа
val keystoreProperties = Properties()
val keystorePropertiesFile = File(rootProject.projectDir, "key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
    println("✅ Key properties loaded: ${keystoreProperties.keys}")
} else {
    println("❌ Key properties file not found: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.playcus.hydracoach"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        // applicationId теперь задается в флейворах
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    flavorDimensions += "app"

    productFlavors {
        create("foodcoach") {
            dimension = "app"
            applicationId = "com.playcus.foodcoach"
            manifestPlaceholders["appName"] = "FoodCoach"
        }

        create("foodcoachsup") {
            dimension = "app"
            applicationId = "com.logics7.foodmasterpro"
            manifestPlaceholders["appName"] = "FoodMaster Pro"
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Google Play Billing Library (требуется для Purchase Connector)
    implementation("com.android.billingclient:billing:7.1.1")

    // AppsFlyer Purchase Connector для IAP валидации
    implementation("com.appsflyer:purchase-connector:2.1.1")

    // DevToDev Analytics SDK v2 (stable version)
    implementation("com.devtodev:android-analytics:2.5.1")
    implementation("com.devtodev:android-google:1.0.1")
}
