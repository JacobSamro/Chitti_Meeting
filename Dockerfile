# Use the Nginx image from Docker Hub
FROM nginx:latest

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Add a new configuration file
# This file sets up Nginx to serve static files from /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files to the Nginx container
COPY build/web/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx when the container has launched
CMD ["nginx", "-g", "daemon off;"]
