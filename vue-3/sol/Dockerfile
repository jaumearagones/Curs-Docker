FROM node as base
COPY . /app
RUN npm install 

FROM base as prod
EXPOSE 80
RUN npm run build

FROM base as dev
WORKDIR /app
EXPOSE 5173
CMD npm run dev

FROM nginx
COPY --from=prod /app/dist /var/www/myapp/dist
COPY default.conf /etc/nginx/conf.d/default.conf 