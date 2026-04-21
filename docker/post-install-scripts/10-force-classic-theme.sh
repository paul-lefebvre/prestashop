#!/bin/sh
set -eu

echo
echo "* Post-install: forcing classic theme for front office stability ..."

mysql -h "$DB_SERVER" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASSWD" "$DB_NAME" <<'SQL'
UPDATE ps_shop
SET theme_name = 'classic'
WHERE id_shop = 1;

INSERT INTO ps_configuration (id_shop_group, id_shop, name, value, date_add, date_upd)
SELECT NULL, NULL, 'PS_THEME_NAME', 'classic', NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1
  FROM ps_configuration
  WHERE name = 'PS_THEME_NAME'
);

UPDATE ps_configuration
SET value = 'classic', date_upd = NOW()
WHERE name = 'PS_THEME_NAME';
SQL

rm -rf /var/www/html/var/cache/*
chown -R www-data:www-data /var/www/html/var/cache /var/www/html/var/logs

echo "* Post-install: classic theme applied and cache cleared."
