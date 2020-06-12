FROM archlinux

RUN pacman -Syu --noconfirm
RUN pacman -Sy git git-lfs  --noconfirm
RUN git-lfs install
#VOLUME [ "/tmp" ]

ENTRYPOINT [ "bash" ]