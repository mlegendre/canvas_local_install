#!/bin/bash
ROOT_DIR=$PWD
CANVAS_ROOT_DIR=~/Desktop/code/canvas-lms
OS_ENV=("Darwin" "Ubuntu")

#This shell script will be used to automate a new environment

#TODO list 
#
# Need to check for RVM and either use it or remove it.
#
# Work on general refactoring
#
# Make the .ssh directory check work, it should work but its not :(
#
# Refactor ideas:
#
# Add the following to make the code nicer
#while true; do
#    read -p "Do you wish to install this program?" yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#        * ) print_dash "Please answer yes or no.";;
#    esac
#done

function beginning(){
  print_dash "This script will be used to create a new local canvas-lms instance"
  cd ~
  
}

#Future feature that will allow you to install canvas on any OS
function os_check(){
platform='uknown'
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Linux' ]]; then
   platform='freebsd'
fi

#Need to figure out how to get this installed on Windows still (Don't laugh im being serious, it would open us up for school using windows OS)

}


function command_line_tools(){
  XTOOLS_CHECK=`xcode-select -p`
  XTOOLS_FOLDER='/Applications/Xcode.app/Contents/Developer'
  NAME_OF_TOOLS="commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
  NAME_OF_WGET="wget-1.12-0.dmg"
  WGET_URL="https://rudix.googlecode.com/files/wget-1.12-0.dmg"
  DROPBOX_URL="https://www.dropbox.com/s/gqfz32662ol6bpe/commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
  ESCAPED_TOOL_NAME="/Volumes/Command\ Line\ Developer\ Tools/"

  #TODO
  # Check for xtools installed?
  # xcode-select -p
  # Should see this /Applications/Xcode.app/Contents/Developer
  # Need to DRY the hdiutil commands up, could probably stick the following into a method of its own
  # hdiutil attach <dmg>
  # sudo installer -verbose -pkg
  # hdiutil detach <dmg>
  # rm <dmg>

  if [[ $XTOOLS_CHECK == $XTOOLS_FOLDER ]];
    then
     print_dash "You already have xtools installed and I am going to skip this part of the installation"
  else

    print_dash "Now Downloading wget and installing xtools, please follow all prompts (You will need to enter your password)"

    #Install wget

    curl -O -k $WGET_URL

    if [[ "$?" == 1 ]];
     then
      print_dash_error "The curl command did not work. Please check the URL and try again."
    fi

    hdiutil attach $NAME_OF_WGET

    sudo installer -verbose -pkg /Volumes/wget.pkg/wget.pkg -target /

    hdiutil detach /Volumes/wget.pkg

    rm wget-1.12-0.dmg

    #Use wget to grab commandline tools

    wget -O  $NAME_OF_TOOLS $DROPBOX_URL --no-check-certificate

    if [[ "$?" == 1 ]];
     then
      print_dash_error "The wget command did not work. Please check the URL and try again."
    fi

    hdiutil attach $NAME_OF_TOOLS
    #TODO figure out how to get rid of UI prompt
    sudo installer -verbose -pkg /Volumes/Command\ Line\ Developer\ Tools/Command\ Line\ Tools\ \(OS\ X\ 10.9\).pkg -target /

    hdiutil detach $ESCAPED_TOOL_NAME

    rm $NAME_OF_TOOLS
 fi
}

function rbenv_install(){
  ruby_version_manager=''

  #sudo apt-get install curl
  cd $ROOT_DIR
  print_dash "I am now going to install rbenv"

  print_dash "Now modifying bash profile to set up rbenv"

  touch ~/.bash_profile

  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile

  print_dash "I am now installing rbenv xmlsec1 and nodejs"

  brew install rbenv ruby-build xmlsec1 node

  print_dash "I will now set up your system for rbenv with ruby 1.9.3 but you can always change this later"

  rbenv install 1.9.3-p448

  rbenv global 1.9.3-p448
}

