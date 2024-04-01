#!/bin/sh

echo 'Run migration'
python3 manage.py makemigrations
python3 manage.py migrate
echo 'Create Super User'
python3 manage.py createsuperuser --noinput || echo "Super user already created"
echo 'Collect Static'
python3 manage.py collectstatic --noinput
exec "$@"