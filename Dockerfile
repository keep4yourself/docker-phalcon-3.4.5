FROM ubuntu:18.04 as intermediate
# install the dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev \
        libxml2-dev\
        locales \
        g++ \
        git \
        libpcre3-dev \
        make \
        php \
        php-dev \
        re2c \
        wget 
RUN locale-gen en_US.UTF-8 && \
        export LANG=en_US.UTF-8
        
RUN git clone --depth 1 -b v3.4.5 git://github.com/phalcon/cphalcon.git

WORKDIR cphalcon/build
RUN ./install && \
    apt-get install -y --allow-unauthenticated \
        apache2 \
        iputils-ping \
        cron \
        curl \
        libc6-i386 \
        mcrypt \
        php \
        php-apcu \
        php-curl \
        php-mbstring \
        php-mysql \
        php-soap \
        php-xml \
        unzip \
        zip && \
        apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        echo "extension=phalcon.so" > /etc/php/7.2/mods-available/phalcon.ini && \
        pecl install xdebug && \
        echo "zend_extension=\"/usr/lib/php/20170718/xdebug.so\"" > /etc/php/7.2/mods-available/xdebug.ini && \
        cp /etc/php/7.2/mods-available/xdebug.ini /etc/php/7.2/apache2/conf.d/20-xdebug.ini && \
        phpenmod phalcon && phpenmod mbstring && \
        a2enmod rewrite && \
        apt-get purge -y \
        zlib1g-dev \
        libxml2-dev\
        locales \
        g++ \
        git \
        libpcre3-dev \
        make \
        re2c \
        wget && \
        rm -rf /cphalcon && \
        mkdir /app

WORKDIR /app
EXPOSE 80
CMD service apache2 start && \
        service cron start && \
    /bin/bash
CMD ["apache2ctl", "-D", "FOREGROUND"]
