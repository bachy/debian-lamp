#!/bin/bash

echo "updating drupal 8"
echo "Switching to project docroot."
cd ./public_html
echo ""
echo "Pulling down latest code."
git pull --ff-only origin prod
echo ""
echo "Clearing drush caches."
drush cache-clear drush
echo ""
echo "Composer install."
composer install --no-dev
echo ""
echo "Running database updates."
drush updb -y
echo ""
echo "Importing configuration."
drush config-import -y
echo ""
echo "Clearing caches."
drush cr
echo ""
echo "Deployment complete."