function github_install(){
  SSH_DIRECTORY="$ROOT_DIR/.ssh"

  print_dash "Installing github on your machine"

  brew install git

  if [ ! -d "$SSH_DIRECTORY" ];
    then
      print_dash $'I see you do not have ssh keys on your system, wait while I generate those for you\nJust press enter when it asks where you want the key to reside and passphrase (makes it easier to find later)'

      ssh-keygen
  fi

  print_dash "Copying your public ssh key to your clipboard"
  pbcopy < ~/.ssh/id_rsa.pub
}


function setting_up_gerrit_hooks(){

  print_dash "If you haven't yet you need to set up a gerrit profile"

  print_dash $'*Your public key is already in your clipboard*\n1. Go to https://gerrit.instructure.com\n2. Click "Sign In" in the upper-right corner\n3. Sign in with your LDAP credentials. (Talk to IT if you don\'t have any yet.)\n4. Add an SSH key on the registration page\n5. Ask BrianP, Simon, PaulH or Cody for Developer rights'

  open 'http://gerrit.instructure.com'

  waiting_for_user

  read -p $'Now we will set up your gerrit hooks\nWhat is your gerrit login name?' USER

  touch ~/.ssh/config

  printf "Host gerrit
  HostName gerrit.instructure.com
  User $USER
  Port 29418" >> ~/.ssh/config

  printf "[color]
  ui = true

  [user]
  name = $name
  email = $name@instructure.com

  [alias]
	gerrit-submit = "!bash -c ' \
		    local_ref=$(git symbolic-ref HEAD); \
		    local_name=${local_ref##refs/heads/}; \
		    remote=$(git config branch.\"$local_name\".remote || echo origin); \
		    remote_ref=$(git config branch.\"$local_name\".merge); \
		    remote_name=${remote_ref##refs/heads/}; \
		    remote_review_ref=\"refs/for/$remote_name\"; \
		    r=\"\"; \
		    if [[ $0 != \"\" && $0 != \"bash\" ]]; then r=\"--reviewer=$0\"; fi; \
		    if [[ $1 != \"\" ]]; then r=\"$r --reviewer=$1\"; fi; \
		    if [[ $2 != \"\" ]]; then r=\"$r --reviewer=$2\"; fi; \
		    if [[ $3 != \"\" ]]; then r=\"$r --reviewer=$3\"; fi; \
		    if [[ $4 != \"\" ]]; then r=\"$r --reviewer=$4\"; fi; \
		    git push --receive-pack=\"gerrit receive-pack $r\" $remote HEAD:$remote_review_ref'"
	st = status" >> ~/.gitconfig
}

function waiting_for_user(){
  print_dash "Would you like more time?"
  read answer

  while [ $answer == "y" ];
  do
   print_dash "I will give you some more time"
   sleep 3m
   print_dash "do you still need more time?"
   read answer
  done
}

function postgresql_install(){
  print_dash "I am now going to download the newest postgressql on your system"

  brew install postgresql

  mkdir -p ~/Library/LaunchAgents

  ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
}

function canvas-lms_download(){
  print_dash "Downloading canvas-lms"
  name=$(git config --global instructure.name)
  user=$(git config --global instructure.user)
  gerrit_host=$(git config --global instructure.gerrithost)
  gerrit_port=$(git config --global instructure.gerritport)
  project=canvas-lms
  target_dir=~/Desktop/code/canvas-lms

  if [ "$name" == "" ] || [ "$user" == "" ]; then
    while true; do
      read -p "please enter your name: " name
      read -p "please enter your instructure ldap username: " user
      read -p "is \"$name ($user@instructure.com)\" right? [y/N] " yn
      case $yn in
        [Yy]* ) break;;
      esac
    done
    git config --global instructure.name "$name"
    git config --global instructure.user "$user"
  fi

  if [ "$gerrit_host" == "" ] || [ "$gerrit_port" == "" ]; then
    gerrit_host=gerrit.instructure.com
    gerrit_port=29418
    git config --global instructure.gerrithost $gerrit_host
    git config --global instructure.gerritport $gerrit_port
  fi

  git clone ssh://$user@$gerrit_host:$gerrit_port/$project $target_dir

  cd ~/Desktop/code/canvas-lms

  for config in delayed_jobs domain file_store outgoing_mail security; \
          do cp config/$config.yml.example config/$config.yml; done

  scp -p gerrit:hooks/commit-msg .git/hooks/
}


