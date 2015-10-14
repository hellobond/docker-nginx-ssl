FROM nginx:1.9

MAINTAINER Anthony O'Brien <asobrien@gmail.com>

COPY sysconfig/ /

RUN ln -sf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

EXPOSE 80 443

CMD ["nginx"]