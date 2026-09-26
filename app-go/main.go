package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/html")
        fmt.Fprintf(w, "<h1>🔵 Go App - AgentRoyer</h1>")
    })
    
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
    })
    
    fmt.Println("Go server listening on :8080")
    http.ListenAndServe(":8080", nil)
}
