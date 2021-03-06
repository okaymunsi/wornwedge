#!/bin/bash

setup_project(){
    # Check if you have git
    #if [ $(check_if_installed "git") -ne 0 ] 
    #then
    #    install "git"
    #fi

    # Get git project
    # Go into project
    #git clone https://github.com/okaymunsi/wornwedge.git || { echo "git cloning failed"; exit; }
    #cd wornwedge/ || { echo "could not enter wornwedge"; exit; }

    # Check if in the correct dir
    [[ "$PWD" =~ wornwedge ]] || { echo "Please run setup.sh from wornwedge/ dir"; return; }

    [[ -f "$PWD"/env/bin/activate ]] || { echo "Could not find .../activate "; return; }
    source ./env/bin/activate || { echo "Could not activate "; return; }

    # Source env/bin/activate
    # Check for..
    # 1. Ruby
    # 2. Gems
    # 2. Bundler
    # 3. Jekyll
    # 4. Nginx
    for pkg in "ruby-full" "build-essential" "nginx" "zlib1g-dev" "rsync" "python"
    do
        ec=$(check_if_installed $pkg)
        if [ $ec -ne 0 ]
        then
            echo "$pkg not found, Installing.."
            install $pkg
        fi
    done

    # Install jekyll, bundler
    gem install jekyll bundler || { echo "Could not install jekyll and bundler"; return; }

    # Which theme are you using?
    cd galileo-theme/
   
    # Install gem dependencies and build project
    bundle || { echo "Could not bundle."; return; }
    bundle exec jekyll build || { echo "Could not run jekyll build"; return; }
    [ -d "$(pwd)/_site" ] || { echo "Did not build _site"; return; }
}

install(){
    echo "Installing $1.."
    sudo apt-get install -y $1 
    if [ $? -eq 0 ] 
    then
        echo "Succesful install of $1"
    else
        echo "Failed install of $1"
        return
    fi
}

check_if_installed(){
    dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null | grep "install ok installed" &>/dev/null

    echo "$?"
}

main(){
    setup_project
}

main
