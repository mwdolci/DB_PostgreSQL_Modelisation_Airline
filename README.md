Pour le premier cours de bases de données du 2 décembre, assurez-vous d'avoir PostgreSQL (https://www.postgresql.org) fonctionnel sur votre ordinateur.

Vous pouvez installer PostgreSQL localement ou utiliser le conteneur Docker préparé pour le cours. Le conteneur sera surtout utile pour Windows, l'installation locale sur des machines macOS / Linux étant beaucoup plus simple.

### Conteneur Docker

1. - Sur macOS / Linux : installer Docker Desktop. **Normalement déjà fait pour vos autres cours**.
   - Sur Windows : installer Docker Desktop + WSL2. Utilisez *PowerShell* ou *Windows Terminal*, pas CMD.  *Git Bash* est aussi possible, mais déconseillé. **Normalement déjà fait pour vos autres cours**.

2. Téléchargez le fichier `cours-bd-MASRAD-docker.zip` joint à ce message ou sur la page web du cours et décompressez-le.

3. Dans un terminal, allez dans le répertoire:

   ```bash
   cd cours-bd-MASRAD-docker
   ```

4. - Ouvrez le ficher `docker-compose.yml` et observez les lignes 19 - 23. 

     ```yaml
     # Répertoire local où nous mettrons les fichers .sql. Ajustez en fonction de vos besoins.
     # Windows
     # - C:/Users/chris/Documents/MAS-RAD/cours/cas_daw/cas-daw-Base-Donnee/Exercices-20251201:/sqlfiles
     # macOS / linux
     # - /Users/huguesm/Documents/cours/MASRAD-IBD-BDA/2025-2026/exercices:/sqlfiles
     ```

   - Choisissez un répertoire local sur votre ordinateur où nous pourrons déposer des fichiers .sql pendant le cours.

   - Sur Windows, décommentez la ligne 21 et ajustez le chemin vers le répertoire choisi (avant :/sqlfiles).

   - Sur macOS / linux, décommentez la ligne 23 et ajustez le chemin vers le répertoire choisi (avant :/sqlfiles).

   - Sauvegardez le fichier.

5. Lancez le conteneur:

    ```bash
    docker compose up
    ```

6. Dans un autre terminal, démarrez psql :

    ```bash
    docker exec -it cours-bd-masrad psql -U etudiant -d bd_masrad
    ```

    Vous devriez voir apparaître :

    ```bash
    bd_masrad=#
    ```

    Note: Si vous utilisez Git Bash, vous devrez probablement démarrer psql avec

    ```bash
    winpty docker exec -it cours-bd-masrad psql -U etudiant -d bd_masrad
    ```

7. Faites un test et entrez votre première requête SQL sur le terminal: 

    ```sql
    SET SEARCH_PATH TO IBD_schema_test;
    SELECT * FROM items;
    ```

    Vous devriez obtenir :

    ```sql
    1 | un premier item quelconque | 2025-11-13 14:58:15.769714+00
    ```

8. Pour insérer un fichier .sql, par exemple, `IBD-Exercice-1-data.sql`, vous pouvez le déposer dans votre répertoire choisi à l'étape 4. et exécuter

   ```sql
   \i /sqlfiles/IBD-Exercice-1-data.sql
   ```

9. Faites un dernier test et entrez votre deuxième requête SQL sur le terminal: 

   ```sql
   SELECT * FROM customer;
   ```

   Le résultat devrait être une grosse table de clients. Si c'est le cas, vous pouvez faire l'exercice 1.

Le conteneur Docker contient également pgadmin (https://www.pgadmin.org), un GUI pour PostgreSQL, accessible à http://localhost:8080 dans votre navigateur une fois le conteneur en opération. Prenez note que je n'utiliserai pas pgadmin pendant le cours, mais que certains d'entre vous le trouverons peut-être utile.

Vous pouvez me contacter à hugues.mercier@he-arc.ch. Bonne préparation!  

# DB_PostgreSQL_Modelisation_Airline
