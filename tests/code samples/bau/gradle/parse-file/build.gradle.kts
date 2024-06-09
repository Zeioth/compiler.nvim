// NOTE: gradlew will prevail over 'build.gradle.kts'.
//       to test it run "gradle wrapper" to generate it.

// Example of a task
tasks.register("hello_world") {
    doLast {
        println("Hello, World!")
    }
}

// Example of a custom task to run all tasks
tasks.register("build_all") {
    dependsOn("hello_world")
}

