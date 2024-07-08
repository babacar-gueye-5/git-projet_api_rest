import psycopg2
from flask import g, current_app

def get_db():
    if 'db' not in g:
        # Ouvrir une nouvelle connexion si elle n'existe pas dans le contexte global
        g.db = psycopg2.connect(
            dbname=current_app.config['gestion_prompts'],
            user=current_app.config['postgres'],
            password=current_app.config['jamdong05'],
            host=current_app.config['localhost'],
            port=current_app.config['5432']
        )
    return g.db

def close_db(e=None):
    # Fermer la connexion à la base de données si elle existe
    db = g.pop('db', None)
    if db is not None:
        db.close()

def init_db(app):
    # Enregistrer la fonction de fermeture de la base de données dans le contexte de l'application
    app.teardown_appcontext(close_db)
