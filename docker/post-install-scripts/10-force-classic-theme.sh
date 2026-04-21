#!/bin/sh
set -eu

echo
echo "* Post-install: forcing classic theme for front office stability ..."

mysql -h "$DB_SERVER" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" <<'SQL'
UPDATE ps_shop
SET theme_name = 'classic'
WHERE id_shop = 1;
SQL

rm -rf /var/www/html/var/cache/*
chown -R www-data:www-data /var/www/html/var/cache /var/www/html/var/logs

echo "* Post-install: classic theme applied and cache cleared."
