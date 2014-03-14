#!/bin/bash

CANVAS_ROOT_DIR=~/Desktop/code/canvas-lms
#This shell script will be used to automate a new environment

#TODO list 
# Refactor ideas:
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
  ROOT_DIR=$PWD

}


function command_line_tools(){
  print_dash "Now Downloading wget and installing xtools, please follow all prompts (You will need to enter your password)"
  #TODO
  # Need to refactor this, could probably stick the following into a method of its own
  # hdiutil attach <dmg>
  # sudo installer -verbose -pkg
  # hdiutil detach <dmg>
  # rm <dmg>

  NAME_OF_TOOLS="commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
  NAME_OF_WGET="wget-1.12-0.dmg"
  WGET_URL="https://rudix.googlecode.com/files/wget-1.12-0.dmg"
  DROPBOX_URL="https://www.dropbox.com/s/gqfz32662ol6bpe/commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
  ESCAPED_TOOL_NAME="Command\ Line\ Developer\ Tools/Command\ Line\ Tools\ \(OS\ X\ 10.9\).dmg"
  #Install wget

  curl -O $WGET_URL

  hdiutil attach $NAME_OF_WGET

  sudo installer -verbose -pkg /Volumes/wget.pkg/wget.pkg -target /
#bug here
  hdiutil detach $NAME_OF_WGET

  rm wget-1.12-0.dmg

  #Use wget to grab commandline tools

  wget -O  $NAME_OF_TOOLS $DROPBOX_URL

  hdiutil attach $NAME_OF_TOOLS
#TODO figure out how to get rid of UI prompt
  sudo installer -verbose -pkg /Volumes/Command\ Line\ Developer\ Tools/Command\ Line\ Tools\ \(OS\ X\ 10.9\).pkg -target /
#bug here
  hdiutil detach $NAME_OF_TOOLS

  rm $NAME_OF_TOOLS

}

function rbenv_install(){
  print_dash "I am now going to install rbenv"
  #TODO
  # brew install rbenv ruby-build xmlsec1 postgresql
  # rbenv install 1.9.3-p448

  # Set environment variable GEM_HOME to ~/gems
  #    touch ~/.bash_profile
  #    print_dash "export GEM_HOME=~/gems" >> ~/.bash_profile
  #    source ~/.bash_profile
  print_dash "I am now installing rbenv xmlsec1 and postgres"

  brew install rbenv ruby-build xmlsec1

  print_dash "I will now set up your system for rbenv with ruby 1.9.3 but you can always change this later"

  print_dash "Now modifying bash profile to set up rbenv"

  touch ~/.bash_profile

  print_dash "Done"

  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile

  source ~/.bash_profile

  rbenv install 1.9.3-p448

  rbenv rehash
}

function github_install(){
  SSH_DIRECTORY="~/.ssh"

  print_dash "Installing github on your machine"

  brew install git

  if [ ! -d $SSH_DIRECTORY ];
    then
      echo $'I see you do not have ssh keys on your system, wait while I generate those for you\nJust press enter when it asks where you want the key to reside and passphrase (makes it easier to find later)'

      ssh-keygen
  fi

  print_dash "Copying your public ssh key to your clipboard"
  pbcopy < ~/.ssh/id_rsa.pub

  print_dash $'1. If you have not already signup for a new account\n2. Sign into github\n3. Go to Account Settings\n4. Click ssh keys in left sidebar\n5. Click Add SSH Keys\n6. Paste your key into the key field\n7. Click Add Key\n8. Confirm by entering github password'

  open 'http://github.com'

  waiting_for_user
}


function setting_up_gerrit_hooks(){

  print_dash "If you haven't yet you need to set up a gerrit profile"

  print_dash $'*Your public key is still in your clipboard*\n1. Go to https://gerrit.instructure.com\n2. Click "Sign In" in the upper-right corner\n3. Sign in with your LDAP credentials. (Talk to IT if you don\'t have any yet.)\n4. Add an SSH key on the registration page\n5. Ask BrianP, Simon, PaulH or Cody for Developer rights'

  open 'http://gerrit.instructure.com'

  waiting_for_user

  echo $'Now we will set up your gerrit hooks\nWhat is your gerrit login name?'
  read name

  touch ~/.ssh/config

  printf "Host gerrit
  HostName gerrit.instructure.com
  User $name
  Port 29418" >> ~/.ssh/config


  printf "[user]
  name = $name
  email = $name@instructure.com" >> ~/.gitconfig



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

  rbenv local 1.9.3-p448

  rebenv rehash
}

function setup_config_files(){
#TODO
# Need to modify the database.yml file
# Need to modify the security.yml file
# Need to modify the outgoingmail.yml file
# Need to modify
echo do something
}

function install_bundler(){
  print_dash "Now installing bundler gem"
  cd ~/Desktop/code/canvas-lms
  sudo gem install bundler 1.5.2

  bundle config build.thrift --with-cppflags='-D_FORTIFY_SOURCE=0'
  bundle install --without mysql
}

function download_cleanBranch_script(){
  print_dash "Downloading cleanbranch script"

  cd $CANVAS_ROOT_DIR

  wget https://raw.github.com/mlegendre/personalprojects/master/cleanBranch.sh --no-check-certificate

  print_dash "Spinning up your server now using cleanBranch.sh, make sure to run that script to checkout patchsets"

  chmod +x cleanBranch.sh

  source $CANVAS_ROOT_DIR/cleanBranch.sh
}

function print_dash() {
  for (( x=0; x < ${#1}; x++ )); do
    printf "#"
  done
  echo ""
  printf "$1"
  echo ""
     for (( x=0; x < ${#1}; x++ )); do
     printf "#"
  done
  echo ""
}

beginning

command_line_tools

ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"

brew doctor

brew update

github_install

setting_up_gerrit_hooks

postgresql_install

rbenv_install

canvas-lms_download

install_bundler

download_cleanBranch_script