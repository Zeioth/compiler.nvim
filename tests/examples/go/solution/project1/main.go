// main.go

package main

import "fmt"

func main() {
    msg := getMessage() // Calling the function from "helper.go"
    fmt.Println(msg)
}

