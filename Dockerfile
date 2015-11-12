FROM nginx:1.9

MAINTAINER Daniel Gladstone <daniel@bond.co>

COPY sysconfig/ /

RUN ln -sf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

EXPOSE 80 443

CMD ["nginx"]