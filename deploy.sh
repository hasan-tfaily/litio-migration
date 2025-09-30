#!/bin/bash

# State of Law - Strapi CMS Deployment Script
# Server: 46.62.219.128

set -e

echo "🚀 Starting deployment of State of Law CMS..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVER_IP="46.62.219.128"  
APP_NAME="encompass-api"
APP_DIR="/var/www/encompass-api"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
DOMAIN="" # Set your domain here

echo -e "${GREEN}📋 Deployment Configuration:${NC}"
echo "Server IP: $SERVER_IP"
echo "App Name: $APP_NAME"
echo "App Directory: $APP_DIR"
echo ""

# Function to run commands on server
run_on_server() {
    echo -e "${YELLOW}🔧 Running on server: $1${NC}"
    ssh app@$SERVER_IP "$1"
}

# Function to copy files to server
copy_to_server() {
    echo -e "${YELLOW}📁 Copying to server: $1 -> $2${NC}"
    scp $1 app@$SERVER_IP:$2
}

echo -e "${GREEN}1. Updating system packages...${NC}"
run_on_server "sudo apt update && sudo apt upgrade -y"

echo -e "${GREEN}2. Installing Node.js 18...${NC}"
run_on_server "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs"

echo -e "${GREEN}3. Installing PostgreSQL...${NC}"
run_on_server "sudo apt install -y postgresql postgresql-contrib"

echo -e "${GREEN}4. Installing Nginx...${NC}"
run_on_server "sudo apt install -y nginx"

echo -e "${GREEN}5. Installing PM2...${NC}"
run_on_server "sudo npm install -g pm2"

echo -e "${GREEN}6. Creating application directory...${NC}"
run_on_server "sudo mkdir -p $APP_DIR && sudo chown -R www-data:www-data $APP_DIR"

echo -e "${GREEN}7. Setting up PostgreSQL database...${NC}"
run_on_server "
sudo -u postgres psql -c \"CREATE DATABASE \\\"encompass-api\\\";\"
sudo -u postgres psql -c \"CREATE USER strapi_user WITH PASSWORD 'your_secure_password_here';\"
sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE \\\"encompass-api\\\" TO strapi_user;\"
sudo -u postgres psql -c \"ALTER USER strapi_user CREATEDB;\"
"

echo -e "${GREEN}8. Copying application files...${NC}"
# Create a temporary directory for deployment
mkdir -p /tmp/deployment
cp -r . /tmp/deployment/
cd /tmp/deployment

# Remove unnecessary files
rm -rf node_modules
rm -rf .git
rm -rf dist
rm -f .env

# Copy to server
tar -czf app.tar.gz .
copy_to_server "app.tar.gz" "/tmp/"
run_on_server "cd $APP_DIR && tar -xzf /tmp/app.tar.gz && rm /tmp/app.tar.gz"

echo -e "${GREEN}9. Installing dependencies...${NC}"
run_on_server "cd $APP_DIR && npm install --production"

echo -e "${GREEN}10. Setting up environment variables...${NC}"
run_on_server "cd $APP_DIR && cp .env.production.example .env"

echo -e "${GREEN}11. Building the application...${NC}"
run_on_server "cd $APP_DIR && npm run build"

echo -e "${GREEN}12. Setting up PM2...${NC}"
run_on_server "cd $APP_DIR && pm2 start ecosystem.config.js --env production"

echo -e "${GREEN}13. Setting up Nginx...${NC}"
run_on_server "sudo systemctl enable nginx && sudo systemctl start nginx"

echo -e "${GREEN}14. Configuring firewall...${NC}"
run_on_server "sudo ufw allow 22 && sudo ufw allow 80 && sudo ufw allow 443 && sudo ufw --force enable"

echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. SSH into your server: ssh app@$SERVER_IP"
echo "2. Edit environment variables: nano $APP_DIR/.env"
echo "3. Update database credentials in .env file"
echo "4. Restart the application: pm2 restart $APP_NAME"
echo "5. Configure your domain in Nginx if needed"
echo "6. Set up SSL certificate with Let's Encrypt"
echo ""
echo -e "${GREEN}🌐 Your application should be accessible at: http://$SERVER_IP:1337${NC}"

# Cleanup
cd /Users/hasantfaily/Documents/my\ projects/stateOfLaw
rm -rf /tmp/deployment
