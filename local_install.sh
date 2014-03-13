#!/bin/bash



#This shell script will be used to automate a new environment 
#
#TODO list 
#  1. Download command line tools 
#    a. use the following command xcode-select --install
#    b. Here is the source http://stackoverflow.com/questions/9329243/xcode-4-4-and-later-install-command-line-tools
#  2. Download the following
#    a. postgresql
#      I. need to setup the correct environment variables
#      II. Need to set up initial user
#    b. rbenv
#      I. need to setup the correct environment variables
#  3. Download the canvas-lms project onto the Desktop or the home directory
#  4. Gem install bundler
#    a. Make sure that it is being installed in the canvas-lms project folder
#  5. Run bundle install
#  6. Run the following scripts
#    a. RAILS_ENV=development bundle exec rake db:create
#    b. RAILS_ENV=development bundle exec rake db:migrate
#    c. RAILS_ENV=development bundle exec rake db:load_initial_data
#  7. run the shell script I have created??
#
# Add the following to make the code nicer
#while true; do
#    read -p "Do you wish to install this program?" yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done

function beginning(){
echo "This script will be used to create a new local canvas-lms instance"
cd ~
ROOT_DIR=$PWD

}


function command_line_tools(){
echo "Now Downloading wget and installing xtools, please follow all prompts (You will need to enter your password)"
#TODO
# Need to refactor this, could probably stick the following into a method of its own
# hdiutil attach <dmg>
# sudo installer -verbose -pkg
# hdiutil detach <dmg>
# rm <dmg>

NAME_OF_TOOLS="commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
DROPBOX_URL="https://www.dropbox.com/s/gqfz32662ol6bpe/commandline_tools_os_x_mavericks_for_xcode__march_2014.dmg"
ESCAPED_TOOL_NAME="Command\ Line\ Developer\ Tools/Command\ Line\ Tools\ \(OS\ X\ 10.9\).dmg"
#Install wget

curl -O https://rudix.googlecode.com/files/wget-1.12-0.dmg

hdiutil attach wget-1.12-0.dmg

sudo installer -verbose -pkg /Volumes/wget.pkg/wget.pkg -target /

hdiutil detach wget-1.12-0.dmg

rm wget-1.12-0.dmg

#Use wget to grab commandline tools

wget -O  $NAME_OF_TOOLS $DROPBOX_URL

hdiutil attach $ESCAPED_TOOL_NAME

sudo installer -verbose -pkg /Volumes/Command\ Line\ Developer\ Tools/Command\ Line\ Tools\ \(OS\ X\ 10.9\).pkg -target /

hdiutil detach $ESCAPED_TOOL_NAME

rm $ESCAPED_TOOL_NAME

}

function install_brew(){
# TODO
# Need lots of error checking
# If this error comes up Error: No such file or directory - /usr/local/Cellar
# Then run this command sudo mkdir /usr/local/Cellar
#
# If this error occurs /usr/local/etc isn't writable or Cannot write to /usr/local/Cellar
# Then do this sudo chown -R `whoami` /usr/local
echo "I am now going to install homebrew please follow the prompts"

ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

brew doctor
}

function github_install(){
SSH_DIRECTORY="~/.ssh"

echo "Installing github on your machine"


brew install github

if [ !-d $SSH_DIRECTORY ];
  then
    echo $'I see you do not have ssh keys on your system, wait while I generate those for you\n
         Just press enter when it asks where you want the key to reside and passphrase (makes it easier to find later)'

    ssh-keygen
fi

  echo "Copying your public ssh key to your clipboard"
  pbcopy < ~/.ssh/id_rsa.pub

  echo $'1. If you have not already signup for a new account\n2. Sign into github\n3. Go to Account Settings\n
        4. Click ssh keys in left sidebar\n5. Click Add SSH Keys\n6. Paste your key into the key field\n
        7. Click Add Key\n8. Confirm by entering github password'

  open 'http://github.com'

  waiting_for_user


}


function setting_up_gerrit_hooks(){

  echo "If you haven't yet you need to set up a gerrit profile"

  echo $'1. Go to https://gerrit.instructure.com\n2. Click "Sign In" in the upper-right corner\n
       3. Sign in with your LDAP credentials. (Talk to IT if you don\'t have any yet.)\n
       4. Add an SSH key on the registration page\n
       5. Ask BrianP, Simon, PaulH or Cody for Developer rights'

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

    scp -p gerrit:hooks/commit-msg .git/hooks/

}

function waiting_for_user(){
  echo "Would you like more time?"
  read answer

  while [ $answer == "y" ];
  do
   echo "I will give you some more time"
   sleep 3m
   echo "do you still need more time?"
   read answer
  done
}

function postgresql_install(){
echo "I am now going to download the newest postgressql on your system"

brew install postgresql



}

function rbenv_install(){
echo "I am now going to install rbenv"
#TODO
# brew install rbenv ruby-build xmlsec1 postgresql
# rbenv install 1.9.3-p448

#

# Set environment variable GEM_HOME to ~/gems
#    touch ~/.bash_profile
#    echo "export GEM_HOME=~/gems" >> ~/.bash_profile
#    source ~/.bash_profile
echo "I am now installing rbenv xmlsec1 and postgres"

brew install rbenv ruby-build xmlsec1 postgresql

echo "I will now set up your system for rbenv with ruby 1.9.3 but you can always change this later"

rbenv install 1.9.3-p448

echo "Now modifying bash profile to set up rbenv"

touch ~/.bash_profile

echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile

source ~/.bash_profile



}

function canvas-lms_download(){
echo "Downloading canvas-lms"
#    cd canvas-lms
#    rbenv local 1.9.3-p448
name=$(git config --global instructure.name)
user=$(git config --global instructure.user)
gerrit_host=$(git config --global instructure.gerrithost)
gerrit_port=$(git config --global instructure.gerritport)
project=$1
target_dir=$2

if [ "$project" == "" ] || [ "$3" != "" ]; then
  echo "Usage: $0 project_name [target_dir]"
  exit -1
fi

if [ "$target_dir" == "" ]; then
  target_dir=$project
fi

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
}

function install_bundler(){
echo "Now installing bundler gem"
# cd ~/
# gem install bundler
}

function download_cleanBranch_script(){
echo "Downloading cleanbranch script"

}

beginning

command_line_tools

install_brew

github_install

