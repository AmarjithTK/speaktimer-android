plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.atherpulse.solasflow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.atherpulse.solasflow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // TODO: Configure your release keystore for Play Store publishing.
            // 1. Generate a keystore: keytool -genkey -v -keystore solasflow-release.jks -alias solasflow -keyalg RSA -keysize 2048 -validity 10000
            // 2. Store the keystore file in a secure location (NOT in version control)
            // 3. Set env vars OR create keystore.properties (excluded from VCS):
            //    storeFile=file("solasflow-release.jks")
            //    storePassword=...
            //    keyAlias=solasflow
            //    keyPassword=...
            // 4. Uncomment below and reference the properties file:
            // val keystoreProps = java.util.Properties()
            // keystoreProps.load(rootProject.file("keystore.properties").inputStream())
            // storeFile = file(keystoreProps["storeFile"] as String)
            // storePassword = keystoreProps["storePassword"] as String
            // keyAlias = keystoreProps["keyAlias"] as String
            // keyPassword = keystoreProps["keyPassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro"),
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
