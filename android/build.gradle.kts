allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/public/") }
        maven { url = uri("https://maven.aliyun.com/repository/google/") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin/") }
        google()
        mavenCentral()
    }
}

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

// Fix for isar_flutter_libs namespace issue
val isarProject = subprojects.find { it.name == "isar_flutter_libs" }
if (isarProject != null) {
    isarProject.afterEvaluate {
        if (isarProject.extensions.findByName("android") is com.android.build.gradle.LibraryExtension) {
            (isarProject.extensions.getByName("android") as com.android.build.gradle.LibraryExtension).apply {
                if (namespace == null) {
                    namespace = "com.hongyu.app_sp_ledger.isar_flutter_libs"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
