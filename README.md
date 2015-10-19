# Nginx Bootstrap Container ![](http://emojipedia-us.s3.amazonaws.com/cache/29/e3/29e3b8e6a4750c6eb936b3574726ec19.png)

This repo is designed to allow you to quickly and easily create a secure (HTTPS) Nginx reverse-proxy container to use with your dockerized applications. Just follow the instructions below to get started.

### Clone the repo
To get started clone the repo so you can build you customized container:

```bash
git clone https://github.com/hellobond/docker-nginx-ssl.git
```

### Edit the Nginx configuration
** Note: this repo is setup so that all configuration files are under the `sysconfig` directory--think of `sysconfig` as the mount point for all configuration setting files in the docker container.**

By default all sites in `/etc/nginx/sites-available` will be symlinked into `sites-enabled`, and the default behavior is to redirect all HTTP requests on port 80 to HTTPS on 443. If that's what you want, you just need to edit `/etc/nginx/sites-available/default-ssl` to suite your needs.

The configuration (by default) looks like this:

```nginx
server {
    listen 443 ssl;

    server_name _;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
      proxy_pass http://gunicorn:8000/;
      proxy_redirect     off;

      proxy_set_header   Host             $host;
      proxy_set_header   X-Real-IP        $remote_addr;
      proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}
```

Nginx will respond to all hostnames and uses the `server.crt` and `server.key` files in `/etc/nginx/ssl/` to handle all the cryptographic handshaking. You need to either add your own server credentials or generate some keys (see below).

Additionally, nginx is setup to reverse-proxy everything to an upstream server running on port 8000 (gunicorn's default). If that's what you're looking to do you don't have to make any changes to the config files.

### Add or generate the server keys
If you have your own server certificates & keys copy them to `sysconfig/etc/nginx/ssl/server.crt` and `sysconfig/etc/nginx/ssl/server.key`, respectively. They will be copied into the container when it's built.

If you dont' have you own certificate from a CA, you can generate a self-signed certificate (although browsers will complain). Just run the following command to do it one shot:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sysconfig/etc/nginx/ssl/server.key -out sysconfig/etc/nginx/ssl/server.crt
```

### Build the container
Let's assume we are using docker-machine to run this container on a remote host.

Firstly, we need to activate docker-machine so that it points at the remote host:

```bash
docker-machine env remotename
```

and follow the commands that are output, primarily this one:

```bash
# Run this command to configure your shell:
# eval "$(docker-machine env remotename)"
```

If you need more info on docker-machine, [check out the docs.](https://docs.docker.com/machine/)

We can build our container, like so:

```bash
docker build -t nginx .
```

Note that if we activated a docker-machine environment, this builds the container (and will subsequently run it) on the remote host.

### Run your application
If we use the default setup, we need to run our wsgi application prior to running the reverse-proxy (read nginx). For instance, running your wsgi app might look something like:

```bash
docker run -d wsgi-app
```

### Run nginx (and link it)
Now we can run the nginx (and, if we're using the default configuration, link it to our applications), like so:

```bash
docker run --name nginx -d -p 80:80 -p 443:443 --link wsgi-app:gunicorn nginx
```





