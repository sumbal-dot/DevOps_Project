#!/bin/bash

# Update system and install dependencies
sudo yum update -y

# Install NGINX
sudo amazon-linux-extras install -y nginx1
sudo systemctl enable nginx
sudo systemctl start nginx

# Install Docker
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Install Git
sudo yum install -y git

# Install Node.js 20 (for any build tools)
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Install Docker Compose (optional for multi-container setups)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone the React app repository
cd /home/ec2-user
sudo git clone https://github.com/Khhafeez47/reactapp.git
sudo chown -R ec2-user:ec2-user reactapp

# Create Dockerfile for React app
cat << 'EOF' > /home/ec2-user/reactapp/Dockerfile
# Stage 1: Build the React app
FROM node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve the app using Nginx
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create necessary directories and files
mkdir -p /home/ec2-user/reactapp/nginx

# Create Nginx configuration for React app
cat <<EOF | sudo tee /home/ec2-user/reactapp/nginx/nginx.conf
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

# Build and run the Docker container
cd /home/ec2-user/reactapp
sudo docker build -t react-app .
sudo docker run -d -p 3000:80 --name react-container react-app

# Configure NGINX reverse proxy
cat <<EOF | sudo tee /etc/nginx/conf.d/reactapp.conf
server {
    listen 80;
    server_name sumbal-project.apparelcorner.shop;  # Replace with your domain

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Restart NGINX
sudo systemctl restart nginx