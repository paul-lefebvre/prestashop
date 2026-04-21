# PrestaShop local

Instance locale PrestaShop prête pour recette client, basée sur Docker Compose et auto-installée.

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

Le premier démarrage peut prendre quelques minutes, le temps que PrestaShop s'installe automatiquement.

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

## URLs en local

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
- `PS_DEMO_MODE=0`
- `PS_DOMAIN=localhost:8080`
- `PS_LANGUAGE=fr`
- `PS_COUNTRY=fr`
- `PS_ENABLE_SSL=0`
- `PS_HANDLE_DYNAMIC_DOMAIN=0`
- `PS_FOLDER_ADMIN=admin-dev`
- `ADMIN_MAIL` et `ADMIN_PASSWD`

Tant que les volumes Docker existent, relancer la stack repart sur l'instance déjà installée.

## Important sur le mode démo

Si `PS_DEMO_MODE=1`, certaines fonctionnalités du back office peuvent être bloquées avec le message `This functionality has been disabled.`.

Pour une instance client réellement éditable, il faut utiliser :

```env
PS_DEMO_MODE=0
```

Si la boutique actuelle a déjà été installée en mode démo, le plus propre est de repartir sur une installation neuve :

```bash
docker compose down -v --remove-orphans
docker compose up -d
```

N'exécute cette réinstallation que si tu peux perdre l'instance actuelle.

## Important sur le domaine dynamique

Utilise `PS_HANDLE_DYNAMIC_DOMAIN=0` par défaut en local.

Quand cette option vaut `1`, l'image Docker place un script `docker_updt_ps_domains.php` devant `index.php` pour réécrire le domaine à la volée. C'est utile seulement si le domaine ou le port changent souvent entre deux démarrages.

Sur une instance stable en `localhost:8080` ou sur un sous-domaine fixe, cette option peut provoquer des redirections parasites sur la home. Ne l'active que si tu en as réellement besoin.

## Important sur le thème front office

Sur cette stack, un script post-install force le thème `classic` après l'installation automatique.

Pourquoi :

- l'image Docker `prestashop/prestashop:9.1.0-apache` installe par défaut `hummingbird`
- dans notre contexte local, `classic` s'est montré plus stable et permet une homepage immédiatement exploitable sur `/`

Le script est dans [docker/post-install-scripts/10-force-classic-theme.sh](/work/prestashop/docker/post-install-scripts/10-force-classic-theme.sh).

Si une boutique est déjà installée et n'a pas basculé sur `classic`, tu peux rejouer le correctif sans reset :

```bash
make fix-theme-classic
```

Tu peux aussi vérifier dans les logs d'installation si le script post-install a bien été exécuté :

```bash
docker compose logs --tail=200 prestashop
```

Tu dois voir passer :

```text
* Running post-install script(s)...
* Post-install: forcing classic theme for front office stability ...
* Post-install: classic theme applied and cache cleared.
```

## Déploiement derrière Nginx sur OVH

Pour une mise en ligne parallèle à une instance Sylius existante, le plus sûr est :

- de garder Sylius tel quel
- d'exposer PrestaShop uniquement en local sur le serveur
- de laisser Nginx publier le sous-domaine en reverse proxy

Exemple pour `prestashop.bjmcom-textile.fr` :

1. Ajuster `.env` sur le serveur :

```env
PS_DOMAIN=prestashop.bjmcom-textile.fr
PS_ENABLE_SSL=1
PS_BIND_IP=127.0.0.1
PS_PORT=8080
PMA_BIND_IP=127.0.0.1
PMA_PORT=8081
```

2. Lancer la stack :

```bash
docker compose up -d
```

3. Déclarer un vhost Nginx :

```nginx
server {
    listen 80;
    server_name prestashop.bjmcom-textile.fr;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name prestashop.bjmcom-textile.fr;

    ssl_certificate /etc/letsencrypt/live/prestashop.bjmcom-textile.fr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/prestashop.bjmcom-textile.fr/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header HTTPS on;
        proxy_http_version 1.1;
        proxy_redirect off;
    }
}
```

4. Tester et recharger Nginx :

```bash
sudo nginx -t
sudo systemctl reload nginx
```

5. Générer ou renouveler le certificat :

```bash
sudo certbot --nginx -d prestashop.bjmcom-textile.fr
```

6. Vérifier :

```bash
curl -I http://127.0.0.1:8080
curl -I https://prestashop.bjmcom-textile.fr
```

Ne publie pas phpMyAdmin sur Internet sans restriction réseau ou authentification supplémentaire.

## Commandes utiles

- `make up` : démarre la stack
- `make down` : arrête et supprime les conteneurs
- `make stop` : arrête sans supprimer
- `make restart` : redémarre proprement
- `make ps` : affiche l'état des services
- `make logs` : suit les logs
- `make pull` : récupère les images
- `make config` : affiche la configuration Compose résolue
- `make fix-theme-classic` : force le thème `classic` sur une boutique déjà installée
- `make reset` : supprime la stack et les volumes

## Remarque importante

Dans cet environnement d'exécution, la commande `docker` n'était pas disponible au moment de la génération. Les fichiers sont prêts à l'emploi, mais le lancement réel doit être exécuté sur une machine disposant de Docker.
