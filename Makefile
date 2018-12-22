PREFIX=/usr
DESTDIR=
DOCS= ChangeLog README.md AUTHORS THANKS
EXECUTABLE_NAME := $(shell grep ^EXECUTABLE_NAME src/systemd-zram.sh | cut -d\' -f2)
PROGRAM_NAME := $(shell grep ^PROGRAM_NAME src/systemd-zram.sh | cut -d\' -f2)
DESCRIPTION := $(shell grep ^DESCRIPTION src/systemd-zram.sh | cut -d\' -f2)
VERSION := $(shell grep ^VERSION src/systemd-zram.sh | cut -d\' -f2)
AUTHOR := $(shell grep ^AUTHOR src/systemd-zram.sh | cut -d\' -f2)
MAIL := $(shell grep ^MAIL src/systemd-zram.sh | cut -d\' -f2)
LICENSE := $(shell grep ^LICENSE src/systemd-zram.sh | cut -d\' -f2)
TIMESTAMP = $(shell LC_ALL=C date '+%a, %d %b %Y %T %z')


ChangeLog: changelog.in
	@echo "$(EXECUTABLE_NAME) ($(VERSION)) unstable; urgency=medium" > $@
	@echo >> $@
	@echo "  * Git build." >> $@
	@echo >> $@
	@echo " -- $(AUTHOR) <$(MAIL)>  $(TIMESTAMP)" >> $@
	@echo >> $@
	@cat $^ >> $@

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
	rm -rf *.xz *.gz *.tgz *.deb *.rpm ChangeLog /tmp/tmp.*.systemd-zram debian/changelog debian/README debian/files debian/systemd-zram debian/debhelper-build-stamp debian/systemd-zram* pkg

deb: ChangeLog README.md
	cp README.md debian/README
	cp ChangeLog debian/changelog
	#fakeroot debian/rules clean
	#fakeroot debian/rules build
	fakeroot debian/rules binary
	mv ../systemd-zram_$(VERSION)_all.deb .
	@echo Package done!
	@echo You can install it as root with:
	@echo dpkg -i systemd-zram_$(VERSION)_all.deb

pacman: clean
	sed -i "s|_name=.*|_name=$(EXECUTABLE_NAME)|" PKGBUILD
	sed -i "s|pkgver=.*|pkgver=$(VERSION)|" PKGBUILD
	makepkg -e
	@echo Package done!
	@echo You can install it as root with:
	@echo pacman -U $(EXECUTABLE_NAME)-local-$(VERSION)-1-any.pkg.tar.xz
