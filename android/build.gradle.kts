// Repositorios globales para todos los proyectos
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración para cambiar el directorio de build
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Tarea para limpiar el directorio de build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 🔹 Usar Gradle 8.9 o superior
tasks.withType<Wrapper> {
    gradleVersion = "8.9"
    distributionType = Wrapper.DistributionType.ALL
}

// 🔹 Configuración de buildscript CORRECTA
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {  // ✅ ESTA ES LA UBICACIÓN CORRECTA
        classpath("com.android.tools.build:gradle:8.3.0") // Versión compatible con Java 17
    }
}
