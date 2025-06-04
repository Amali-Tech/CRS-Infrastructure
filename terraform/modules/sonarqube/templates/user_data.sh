#!/bin/bash

# Install Docker and Docker Compose
apt-get update
apt-get install -y docker.io nginx certbot python3-certbot-nginx
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Set vm.max_map_count for SonarQube
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# Configure Nginx
cat > /etc/nginx/sites-available/sonarqube << 'EOF'
server {
    listen 80;
    server_name sonar.auto-hive.site;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the site
ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
nginx -t
systemctl restart nginx
systemctl enable nginx

# Get SSL certificate
certbot --nginx -d sonar.auto-hive.site --non-interactive --agree-tos --email admin@auto-hive.site

# Add certbot renewal to crontab
echo "0 0 * * * root certbot renew --quiet" > /etc/cron.d/certbot-renew

# Format and mount EBS volumes
mkfs -t ext4 /dev/sdf
mkfs -t ext4 /dev/sdg

mkdir -p /mnt/sonarqube
mkdir -p /mnt/postgresql

mount /dev/sdf /mnt/sonarqube
mount /dev/sdg /mnt/postgresql

# Add to fstab for persistence
echo "/dev/sdf /mnt/sonarqube ext4 defaults,nofail 0 2" >> /etc/fstab
echo "/dev/sdg /mnt/postgresql ext4 defaults,nofail 0 2" >> /etc/fstab

# Create necessary directories
mkdir -p /mnt/sonarqube/data
mkdir -p /mnt/sonarqube/extensions
mkdir -p /mnt/sonarqube/logs
mkdir -p /mnt/postgresql/data

# Set permissions
chown -R ubuntu:ubuntu /mnt/sonarqube
chown -R ubuntu:ubuntu /mnt/postgresql

# Get database password from SSM Parameter Store
DB_PASSWORD=$(aws ssm get-parameter --name "/${project_name}/${environment}/sonarqube/db/password" --with-decryption --query "Parameter.Value" --output text)

# Create docker-compose.yml
cat > /home/ubuntu/docker-compose.yml << 'EOF'
version: "3.8"
services:
  sonarqube:
    image: sonarqube:latest
    ports:
      - "9000:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD='$DB_PASSWORD'
    volumes:
      - /mnt/sonarqube/data:/opt/sonarqube/data
      - /mnt/sonarqube/extensions:/opt/sonarqube/extensions
      - /mnt/sonarqube/logs:/opt/sonarqube/logs
    depends_on:
      - db
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/api/system/status"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD='$DB_PASSWORD'
      - POSTGRES_DB=sonar
    volumes:
      - /mnt/postgresql/data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sonar"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

EOF

# Start the containers
cd /home/ubuntu
docker-compose up -d

# Enable Docker Compose to start on boot
cat > /etc/systemd/system/docker-compose.service << 'EOF'
[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable docker-compose
systemctl start docker-compose