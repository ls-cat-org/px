VERSION := 1.6
help:
	echo "Usage: sudo make install"

md2test: md2test.c
	gcc md2test.c -o md2test -lpq

clean:
	rm -f md2test *.o *~

dist:
	ln -fs . pxMarServer-$(VERSION)
	tar -czvf pxMarServer-$(VERSION).tar.gz pxMarServer-$(VERSION)/pxMarServer.py pxMarServer-$(VERSION)/marccd pxMarServer-$(VERSION)/Makefile pxMarServer-$(VERSION)/fixMarccdLog pxMarServer-$(VERSION)/append.to.sudoers pxMarServer-$(VERSION)/testCcd.py pxMarServer-$(VERSION)/md2test.c
	cd pxMarServer-$(VERSION)
	rm -f pxMarServer-$(VERSION)

install:
	install -p marccd_server_v1.conf /opt/marccd/configuration/marccd_server_v1.conf
	install -p pxMarServer.py /usr/local/bin
	install -p startMarccd /usr/local/bin
	install -p fixMarccdLog /usr/local/bin
	install -p AutoDetector.py /usr/local/bin
	install -p MarccdConfFile.py /usr/local/bin
	./maybe_install_pxMarServer_rsyslogd.sh
#	./append.to.sudoers
