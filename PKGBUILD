# Maintainer: Manuel Domínguez López <mdomlop at gmail dot com>

_pkgver_year=2018
_pkgver_month=01
_pkgver_day=09

_name=systemd-zram
_gitname=${name}-git

pkgname=${_name}-local
pkgver=0.1b
pkgrel=1
pkgdesc="Systemd zRAM loader."
url="https://github.com/mdomlop/${_name}.git"
source=()
md5sums=('SKIP')
license=('GPL3')
arch=('any')
conflicts=(${_name} ${_gitname})
provides=($_name)


build() {
    cd "$startdir"
    make
    }

package() {
    cd "$startdir"
    make arch_install DESTDIR=${pkgdir}
}
