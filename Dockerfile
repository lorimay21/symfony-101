FROM "php:8.1-apache"

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ARG PHP_MODE

# Setup PHP and Apache configuration
RUN mv "$PHP_INI_DIR/php.ini-$PHP_MODE" "$PHP_INI_DIR/php.ini" && \
    sed -ri -e 's!((post_max_size|upload_max_filesize) = ).M!\110M!g' $PHP_INI_DIR/php.ini && \
    sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install packages
RUN apt-get update -y && \
    apt-get install -y \
    zip \
    unzip \
    git \
    curl \
    wget \
    zlib1g-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxrender1 \
    libfontconfig1 \
    libx11-dev \
    libjpeg62 \
    libxtst6 \
    supervisor

# Configure extensions
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-install bcmath pdo_mysql gd zip pcntl && \
    a2enmod rewrite && \
    a2enmod headers
