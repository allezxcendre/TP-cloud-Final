# Utilise une image de base Python légère
FROM python:3.9-slim

# Définit le répertoire de travail dans le conteneur
WORKDIR /app

# Copie le fichier requirements.txt et installe les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie le reste du code source
COPY . .

# Expose le port par lequel l'application s'exécutera
EXPOSE 8080

# Commande à exécuter lorsque le conteneur démarre
CMD ["python", "app.py"]