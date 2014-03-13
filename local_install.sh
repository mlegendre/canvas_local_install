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
echo For now you have to manually install command line tools by doing the following
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
ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

}

function postgresql_install(){
echo "I am now going to download the newest postgressql on your system"

}

function rbenv_install(){
echo "I am now going to install rbenv"
#TODO
# brew install rbenv ruby-build xmlsec1 postgresql
# rbenv install 1.9.3-p448
echo "Now modifying bash profile to set up rbenv"
#    touch ~/.bash_profile
#    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
#    source ~/.bash_profile
#    cd canvas-lms
#    rbenv local 1.9.3-p448
#    mkdir ~/gems
# Set environment variable GEM_HOME to ~/gems
#    touch ~/.bash_profile
#    echo "export GEM_HOME=~/gems" >> ~/.bash_profile
#    source ~/.bash_profile

}

function github_install(){
echo "Installing github on your machine"
#TODO
# Create ssh keys if not already generated
# brew install github


}

function canvas-lms_download(){
echo "Downloading canvas-lms"

}

function install_bundler(){
echo "Now installing bundler gem"

}

beginning

command_line_tools


