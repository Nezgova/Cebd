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

--VIEWS
--Nombres de participants à une épreuve
CREATE VIEW IF NOT EXISTS V_participants_epreuves AS
	SELECT nom_epreuve, COUNT(id_participant)
	FROM Participe JOIN Epreuves USING(id_epreuve)
	GROUP BY nom_epreuve;

--Nombre d'épreuve associer à une discipline
CREATE VIEW IF NOT EXISTS V_epreuve_discipline AS
	SELECT nom_discipline, COUNT(id_epreuve)
    FROM Disciplines JOIN Epreuves USING (id_discipline)
    GROUP BY nom_discipline;
    
--Pays par equipe
CREATE VIEW IF NOT EXISTS V_nomPaysParEquipe AS
	SELECT id_equipe, nom_pays
	FROM Engager E1 JOIN Sportifs S1 ON (E1.id_sportif = S1.id_sportif)
	JOIN Pays P1 ON (P1.id_pays = S1.id_pays)
	GROUP BY id_equipe;

--VU DEMANDER:
--Calculs des ages du sportifs
CREATE VIEW IF NOT EXISTS V_LesAgesSportifs AS
    SELECT id_sportif, nom_sportif, prenom_sportif, nom_pays, categorie_sportif, date_naissance_sportif, 
    (STRFTIME('%Y-', 'now') - STRFTIME('%Y-', date_naissance_sportif) - 
		(
		STRFTIME('%m-%d', 'now') < 
		STRFTIME('%m-%d', date_naissance_sportif)
		)) AS age_sportif
    FROM Sportifs JOIN Pays USING (id_pays);

--Nombres d'équipiers
CREATE VIEW IF NOT EXISTS V_LesNbsEquipiers AS
	SELECT id_equipe, COUNT(id_sportif) AS nbEquipiers
	FROM Engager
	GROUP BY id_equipe;

--Age moyen par équipe qui ont gagné l'or
CREATE VIEW IF NOT EXISTS V_AgeMoyenParEquipeGagnerOr AS
	SELECT id_equipe, AVG(age_sportif) as MoyenneAge
	FROM Engager E1 JOIN V_LesAgesSportifs A1 ON (E1.id_sportif = A1.id_sportif)
	JOIN Medailles M1 ON (E1.id_equipe = M1.id_participant AND M1.type_medaille = 'or')
	GROUP BY id_equipe;-- Medailles par pays
CREATE VIEW IF NOT EXISTS V_ClassementPaysMedaille AS
WITH MedaillesParPays AS (
    SELECT
        M.id_epreuve,
        M.type_medaille,
        P.nom_pays
    FROM Medailles M
    JOIN Sportifs S ON M.id_participant = S.id_sportif 
    JOIN Pays P ON S.id_pays = P.id_pays
    WHERE M.id_participant BETWEEN 1000 AND 1500 
    UNION ALL
    SELECT
        M.id_epreuve,
        M.type_medaille,
        P.nom_pays
    FROM Medailles M
    JOIN Engager EN ON M.id_participant = EN.id_equipe 
    JOIN Sportifs S ON EN.id_sportif = S.id_sportif
    JOIN Pays P ON S.id_pays = P.id_pays
    WHERE M.id_participant BETWEEN 1 AND 100
    GROUP BY M.id_epreuve, M.type_medaille, P.nom_pays 
)
SELECT
    nom_pays,
    SUM(CASE WHEN type_medaille = 'or' THEN 1 ELSE 0 END) AS nbOr,
    SUM(CASE WHEN type_medaille = 'argent' THEN 1 ELSE 0 END) AS nbArgent,
    SUM(CASE WHEN type_medaille = 'bronze' THEN 1 ELSE 0 END) AS nbBronze
FROM MedaillesParPays
GROUP BY nom_pays
ORDER BY nbOr DESC, nbArgent DESC, nbBronze DESC;
