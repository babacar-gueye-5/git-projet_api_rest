# config.py

import os
# Configuration de la base de données PostgreSQL
class Config:
    # Clé secrète pour sécuriser les sessions et les tokens JWT
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your_secret_key'
    
    # URI de la base de données PostgreSQL
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'postgresql://username:password@localhost/dbname'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Clé secrète pour JWT
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'your_jwt_secret_key'
    
    # Détails de la connexion à la base de données
    DATABASE_HOST = 'localhost'
    DATABASE_PORT = '5432'
    DATABASE_USER = 'postgres'
    DATABASE_PASSWORD = 'jamdong05'
    DATABASE_NAME = 'gestion_prompts'



class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'postgresql://username:password@localhost/gestion_prompts'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    MAIL_SERVER = 'smtp.gmail.com'
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.environ.get('babakargueye05@gmail.com')  # votre adresse e-mail
    MAIL_PASSWORD = os.environ.get('mbaye555')  # votre mot de passe e-mail
    ADMINS = ['babakargueye05@gmail.com']  # liste des administrateurs à notifier


