FROM instrumentisto/flutter:3.13.4 as build-env

# Copy files to container and build
RUN mkdir /app/
ADD . /app/
WORKDIR /app/

RUN flutter pub get

RUN flutter build web --web-renderer auto

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf