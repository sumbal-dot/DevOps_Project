#!/bin/bash

# Update & install Docker, Docker Compose, Nginx, Certbot
apt update -y && apt upgrade -y
apt install -y docker.io docker-compose nginx curl python3-certbot-nginx

# 🔁 Create a 1GB Swap File to prevent OOM crashes (especially on micro instances)
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Enable and start Docker & Nginx
systemctl enable docker --now
systemctl enable nginx --now
usermod -aG docker ubuntu

# Wait for Docker to fully start
sleep 10

# Setup Metabase container via Docker Compose
mkdir -p /home/ubuntu/metabase
cd /home/ubuntu/metabase

cat <<EOF > docker-compose.yml
version: '3'
services:
    metabase:
        image: metabase/metabase:latest
        container_name: metabase
        ports:
            - "3000:3000"
        volumes:
            - metabase-data:/metabase-data
        environment:
            MB_DB_FILE: /metabase-data/metabase.db
        restart: always

volumes:
    metabase-data:
EOF

# Give proper permissions
chown -R ubuntu:ubuntu /home/ubuntu/metabase

# Run Docker Compose
cd /home/ubuntu/metabase
sudo -u ubuntu docker-compose up -d

# Configure Nginx reverse proxy
cat <<EOF > /etc/nginx/sites-available/metabase
server {
    listen 80;
    server_name sumbal-bi.apparelcorner.shop;

    location / {
        proxy_pass http://localhost:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the config
ln -sf /etc/nginx/sites-available/metabase /etc/nginx/sites-enabled/metabase
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Wait for DNS to propagate before issuing certificate
sleep 120

# Get HTTPS cert
certbot --nginx -d sumbal-bi.apparelcorner.shop --non-interactive --agree-tos -m s.bhayo.29400@khi.iba.edu.pk || echo "Certbot failed — run it manually later"

# Test auto-renewal
certbot renew --dry-run