import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.exists()) {
    releasePropertiesFile.inputStream().use(releaseProperties::load)
}

fun releaseSetting(propertyName: String, environmentName: String): String? =
    releaseProperties.getProperty(propertyName)
        ?: System.getenv(environmentName)?.takeIf { it.isNotBlank() }

val releaseStorePath = releaseSetting("storeFile", "LAWRENCE_KEYSTORE_PATH")
val releaseStorePassword = releaseSetting("storePassword", "LAWRENCE_KEYSTORE_PASSWORD")
val releaseKeyAlias = releaseSetting("keyAlias", "LAWRENCE_KEY_ALIAS")
val releaseKeyPassword = releaseSetting("keyPassword", "LAWRENCE_KEY_PASSWORD")
val hasReleaseSigning = listOf(
    releaseStorePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }
val requestsProductionRelease = gradle.startParameter.taskNames.any {
    it.contains("production", ignoreCase = true) &&
        it.contains("release", ignoreCase = true)
}

if (requestsProductionRelease && !hasReleaseSigning) {
    throw GradleException(
        "Production release signing is required. Configure android/key.properties " +
            "or the LAWRENCE_KEYSTORE_* environment variables.",
    )
}

android {
    namespace = "academy.lawrence.lawrence"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "academy.lawrence.lawrence"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Lawrence Academy Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "Lawrence Academy")
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(requireNotNull(releaseStorePath))
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
