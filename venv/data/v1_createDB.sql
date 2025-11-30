--Epreuves part
CREATE TABLE IF NOT EXISTS Disciplines(
    id_discipline INTEGER,
    nom_discipline TEXT NOT NULL,
	CONSTRAINT pk_auto_id_discipline PRIMARY KEY(id_discipline AUTOINCREMENT),
    CONSTRAINT un_nom_discipline UNIQUE (nom_discipline)
);

CREATE TABLE IF NOT EXISTS Epreuves(
    id_epreuve INTEGER,
    nom_epreuve TEXT NOT NULL,
    forme_epreuve TEXT NOT NULL,
    categorie_epreuve TEXT NOT NULL,
    date_epreuve NUMERIC,
    nb_sportif_epreuve INTEGER,
    id_discipline INTEGER NOT NULL,
	CONSTRAINT pk_auto_id_epreuve PRIMARY KEY(id_epreuve),
    CONSTRAINT fk_id_discipline FOREIGN KEY (id_discipline) REFERENCES Disciplines(id_discipline),
    CONSTRAINT ck_forme_epreuve CHECK (forme_epreuve = "individuelle" OR forme_epreuve = "par equipe" OR forme_epreuve = "par couple"),
    CONSTRAINT ck_categorie_epreuve CHECK (categorie_epreuve = "masculin" OR categorie_epreuve = "feminin" OR categorie_epreuve = "mixte"),
    CONSTRAINT un_nom_epreuve UNIQUE(nom_epreuve)
);

--Sportifs part:

CREATE TABLE IF NOT EXISTS Pays(
    id_pays INTEGER,
    nom_pays TEXT NOT NULL,
	CONSTRAINT pk_auto_id_pays PRIMARY KEY (id_pays AUTOINCREMENT),
    CONSTRAINT un_nom_pays UNIQUE(nom_pays)
);

CREATE TABLE IF NOT EXISTS Sportifs(
    id_sportif INTEGER,
    nom_sportif TEXT NOT NULL,
    prenom_sportif TEXT NOT NULL,
    date_naissance_sportif NUMERIC NOT NULL,
    categorie_sportif TEXT NOT NULL,
    id_pays INTEGER NOT NULL,
	CONSTRAINT pk_id_sportif PRIMARY KEY (id_sportif),
    CONSTRAINT fk_id_pays FOREIGN KEY (id_pays) REFERENCES Pays(id_pays),
    CONSTRAINT un_nom_prenom_sportif UNIQUE(nom_sportif, prenom_sportif),
    CONSTRAINT ck_id_sportif CHECK (id_sportif >= 1000 AND id_sportif <= 1500)
);

CREATE TABLE IF NOT EXISTS Equipes(
    id_equipe INTEGER NOT NULL,
    nom_equipe TEXT NOT NULL DEFAULT "No Name Team",
	CONSTRAINT pk_id_equipe PRIMARY KEY (id_equipe),
    CONSTRAINT ck_id_equipe CHECK (id_equipe >= 1 AND id_equipe <= 100)
);

CREATE TABLE IF NOT EXISTS Engager(
    id_sportif INTEGER NOT NULL,
    id_equipe INTEGER NOT NULL,
    CONSTRAINT pk_id_sportif_equipe PRIMARY KEY (id_sportif, id_equipe),
    CONSTRAINT fk_id_sportif FOREIGN KEY (id_sportif) REFERENCES Sportifs(id_sportif) ON DELETE CASCADE,
    CONSTRAINT fk_id_equipe FOREIGN KEY (id_equipe) REFERENCES Equipes(id_equipe) ON DELETE CASCADE
);
--ON DELETE CASCADE pour contourner le triggers si on veut supprimer complètement une équipe !


--Resultats part:

CREATE TABLE IF NOT EXISTS Medailles(
    id_participant INTEGER,
    id_epreuve INTEGER,
    type_medaille TEXT NOT NULL,
    CONSTRAINT pk_id_participant_epreuve PRIMARY KEY (id_participant, id_epreuve),
    CONSTRAINT fk_id_epreuve FOREIGN KEY (id_epreuve) REFERENCES Epreuves(id_epreuve),
    CONSTRAINT type_medaille CHECK (type_medaille = "or" OR type_medaille = "argent" OR type_medaille = "bronze"),
    CONSTRAINT un_id_epreuve_type_medaille UNIQUE(id_epreuve, type_medaille)
);

-- Participation part:

CREATE TABLE IF NOT EXISTS Participe(
    id_participant INTEGER,
    id_epreuve INTEGER,
    CONSTRAINT pk_id_participant PRIMARY KEY (id_participant, id_epreuve),
    CONSTRAINT fk_id_epreuve FOREIGN KEY (id_epreuve) REFERENCES Epreuves(id_epreuve)
);