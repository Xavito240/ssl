#!/bin/bash

# Variables
GLPI_ROOT="/var/www/html/glpi"
SSL_CERT_PATH="/etc/ssl/certs/glpi.crt"
SSL_KEY_PATH="/etc/ssl/private/glpi.key"
APACHE_SITES_AVAILABLE="/etc/apache2/sites-available"
APACHE_LOG_DIR="/var/log/apache2"

# Enable Apache SSL module
sudo a2enmod ssl

# Generate SSL certificate
openssl genrsa -out "$SSL_KEY_PATH" 2048
openssl req -new -key "$SSL_KEY_PATH" -out /tmp/glpi.csr
openssl x509 -req -days 365 -in /tmp/glpi.csr -signkey "$SSL_KEY_PATH" -out "$SSL_CERT_PATH"

# Configure Apache virtual host for SSL
cat <<EOL | sudo tee "$APACHE_SITES_AVAILABLE/glpi-ssl.conf" > /dev/null
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot $GLPI_ROOT

    SSLEngine on
    SSLCertificateFile $SSL_CERT_PATH
    SSLCertificateKeyFile $SSL_KEY_PATH

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>

    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    ErrorLog $APACHE_LOG_DIR/error.log
    CustomLog $APACHE_LOG_DIR/access.log combined
</VirtualHost>
EOL

# Enable the SSL virtual host
sudo a2ensite glpi-ssl

# Restart Apache
sudo systemctl restart apache2

# Cleanup
rm /tmp/glpi.csr

echo "SSL configuration for GLPI is complete. Access GLPI using https://your-server"
