FROM instrumentisto/flutter:3.10.6 as build-env

# Copy files to container and build
RUN mkdir /app/
ADD . /app/
WORKDIR /app/

RUN flutter pub get

RUN flutter build web --web-renderer html --base-href=/meet/

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html