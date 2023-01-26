# Extend from the official Elixir image
FROM elixir:1.14.2-slim

# Install debian packages
RUN apt-get update && \
    apt-get install --yes \
    build-essential \
    inotify-tools \
    postgresql-client \
    git \
    glibc-source && \
    apt-get clean

WORKDIR /app

# Set environment
ENV MIX_ENV dev

# Install hex package manager and rebar
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix do local.hex --force, local.rebar --force

# Cache elixir dependecies and lock file
COPY mix.* ./

# Install and compile dependecies
RUN mix do deps.get
RUN mix deps.compile

# Copy all application files
COPY . ./