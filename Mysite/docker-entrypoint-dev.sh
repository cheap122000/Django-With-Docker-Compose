#!/bin/bash
date

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