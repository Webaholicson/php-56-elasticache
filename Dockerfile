# Base image on CircleCI's image for PHP 5.6
FROM circleci/php:5.6-apache-browsers

# Update dependencies
RUN sudo apt-get update && sudo apt-get upgrade

# Install PHP extension dependencies and MySQL Client
RUN sudo apt-get install bash geoip-database geoip-database-extra libc-client-dev libgeoip-dev libicu-dev libkrb5-dev libmcrypt-dev libmemcached-dev libpng-dev libtidy-dev libxml2-dev mysql-client wget tar

RUN wget https://elasticache-downloads.s3.amazonaws.com/ClusterClient/PHP-5.6/latest-64bit -O elasticache-php-client.tgz \
	&& sudo pecl install elasticache-php-client.tgz \
	&& rm -f elasticache-php-client.tgz \
	&& echo "extension=amazon-elasticache-cluster-client.so" | sudo tee --append /usr/local/etc/php/conf.d/memcached.ini

# Install PECL extensions
RUN sudo pecl install apcu geoip memcache

# Enable PECL extensions
RUN sudo docker-php-ext-enable geoip memcache

RUN sudo docker-php-source extract \
	&& curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/2.2.8.tar.gz \
	&& tar xfz /tmp/redis.tar.gz \
	&& rm -r /tmp/redis.tar.gz \
	&& sudo mv phpredis-2.2.8 /usr/src/php/ext/redis \
	&& sudo docker-php-ext-install redis \
	&& sudo docker-php-source delete

# Install PHP extensions
RUN sudo docker-php-ext-install mcrypt opcache pdo_mysql soap tidy bcmath
