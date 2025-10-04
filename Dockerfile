# Stage 1: Build the React app
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve the built app with a web server
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
RUN echo ' \
    server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
    try_files $uri /index.html; \
    } \
    location /static/ { \
    expires 1y; \
    access_log off; \
    add_header Cache-Control "public, max-age=31536000, immutable"; \
    } \
    error_page 404 /index.html; \
    } \
    ' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]