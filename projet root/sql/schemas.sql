-- Database: gestion promts

-- DROP DATABASE IF EXISTS "gestion promts";

CREATE DATABASE "gestion promts"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'fr_FR.UTF-8'
    LC_CTYPE = 'fr_FR.UTF-8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- creation des tables de la base de donnees 

-- creation table des utilisateurs
DROP TABLE IF EXISTS Admins;
CREATE TABLE Admins (
    idAdmin SERIAL PRIMARY KEY,
    username_Admin VARCHAR(255) NOT NULL,
    email_Admin VARCHAR(255) UNIQUE NOT NULL,
    password_Admin VARCHAR(255) NOT NULL,
);


-- creation table des utilisateurs
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    idUser SERIAL PRIMARY KEY,
    username_User VARCHAR(255) NOT NULL,
    email_User VARCHAR(255) UNIQUE NOT NULL,
    password_User VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL -- Peut être 'user', ou 'visitor'
    idGroup INTEGER,
    FOREIGN KEY (idGroup) REFERENCES UserGroups(idGroup) ON DELETE SET NULL
);


-- creation table des Prompts
DROP TABLE IF EXISTS Prompts;
CREATE TABLE Prompts (
	idPrompt SERIAL PRIMARY KEY,
	titre vARCHAR (255) NOT NULL,
	description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'En attente', -- État initial
    prixPrompt INTEGER DEFAULT 1000, -- État initial
	date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idUser INTEGER,
    FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE SET NULL
);


-- creation table Groupe 
DROP TABLE IF EXISTS UserGroups;
CREATE TABLE UserGroups (
    idGroup SERIAL PRIMARY KEY,
    nameGroup VARCHAR(255) NOT NULL,
    descriptionGroup TEXT NOT NULL,
    date_creation_group TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
    idAdmin INTEGER,
    FOREIGN KEY (idAdmin) REFERENCES Admin(idAdmin) ON DELETE SET NULL   
);


-- creation table Vote 
DROP TABLE IF EXISTS Vote;
CREATE TABLE Vote (
	vote INTEGER,
	idUser INTEGER,
	idPrompt INTEGER,
	FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
	FOREIGN KEY (idPrompt) REFERENCES Prompts(idPrompt) ON DELETE CASCADE
);

-- creation table Note 
DROP TABLE IF EXISTS Note;
CREATE TABLE Note (
	note INTEGER,
	idUser INTEGER,
	idPrompt INTEGER,
	FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
	FOREIGN KEY (idPrompt) REFERENCES Prompts(idPrompt) ON DELETE CASCADE
);


-- creation table ArchiverPrompts
DROP TABLE IF EXISTS Note;
CREATE TABLE ArchiverPrompts (
    idPrompt SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    date_creation TIMESTAMP,
    idUser INTEGER,
    date_archived TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




-- Trigger pour archiver les prompts supprimés dans une table ArchiverPrompts
CREATE OR REPLACE FUNCTION archive_prompt()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ArchivedPrompts (idPrompt, titre, description, date_creation, idUser)
    VALUES (OLD.idPrompt, OLD.titre, OLD.description, OLD.date_creation, OLD.idUser);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_prompt_delete
AFTER DELETE ON Prompts
FOR EACH ROW
EXECUTE FUNCTION archive_prompt();


-- Créez une fonction pour calculer les votes et mettre à jour le statut du prompt
CREATE OR REPLACE FUNCTION update_prompt_status()
RETURNS TRIGGER AS $$
DECLARE
    total_votes INTEGER;
    prompt_creator_group INTEGER;
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



