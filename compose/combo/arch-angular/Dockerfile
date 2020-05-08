FROM archlinux/base

# some additional hoops because of this error:
# warning: dependency cycle detected:
# warning: curl will be installed before its ca-certificates-mozilla dependency

RUN pacman -Sy
RUN pacman --noconfirm -S ca-certificates-mozilla
RUN pacman --noconfirm -Syu 
RUN pacman --noconfirm -Syu git npm
RUN npm i -g @angular/cli

WORKDIR /home/angular
RUN ng new angularwebapp --routing=false --style=scss
WORKDIR /home/angular/angularwebapp
RUN ng serve  --port 4222 --host 0.0.0.0
