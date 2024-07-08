# app/routes/auth_routes.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, JWTManager
from app.models.user_model import User
from app.models.admin_model import Admin

auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    # Récupérer les données JSON envoyées par l'utilisateur
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    role = data.get('role')

    # Trouver l'utilisateur ou l'administrateur par email
    if role == 'admin':
        user = Admin.find_by_email(email)
        user_id = 'idAdmin'
    else:
        user = User.find_by_email(email)
        user_id = 'idUser'

    # Vérifier le mot de passe et créer un token JWT si les informations sont correctes
    if user and Admin.check_password(user[3], password) if role == 'admin' else User.check_password(user[3], password):
        access_token = create_access_token(identity={'id': user[0], 'role': role})
        return jsonify(access_token=access_token), 200

    # Retourner une réponse d'erreur si les informations sont incorrectes
    return jsonify({"msg": "Bad email or password"}), 401

def init_routes(app):
    # Enregistrer le blueprint d'authentification dans l'application
    app.register_blueprint(auth_bp)


from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, JWTManager
from app import db

auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    # Vérifiez dans la table Admins
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Admins WHERE email_Admin = %s", (email,))
    admin = cursor.fetchone()
    
    # Vérifier le mot de passe et créer un token JWT si les informations sont correctes
    if admin and check_password(admin[3], password):  # Assuming password is the 4th column
        access_token = create_access_token(identity={'id': admin[0], 'role': 'admin'})
        cursor.close()
        return jsonify(access_token=access_token), 200
    
    # Si non trouvé, vérifiez dans la table Users
    cursor.execute("SELECT * FROM Users WHERE email_User = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    
    # Vérifier le mot de passe et créer un token JWT si les informations sont correctes
    if user and check_password(user[3], password):  # Assuming password is the 4th column
        access_token = create_access_token(identity={'id': user[0], 'role': 'user'})
        return jsonify(access_token=access_token), 200
    
    # Retourner une réponse d'erreur si les informations sont incorrectes
    return jsonify({"msg": "erreur sur votre email ou votre mot de passe"}), 401

def check_password(stored_password, provided_password):
    # Vérification simple du mot de passe (ajustez cette logique selon vos besoins)
    return stored_password == provided_password

def init_routes(app):
    # Enregistrer le blueprint d'authentification dans l'application
    app.register_blueprint(auth_bp)

