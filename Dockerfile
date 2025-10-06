# Use a lightweight base image for Nginx
FROM nginx:alpine

# Copy the static HTML file to the default Nginx web root
COPY index.html /usr/share/nginx/html/index.html

# The default Nginx CMD will run the server
EXPOSE 80
