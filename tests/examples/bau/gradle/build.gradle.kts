// NOTE: gradlew will prevail over build.gradle.

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

