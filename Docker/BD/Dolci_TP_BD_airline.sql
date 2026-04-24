\qecho '------------------------------------------------------------'
\qecho 'TP Dolci Marco'
\qecho '------------------------------------------------------------'
\qecho
\qecho '------------------------------------------------------------'
\qecho 'Création des tables pour la gestion d une compagnie aérienne'
\qecho '------------------------------------------------------------'
\qecho 'Je commence par supprimer le schéma airline s il existe déjà pour éviter les problèmes de doublons,'
\qecho 'puis je crée le schéma et je définis le search_path pour travailler dans ce schéma'
\qecho
\qecho 'CASCADE signifie que si le schéma existe déjà, il sera supprimé avec toutes les tables et objets qu il contient,'
\qecho 'ce qui permet de repartir d une base propre sans erreurs de doublons'
\qecho
\qecho 'SET search_path = variable PostgreSQL'
\qecho '\pset pager off = pour éviter less dans terminal'

\pset pager off

DROP SCHEMA IF EXISTS airline CASCADE;
CREATE SCHEMA airline;
SET search_path TO airline;


\qecho
\qecho '------------------------------------------------------------'
\qecho 'Création des tables'
\qecho '------------------------------------------------------------'
\qecho
\qecho 'Je crée la table aeroport avec comme clé primaire le code de l aeroport fixe à 3 caractères, puis la ville et le nom de l aeroport'
\qecho 'Je contrôle que la ville et le nom ne sont pas nuls'
CREATE TABLE aeroport (
    code CHAR(3) PRIMARY KEY,
    ville VARCHAR(80) NOT NULL,
    nom VARCHAR(80) NOT NULL
);
\echo '--- aeroport ---'
SELECT * FROM aeroport;


\qecho
\qecho 'Je crée la table configuration (correspond à la configuration de l avion) avec comme clé primaire un identifiant de configuration,'
\qecho 'puis le nombre de sièges de cette configuration'
\qecho
\qecho 'Je contrôle que le nombre de sièges soit supérieur à 0'
CREATE TABLE configuration (
    id_config INT PRIMARY KEY,
    nombre_sieges INT NOT NULL CHECK (nombre_sieges > 0)
);
\echo '--- configuration ---'
SELECT * FROM configuration;


\qecho
\qecho 'Je crée la table classe_tarifaire avec comme clé primaire le nom de la classe tarifaire limité à 20 caractères'
CREATE TABLE classe_tarifaire (
    nom_classe VARCHAR(20) PRIMARY KEY
);
\echo '--- classe_tarifaire ---'
SELECT * FROM classe_tarifaire;


\qecho
\qecho 'Je remplis la table classe_tarifaire avec les différentes classes tarifaires, de sorte à ce que les données soient prêtes pour les autres tables qui en ont besoin'
INSERT INTO classe_tarifaire VALUES
('First'),
('Business'),
('Economy+'),
('Economy');
\qecho
\qecho 'Je crée la table passager avec comme clé primaire un identifiant de passager, puis le nom du passager et son numéro de fidélisation (qui peut être nul car optionnel)'
CREATE TABLE passager (
    id_passager INT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    numero_fidelisation VARCHAR(50)
);
\echo '--- passager ---'
SELECT * FROM passager;


\qecho
\qecho 'Je crée la table segment_vol avec comme clé primaire un numéro de segment, puis les codes des aéroports de départ et d arrivée,'
\qecho 'les heures de départ et d arrivée prévues'
\qecho
\qecho 'aeroport_depart et aeroport_arrivee font référence à la table aeroport, je crée donc des clés étrangères'
\qecho
\qecho 'Par sécurité, je contrôle que les aéroports de départ et d arrivée soient différents'
\qecho
\qecho 'J utilise CONSTRAINT pour nommer les contraintes de clés étrangères et de check,'
\qecho 'ce n est pas obligatoire, mais c est une bonne pratique (fk = foreign key, chk = check)'
CREATE TABLE segment_vol (
    numero_segment INT PRIMARY KEY,
    aeroport_depart CHAR(3) NOT NULL,
    aeroport_arrivee CHAR(3) NOT NULL,
    heure_depart_prevu TIME NOT NULL,
    heure_arrivee_prevu TIME NOT NULL,

    CONSTRAINT fk_segment_aeroport_depart
        FOREIGN KEY (aeroport_depart)
        REFERENCES aeroport(code),

    CONSTRAINT fk_segment_aeroport_arrivee
        FOREIGN KEY (aeroport_arrivee)
        REFERENCES aeroport(code),

    CONSTRAINT chk_aeroports_differents
        CHECK (aeroport_depart <> aeroport_arrivee)
);
\echo '--- segment_vol ---'
SELECT * FROM segment_vol;


