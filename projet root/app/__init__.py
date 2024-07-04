from flask import Flask
from .db import init_db

def create_app():
    app = Flask(__name__)
    app.config.from_pyfile('../config.py')
    
    init_db(app)

    from .routes.auth_routes import auth_bp
    from .routes.prompt_routes import prompt_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(prompt_bp, url_prefix='/prompts')

    return app
