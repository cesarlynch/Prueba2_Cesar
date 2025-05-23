FROM ubuntu:22.04

LABEL maintainer="cesar.lynch@duocuc.cl"

ENV DEBIAN_FRONTEND=noninteractive
ENV NAGIOS_USER=nagios
ENV NAGIOS_GROUP=nagios

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    build-essential \
    libgd-dev \
    unzip \
    wget \
    curl \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario y grupo para Nagios
RUN useradd -m -s /bin/bash ${NAGIOS_USER}

# Descargar y compilar Nagios Core
WORKDIR /tmp
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.7.tar.gz && \
    tar xzf nagios-4.5.7.tar.gz && \
    cd nagios-4.5.7 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make all && \
    make install && \
    make install-commandmode && \
    make install-init && \
    make install-config && \
    make install-webconf

# Configurar usuario de interfaz web
RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios

# Habilitar CGI en Apache
RUN a2enmod cgi

EXPOSE 80

# Iniciar Nagios y Apache al arrancar
CMD service apache2 start && /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg && tail -f /dev/null

