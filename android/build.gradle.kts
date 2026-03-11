allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.projectDirectory
        .dir("../build")
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val projectPath = project.projectDir.absolutePath
    val rootPath = rootProject.projectDir.absolutePath
    if (projectPath.substringBefore(":") == rootPath.substringBefore(":")) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (name == "isar_flutter_libs") {
        val fixConfig = {
            val androidExtension = extensions.findByName("android")
            if (androidExtension != null) {
                // Fix Namespace
                try {
                    val setNamespaceMethod = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(androidExtension, "dev.isar.isar_flutter_libs")
                } catch (e: Exception) {
                    logger.warn("Failed to set namespace for isar_flutter_libs", e)
                }

                // Fix CompileSdk
                try {
                    val setCompileSdkMethod = androidExtension.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    setCompileSdkMethod.invoke(androidExtension, 34)
                } catch (e: Exception) {
                    try {
                        // Fallback for older AGP or different hierarchy
                        val setCompileSdkVersionMethod = androidExtension.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                        setCompileSdkVersionMethod.invoke(androidExtension, 34)
                    } catch (e2: Exception) {
                        logger.warn("Failed to set compileSdk for isar_flutter_libs", e2)
                    }
                }
            }
        }

        try {
            afterEvaluate {
                fixConfig()
            }
        } catch (e: Exception) {
            fixConfig()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
