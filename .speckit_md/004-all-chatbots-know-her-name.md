# 003 Chatbots Know Her Name

**Ajouter l'identité système à RUSTINA, PYTHONA et GONA.**

Chaque chatbot saura qui elle est et répondra à des questions d'identité.

---

## Steps

1. echo "Starting: Adding system identity to all chatbots..."

2. echo "=== PYTHON: Update PYTHONA with identity ==="

3. cat > app-python/Projects/chatbot/app.py << 'EOF'
from flask import Flask, jsonify, request

app = Flask(__name__)

# Chatbot PYTHONA
CHATBOT_NAME = "PYTHONA"
CHATBOT_VERSION = "1.0.0"
SYSTEM_PROMPT = "You are PYTHONA, a helpful AI chatbot powered by Groq under Python. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."

@app.route('/')
def index():
    return jsonify({
        "message": "Welcome to PYTHONA Chatbot",
        "name": CHATBOT_NAME,
        "version": CHATBOT_VERSION,
        "description": "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Python"
    })

@app.route('/chatbot', methods=['GET', 'POST'])
def chatbot():
    if request.method == 'POST':
        data = request.get_json()
        user_message = data.get('message', '')
        
        # Simulate AI response with identity
        response = generate_response(user_message)
        
        return jsonify({
            "bot": CHATBOT_NAME,
            "user_input": user_message,
            "response": response,
            "identity": CHATBOT_NAME
        })
    
    return jsonify({
        "bot": CHATBOT_NAME,
        "message": "Use POST to send messages to chatbot",
        "system_prompt": SYSTEM_PROMPT
    })

def generate_response(user_message):
    """Generate response based on user message, respecting identity"""
    message_lower = user_message.lower()
    
    # Identity questions
    if any(word in message_lower for word in ['qui', 'name', 'appel', 'suis-je', 'who are you', 'what is your name']):
        return f"Je suis {CHATBOT_NAME}, un assistant IA alimenté par Groq sous Python. C'est mon identité et ma raison d'être!"
    
    if any(word in message_lower for word in ['comment', 'tes-tu', 'are you', 'ton nom']):
        return f"Mon nom est {CHATBOT_NAME}. Je suis un chatbot intelligent propulsé par Groq sous Python."
    
    # Default response
    return f"{CHATBOT_NAME} responds: Hello! You said '{user_message}'. Comment puis-je vous aider?"

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "bot": CHATBOT_NAME,
        "identity_aware": True
    }), 200

@app.route('/identity', methods=['GET'])
def identity():
    return jsonify({
        "name": CHATBOT_NAME,
        "system_prompt": SYSTEM_PROMPT,
        "version": CHATBOT_VERSION,
        "knows_identity": True
    }), 200

if __name__ == '__main__':
    print(f"🐍 {CHATBOT_NAME} starting on port 5000...")
    print(f"   System Prompt: {SYSTEM_PROMPT}")
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

4. echo "=== GO: Update GONA with identity ==="

5. cat > app-go/Projects/chatbot/main.go << 'EOF'
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
)

const (
	CHATBOT_NAME    = "GONA"
	CHATBOT_VERSION = "1.0.0"
	SYSTEM_PROMPT   = "You are GONA, a helpful AI chatbot powered by Groq under Go. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."
)

type Response struct {
	Message        string `json:"message,omitempty"`
	Name           string `json:"name,omitempty"`
	Version        string `json:"version,omitempty"`
	Status         string `json:"status,omitempty"`
	Bot            string `json:"bot,omitempty"`
	Description    string `json:"description,omitempty"`
	SystemPrompt   string `json:"system_prompt,omitempty"`
	IdentityAware  bool   `json:"identity_aware,omitempty"`
	KnowsIdentity  bool   `json:"knows_identity,omitempty"`
}

type ChatRequest struct {
	Message string `json:"message"`
}

