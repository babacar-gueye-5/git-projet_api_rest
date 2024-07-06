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
CREATE TABLE Users (
    idUser SERIAL PRIMARY KEY,
    username_User VARCHAR(255) NOT NULL,
    email_User VARCHAR(255) UNIQUE NOT NULL,
    password_User VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL -- Peut être 'user', ou 'visitor'
    idGroup INTEGER,
    FOREIGN KEY (idGroup) REFERENCES UserGroups(idGroup) ON DELETE SET NULL
);

-- creation table des utilisateurs
CREATE TABLE Admin (
    idAdmin SERIAL PRIMARY KEY,
    username_Admin VARCHAR(255) NOT NULL,
    email_Admin VARCHAR(255) UNIQUE NOT NULL,
    password_Admin VARCHAR(255) NOT NULL,
);


-- creation table des Prompts
CREATE TABLE Prompts (
	idPrompts SERIAL PRIMARY KEY,
	titre vARCHAR (255) NOT NULL,
	description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'En attente', -- État initial
	date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idUser INTEGER,
    FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE SET NULL
);

-- creation table Groupe 

CREATE TABLE UserGroups (
    idGroup SERIAL PRIMARY KEY,
    nameGroup VARCHAR(255) NOT NULL,
    descriptionGroup TEXT NOT NULL,
    date_creation_group TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
    idAdmin INTEGER,
    FOREIGN KEY (idAdmin) REFERENCES Admin(idAdmin) ON DELETE SET NULL   
);

-- creation table Vote 

CREATE TABLE Vote (
	vote INTEGER,
	idUser INTEGER,
	idPrompts INTEGER,
	FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
	FOREIGN KEY (idPrompts) REFERENCES Prompts(idPrompts) ON DELETE CASCADE
);

