# README.md — Modélisation d’une base de données PostgreSQL pour une compagnie aérienne

## 📌 Présentation du projet

Ce projet a été réalisé dans le cadre du cours **Base de Données Avancé (MAS-RAD / CAS-DAW)**.

L’objectif principal est de **concevoir et implémenter une base de données relationnelle complète pour la gestion d’une compagnie aérienne**, en appliquant les bonnes pratiques de modélisation SQL :

* création de schémas relationnels
* définition des clés primaires et étrangères
* contraintes d’intégrité (`CHECK`, `NOT NULL`, etc.)
* organisation logique des données
* insertion et interrogation des données via SQL

Le projet est exécuté avec **PostgreSQL dans Docker**, ce qui permet de lancer rapidement un environnement prêt à l’emploi.

---

## ✈️ Sujet traité : Gestion d’une compagnie aérienne

La base de données modélise plusieurs entités métier liées au transport aérien, notamment :

* aéroports
* vols et segments de vols
* avions et configurations
* passagers
* réservations
* classes tarifaires
* relations entre trajets, clients et vols

Le script principal du projet crée notamment un schéma nommé :

```sql
airline
```

---

## 🛠️ Technologies utilisées

* PostgreSQL
* Docker Desktop
* PowerShell
* SQL (DDL / DML)

---

## 📁 Structure du projet

```text
SQL/
│── Docker/
│   │── docker-compose.yml
│   │── BD/
│   │   └── Dolci_TP_BD_airline.sql
│
│── README.md
```

---

## 🚀 Lancer le projet

## 1. Se placer dans le dossier Docker

```powershell
cd SQL\Docker
```

---

## 2. Démarrer Docker

Lancer Docker Desktop.

---

## 3. Lancer PostgreSQL

Dans un premier terminal :

```powershell
docker compose up
```

---

## 4. Ouvrir PostgreSQL

Dans un second terminal :

```powershell
docker exec -it cours-bd-masrad psql -U etudiant -d bd_masrad
```

---

## 5. Exécuter le script principal du projet

Dans PostgreSQL :

```sql
\i /sqlfiles/Dolci_TP_BD_airline.sql
```

Ce script :

* supprime puis recrée le schéma `airline`
* crée les tables
* ajoute les contraintes
* prépare la base pour les requêtes

---

## 🧪 Exemple de requêtes utiles

Lister les tables :

```sql
\dt airline.*
```

Changer de schéma :

```sql
SET search_path TO airline;
```

Afficher les passagers :

```sql
SELECT * FROM passager;
```

---

## 🛑 Arrêter le projet

```powershell
docker compose down
```

---

## 📚 Objectifs pédagogiques du projet

Ce travail démontre la maîtrise des notions suivantes :

* modélisation relationnelle
* normalisation des données
* intégrité référentielle
* création de structures SQL robustes
* manipulation de PostgreSQL
* utilisation de Docker pour l’environnement de développement

---

## 👨‍💻 Auteur

Projet réalisé par **Marco Dolci** dans le cadre du cursus **MAS-RAD / CAS-DAW**.
