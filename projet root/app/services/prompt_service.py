from app.email import send_email
from app.models import Prompts, Users

def update_prompt_status(id_prompt, new_status):
    prompt = Prompts.query.get(id_prompt)
    if prompt:
        prompt.status = new_status
        db.session.commit()
        
        # Envoyer un email de notification aux administrateurs
        admin_emails = [user.email for user in Users.query.filter_by(role='admin').all()]
        send_email(
            subject="Notification de changement d'état du prompt",
            sender=app.config['ADMINS'][0],
            recipients=admin_emails,
            text_body=f"L'état du prompt '{prompt.title}' a été mis à jour à '{new_status}'.",
            html_body=f"<p>L'état du prompt <strong>{prompt.title}</strong> a été mis à jour à <strong>{new_status}</strong>.</p>"
        )

from app import db, app

def request_prompt_modification(id_prompt):
    prompt = Prompts.query.get(id_prompt)
    if prompt:
        prompt.status = 'À revoir'
        db.session.commit()
        
        # Trouver l'utilisateur propriétaire du prompt
        user = Users.query.get(prompt.idUser)
        if user:
            send_email(
                subject="Notification de modification du prompt",
                sender=app.config['ADMINS'][0],
                recipients=[user.email_User],
                text_body=f"Votre prompt '{prompt.title}' a été mis à jour à l'état 'À revoir' par l'administrateur.",
                html_body=f"<p>Votre prompt <strong>{prompt.title}</strong> a été mis à jour à l'état <strong>'À revoir'</strong> par l'administrateur.</p>"
            )
