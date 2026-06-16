# Imagen oficial con la versión exacta que tenemos instalada
FROM ruby:3.3.8-slim

# 👇 INSTALAMOS TODAS LAS LIBRERÍAS NECESARIAS (incluida la que faltaba: libyaml-dev)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  libsqlite3-dev \
  libyaml-dev \
  curl \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Carpeta de trabajo
WORKDIR /app

# 👇 CREAMOS LA CARPETA DATA (CRUCIAL para que la base de datos persista)
RUN mkdir -p /app/data && chmod 777 /app/data

# Copiamos dependencias primero (mejor rendimiento de caché)
COPY Gemfile Gemfile.lock ./

# 👇 COMANDO CORREGIDO: eliminamos el flag obsoleto y usamos la configuración nueva
RUN gem install bundler
RUN bundle config set without "development test"
RUN bundle install --jobs 4

# Copiamos todo el código
COPY . .

# Puerto de la API
EXPOSE 3000

# Comando de inicio (igual que en tu plan)
CMD ["rails", "server", "-b", "0.0.0.0"]
