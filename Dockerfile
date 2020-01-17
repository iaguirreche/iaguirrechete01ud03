# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host" \
	creationDate="17-01-2019" \
	maintainer="Itziar Aguirreche <iaguirreche@birt.eus>"

# Instalamos el editor nano
RUN \
	apt-get update \
	&& apt-get install nano \
	&& apt-get install apache2 --yes \
	&& apt-get install proftpd --yes \
	&& apt-get install ssh --yes \
	&& apt-get install git --yes \
	&& mkdir /var/www/html/sitio1 /var/www/html/sitio2 \
	&& useradd -m -d /var/www/html/sitio1 -p $(openssl passwd -1 iaguirreche1) -s /usr/sbin/nologin iaguirreche1 \
	&& useradd -m -d /var/www/html/sitio2 -s /bin/bash -p iaguirreche2 iaguirreche2 \
# Copiamos el index al directorio por defecto del servidor Web
COPY index1.html index2.html sitio1.conf sitio2.conf sitio1.key sitio1.cer /
COPY id_rsa /etc
COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY tls.conf /etc/proftpd/tls.conf
COPY proftpd.crt /etc/ssl/certs/proftpd.crt
COPY proftpd.key /etc/ssl/private/proftpd.key
COPY ftpusers /etc/ftpusers
COPY ssh_config /etc/ssh/ssh_config
COPY sshd_config /etc/ssh/sshd_config 
RUN \
	mv /index1.html /var/www/html/sitio1/index.html \
	&& mv /index2.html /var/www/html/sitio2/index.html \
	&& mv /sitio1.conf /etc/apache2/sites-available \
	&& a2ensite sitio1 \
	&& mv /sitio2.conf /etc/apache2/sites-available \
	&& a2ensite sitio2 \
	&& mv /sitio1.key /etc/ssl/private \
	&& mv /sitio1.cer /etc/ssl/certs \
	&& a2enmod ssl \
	&& eval "$(ssh-agent -s)" \
	&& chmod 700 /etc/id_rsa \
	&& ssh-add /etc/id_rsa \
	&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
	&& git clone git@github.com:deaw-birt/deaw03-te1-ftp-anonimo.git /srv/ftp/clon \
# Indicamos el puerto que utiliza la imagen
EXPOSE 80
EXPOSE 443
EXPOSE 20
EXPOSE 21
EXPOSE 50000-50033
EXPOSE 1022