# This function will modify the database/secuity/environments YAML files
function setup_config_files(){
  #TODO Need the outgoing mail yml configured
  string_to_replace="facdd3a131ddd8988b14f6e4e01039c93cfa0160"
  random=$(openssl rand -base64 20)
  # config_replacments=(  )

  #This modifies the database yml file
  cp config/database.yml.example config/database.yml
  sed -i.bak 's/ queue:/ #queue:/' config/database.yml
  sed -i.bak 's/    adapter: postgresql/  # adapter: postgresql/' config/database.yml
  sed -i.bak 's/    encoding: utf8/  # encoding: utf8/' config/database.yml
  sed -i bak 's/    timeout: 5000/    # timeout: 5000/' config/database.yml
  sed -i.bak 's/ database: canvas_queue_development/ # database: canvas_queue_development/' config/database.yml
  sed -i.bak 's/  database: canvas_queue_production/  #database: canvas_queue_production/' config/database.yml
  sed -i.bak 's/  host: localhost/  #host: localhost/' config/database.yml
  sed -i.bak 's/  username: canvas/  #username: canvas/' config/database.yml
  sed -i.bak 's/  password: your_password/  #password: your_password/' config/database.yml
  rm config/database.yml.bak

  # This modifies the security.yml file
  sed -i.bak 's/ facdd3a131ddd8988b14f6e4e01039c93cfa0160/ '$random'/' config/security.yml
  # Need to modify the outgoingmail.yml file

  #This modifies the envirnoments file
  touch config/environments/development-local.rb
  printf "config.cache_classes = true
config.action_controller.perform_caching = true
config.action_view.cache_template_loading = true" >> config/environments/development-local.rb
}

function install_bundler(){
  print_dash "Now installing bundler gem"

  cd ~/Desktop/code/canvas-lms

  gem install bundler --version "=1.5.1"
}

function load_initial_data(){

  bundle config build.thrift --with-cppflags='-D_FORTIFY_SOURCE=0'
  bundle install --without mysql

  bundle exec rake db:create

  if [[ ! "$?" == 0 ]];
  then
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
  fi

  bundle exec rake db:migrate

  if [[ ! "$?" == 0 ]];
  then
    print_dash_error "Something happeend while creating the database. Is your server running?"
    exit
  fi

  bundle exec rake db:load_initial_data
}

function download_cleanBranch_script(){
  print_dash "Downloading cleanbranch script"

  cd $CANVAS_ROOT_DIR

  wget https://raw.github.com/mlegendre/personalprojects/master/cleanBranch.sh --no-check-certificate

  if [[ ! "$?" == 0 ]];
   then
    print_dash_error "Something happened downloading my cleanBranch script. Did I move it? You will never know."
  fi

  print_dash "Spinning up your server now using cleanBranch.sh, make sure to run that script to checkout patchsets"

  npm install

  sed -i.bak 's/marc/'$USER'/' cleanBranch.sh

  rm cleanBranch.sh.bak

  chmod +x cleanBranch.sh

  source $CANVAS_ROOT_DIR/cleanBranch.sh
}

# This function just checks to make sure the functions work


# This function just takes a string and adds a bunch of #'s to the bottom and top of the string
function print_dash() {
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
  printf '\e[38;5;46m%-6s\e[m' "$1"
  echo ""
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
}

function print_dash_error() {
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
  printf '\e[38;5;124m%-6s\e[m' "$1"
  echo ""
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
}

function print_dash_warning() {
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
  printf '\e[38;5;226m%-6s\e[m' "$1"
  echo ""
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
}

beginning

command_line_tools

which -s brew
if [[ $? != 0 ]] ; then
  print_dash "You do not have homebrew installed please wait while I get that set up"
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
  brew doctor
  brew update
else
  echo "You have homebrew installed already"
fi

github_install

setting_up_gerrit_hooks

postgresql_install

rbenv_install

source ~/.bash_profile

rbenv rehash

canvas-lms_download

setup_config_files

install_bundler

rbenv rehash

load_initial_data

download_cleanBranch_script

