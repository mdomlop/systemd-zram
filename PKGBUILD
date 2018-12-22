# Maintainer: Manuel Domínguez López <mdomlop at gmail dot com>

_pkgver_year=2018
_pkgver_month=01
_pkgver_day=09

pkgname=systemd-zram
pkgver=0.2b
pkgrel=1
pkgdesc="Systemd zRAM loader."
url="https://github.com/mdomlop/$pkgname"
source=()
license=('GPL3')
arch=('any')
changelog=ChangeLog

package() {
    cd "$startdir"
    make arch_install DESTDIR="$pkgdir"
}
