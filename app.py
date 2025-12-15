from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return '<h1>Bienvenue sur mon application Python conteneurisée sur GKE ceci est la V2 !</h1>'

if __name__ == '__main__':
    # Écoute sur toutes les interfaces (nécessaire pour Docker)
    app.run(host='0.0.0.0', port=8080)