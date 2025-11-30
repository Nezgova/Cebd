import sqlite3, pandas
from sqlite3 import IntegrityError

def read_excel_file_V0(data:sqlite3.Connection, file):
    df_sportifs = pandas.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_sportifs = df_sportifs.where(pandas.notnull(df_sportifs), 'null')

    #Sportifs:
    cursor = data.cursor()
    for ix, row in df_sportifs.iterrows():
        try:
            query = "INSERT OR IGNORE INTO Pays(nom_pays) VALUES ('{}')".format(
                row['pays']
            )
            print(query)
            cursor.execute(query)
            
            query = "INSERT OR IGNORE INTO Equipes(id_equipe) VALUES ('{}')".format(
                row['numEq']
            )
            print(query)
            cursor.execute(query)

            query = "INSERT OR IGNORE INTO Sportifs(id_sportif, nom_sportif, prenom_sportif, categorie_sportif, date_naissance_sportif, id_pays) VALUES ('{}','{}','{}','{}','{}', (SELECT id_pays FROM Pays WHERE nom_pays = '{}') )".format(
                row['numSp'], row['nomSp'], row['prenomSp'], row['categorieSp'], row['dateNaisSp'], row['pays']
                )
            print(query)
            cursor.execute(query)

            query = "INSERT OR IGNORE INTO Engager(id_sportif, id_equipe) VALUES ('{}', '{}')".format(
                row['numSp'],  row['numEq']
            )
            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(err)

    #Epreuves
    df_epreuves = pandas.read_excel(file, sheet_name='LesEpreuves', dtype=str)
    df_epreuves = df_epreuves.where(pandas.notnull(df_epreuves), 'null')

    cursor = data.cursor()
    for ix, row in df_epreuves.iterrows():
        try:
            query = "INSERT OR IGNORE INTO Disciplines(nom_discipline) VALUES ('{}')".format(
                row['nomDi']
            )
            print(query)
            cursor.execute(query)

            query = "INSERT OR IGNORE INTO Epreuves(id_epreuve, nom_epreuve, forme_epreuve, categorie_epreuve, date_epreuve, nb_sportif_epreuve, id_discipline) VALUES ({},'{}','{}','{}','{}','{}', (SELECT id_discipline FROM Disciplines WHERE nom_discipline = '{}'))".format(
                row['numEp'], row['nomEp'], row['formeEp'], row['categorieEp'], row['dateEp'], row['nbSportifsEp'], row['nomDi'])

            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}")

    #Inscriptions:
    df_inscriptions = pandas.read_excel(file, sheet_name='LesInscriptions', dtype=str)

    cursor = data.cursor()
    for ix, row in df_inscriptions.iterrows():
        try:
            query = "INSERT OR IGNORE INTO Participe(id_participant, id_epreuve) VALUES ('{}','{}')".format(
                row['numIn'], row['numEp']
            )
            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}")

    #Résultats:
    df_resultats = pandas.read_excel(file, sheet_name='LesResultats', dtype=str)

    cursor = data.cursor()
    for ix, row in df_resultats.iterrows():
        try:
            query = "INSERT OR IGNORE INTO Medailles(id_epreuve,id_participant, type_medaille) VALUES ('{}','{}','{}')".format(
                row['numEp'], row['gold'], 'or'
            )
            print(query)
            cursor.execute(query)

            query = "INSERT OR IGNORE INTO Medailles(id_epreuve,id_participant, type_medaille) VALUES ('{}','{}','{}')".format(
                row['numEp'], row['silver'], 'argent'
            )
            print(query)
            cursor.execute(query)

            query = "INSERT OR IGNORE INTO Medailles(id_epreuve,id_participant, type_medaille) VALUES ('{}','{}','{}')".format(
                row['numEp'], row['bronze'], 'bronze'
            )
            
            # On affiche la requête pour comprendre la construction. A enlever une fois compris.
            print(query)
            cursor.execute(query)
        except IntegrityError as err:
            print(f"{err} : \n{row}")