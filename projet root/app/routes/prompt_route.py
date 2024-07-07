from flask import Blueprint, request, jsonify
from app.services.prompt_service import request_prompt_modification

prompt_routes = Blueprint('prompt_routes', __name__)

@prompt_routes.route('/prompts/<int:id_prompt>/request_modification', methods=['POST'])
def request_modification(id_prompt):
    request_prompt_modification(id_prompt)
    return jsonify({"message": "Modification request sent and prompt status updated to 'À revoir'."}), 200


# app/routes/prompt_routes.py

from flask import Blueprint, request, jsonify
from app import app, db
from app.db import get_db

prompt_bp = Blueprint('prompt', __name__)

@prompt_bp.route('/prompts', methods=['GET'])
def get_prompts():
    # Exemple de route pour obtenir tous les prompts
    db = get_db()
    cursor = db.cursor()
    cursor.execute('SELECT * FROM prompts;')
    prompts = cursor.fetchall()
    db.close()
    return jsonify(prompts), 200
