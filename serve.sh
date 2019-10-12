#!/bin/bash

# Argument checking
if [ $# -ne 1 ]
  then
    echo "No arguments supplied"
    exit 1
fi

SITE="wornwedge"
# Check if in correct dir
[[ "$PWD" =~ $1 ]] || { echo "Please be in $1/ dir"; exit 1; }

# Check if in VENV
INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')
[[ $INVENV -eq "0" ]] && { echo "Please be inside $1 VENV"; exit 1; }

# Build site
bundle exec jekyll build
[[ -d $PWD/_site ]] || { echo "Could not find $PWD/_site"; exit 1; }

# Check if /var/www/ is setup
[[ -d /var/www/$SITE/$1 ]] || { echo "Making /var/www/$SITE/$1"; mkdir -p /var/www/$SITE/$1; }
rsync -avh $PWD/_site/* /var/www/$SITE/$1 || { echo "rsync failed"; exit 1; }

# Setup /nginx sites
[[ -f /etc/nginx/sites-available/$SITE.com ]] || { printf "server {\nlisten 80;\nroot /var/www/$SITE/$1;\nindex index.html;\nserver_name www.$SITE.com;\n}\n" > /etc/nginx/sites-available/$SITE.com && echo "Created /etc/nginx/sites-available/$SITE.com"; }

[[ -f /etc/nginx/sites-enabled/$SITE.com ]] || { ln -s /etc/nginx/sites-available/$SITE.com /etc/nginx/sites-enabled/; }

exit 0
