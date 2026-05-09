// 1. Firebase ke liye buildscript block (Ye zaroori hai)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services ka rasta
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// 2. Repositories block
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Aapka purana Build Directory logic
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

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