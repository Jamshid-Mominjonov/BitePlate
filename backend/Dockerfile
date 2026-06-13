FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get --no-precompile

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:bullseye-slim
WORKDIR /app
COPY --from=build /app/bin/server ./bin/server
EXPOSE 8080
CMD ["./bin/server"]