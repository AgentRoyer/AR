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
	BOT_COLOR       = "orange" // Or/bronze
	GROQ_URL        = "https://api.groq.com/openai/v1/chat/completions"
	GROQ_MODEL      = "openai/gpt-oss-20b"
	SYSTEM_PROMPT   = "You are GONA, a helpful AI chatbot powered by Groq under Go. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."
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
	Identity  string `json:"identity"`
	Color     string `json:"color"`
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
	// Identité : le prompt système précède toujours la conversation
	withSystem := append([]ChatMessage{{Role: "system", Content: SYSTEM_PROMPT}}, messages...)
	payload, _ := json.Marshal(map[string]any{"model": GROQ_MODEL, "messages": withSystem, "temperature": 0.7})
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
		Identity:  CHATBOT_NAME,
		Color:     BOT_COLOR,
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
	writeJSON(w, http.StatusOK, map[string]any{"status": "healthy", "bot": CHATBOT_NAME, "color": BOT_COLOR, "identity_aware": true})
}

func identityHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"name":           CHATBOT_NAME,
		"system_prompt":  SYSTEM_PROMPT,
		"version":        CHATBOT_VERSION,
		"color":          BOT_COLOR,
		"knows_identity": true,
	})
}

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/", indexHandler).Methods("GET")
	router.HandleFunc("/chatbot", chatbotHandler).Methods("GET", "POST")
	router.HandleFunc("/chatbot/", indexHandler).Methods("GET")
	router.HandleFunc("/api/chat", apiChatHandler).Methods("POST")
	router.HandleFunc("/health", healthHandler).Methods("GET")
	router.HandleFunc("/identity", identityHandler).Methods("GET")

	fmt.Printf("🔵 %s starting on port 8080...\n", CHATBOT_NAME)
	fmt.Printf("   System Prompt: %s\n", SYSTEM_PROMPT)
	log.Fatal(http.ListenAndServe(":8080", router))
}
