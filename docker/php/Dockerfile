FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    libc-client-dev \
    libmagickwand-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
        pdo_mysql \
        mysqli \
        mbstring \
        curl \
        gd \
        zip \
        intl \
        opcache \
        imap

# Install Imagick extension
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Copy custom PHP configuration
COPY php.ini /usr/local/etc/php/php.ini

# Create log directory for PHP-FPM
RUN mkdir -p /var/log/php-fpm && \
    chown www-data:www-data /var/log/php-fpm

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]