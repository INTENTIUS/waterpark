# Build the site with Hugo, serve it with nginx. Same Hugo version CI uses for Pages.
FROM alpine:3.20 AS build
ARG HUGO_VERSION=0.162.1
ARG TARGETARCH
RUN apk add --no-cache ca-certificates curl tar libc6-compat libstdc++ \
 && curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${TARGETARCH:-amd64}.tar.gz" \
    | tar -xz -C /usr/local/bin hugo
WORKDIR /src
COPY . .
RUN hugo --gc --minify --baseURL "/"

FROM nginx:1.27-alpine
COPY --from=build /src/public /usr/share/nginx/html
EXPOSE 80
