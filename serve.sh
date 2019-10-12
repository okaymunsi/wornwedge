#!/bin/bash
set -e

# Argument checking
if [ $# -ne 1 ]
  then
    echo "No arguments supplied"
fi

site='wornwedge'
# Check if in correct dir
[[ -d "$PWD" =~ $1 ]] || { echo "Please be in $1/ dir"; exit 1; }

# Build site
bundle exec jekyll build
[[ -d $PWD/$1/_site ]] || { echo "Could not find $PWD/$1/_site"; exit 1; }

# Check if /var/www/ is setup
[[ -d /var/www/$site/$1 ]] || { echo "Making /var/www/$site/$1"; mkdir /var/www/$site/$1; }
rsync -avh --dry-run $PWD/$1/_site /var/www/$site/$1

# Setup /nginx sites
[[ -f /etc/nginx/sites-available/$site.com ]] || { echo "server {\nlisten 80;\nroot /var/www/$site/$1;\nindex index.html;\nserver_name www.$site.com;\n}" > /etc/nginx/sites-available/$site.com && echo "Created /etc/nginx/sites-available/$site.com" }

[[ -f /etc/nginx/sites-enabled/$site.com ]] || { ln -s /etc/nginx/sites-available/$site.com /etc/nginx/sites-enabled/ }
