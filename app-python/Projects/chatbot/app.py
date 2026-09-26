import os
from datetime import datetime
from pathlib import Path

import requests
from flask import Flask, Response, jsonify, request

app = Flask(__name__)

# Chatbot PYTHONA — même interface et même API que RUSTINA (app-rust/Projects/chatbot)
CHATBOT_NAME = "PYTHONA"
CHATBOT_VERSION = "1.0.0"
BOT_COLOR = "green"  # Émeraude
SYSTEM_PROMPT = "You are PYTHONA, a helpful AI chatbot powered by Groq under Python. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently."
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "openai/gpt-oss-20b"
TEMPLATE = (Path(__file__).parent / "templates" / "index.html").read_text(encoding="utf-8")


def groq_complete(messages):
    # Clé fournie par le .env de la racine du codespace (docker-compose env_file)
    api_key = os.environ.get("GROQ_API_KEY_CFC", "").strip()
    if not api_key:
        raise RuntimeError("GROQ_API_KEY_CFC est manquante sur le serveur.")
    try:
        response = requests.post(
            GROQ_URL,
            headers={"Authorization": f"Bearer {api_key}"},
            # Identité : le prompt système précède toujours la conversation
            json={"model": GROQ_MODEL, "messages": [{"role": "system", "content": SYSTEM_PROMPT}] + messages, "temperature": 0.7},
            timeout=60,
        )
    except requests.RequestException as error:
        raise RuntimeError(f"Impossible de joindre Groq : {error}")
    if not response.ok:
        raise RuntimeError(f"Groq a renvoyé le statut {response.status_code}.")
    choices = response.json().get("choices") or []
    if not choices:
        raise RuntimeError("Groq n’a renvoyé aucun message.")
    message = choices[0]["message"]
    return {"role": message["role"], "content": message["content"]}


def render_index():
    html = TEMPLATE.replace("__TIMESTAMP__", datetime.now().strftime("%d/%m/%Y %H:%M"))
    return Response(html, mimetype="text/html")


@app.route('/')
def index():
    return render_index()


@app.route('/chatbot', methods=['GET', 'POST'])
@app.route('/chatbot/', methods=['GET'])
def chatbot():
    if request.method == 'POST':
        data = request.get_json(silent=True) or {}
        user_message = data.get('message', '')
        try:
            reply = groq_complete([{"role": "user", "content": user_message}])
        except RuntimeError as error:
            return jsonify({"bot": CHATBOT_NAME, "error": str(error)}), 502
        return jsonify({
            "bot": CHATBOT_NAME,
            "user_input": user_message,
            "response": reply["content"],
            "identity": CHATBOT_NAME,
            "color": BOT_COLOR
        })

    return render_index()


@app.route('/api/chat', methods=['POST'])
def api_chat():
    data = request.get_json(silent=True)
    if not data or not isinstance(data.get('messages'), list):
        return jsonify({"error": "JSON invalide : champ messages attendu"}), 400
    try:
        return jsonify({"message": groq_complete(data['messages'])})
    except RuntimeError as error:
        return jsonify({"error": str(error)}), 502


@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "bot": CHATBOT_NAME,
        "color": BOT_COLOR,
        "identity_aware": True
    }), 200


@app.route('/identity', methods=['GET'])
def identity():
    return jsonify({
        "name": CHATBOT_NAME,
        "system_prompt": SYSTEM_PROMPT,
        "version": CHATBOT_VERSION,
        "color": BOT_COLOR,
        "knows_identity": True
    }), 200


if __name__ == '__main__':
    print(f"🐍 {CHATBOT_NAME} starting on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=False)
