
import bcrypt
from app import db

class Admin:
    @staticmethod
    def find_by_email(email):
        cursor = db.cursor()
        cursor.execute("SELECT * FROM Admins WHERE email_Admin = %s", (email,))
        admin = cursor.fetchone()
        cursor.close()
        return admin

    @staticmethod
    def check_password(stored_password, provided_password):
        """
        Vérifie le mot de passe fourni par rapport au mot de passe stocké haché.

        Args:
        stored_password (str): Le mot de passe haché stocké dans la base de données.
        provided_password (str): Le mot de passe fourni par l'administrateur.

        Returns:
        bool: True si le mot de passe correspond, False sinon.
        """
        return bcrypt.checkpw(provided_password.encode('utf-8'), stored_password.encode('utf-8'))
    
    @staticmethod
    def hash_password(password):
        """
        Hash le mot de passe fourni en utilisant bcrypt.

        Args:
        password (str): Le mot de passe à hacher.

        Returns:
        str: Le mot de passe haché.
        """
        return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
