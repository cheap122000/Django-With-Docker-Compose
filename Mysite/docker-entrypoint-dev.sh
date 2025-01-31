#!/bin/bash

if [ ! -d "Mysite" ]; then
    echo "Mysite project not found, creating..."
    django-admin startproject Mysite .
    cp ./custom_settings.py Mysite/settings.py
    cp ./custom_urls.py Mysite/urls.py
    echo "Mysite project created"
fi

echo "wating for database..."
RETRIES=20
SLEEP=5

until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" ; do
  ((RETRIES--))
  if [ $RETRIES -le 0 ]; then
    echo "postgres cannot connect, exit"
    exit 1
  fi
  echo "PostgreSQL is not ready, waiting $SLEEP seconds..."
  sleep $SLEEP
done

echo "database is ready"

echo "--------------- Running docker entrypoint script"
echo "--------------- Running Django migrations"
python3 manage.py makemigrations
python3 manage.py migrate
echo '--------------- Create Super User'
python3 manage.py createsuperuser --noinput || echo "Super user already created"
echo "--------------- Collect Static"
python3 manage.py collectstatic --noinput
echo "--------------- Running server"
python3 manage.py runserver 0.0.0.0:8000