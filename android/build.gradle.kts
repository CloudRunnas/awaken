import com.android.build.gradle.LibraryExtension

val pluginNamespaceFixes = mapOf(
    "on_audio_edit" to "com.lucasjosino.on_audio_edit",
    "on_audio_query_android" to "com.lucasjosino.on_audio_query",
    "on_audio_query" to "com.lucasjosino.on_audio_query",
    "awesome_notifications" to "me.carda.awesome_notifications",
    "flare_flutter" to "com.example.flare_flutter",
)

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

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace.isNullOrBlank()) {
                namespace = pluginNamespaceFixes[project.name]
                    ?: project.group.toString().takeIf { it.isNotBlank() }
                    ?: "com.phoenix.${project.name.replace('-', '_')}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
