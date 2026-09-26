from flask import Flask, jsonify, request

app = Flask(__name__)

# Chatbot PYTHONA
CHATBOT_NAME = "PYTHONA"
CHATBOT_VERSION = "1.0.0"

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
        return jsonify({
            "bot": CHATBOT_NAME,
            "user_input": user_message,
            "response": f"Hello from {CHATBOT_NAME}! You said: {user_message}"
        })
    
    return jsonify({
        "bot": CHATBOT_NAME,
        "message": "Use POST to send messages to chatbot"
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "bot": CHATBOT_NAME
    }), 200

if __name__ == '__main__':
    print(f"🐍 {CHATBOT_NAME} starting on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=False)