\qecho
\qecho 'Je crée la table avion avec comme clé primaire un identifiant d avion'
\qecho 'je crée une clé étrangère vers la table configuration pour indiquer la configuration de l avion'
CREATE TABLE avion (
    id_avion INT PRIMARY KEY,
    modele VARCHAR(50) NOT NULL,
    configuration INT NOT NULL,

    CONSTRAINT fk_avion_configuration
        FOREIGN KEY (configuration)
        REFERENCES configuration(id_config)
);
\echo '--- avion ---'
SELECT * FROM avion;


\qecho
\qecho 'Je crée la table vol_effectif avec comme clé primaire un identifiant de vol effectif, puis le numéro de segment, la date de départ,'
\qecho 'les heures de départ et d arrivée effectives, et l avion utilisé pour ce vol'
\qecho
\qecho 'Je crée des clés étrangères vers la table segment_vol pour le numéro de segment et vers la table avion pour l avion utilisé'
\qecho
\qecho 'Afin d éviter une longue clé primaire composite, je crée une clé artificielle (id_vol_effectif) pour identifier de manière unique chaque vol effectif'
\qecho
\qecho 'Je contrôle (avec une contrainte UNIQUE) que la combinaison du numéro de segment,'
\qecho 'de la date de départ et de l heure de départ soit unique pour éviter les éventuels doublons de vols effectifs (uq = unique)'
CREATE TABLE vol_effectif (
    id_vol_effectif INT PRIMARY KEY,
    numero_segment INT NOT NULL,
    date_depart_effectif DATE NOT NULL,
    heure_depart_effectif TIME NOT NULL,
    heure_arrivee_effective TIME,
    avion INT NOT NULL,

    CONSTRAINT fk_vol_segment
        FOREIGN KEY (numero_segment)
        REFERENCES segment_vol(numero_segment),

    CONSTRAINT fk_vol_avion
        FOREIGN KEY (avion)
        REFERENCES avion(id_avion),

    CONSTRAINT uq_vol_effectif_unique
        UNIQUE (numero_segment, date_depart_effectif, heure_depart_effectif)
);
\echo '--- vol_effectif ---'
SELECT * FROM vol_effectif;


\qecho
\qecho 'Je crée la table siege avec comme clé primaire la combinaison du numéro de siège et de la configuration'
\qecho '(car le même numéro de siège peut exister dans différentes configurations), puis la classe tarifaire du siège'
\qecho
\qecho 'Je crée des clés étrangères vers la table configuration pour la config et vers la table classe_tarifaire pour la classe tarifaire du siège'
\qecho
\qecho 'j utilise un VARCHAR au lieu d un INT pour le numéro de siège pour permettre des numéros de sièges alphanumériques (ex: 12A)'
CREATE TABLE siege (
    numero_siege VARCHAR(10) NOT NULL,
    config INT NOT NULL,
    classe_tarifaire VARCHAR(20) NOT NULL,

    PRIMARY KEY (numero_siege, config),

    CONSTRAINT fk_siege_configuration
        FOREIGN KEY (config)
        REFERENCES configuration(id_config),

    CONSTRAINT fk_siege_classe
        FOREIGN KEY (classe_tarifaire)
        REFERENCES classe_tarifaire(nom_classe)
);
\echo '--- siege ---'
SELECT * FROM siege;


