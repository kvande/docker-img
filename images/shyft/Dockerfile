FROM archlinux/base
ENV LANG=en_US.UTF-8

RUN pacman -Sy
RUN pacman -S --noconfirm make devtools git-lfs 
RUN pacman -S --noconfirm ccache
# RUN pacman -S --noconfirm sudo
RUN pacman -S --noconfirm util-linux
RUN pacman -S --noconfirm wget base-devel
RUN pacman -S --noconfirm fakeroot
RUN pacman -S --noconfirm cmake
RUN pacman -S --noconfirm npm
RUN pacman -S --noconfirm blas gcc-fortran tcsh


RUN git lfs install; exit 0

RUN pacman -S --needed --noconfirm sudo # Install sudo
RUN useradd builduser -m # Create the builduser
RUN passwd -d builduser # Delete the buildusers password
#RUN printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers # Allow the builduser passwordless sudo

RUN useradd -m -g wheel -p ci ci
RUN echo 'builduser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers ;
RUN install -m 0700 -g wheel -o ci -d /home/ci/projects
#USER builduser
RUN su builduser -c "ccache --set-config=cache_dir=/home/ci/projects/.ccache --set-config=max_size=20G"
COPY build_install_aur_pkgs.sh /tmp
RUN chmod +x /tmp/build_install_aur_pkgs.sh

RUN su ci -c /tmp/build_install_aur_pkgs.sh
CMD ["/usr/bin/bash"]
