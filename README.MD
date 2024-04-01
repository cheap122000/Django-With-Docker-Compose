# Django With Docker Compose
### With dev mode
- Note
    - You can run code immediately after editing.
    - Debug in settings.py is True.
- Run project in dev mode:
    ```
    docker compose -f docker-compose-dev.yml up
    ```
    - Then you will see the django rocket in localhost:8888

### With product mode
- Note
    - DEBUG in settings.py is set to False
    - Use Nginx proxy with unix sock.
    - Use Nginx to proxy static and media files.
- Run project in product mode:
    ```
    docker compose -f docker-compose-product.yml up -d
    ```
    - web server is run on port 80 & 443

## Nginx and [Certbot](https://phoenixnap.com/kb/letsencrypt-docker)
- If you want to install SSL certificates, follow the steps below.
- Modify nginx/your-host.com.conf
    - Comment line 10 and uncomment line 11
        ```
        # server_name  localhost 127.0.0.1;
        server_name <your-host.com>
        ```
    - Uncomment Line 18 - 20
        ```
        location / {
           return 301 https://$host$request_uri;
        }
        ```
    - Comment Line 22 - 41
        ```
        # location /static {
        #     alias /app/staticfiles; # your Django project's static files - amend as required
        # }

        # location /media {
        #     alias /app/media; # your Django project's static files - amend as required
        # }

        # location / {
        #     # allow 127.0.0.1;
        #     # deny all;

        #     uwsgi_pass  uwsgi;
        #     keepalive_timeout 300s;
        #     proxy_read_timeout 600s;
        #     uwsgi_read_timeout 600s;
        #     uwsgi_send_timeout 600s;

        #     include     /etc/nginx/uwsgi_params; # the uwsgi_params file you installed
        # }
        ```
- Then test certbot in dry run first:
    ```
    docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d [domain-name]
    ```
- If there are no errors, run the command again without dry run flag
    ```
    docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d [domain-name]
    ```
- If successful, uncomment line 44 - 98 in nginx/your-host.com.conf
    ```
    # server {
        listen 443 ssl http2;
        server_name <your-host.com>
        charset     utf-8;

        ssl_certificate /etc/nginx/ssl/live/<your-host.com>/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/live/<your-host.com>/privkey.pem;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers "TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256";
        ssl_stapling on;
        ssl_stapling_verify on;
    
    
        client_max_body_size 100M;   # adjust to taste
        keepalive_timeout 300s;
        proxy_read_timeout 600s;
    
        location /static {
            alias /app/staticfiles; # your Django project's static files - amend as required
        }
    
        location /media {
            alias /app/media; # your Django project's static files - amend as required
        }
    
        location /nginx/status {
            stub_status on;
    
            # access_log /usr/local/nginx/logs/status.log;
            access_log off;
    
            auth_basic "NginxStatus";
    
            # allow 127.0.0.1;
            # deny all;
        }
    
        location / {
            # allow 127.0.0.1;
            # deny all;
    
            uwsgi_pass  uwsgi;
            keepalive_timeout 300s;
            proxy_read_timeout 600s;
            uwsgi_read_timeout 600s;
            uwsgi_send_timeout 600s;
    
            include     /etc/nginx/uwsgi_params; # the uwsgi_params file you installed
        }
    
    }
    ```
- Reload nginx
    ```
    docker-compose exec web-app nginx -s reload
    ```
- Renew certificates when yours is expired
    ```
    docker-compose run --rm certbot renew
    ```