\qecho
\qecho 'Je crée la table tarif avec comme clé primaire la combinaison de l identifiant de vol effectif et du nom de classe tarifaire'
\qecho
\qecho 'Je crée des clés étrangères vers la table vol_effectif pour l identifiant de vol effectif et vers la table classe_tarifaire pour le nom de classe tarifaire'
\qecho
\qecho 'Je contrôle que le montant du tarif soit positif ou nul (car il peut éventuellement y avoir des offres gratuites)'
\qecho
\qecho 'NUMERIC(10,2) signifie que le montant peut avoir jusqu à 10 chiffres au total, dont 2 chiffres après la virgule'
\qecho 
\qecho 'Je fais ON DELETE CASCADE sur la clé étrangère vers vol_effectif, car si un vol n existe plus, les tarifs non plus'
CREATE TABLE tarif (
    vol_effectif INT NOT NULL,
    classe_tarifaire VARCHAR(20) NOT NULL,
    montant NUMERIC(10,2) NOT NULL CHECK (montant >= 0),

    PRIMARY KEY (vol_effectif, classe_tarifaire),

    CONSTRAINT fk_tarif_vol
        FOREIGN KEY (vol_effectif)
        REFERENCES vol_effectif(id_vol_effectif)
        ON DELETE CASCADE,

    CONSTRAINT fk_tarif_classe
        FOREIGN KEY (classe_tarifaire)
        REFERENCES classe_tarifaire(nom_classe)
);
\echo '--- tarif ---'
SELECT * FROM tarif;


\qecho
\qecho 'Je crée la table reservation avec comme clé primaire un identifiant de réservation, puis le numéro de vol effectif,'
\qecho 'le numéro de siège réservé, la configuration du siège réservé, et le passager qui a fait la réservation'
\qecho
\qecho 'Je crée des clés étrangères vers la table vol_effectif pour le numéro de vol effectif, vers la table siege pour le numéro de siège et la configuration,'
\qecho 'et vers la table passager pour le passager qui a fait la réservation'
\qecho
\qecho 'Je contrôle (avec des contraintes UNIQUE) que pour un même vol effectif, un même passager ne puisse pas faire plusieurs réservations,'
\qecho 'et qu un même siège (numéro de siège + configuration) ne puisse pas être réservé plusieurs fois pour un même vol effectif'
\qecho
\qecho 'Je récupère aussi la config car un siège avec le même numéro peut exister dans différentes configurations'
\qecho
\qecho 'Je fais un ON DELETE CASCADE sur réservation vol effectif, car si vol annulé les réservations associées ne font plus de sens'
CREATE TABLE reservation (
    id_reservation INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vol_effectif INT NOT NULL,
    numero_siege VARCHAR(10) NOT NULL,
    config INT NOT NULL,
    passager INT NOT NULL,

    CONSTRAINT fk_reservation_vol
        FOREIGN KEY (vol_effectif)
        REFERENCES vol_effectif(id_vol_effectif)
        ON DELETE CASCADE,

    CONSTRAINT fk_reservation_siege
        FOREIGN KEY (numero_siege, config)
        REFERENCES siege(numero_siege, config),

    CONSTRAINT fk_reservation_passager
        FOREIGN KEY (passager)
        REFERENCES passager(id_passager),

    CONSTRAINT uq_reservation_passager_vol
        UNIQUE (vol_effectif, passager),

    CONSTRAINT uq_reservation_siege_vol
        UNIQUE (vol_effectif, numero_siege, config)
);
\echo '--- reservation ---'
SELECT * FROM reservation;


