#!/bin/bash

echo "updating"
echo "Switching to project docroot."
cd ./public_html
echo ""
echo "Pulling down latest code."
git pull --ff-only origin prod
echo ""
echo "Deployment complete."
