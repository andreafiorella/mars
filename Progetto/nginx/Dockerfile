FROM openresty/openresty:alpine

RUN apk add --no-cache \
    curl \
    git \
    lua5.1 \
    lua5.1-dev \
    build-base \
    luarocks

RUN luarocks-5.1 install lua-resty-http

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY script.lua /usr/local/openresty/nginx/conf/script.lua
COPY static.lua /usr/local/openresty/nginx/conf/static.lua
COPY static.html /usr/local/openresty/nginx/html/static.html

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
