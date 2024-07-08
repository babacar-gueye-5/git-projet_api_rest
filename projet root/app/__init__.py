
from flask import Flask
from flask_jwt_extended import JWTManager
from config import Config
from app.routes.authentif_route import init_routes
from app.db import get_db, close_db

app = Flask(__name__)
app.config.from_object(Config)

# Configuration de JWT
jwt = JWTManager(app)

# Enregistrement des routes
init_routes(app)

@app.teardown_appcontext
def teardown_db(error):
    close_db()



from flask_mail import Mail
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

mail = Mail(app)

from app import routes, models


# app/__init__.py






