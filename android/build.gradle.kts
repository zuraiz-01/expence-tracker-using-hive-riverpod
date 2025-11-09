// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Google Services plugin (for Firebase)
        classpath("com.google.gms:google-services:4.4.2")

        // ✅ (Optional) Add this if you plan to use Crashlytics or Performance Monitoring
        // classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.2")
        // classpath("com.google.firebase:perf-plugin:1.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Use a centralized build directory to keep Flutter + Android builds clean
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Ensure that all subprojects depend on the :app module evaluation
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
