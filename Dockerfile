FROM nginx:1.27-alpine
COPY build /usr/share/html  # nginx path to web files