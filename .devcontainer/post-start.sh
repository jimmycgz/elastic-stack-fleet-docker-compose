#!/bin/bash

# Configure git safe directory
git config --global --add safe.directory /workspaces/elastic-stack-fleet-docker-compose

# Add aliases
cat << EOF >> ~/.bashrc

# Custom aliases
alias ll='ls -alF'
alias dc='docker-compose'
alias dcdn='docker-compose down'
alias dcup='docker-compose up -d'
alias dcb='docker-compose build'
alias dk='docker'
alias dklo='docker logs'
alias dklof='docker logs -f'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkrm='docker rm'
alias dkex='docker exec -it'
alias gm='git add --all && git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gst='git status'
alias gp='git push'
EOF

echo "Aliases have been added to .bashrc"