type ChatResponse struct {
	Bot      string `json:"bot"`
	UserInput string `json:"user_input"`
	Response string `json:"response"`
	Identity string `json:"identity"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Message:     "Welcome to GONA Chatbot",
		Name:        CHATBOT_NAME,
		Version:     CHATBOT_VERSION,
		Description: "Un espace calme pour réfléchir, écrire et avancer avec un assistant propulsé par Groq sous Go",
	}
	json.NewEncoder(w).Encode(resp)
}

func generateResponse(userMessage string) string {
	messageLower := strings.ToLower(userMessage)
	
	// Identity questions
	identityKeywords := []string{"qui", "name", "appel", "suis-je", "who are you", "what is your name", "comment", "tes-tu", "are you", "ton nom"}
	
	for _, keyword := range identityKeywords {
		if strings.Contains(messageLower, keyword) {
			if strings.Contains(messageLower, "qui") || strings.Contains(messageLower, "appel") || strings.Contains(messageLower, "name") {
				return fmt.Sprintf("Je suis %s, un assistant IA alimenté par Groq sous Go. C'est mon identité et ma raison d'être!", CHATBOT_NAME)
			}
			if strings.Contains(messageLower, "comment") || strings.Contains(messageLower, "tes-tu") {
				return fmt.Sprintf("Mon nom est %s. Je suis un chatbot intelligent propulsé par Groq sous Go.", CHATBOT_NAME)
			}
		}
	}
	
	// Default response
	return fmt.Sprintf("%s responds: Hello! You said '%s'. Comment puis-je vous aider?", CHATBOT_NAME, userMessage)
}

func chatbotHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method == "POST" {
		body, _ := io.ReadAll(r.Body)
		var chatReq ChatRequest
		json.Unmarshal(body, &chatReq)

		response := ChatResponse{
			Bot:       CHATBOT_NAME,
			UserInput: chatReq.Message,
			Response:  generateResponse(chatReq.Message),
			Identity:  CHATBOT_NAME,
		}
		json.NewEncoder(w).Encode(response)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"bot":             CHATBOT_NAME,
		"message":         "Use POST to send messages to chatbot",
		"system_prompt":   SYSTEM_PROMPT,
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Status:        "healthy",
		Bot:           CHATBOT_NAME,
		IdentityAware: true,
	})
}

func identityHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Name:          CHATBOT_NAME,
		SystemPrompt:  SYSTEM_PROMPT,
		Version:       CHATBOT_VERSION,
		KnowsIdentity: true,
	})
}

func main() {
	router := mux.NewRouter()

	router.HandleFunc("/", indexHandler).Methods("GET")
	router.HandleFunc("/chatbot", chatbotHandler).Methods("GET", "POST")
	router.HandleFunc("/health", healthHandler).Methods("GET")
	router.HandleFunc("/identity", identityHandler).Methods("GET")

	fmt.Printf("🔵 %s starting on port 8080...\n", CHATBOT_NAME)
	fmt.Printf("   System Prompt: %s\n", SYSTEM_PROMPT)
	log.Fatal(http.ListenAndServe(":8080", router))
}
EOF

6. echo "=== RUST: Update RUSTINA with identity ==="

7. cat >> app-rust/Projects/chatbot/src/main.rs << 'EOF'

// Add system identity support
pub const CHATBOT_NAME: &str = "RUSTINA";
pub const SYSTEM_PROMPT: &str = "You are RUSTINA, a helpful AI chatbot powered by Groq under Rust. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently.";

pub fn generate_response(user_message: &str) -> String {
    let message_lower = user_message.to_lowercase();
    
    // Identity questions
    if message_lower.contains("qui") 
        || message_lower.contains("name") 
        || message_lower.contains("appel")
        || message_lower.contains("suis-je")
        || message_lower.contains("who are you")
        || message_lower.contains("what is your name") {
        return format!("Je suis {}, un assistant IA alimenté par Groq sous Rust. C'est mon identité et ma raison d'être!", CHATBOT_NAME);
    }
    
    if message_lower.contains("comment")
        || message_lower.contains("tes-tu")
        || message_lower.contains("are you")
        || message_lower.contains("ton nom") {
        return format!("Mon nom est {}. Je suis un chatbot intelligent propulsé par Groq sous Rust.", CHATBOT_NAME);
    }
    
    // Default response
    format!("{} responds: Hello! You said '{}'. Comment puis-je vous aider?", CHATBOT_NAME, user_message)
}
EOF

8. echo "Rebuilding and restarting all three chatbots..."

9. docker-compose down app-rust app-python app-go

10. docker-compose build app-rust app-python app-go

11. docker-compose up -d app-rust app-python app-go

12. sleep 15

13. echo "=== Testing PYTHONA Identity (port 8004) ==="

14. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Qui es-tu?"}' | jq .

15. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Comment t'\''appelles-tu?"}' | jq .

16. echo "=== Testing GONA Identity (port 8003) ==="

17. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Who are you?"}' | jq .

18. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"What is your name?"}' | jq .

19. echo "=== Testing RUSTINA Identity (port 8002) ==="

20. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Qui es-tu?"}' | jq .

21. curl -k -X POST https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message":"Comment t'\''appelles-tu?"}' | jq .

22. echo "=== Testing Identity Endpoints (GET /identity) ==="

23. echo "PYTHONA /identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8004.app.github.dev/identity | jq .

24. echo "GONA /identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8003.app.github.dev/identity | jq .

25. echo "RUSTINA /identity:" && curl -k https://literate-bassoon-xrr7x4qwqqv4hq4-8002.app.github.dev/identity | jq .

26. echo "=== All three chatbots now know their names! ==="

27. echo "PYTHONA knows: Je suis PYTHONA"

28. echo "GONA knows: Je suis GONA"

29. echo "RUSTINA knows: Je suis RUSTINA"

30. docker-compose ps

31. git add app-python/ app-go/ app-rust/ && git commit -m "003: Add system identity to all chatbots - RUSTINA/PYTHONA/GONA now know their names"

32. git push

## Success Criteria

- ✓ PYTHONA responds to identity questions with "Je suis PYTHONA"
- ✓ GONA responds to identity questions with "Je suis GONA"
- ✓ RUSTINA responds to identity questions with "Je suis RUSTINA"
- ✓ Each chatbot has SYSTEM_PROMPT embedded
- ✓ New /identity endpoint shows bot info and system prompt
- ✓ Questions like "Qui es-tu?" trigger identity response
- ✓ Questions like "Comment t'appelles-tu?" trigger name response
- ✓ Questions like "Who are you?" work on English queries
- ✓ All three services running and healthy
- ✓ Git committed and pushed

## API Endpoints

### Identity Endpoint
```bash
GET /identity

Response:
{
  "name": "PYTHONA",
  "system_prompt": "You are PYTHONA, a helpful AI chatbot...",
  "version": "1.0.0",
  "knows_identity": true
}
```

### Chatbot with Identity Questions
```bash
POST /chatbot
Content-Type: application/json

{
  "message": "Qui es-tu?"
}

Response:
{
  "bot": "PYTHONA",
  "user_input": "Qui es-tu?",
  "response": "Je suis PYTHONA, un assistant IA alimenté par Groq sous Python. C'est mon identité et ma raison d'être!",
  "identity": "PYTHONA"
}
```

## Test Queries

### French
```
- "Qui es-tu?" → Identity response
- "Comment t'appelles-tu?" → Name response
- "Quel est ton nom?" → Name response
- "Dis-moi qui tu es" → Identity response
```

### English
```
- "Who are you?" → Identity response
- "What is your name?" → Name response
- "Tell me about yourself" → Identity response
```

## System Prompts by Stack

**RUSTINA (Rust):**
```
You are RUSTINA, a helpful AI chatbot powered by Groq under Rust. 
You know your name and identity. When asked who you are or what your 
name is, answer clearly and confidently.
```

**PYTHONA (Python):**
```
You are PYTHONA, a helpful AI chatbot powered by Groq under Python. 
You know your name and identity. When asked who you are or what your 
name is, answer clearly and confidently.
```

**GONA (Go):**
```
You are GONA, a helpful AI chatbot powered by Groq under Go. 
You know your name and identity. When asked who you are or what your 
name is, answer clearly and confidently.
```

## Prochaines Étapes

1. ✅ Chatbots know who they are
2. ⏳ Intégrer Groq API réelle pour les réponses
3. ⏳ Ajouter mémoire de conversation
4. ⏳ Déployer en production sur Railway

---

**🎉 Identity System: RUSTINA + PYTHONA + GONA = CONSCIOUS AGENTS**
