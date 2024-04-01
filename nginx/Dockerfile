FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
COPY your-host.com.conf /etc/nginx/sites-available/

RUN mkdir -p /etc/nginx/sites-enabled/\
    && ln -s /etc/nginx/sites-available/your-host.com.conf /etc/nginx/sites-enabled/

CMD ["nginx", "-g", "daemon off;"]

