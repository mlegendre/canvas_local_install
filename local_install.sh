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

function beginning(){
echo "This script will be used to create a new canvas-lms instance"
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
    echo "I see you do not have ssh keys on your system, wait while I generate those for you\n
         Just press enter when it asks where you want the key to reside and passphrase (makes it easier to find later)"

    ssh-keygen
fi

  echo "Copying your public ssh key to your clipboard"
  pbcopy < ~/.ssh/id_rsa.pub

  echo "1. If you have not already signup for a new account\n2. Sign into github\n3. Go to Account Settings\n
        4. Click ssh keys in left sidebar\n5. Click Add SSH Keys\n6. Paste your key into the key field\n
        7. Click Add Key\n8. Confirm by entering github password"

  open 'http://github.com'

  waiting_for_user
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

}

function rbenv_install(){
echo "I am now going to install rbenv"
#TODO
# brew install rbenv ruby-build xmlsec1 postgresql
# rbenv install 1.9.3-p448

#
#    cd canvas-lms
#    rbenv local 1.9.3-p448
#    mkdir ~/gems
# Set environment variable GEM_HOME to ~/gems
#    touch ~/.bash_profile
#    echo "export GEM_HOME=~/gems" >> ~/.bash_profile
#    source ~/.bash_profile
echo "I am now installing rbenv"

brew install rbenv

echo "I will now set up your system for rbenv with ruby 1.9.3 but you can always change this later"

echo "Now modifying bash profile to set up rbenv"

touch ~/.bash_profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

}

function canvas-lms_download(){
echo "Downloading canvas-lms"

}

function install_bundler(){
echo "Now installing bundler gem"

}

beginning

command_line_tools

install_brew

github_install

