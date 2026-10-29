clean:
	rm -r ./eln-cache ./elpa ./etc ./tmp ./tree-sitter ./var

install-desktop:
	ln -sf $(CURDIR)/emacsclient.desktop ~/.local/share/applications/emacsclient.desktop
	ln -sf $(CURDIR)/emacsclient.desktop ~/.local/share/applications/emacs.desktop
	kbuildsycoca6
