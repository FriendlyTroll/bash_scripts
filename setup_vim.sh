#!/bin/bash
# setup vim and ctags
# Sources: 
# https://kulkarniamit.github.io/whatwhyhow/howto/use-vim-ctags.html
# https://gist.github.com/miguelgrinberg/527bb5a400791f89b3c4da4bd61222e4

VIMRC="https://gist.githubusercontent.com/FriendlyTroll/4f4b1d8d32399df3cc34a322b543be9b/raw/5b85cf33bcb980dce9820b6d6147894f94eeb33f/.vimrc"

# Download the custom vimrc file from github into .vimrc file
echo "[@] Downloading vimrc..."
$(which curl) $VIMRC --output ~/.vimrc

echo "[@] Installing ctags..."
sudo apt install universal-ctags

echo "[@] Creating ctags configuration file..."
$(which mkdir) .ctags.d
$(which cat) << EOF > ~/.ctags.d/python.ctags
--recurse=yes
--exclude=.git
--exclude=BUILD
--exclude=.svn
--exclude=*.js
--exclude=vendor/*
--exclude=node_modules/*
--exclude=db/*
--exclude=log/*
--exclude=\*.min.\*
--exclude=\*.swp
--exclude=\*.bak
--exclude=\*.pyc
--exclude=\*.class
--exclude=\*.sln
--exclude=\*.csproj
--exclude=\*.csproj.user
--exclude=\*.cache
--exclude=\*.dll
--exclude=\*.pdb
--exclude=android/.buildozer
--exclude=venv/*
EOF

echo "[@] ctags installed. Run \"ctags .\" in your code directory to generate tags."
