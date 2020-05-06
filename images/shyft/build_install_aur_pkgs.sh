#!/bin/bash
export CMAKE_BUILD_PARALLEL_LEVEL=4
tmpdir=$(mktemp -d)
aur_pkgs="superlu armadillo dlib doctest"
# for some reason this one fails on wget:
#aur_pkgs="doctest dlib"
any_failed=0
sudo pacman --noconfirm -Sy
pushd ${tmpdir}
for pkg in ${aur_pkgs}; do
  echo "build ${pkg}"
  wget -qO - https://aur.archlinux.org/cgit/aur.git/snapshot/${pkg}.tar.gz | tar -xvz
  pushd ${pkg}
  makepkg -cf
  sudo pacman --noconfirm -U ${pkg}-*.pkg.tar.xz
  popd
done
sudo pip install pytest-parallel bokeh
echo "installing @angular/cli at system level"
echo n | sudo npm install -g --silent @angular/cli
sudo rm -rf ${tmpdir}
