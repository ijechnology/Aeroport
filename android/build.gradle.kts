// android/build.gradle.kts (FILE ROOT YANG BERSIH)

// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    // Biarkan tanpa versi untuk menghindari konflik dengan gradle/wrapper
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false 
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)


// --- HAPUS BLOK SUBPROJECTS YANG ERROR DARI SINI ---


subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}