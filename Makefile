PREFIX=/usr
DESTDIR=
DOCS= ChangeLog README.md AUTHORS THANKS
EXECUTABLE_NAME := $(shell grep ^EXECUTABLE_NAME src/systemd-zram.sh | cut -d\' -f2)
VERSION := $(shell grep ^VERSION src/systemd-zram.sh | cut -d\' -f2)
LICENSE := $(shell grep ^LICENSE src/systemd-zram.sh | cut -d\' -f2)

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

debian_pkg: ChangeLog README.md
	cp README.md debian/README
	cp ChangeLog debian/changelog
	#fakeroot debian/rules clean
	#fakeroot debian/rules build
	fakeroot debian/rules binary
	mv ../systemd-zram_$(VERSION)_all.deb .
	@echo Package done!
	@echo You can install it as root with:
	@echo dpkg -i systemd-zram_$(VERSION)_all.deb

arch_pkg: clean
	sed -i "s|_name=.*|_name=$(EXECUTABLE_NAME)|" PKGBUILD
	sed -i "s|pkgver=.*|pkgver=$(VERSION)|" PKGBUILD
	makepkg -e
	@echo Package done!
	@echo You can install it as root with:
	@echo pacman -U $(EXECUTABLE_NAME)-$(VERSION)-1-any.pkg.tar.xz