\qecho
\qecho 'Création de la table total_encaisse_vol pour stocker le montant total encaissé pour chaque vol effectif,'
\qecho 'avec comme clé primaire l identifiant du vol effectif et une colonne pour le montant total encaissé'
\qecho
\qecho 'Je crée une clé étrangère vers la table vol_effectif pour l identifiant du vol effectif'
\qecho
\qecho 'Je contrôle que le montant total encaissé soit positif ou nul'
\qecho 'Je fais ON DELETE CASCADE sur la clé étrangère vers vol_effectif, car si un vol n existe plus, le total encaissé pour ce vol n a plus de sens'
CREATE TABLE total_encaisse_vol (
    vol_effectif INT PRIMARY KEY,
    montant_total NUMERIC(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_total_vol
        FOREIGN KEY (vol_effectif)
        REFERENCES vol_effectif(id_vol_effectif)
        ON DELETE CASCADE
);
\echo '--- total_encaisse_vol ---'
SELECT * FROM total_encaisse_vol;

\qecho
\qecho '------------------------------------------------------------'
\qecho 'Affichage de toutes les tables'
\qecho '------------------------------------------------------------'

\dt

\qecho
\qecho '------------------------------------------------------------'
\qecho 'Création des fonctions'
\qecho '------------------------------------------------------------'
\qecho
\qecho 'Je crée une fonction trigger pour mettre à jour le montant total encaissé pour un vol effectif donné dans'
\qecho 'la table total_encaisse_vol à chaque fois qu une réservation est insérée, mise à jour ou supprimée'
\qecho
\qecho 'Explications détaillées:'
\qecho '------------------------'
\qecho '- v_vol_effectif = variable locale pour stocker l identifiant du vol effectif concerné par la réservation insérée, mise à jour ou supprimée'
\qecho
\qecho '- TG_OP = variable spéciale qui contient l opération qui a déclenché le trigger (INSERT ou DELETE)'
\qecho
\qecho '- v_vol_effectif := OLD.vol_effectif; signifie que si l opération est une suppression (DELETE),'
\qecho 'on récupère l identifiant du vol effectif à partir de la ligne supprimée (OLD. = variable spéciale qui contient l ancienne ligne pour les triggers DELETE)'
\qecho
\qecho '- v_vol_effectif := NEW.vol_effectif; signifie que si l opération est une insertion (INSERT),'
\qecho 'on récupère l identifiant du vol effectif à partir de la nouvelle ligne insérée (NEW. = variable spéciale qui contient la nouvelle ligne pour les triggers INSERT)'
\qecho
\qecho '- INSERT INTO total_encaisse_vol; permet d insérer une ligne dans la table total_encaisse_vol pour le vol effectif'
\qecho 'concerné si elle n existe pas déjà (ON CONFLICT DO NOTHING évite les erreurs en cas de doublon), valeur 0 = montant total initialisé à 0'
\qecho
\qecho '- UPDATE = permet de recalculer et mettre à jour le montant total encaissé pour le vol effectif concerné'
\qecho
\qecho '- SET montant_total = on va donner une nouvelle valeur au montant total'
\qecho
\qecho '- COALESCE(..., 0) = si le résultat est NULL, alors prendre 0, par sécurité'
\qecho
\qecho '- SELECT SUM(t.montant) = la somme de tous les montants des réservations du vol (t = alias de la table tarif)'
\qecho
\qecho '- FROM reservation r = on part de la table reservation (r = alias de reservation), qui contient les réservations effectuées'
\qecho
\qecho '- JOIN siege s ON s.numero_siege = r.numero_siege AND s.config = r.config = on fait une jointure avec la table'
\qecho 'siege pour récupérer la classe tarifaire du siège réservé, en joignant sur le numéro de siège et la configuration'
\qecho
\qecho '- JOIN tarif t ON t.vol_effectif = r.vol_effectif AND t.classe_tarifaire = s.classe_tarifaire =>'
\qecho 'on fait une jointure avec la table tarif pour récupérer le montant du tarif correspondant au vol effectif et à la classe tarifaire du siège réservé'
\qecho
\qecho '- WHERE r.vol_effectif = v_vol_effectif = on filtre les réservations pour ne prendre en compte que celles du vol effectif concerné'
\qecho
\qecho '- RETURN NULL; = la valeur de retour n a pas d importance, on retourne NULL'
CREATE FUNCTION maj_total_encaisse_vol()
RETURNS TRIGGER AS $$
DECLARE
    v_vol_effectif INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_vol_effectif := OLD.vol_effectif;
    ELSE
        v_vol_effectif := NEW.vol_effectif;
    END IF;

    INSERT INTO total_encaisse_vol (vol_effectif, montant_total)
    VALUES (v_vol_effectif, 0)
    ON CONFLICT (vol_effectif) DO NOTHING;

    UPDATE total_encaisse_vol
    SET montant_total = COALESCE((
        SELECT SUM(t.montant)
        FROM reservation r
        JOIN siege s
          ON s.numero_siege = r.numero_siege
         AND s.config = r.config
        JOIN tarif t
          ON t.vol_effectif = r.vol_effectif
         AND t.classe_tarifaire = s.classe_tarifaire
        WHERE r.vol_effectif = v_vol_effectif
    ), 0)
    WHERE total_encaisse_vol.vol_effectif = v_vol_effectif;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


\qecho
\qecho 'Ce trigger fait en sorte qu après avoir inséré mis à jour ou supprimé une réservation, le montant total encaissé pour le vol effectif concerné'
\qecho 'soit recalculé et mis à jour dans la table total_encaisse_vol'
CREATE TRIGGER trg_maj_total_encaisse_reservation
AFTER INSERT OR DELETE OR UPDATE ON reservation
FOR EACH ROW
EXECUTE FUNCTION maj_total_encaisse_vol();


\qecho
\qecho '------------------------------------------------------------'
\qecho 'Insertion des données'
\qecho '------------------------------------------------------------'
\qecho 'Aeropport'
INSERT INTO aeroport (code, ville, nom) VALUES
('CDG', 'Paris', 'Charles de Gaulle'),
('LHR', 'Londres', 'Heathrow'),
('BOS', 'Boston', 'Logan International');
\echo '--- aeroport ---'
SELECT * FROM aeroport;


\qecho
\qecho 'Configuration'
INSERT INTO configuration (id_config, nombre_sieges) VALUES
(1, 180),
(2, 220),
(3, 300);
\echo '--- configuration ---'
SELECT * FROM configuration;


\qecho
\qecho 'Passagers'
INSERT INTO passager (id_passager, nom, numero_fidelisation) VALUES
(1, 'Valentino Rossi', 'FID-1001-WE'),
(2, 'Stephen Curry', 'FID-1002-WE'),
(3, 'Usain Bolt', 'FID-1003-WE'),
(4, 'Michael Phelps', NULL),
(5, 'Serena Williams', 'FID-1005-WE'),
(6, 'Paulo Maldini', 'FID-1006-WE');
\echo '--- passager ---'
SELECT * FROM passager;


\qecho
\qecho 'Segment de vol'
INSERT INTO segment_vol (
    numero_segment,
    aeroport_depart,
    aeroport_arrivee,
    heure_depart_prevu,
    heure_arrivee_prevu
) VALUES
(101, 'CDG', 'LHR', '08:00', '09:00'),
(102, 'LHR', 'BOS', '10:30', '13:30'),
(103, 'BOS', 'CDG', '04:00', '22:30');
\echo '--- segment_vol ---'
SELECT * FROM segment_vol;


\qecho
\qecho 'Avion'
INSERT INTO avion (id_avion, modele, configuration) VALUES
(1, 'Airbus A320', 1),
(2, 'Boeing 787', 2),
(3, 'Airbus A350', 3);
\echo '--- avion ---'
SELECT * FROM avion;


\qecho
\qecho 'Vol effectif'
INSERT INTO vol_effectif (
    id_vol_effectif,
    numero_segment,
    date_depart_effectif,
    heure_depart_effectif,
    heure_arrivee_effective,
    avion
) VALUES
(1001, 101, '2026-06-01', '08:05', '09:02', 1),
(1002, 102, '2026-06-01', '10:40', '13:35', 2),
(1003, 103, '2026-06-02', '04:10', '22:40', 3);
\echo '--- vol_effectif ---'
SELECT * FROM vol_effectif;


\qecho
\qecho 'Siege'
INSERT INTO siege (numero_siege, config, classe_tarifaire) VALUES
('1A', 1, 'First'),
('14C', 1, 'Economy+'),
('2B', 2, 'Business'),
('4F', 2, 'Economy'),
('12C', 3, 'Economy'),
('46C', 3, 'Economy');
\echo '--- siege ---'
SELECT * FROM siege;


\qecho
\qecho 'Tarif'
INSERT INTO tarif (vol_effectif, classe_tarifaire, montant) VALUES
(1001, 'First', 450.00),
(1001, 'Economy+', 390.00),
(1002, 'Business', 1200.00),
(1002, 'Economy', 700.00),
(1003, 'Economy', 650.00);
\echo '--- tarif ---'
SELECT * FROM tarif;

\qecho
\qecho '------------------------------------------------------------'
\qecho 'Transactions : réservations et annulations'
\qecho '------------------------------------------------------------'
\qecho
\qecho 'Lors de l insertion de ces réservations, le trigger va automatiquement mettre à jour le montant total encaissé pour les vols effectifs concernés dans la table total_encaisse_vol'
\qecho 'Premières réservations pour vol 1001, 1002 et 1003'
BEGIN;
INSERT INTO reservation (vol_effectif, numero_siege, config, passager) VALUES
(1001, '1A', 1, 1),
(1002, '2B', 2, 2),
(1003, '12C', 3, 3);
COMMIT;

SELECT * FROM reservation;
SELECT * FROM total_encaisse_vol ORDER BY vol_effectif;


\qecho 'Ajout deuxième réservation pour vol 1001, le montant total dans total_montant va s incrémenter'
BEGIN;
INSERT INTO reservation (vol_effectif, numero_siege, config, passager) VALUES
(1001, '14C', 1, 4);
COMMIT;

SELECT * FROM reservation;
SELECT * FROM total_encaisse_vol ORDER BY vol_effectif;


\qecho 'Ajout deuxième réservation pour vol 1002, le montant total dans total_montant va s incrémenter'
BEGIN;
INSERT INTO reservation (vol_effectif, numero_siege, config, passager) VALUES
(1002, '4F', 2, 5);
COMMIT;

SELECT * FROM reservation;
SELECT * FROM total_encaisse_vol ORDER BY vol_effectif;


\qecho 'Ajout deuxième réservation pour vol 1003, le montant total dans total_montant va s incrémenter'
BEGIN;
INSERT INTO reservation (vol_effectif, numero_siege, config, passager) VALUES
(1003, '46C', 3, 6);
COMMIT;

SELECT * FROM reservation;
SELECT * FROM total_encaisse_vol ORDER BY vol_effectif;

\qecho 'Annulation de la réservation 1, le montant total du vol corresponant est recalculé'
BEGIN;
DELETE FROM reservation
WHERE id_reservation = 1;
COMMIT;

SELECT * FROM reservation;
SELECT * FROM total_encaisse_vol ORDER BY vol_effectif;

\qecho '------------------------------------------------------------'
\qecho 'Récapitulatif'
\qecho '------------------------------------------------------------'
\qecho 'Une dernière requête pour retourner une table avec toutes les infos les plus pertinentes'
\qecho 
SELECT 
    r.vol_effectif,
    ad.ville AS ville_depart,
    aa.ville AS ville_arrivee,
    ve.date_depart_effectif,
    ve.heure_depart_effectif,
    p.nom AS passager,
    r.numero_siege,
    t.montant
FROM reservation r
JOIN passager p 
    ON p.id_passager = r.passager
JOIN siege s 
    ON s.numero_siege = r.numero_siege 
   AND s.config = r.config
JOIN tarif t 
    ON t.vol_effectif = r.vol_effectif 
   AND t.classe_tarifaire = s.classe_tarifaire
JOIN vol_effectif ve
    ON ve.id_vol_effectif = r.vol_effectif
JOIN segment_vol sv
    ON sv.numero_segment = ve.numero_segment
JOIN aeroport ad
    ON ad.code = sv.aeroport_depart
JOIN aeroport aa
    ON aa.code = sv.aeroport_arrivee
ORDER BY r.vol_effectif, p.nom;