package main

import (
	"bytes"
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gorilla/mux"
)

// Chatbot GONA — même interface et même API que RUSTINA (app-rust/Projects/chatbot)
const (
	CHATBOT_NAME    = "GONA"
	CHATBOT_VERSION = "1.0.0"
	GROQ_URL        = "https://api.groq.com/openai/v1/chat/completions"
	GROQ_MODEL      = "openai/gpt-oss-20b"
)

//go:embed templates/index.html
var indexTemplate string

type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type ChatRequest struct {
	Message string `json:"message"`
}

type ChatResponse struct {
	Bot       string `json:"bot"`
	UserInput string `json:"user_input"`
	Response  string `json:"response"`
}

type groqResponse struct {
	Choices []struct {
		Message ChatMessage `json:"message"`
	} `json:"choices"`
}

var groqClient = &http.Client{Timeout: 60 * time.Second}

func groqComplete(messages []ChatMessage) (ChatMessage, error) {
	// Clé fournie par le .env de la racine du codespace (docker-compose env_file)
	apiKey := strings.TrimSpace(os.Getenv("GROQ_API_KEY_CFC"))
	if apiKey == "" {
		return ChatMessage{}, errors.New("GROQ_API_KEY_CFC est manquante sur le serveur.")
	}
	payload, _ := json.Marshal(map[string]any{"model": GROQ_MODEL, "messages": messages, "temperature": 0.7})
	req, _ := http.NewRequest(http.MethodPost, GROQ_URL, bytes.NewReader(payload))
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := groqClient.Do(req)
	if err != nil {
		return ChatMessage{}, fmt.Errorf("Impossible de joindre Groq : %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return ChatMessage{}, fmt.Errorf("Groq a renvoyé le statut %s.", resp.Status)
	}
	var data groqResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return ChatMessage{}, fmt.Errorf("Réponse Groq invalide : %v", err)
	}
	if len(data.Choices) == 0 {
		return ChatMessage{}, errors.New("Groq n’a renvoyé aucun message.")
	}
	return data.Choices[0].Message, nil
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(value)
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprint(w, strings.Replace(indexTemplate, "__TIMESTAMP__", time.Now().Format("02/01/2006 15:04"), 1))
}

func chatbotHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		indexHandler(w, r)
		return
	}

	var chatReq ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&chatReq); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "JSON invalide : " + err.Error()})
		return
	}
	reply, err := groqComplete([]ChatMessage{{Role: "user", Content: chatReq.Message}})
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"bot": CHATBOT_NAME, "error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, ChatResponse{
		Bot:       CHATBOT_NAME,
		UserInput: chatReq.Message,
		Response:  reply.Content,
	})
}

func apiChatHandler(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Messages []ChatMessage `json:"messages"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "JSON invalide : " + err.Error()})
		return
	}
	reply, err := groqComplete(body.Messages)
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": err.Error()})
		return
	}
	writeJSON(w, http.StatusOK, map[string]ChatMessage{"message": reply})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "healthy", "bot": CHATBOT_NAME})
}

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/", indexHandler).Methods("GET")
	router.HandleFunc("/chatbot", chatbotHandler).Methods("GET", "POST")
	router.HandleFunc("/chatbot/", indexHandler).Methods("GET")
	router.HandleFunc("/api/chat", apiChatHandler).Methods("POST")
	router.HandleFunc("/health", healthHandler).Methods("GET")

	fmt.Printf("🔵 %s starting on port 8080...\n", CHATBOT_NAME)
	log.Fatal(http.ListenAndServe(":8080", router))
}
