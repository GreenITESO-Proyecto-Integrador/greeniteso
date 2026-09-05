FROM python:3.14-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Instalación de utilidades esenciales para desarrollo y Make
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    git \
    curl \
    sudo \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Argumentos configurables para el usuario del dev container
ARG USERNAME=adminuser
ARG USER_UID=1000
ARG USER_GID=1000

# Creación limpia de usuario/grupo tolerante a colisiones de GID/UID existentes
RUN (getent group $USER_GID || groupadd --gid $USER_GID $USERNAME) \
    && (getent passwd $USER_UID || useradd --uid $USER_UID --gid $USER_GID -m $USERNAME) \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Creación del entorno virtual de Python con permisos para el usuario
RUN python -m venv $VIRTUAL_ENV \
    && chown -R $USERNAME:$USERNAME $VIRTUAL_ENV

WORKDIR /workspace/kit

# Copia de requerimientos e instalación bajo el usuario no root
COPY kit/requirements.txt /workspace/kit/requirements.txt

USER $USERNAME

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /workspace/kit/requirements.txt

# Copia del resto del código de la carpeta kit
COPY kit /workspace/kit

# Declaración del puerto de Django
EXPOSE 8000

CMD ["make", "start"]