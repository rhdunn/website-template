all:
	jekyll build

install:
	rm -rf /var/www/*
	tar -c -C _site -f - . | (cd /var/www; tar -xvf -)
