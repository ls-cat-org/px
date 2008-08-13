VERSION= 1.1
help:
	echo "Usage: sudo make install"


md2test: md2test.c
	gcc md2test.c -o md2test -lpq

clean:
	rm -f md2test *.o *~

dist:
	ln -fs . pxMarServer-$(VERSION)
	tar czvf pxMarServer-$(VERSION).tar.gz pxMarServer-$(VERSION)/pxMarServer.py pxMarServer-$(VERSION)/marccd pxMarServer-$(VERSION)/Makefile pxMarServer-$(VERSION)/fixMarccdLog pxMarServer-$(VERSION)/append.to.sudoers pxMarServer-$(VERSION)/testCcd.py pxMarServer-$(VERSION)/md2test.c
	cd pxMarServer-$(VERSION)
	rm -f pxMarServer-$(VERSION)

install: 
	install pxMarServer.py /usr/local/bin
	install marccd /usr/local/bin
	install fixMarccdLog /usr/local/bin

	grep -q pxMarServer /etc/sudoers || echo "Please append append.to.sudoers to /etc/sudoers"


