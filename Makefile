PREFIX=/usr
DESTDIR=
DOCS= ChangeLog README.md AUTHORS THANKS
EXECUTABLE_NAME := $(shell grep ^EXECUTABLE_NAME src/systemd-zram.sh | cut -d\' -f2)
VERSION := $(shell grep ^VERSION src/systemd-zram.sh | cut -d\' -f2)
LICENSE := $(shell grep ^LICENSE src/systemd-zram.sh | cut -d\' -f2)

DEBIANPKG = $(EXECUTABLE_NAME)_$(VERSION)_all.deb
ARCHPKG = $(EXECUTABLE_NAME)-$(VERSION)-1-any.pkg.tar.xz

default:
	@echo Nothing to do. Just run make install or make arch_install.

install: $(DOCS)
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/doc/systemd-zram"
	install -Dm 644 $^ "$(DESTDIR)$(PREFIX)/share/doc/systemd-zram"
	install -Dm 755 src/systemd-zram.sh "$(DESTDIR)$(PREFIX)/bin/systemd-zram"
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/licenses/systemd-zram"
	install -Dm 644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/systemd-zram/COPYING"
	install -Dm 644 src/systemd-zram.service "$(DESTDIR)/lib/systemd/system/systemd-zram.service"

arch_install: $(DOCS)
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/doc/systemd-zram"
	install -Dm 644 $^ "$(DESTDIR)$(PREFIX)/share/doc/systemd-zram"
	install -Dm 755 src/systemd-zram.sh "$(DESTDIR)$(PREFIX)/bin/systemd-zram"
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/licenses/systemd-zram"
	install -Dm 644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/systemd-zram/COPYING"
	install -Dm 644 src/systemd-zram.service "$(DESTDIR)$(PREFIX)/lib/systemd/system/systemd-zram.service"


uninstall:
	rm -f $(PREFIX)/bin/systemd-zram
	rm -f /lib/systemd/system/systemd-zram.service
	rm -rf $(PREFIX)/share/licenses/systemd-zram/
	rm -rf $(PREFIX)/share/doc/systemd-zram/

clean:
	rm -rf *.xz *.gz *.tgz *.deb *.rpm /tmp/tmp.*.systemd-zram debian/changelog debian/README debian/files debian/systemd-zram debian/debhelper-build-stamp debian/systemd-zram* pkg

debian_pkg: $(DEBIANPKG)

debian/README: README.md
	cp $^ $@

debian/changelog: ChangeLog
	cp $^ $@

$(DEBIANPKG): debian/README debian/changelog
	#fakeroot debian/rules clean
	#fakeroot debian/rules build
	fakeroot debian/rules binary
	mv ../$@ .
	@echo Package done!
	@echo You can install it as root with:
	@echo dpkg -i $@

arch_pkg: $(ARCHPKG)

$(ARCHPKG): clean
	sed -i "s|_name=.*|_name=$(EXECUTABLE_NAME)|" PKGBUILD
	sed -i "s|pkgver=.*|pkgver=$(VERSION)|" PKGBUILD
	makepkg -d
	@echo Package done!
	@echo You can install it as root with:
	@echo pacman -U $@
