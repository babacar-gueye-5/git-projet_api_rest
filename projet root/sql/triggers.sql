-- Trigger pour archiver les prompts supprimés dans une table ArchiverPrompts
CREATE OR REPLACE FUNCTION archive_prompt()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ArchivedPrompts (idPrompt, titre, description, date_creation, idUser)
    VALUES (OLD.idPrompt, OLD.titre, OLD.description, OLD.date_creation, OLD.idUser);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur pour archiver les prompts
CREATE TRIGGER after_prompt_delete
AFTER DELETE ON Prompts
FOR EACH ROW
EXECUTE FUNCTION archive_prompt();


-- Création de la fonction et du déclencheur pour gérer l'état "Rappel"
CREATE OR REPLACE FUNCTION set_prompt_reminder()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier si le prompt est toujours en attente après deux jours
    IF NEW.status = 'En attente' AND NEW.date_creation + interval '2 days' < current_timestamp THEN
        UPDATE Prompts
        SET status = 'Rappel'
        WHERE idPrompts = NEW.idPrompts;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur pour passer à l'état "Rappel" après deux jours sans action
CREATE TRIGGER trigger_set_prompt_reminder
AFTER INSERT OR UPDATE ON Prompts
FOR EACH ROW
EXECUTE FUNCTION set_prompt_reminder();



-- Créez une fonction pour calculer les votes et mettre à jour le statut du prompt
CREATE OR REPLACE FUNCTION update_prompt_status()
RETURNS TRIGGER AS $$
DECLARE
    total_votes INTEGER;
    prompt_creator_group INTEGER;Si un Prompt reste en état À supprimer pendant plus d'un jour sans action de
l'administrateur, il passe à l'état Rappel.
BEGIN
    -- Trouver le groupe de l'utilisateur qui a créé le prompt
    SELECT idGroup INTO prompt_creator_group
    FROM UserGroups
    WHERE idUser = (SELECT idUser FROM Prompts WHERE idPrompts = NEW.idPrompts);

    -- Calculer le total des votes pour le prompt concerné
    SELECT SUM(
        CASE
            WHEN (SELECT idGroup FROM UserGroups WHERE idUser = NEW.idUser) = prompt_creator_group THEN 2
            ELSE 1
        END
    ) INTO total_votes
    FROM Vote
    WHERE idPrompts = NEW.idPrompts; 

    -- Mettre à jour le statut du prompt si le total des votes atteint 6
    IF total_votes >= 6 THEN
        UPDATE Prompts
        SET status = 'Activer'
        WHERE idPrompts = NEW.idPrompts;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créez le trigger qui appelle cette fonction après l'insertion ou la mise à jour d'un vote
CREATE TRIGGER check_votes
AFTER INSERT OR UPDATE ON Vote
FOR EACH ROW
EXECUTE FUNCTION update_prompt_status();



-- Création de la fonction pour mettre à jour le prix
CREATE OR REPLACE FUNCTION update_prompt_price()
RETURNS TRIGGER AS $$
DECLARE
    avg_note NUMERIC;
    same_group_weight NUMERIC := 0.6;
    different_group_weight NUMERIC := 0.4;
BEGIN
    -- Calculer la moyenne pondérée des notes pour le prompt concerné
    SELECT SUM(
        CASE
            WHEN ug.idGroup = (SELECT ug2.idGroup FROM UserGroups ug2 WHERE ug2.idUser = p.idUser) THEN n.note * same_group_weight
            ELSE n.note * different_group_weight
        END
    ) / COUNT(n.idNote) INTO avg_note
    FROM Note n
    JOIN Users u ON n.idUser = u.idUser
    JOIN UserGroups ug ON u.idUser = ug.idUser
    JOIN Prompts p ON n.idPrompt = p.idPrompt
    WHERE n.idPrompt = NEW.idPrompt;

    -- Mettre à jour le prix du prompt en fonction de la moyenne pondérée des notes
    UPDATE Prompts
    SET price = 1000 * (1 + COALESCE(avg_note, 0))
    WHERE idPrompt = NEW.idPrompt;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur pour mettre à jour le prix des prompts basé sur les notes
CREATE TRIGGER trigger_update_prompt_price
AFTER INSERT OR UPDATE ON Note
FOR EACH ROW
EXECUTE FUNCTION update_prompt_price();


--  ajouter champ pour la date de la dernière mise à jour du statut 
ALTER TABLE Prompts ADD COLUMN status_last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

--une fonction qui met à jour le statut d'un prompt à "Rappel" si le statut est "À supprimer" depuis plus d'un jour 
CREATE OR REPLACE FUNCTION update_status_to_reminder()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'À supprimer' AND 
       NEW.status_last_updated < NOW() - INTERVAL '1 day' THEN
        UPDATE Prompts
        SET status = 'Rappel',
            status_last_updated = CURRENT_TIMESTAMP
        WHERE idPrompt = NEW.idPrompt;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--
CREATE TRIGGER check_status_to_reminder
AFTER UPDATE ON Prompts
FOR EACH ROW
EXECUTE FUNCTION update_status_to_reminder();
