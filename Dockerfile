FROM php:5.4.35-apache

ENV DEBIAN_FRONTEND noninteractive

#Create and expose webiste directory
RUN mkdir -p /var/www/html/public
VOLUME ["/var/www/html"]

# Setup Apache and PHP
RUN 	apt-get -o 'Acquire::CompressionTypes::Order::="gz"' update && \
	apt-get install -y --no-install-recommends \
 	libmcrypt-dev \
	libbz2-dev \
	libpng12-dev && \
	docker-php-ext-install mcrypt bz2 gd mbstring zip pdo_mysql && \
	apt-get purge --auto-remove -y libmcrypt-dev libbz2-dev libpng12-dev && \
	apt-get install -y --no-install-recommends libmcrypt4 libbz2-1.0 libpng12-0 && \
	a2enmod rewrite && \
	a2enmod expires 
	
# Copy config files
COPY config/apache.conf /etc/apache2/apache2.conf
COPY config/php.ini /usr/local/etc/php/php.ini

# Configure opcache
RUN 	apt-get install --no-install-recommends unzip && \
	curl -o /root/opcache.zip -L https://github.com/zendtech/ZendOptimizerPlus/archive/v7.0.3.zip && \ 
	cd /root && \
	unzip opcache.zip && \
	cd /root/ZendOptimizerPlus-7.0.3 && \
	/usr/local/bin/phpize && \ 
	./configure --with-php-config=/usr/local/bin/php-config && \
	make  && \
	make install && \
	cd /root && \
	rm -fr /root/ZendOptimizerPlus-7.0.3 && \
	rm -fr /root/opcache.zip

# Configure xdebug
RUN 	curl -o /root/xdebug.zip -L https://github.com/derickr/xdebug/archive/xdebug_2_2.zip && \
	cd /root && \
	unzip xdebug.zip && \
	cd /root/xdebug-xdebug_2_2 && \
	/usr/local/bin/phpize && \ 
	./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config && \
	make  && \
	make install && \
	cd /root && \
	rm -fr /root/xdebug-xdebug_2_2 && \
	rm -fr /root/xdebug.zip
