# PrestaShop local

Instance locale PrestaShop prête pour démo/recette client, basée sur Docker Compose et auto-installée.

## Version retenue

- PrestaShop : `9.1.0`
- Image applicative : `prestashop/prestashop:9.1.0-apache`
- Base de données : `mysql:5.7`
- phpMyAdmin : `phpmyadmin:5-apache`

La version `9.1.0` a été retenue car c'est la dernière stable officielle trouvée au moment de l'exécution, et la documentation officielle PrestaShop pour Docker continue d'illustrer l'usage avec un conteneur MySQL `5.7`.

## Prérequis

- Docker
- Docker Compose v2 (`docker compose`)

## Démarrage

Depuis ce dossier :

```bash
docker compose up -d
```

ou :

```bash
make up
```

Le premier démarrage peut prendre quelques minutes, le temps que PrestaShop s'installe automatiquement et charge les données de démonstration.

## Arrêt

```bash
docker compose down
```

ou :

```bash
make down
```

## Redémarrage

```bash
make restart
```

## Reset complet

Supprime les conteneurs et les volumes persistants. Le prochain `up` réinstallera une boutique propre.

```bash
docker compose down -v --remove-orphans
```

ou :

```bash
make reset
```

## URLs

- Front office : http://localhost:8080
- Back office : http://localhost:8080/admin-dev
- phpMyAdmin : http://localhost:8081

## Identifiants

Ces valeurs sont définies dans `.env`.

- Admin PrestaShop
- Email : `demo@example.com`
- Mot de passe : `ChangeMe123!`

- Base de données PrestaShop
- Base : `prestashop`
- Utilisateur : `prestashop`
- Mot de passe : `prestashop`

- Root MySQL
- Utilisateur : `root`
- Mot de passe : `root`

## Fichiers persistés

- Volume `db_data` : données MySQL
- Volume `prestashop_data` : fichiers de la boutique, y compris l'installation générée et les contenus utiles pour rejouer la stack sans réinstallation

## Fonctionnement de l'auto-install

La stack utilise les variables d'environnement officielles de l'image PrestaShop :

- `PS_INSTALL_AUTO=1`
- `PS_DEMO_MODE=1`
- `PS_DOMAIN=localhost:8080`
- `PS_FOLDER_ADMIN=admin-dev`
- `ADMIN_MAIL` et `ADMIN_PASSWD`

Tant que les volumes Docker existent, relancer la stack repart sur l'instance déjà installée.

## Commandes utiles

- `make up` : démarre la stack
- `make down` : arrête et supprime les conteneurs
- `make stop` : arrête sans supprimer
- `make restart` : redémarre proprement
- `make ps` : affiche l'état des services
- `make logs` : suit les logs
- `make pull` : récupère les images
- `make config` : affiche la configuration Compose résolue
- `make reset` : supprime la stack et les volumes

## Remarque importante

Dans cet environnement d'exécution, la commande `docker` n'était pas disponible au moment de la génération. Les fichiers sont prêts à l'emploi, mais le lancement réel doit être exécuté sur une machine disposant de Docker.
