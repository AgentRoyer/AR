FROM python:3.11-slim
WORKDIR /app/projects
COPY ./Projects ./
RUN pip install --no-cache-dir -r chatbot/requirements.txt
WORKDIR /app/projects/chatbot
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1
ENV FLASK_APP=app.py
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
