#!/bin/sh

# $cwd is defined in webhook conf

# update bare repos
git --git-dir=git-repositories/app.enfrancais.fr.git fetch origin prod:prod
# deploy prod
cd www/enfrancais.fr/app
./deploy.sh
