FROM node:20-bookworm-slim as build

RUN npm i -g pnpm

WORKDIR /app

COPY pnpm-lock.yaml .
RUN pnpm fetch --ignore-scripts
COPY . .
RUN pnpm install -r --offline --ignore-scripts
RUN pnpm run build


FROM nginx:stable-alpine
ENV NODE_ENV production

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/ /usr/share/nginx/html

WORKDIR /app

RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

CMD ["nginx", "-g", "daemon off;"]
