package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

const (
	CHATBOT_NAME    = "GONA"
	CHATBOT_VERSION = "1.0.0"
)

type Response struct {
	Message string `json:"message,omitempty"`
	Name    string `json:"name,omitempty"`
	Version string `json:"version,omitempty"`
	Status  string `json:"status,omitempty"`
	Bot     string `json:"bot,omitempty"`
}

type ChatRequest struct {
	Message string `json:"message"`
}

type ChatResponse struct {
	Bot        string `json:"bot"`
	UserInput  string `json:"user_input"`
	Response   string `json:"response"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := map[string]string{
		"message":     "Welcome to GONA Chatbot",
		"name":        CHATBOT_NAME,
		"version":     CHATBOT_VERSION,
		"description": "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Go",
	}
	json.NewEncoder(w).Encode(resp)
}

func chatbotHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method == "POST" {
		body, _ := io.ReadAll(r.Body)
		var chatReq ChatRequest
		json.Unmarshal(body, &chatReq)

		json.NewEncoder(w).Encode(ChatResponse{
			Bot:       CHATBOT_NAME,
			UserInput: chatReq.Message,
			Response:  fmt.Sprintf("Hello from %s! You said: %s", CHATBOT_NAME, chatReq.Message),
		})
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"bot":     CHATBOT_NAME,
		"message": "Use POST to send messages to chatbot",
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Status: "healthy",
		Bot:    CHATBOT_NAME,
	})
}

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/", indexHandler).Methods("GET")
	router.HandleFunc("/chatbot", chatbotHandler).Methods("GET", "POST")
	router.HandleFunc("/health", healthHandler).Methods("GET")

	fmt.Printf("🔵 %s starting on port 8080...\n", CHATBOT_NAME)
	log.Fatal(http.ListenAndServe(":8080", router))
}
