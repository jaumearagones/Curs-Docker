# Proyecto Vue v3

El objetivo de este proyecto es crear una imagen Docker para un proyecto Vue v3.

> Se ha modificado la configuración del servidor vite por defecto para permitir el hot-reloading desde WSL. Revisar el fichero `vite.config.ts`.


## 1. Imagen Docker para desarollo

> En la [documentación](https://docs.docker.com/reference/cli/docker/image/build/#file) encontraréis la manera de indicar el nombre del fichero cuando este es diferente de `Dockerfile`.

Crea un fichero `Dockerfile.dev` para las instrucciones de creación de una imagen Docker orientada al desarollo. Recuerda que en Vue para iniciar un servidor de desarrollo debes ejecutar:

```sh
npm install
npm run dev
```

## 2. Imagen Docker para producción

Crea un fichero `Dockerfile.prod` para las instrucciones de creación de una imagen Docker orientada al desarollo. Recuerda que en Vue compilar y minificar ficheros para producción hay que ejecutar:

```sh
npm install
npm run build
```

Esto creará una carpeta `dist` que contendrá los ficheros estáticos de nuestro sitio web. Estos ficheros los debe servir un servidor web, puedes hacer uso del servicio Nginx copiando el contenido de la carpeta dist en la ruta `/var/www/myapp/dist` y añadiendo la siguiente configuración:

```
server {
    listen      80 default_server;   
    charset utf-8;
    root    /var/www/myapp/dist;
    index   index.html;

    location / {
        root /var/www/myapp/dist;
        try_files $uri  /index.html;
    }    
    error_log  /var/log/nginx/vue-app-error.log;
    access_log /var/log/nginx/vue-app-access.log;
}
```

## 3. Mismo Dockerfile para desarrollo y producción

Tener dos ficheros Dockerfile puede introducir errores. Vamos a ver como podemos solucinar este error haciendo uso de [multi-stages builds](https://docs.docker.com/build/building/multi-stage/):

```
ARG APP_ENV=dev

FROM alpine as base
RUN echo "running BASE commands"

# Building de pre-install Prod image
FROM base as prod-preinstall
RUN echo "running PROD pre-install commands"

# Building the Dev image
FROM base as dev-preinstall
RUN echo "running DEV pre-install commands"

# Installing the app files
FROM ${APP_ENV}-preinstall as install
RUN echo "running install commands"

FROM install as prod-postinstall
RUN echo "running PROD post-install commands"

FROM install as dev-postinstall
RUN echo "running DEV post-install commands"

FROM ${APP_ENV}-postinstall
RUN echo "running final commands"
```

Ejecutando:
```bash
$ docker build -t prod --build-arg APP_ENV=prod .

 => /bin/sh -c echo "running BASE commands"                       0.5s
 => /bin/sh -c echo "running PROD pre-install commands"           0.4s
 => /bin/sh -c echo "running install commands"                    0.4s
 => /bin/sh -c echo "running PROD post-install commands"          0.4s
 => /bin/sh -c echo "running final commands"                      0.4s
 => exporting to image                                            0.0s
```

```bash
$ docker build -t dev .

 => CACHED /bin/sh -c echo "running BASE commands"                  0.0s
 => /bin/sh -c echo "running DEV pre-install commands"              0.4s
 => /bin/sh -c echo "running install commands"                      0.5s
 => /bin/sh -c echo "running DEV post-install commands"             0.4s
 => /bin/sh -c echo "running final commands"                        0.4s
 => exporting to image                                              0.0s

```

En nuestro caso, no podemos usar la misma imagen base para desarrollo y producción, puesto que una ha de ser `node` y otra un servidor web. Sin embargo, sí que podemos adaptar este enfoque usando [target](https://docs.docker.com/build/building/multi-stage/#stop-at-a-specific-build-stage):

```
FROM node as base
RUN echo "FROM node as base"

FROM base as prod
RUN echo "FROM base as prod"

FROM base as dev
RUN echo "FROM base as dev"

FROM nginx
RUN echo "FROM nginx"
<COPY --from prod>
```

```bash
$ docker build -t dev --target dev .
...
 => [base 2/5] RUN echo "FROM node as base"                         0.0s
 => [dev 1/1] RUN echo "FROM base as dev"                                  0.3s
```

```bash
$ docker build -t prod  .

 => [base 2/5] RUN echo "FROM node as base"                         0.0s
 => [prod 1/2] RUN echo "FROM base as prod"                                0.3s
  => [stage-3 2/3] RUN echo "FROM nginx"                             0.0s

```
