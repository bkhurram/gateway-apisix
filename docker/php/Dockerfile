# Use Red Hat UBI 9
# FROM redhat/ubi9:latest
FROM almalinux:9

# control at build time
ARG INSTALL_XDEBUG=false
ARG INSTALL_E2E=false

# Create necessary runtime directories
RUN mkdir -p /var/www/vhosts/

WORKDIR /var/www/vhosts/

# Install DNF first
RUN yum -y update && \
		yum -y install dnf && \
		yum clean all && \
		rm -rf /var/cache/yum

# add bash
RUN dnf install -y \
		bash \
		bash-completion;

RUN dnf install -y \
		vim \
		nano \
		wget \
		git \
		make \
		zip \
		unzip \
		tar \
		tree \
		xz \
		lsof \
		which \
		lsof \
		podman \
		procps-ng \
		net-tools;

# Enable PHP 8.1 module
RUN dnf module reset -y php && \
		dnf module enable php:8.2 -y

# Install httpd (Apache) and php-fpm and module
RUN dnf install -y httpd httpd-tools \
		php php-fpm php-opcache php-bcmath php-bz2 php-calendar php-ctype php-curl php-date php-dom php-exif php-fileinfo php-filter php-ftp php-gd php-gettext php-hash php-iconv php-intl php-json php-ldap php-libxml php-mbstring php-mysqli php-mysqlnd php-openssl php-pcntl php-pcre php-pdo_mysql php-pdo_sqlite php-posix php-readline php-session php-shmop php-soap php-sockets php-sqlite3 php-standard php-sysvmsg php-sysvsem php-sysvshm php-tokenizer php-xml php-xmlreader php-xmlwriter php-xsl php-zip php-zlib && \
		dnf clean all

# composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    HASH="$(curl -sS https://composer.github.io/installer.sig)" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') !== '$HASH') { echo 'Installer corrotto'; exit(1); }" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# add ssl
RUN dnf install -y ca-certificates mod_ssl && \
		dnf clean all

# create certificates
RUN openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/pki/tls/private/localhost.key \
		-out /etc/pki/tls/certs/localhost.crt \
		-subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=localhost"

RUN if [ "$INSTALL_XDEBUG" = "true" ]; then \
		dnf install -y php-pecl-xdebug php-devel gcc make && \
		dnf clean all; \
fi

## crate xdebug.ini
RUN if [ "$INSTALL_XDEBUG" = "true" ]; then \
	echo "zend_extension=xdebug.so"                 > /etc/php.d/15-xdebug.ini && \
	echo ""                                         >> /etc/php.d/15-xdebug.ini && \
	echo "[xdebug]"                                 >> /etc/php.d/15-xdebug.ini && \
	echo "xdebug.mode=develop,debug"                >> /etc/php.d/15-xdebug.ini && \
	echo "xdebug.client_host=host.docker.internal"  >> /etc/php.d/15-xdebug.ini && \
	echo "xdebug.start_with_request=yes"            >> /etc/php.d/15-xdebug.ini; \
fi

# Disable default welcome page
RUN rm -f /etc/httpd/conf.d/welcome.conf

# php compiler
# NOTE: on mount volume /etc/httpd/conf.d/ copy php.conf

# Create necessary runtime directories
RUN mkdir -p /run/php-fpm && \
		mkdir -p /var/run/php-fpm

# Configure php-fpm to listen on a TCP port instead of a Unix socket
RUN sed -i 's|^listen = .*$|listen = /run/php-fpm/www.sock|' /etc/php-fpm.d/www.conf

# Configure enable container enviroment /etc/enviroment
RUN sed -i 's|^;clear_env = .*$|clear_env = no|' /etc/php-fpm.d/www.conf

# Redirect logs
RUN sed -i 's|ErrorLog "logs/error_log"|ErrorLog /dev/stderr|' /etc/httpd/conf/httpd.conf && \
sed -i 's|CustomLog "logs/access_log" combined|CustomLog /dev/stdout combined|' /etc/httpd/conf/httpd.conf

# NodeJS
# cypress xvfb-run
RUN if [ "$INSTALL_E2E" = "true" ]; then \
		dnf -y install \
		gcc \
		gcc-c++ \
		make \
		gtk2 \
		gtk3 \
		mesa-libgbm \
		libnotify \
		#GConf2 \
		nss \
		libXScrnSaver \
		alsa-lib \
		libXtst \
		xauth \
		xorg-x11-server-Xvfb && \
		dnf clean all; \
fi

# Install curl and NodeSource setup script
RUN if [ "$INSTALL_E2E" = "true" ]; then \
		curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - && \
		dnf install -y nodejs && \
		dnf clean all; \
fi

# phpinfo
RUN mkdir -p /var/www/html && \
		echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# Expose the web server port
EXPOSE 80 443

# Start php-fpm and httpd when the container launches
CMD ["/bin/bash", "-c", "php-fpm & httpd -D FOREGROUND"]