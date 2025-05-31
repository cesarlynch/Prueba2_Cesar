# Comencé por preparar el entorno en una instancia EC2 con Ubuntu, actualizando los paquetes del sistema operativo mediante:

sudo apt update && sudo apt upgrade -y

# Posteriormente, instalé las dependencias necesarias para Docker con:
sudo apt install -y ca-certificates curl gnupg lsb-release

# Luego se creó la carpeta de claves GPG y se añadió la clave del repositorio de Docker:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Después, se configuró el repositorio estable de Docker y se actualizó la lista de paquetes:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# Con el repositorio ya disponible, instalé Docker con todos sus componentes necesarios:
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Una vez instalado Docker, creé un nuevo directorio para alojar el proyecto:
mkdir nagios-core-docker
cd nagios-core-docker

# Dentro de este directorio, creé tres archivos esenciales: 
touch Dockerfile README.md .gitignore

Dockerfile: contendrá las instrucciones para construir la imagen.

README.md: documentación para explicar cómo usar la imagen.

.gitignore: excluir archivos innecesarios del repositorio Git.

# Pasé a editar el Dockerfile con el siguiente contenido:
FROM ubuntu:22.04
LABEL maintainer="cesar.lynch@duocuc.cl"

ENV DEBIAN_FRONTEND=noninteractive
ENV NAGIOS_USER=nagios
ENV NAGIOS_GROUP=nagios

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

RUN useradd -m -s /bin/bash ${NAGIOS_USER}

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

RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios
RUN a2enmod cgi

EXPOSE 80

CMD service apache2 start && /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg && tail -f /dev/null

# Este archivo realiza lo siguiente:

Base de imagen: parte de Ubuntu 22.04.

Etiqueta de mantenimiento.

Variables de entorno para evitar prompts y definir usuario/grupo de Nagios.

Instalación de dependencias como Apache, PHP, compiladores, bibliotecas gráficas y herramientas de red.

Creación de usuario 'nagios' con shell asignado.

Descarga, descompresión, compilación e instalación de Nagios Core 4.5.7 en /tmp.

Configuración de acceso web creando un usuario nagiosadmin con contraseña nagios.

Activación del módulo CGI en Apache, necesario para el frontend web de Nagios.

Exposición del puerto 80, que es donde Apache servirá la interfaz.

Comando de inicio que lanza Apache y Nagios al arrancar el contenedor.

# Una vez guardado el Dockerfile, construí la imagen ejecutando:
sudo docker build -t nagios-core .

# Esto generó exitosamente la imagen con el nombre nagios-core, verificable con:
docker images

# Luego, inicié el contenedor con:
docker run -d -p 80:80 --name nagios nagios-core

# Esto ejecuta la imagen en segundo plano, asignando el nombre nagios y exponiendo el servicio web en el puerto 80. Confirmé su ejecución con:
docker ps

# Y validé la instalación interna de Nagios inspeccionando su carpeta compartida:
docker exec -it nagios ls /usr/local/nagios/share

# Finalmente, para documentar y versionar este proyecto, inicialicé un repositorio Git local:
git init
git add .
git commit -m "Primera versión del contenedor Docker para Nagios Core"

# Subí el proyecto a GitHub mediante clave SSH generada con ssh-keygen, y configuré el repositorio remoto:
git remote add origin git@github.com:cesarlynch/Prueba2_Cesar.git
git branch -M main
git push -u origin main

Esto dejó el proyecto disponible públicamente en GitHub, incluyendo el Dockerfile y documentación.








```bash
docker build -t nagios-core .



---------------------Usuario de nagios------------------
Usuario: nagiosadmin
contraseña: nagios

