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

CREATE TABLE Users (
    idUser SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL -- Peut être 'admin', 'user', ou 'visitor'
);

-- creation table des Prompts
CREATE TABLE Prompts (
	idPrompts SERIAL PRIMARY KEY,
	titre vARCHAR (255) NOT NULL,
	description TEXT NOT NULL,
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
);

-- creation table Vote 

CREATE TABLE Vote (
	vote INTEGER,
	idUser INTEGER,
	idPrompts INTEGER,
	FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
	FOREIGN KEY (idPrompts) REFERENCES Prompts(idPrompts) ON DELETE CASCADE
);

