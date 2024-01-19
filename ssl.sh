#!/bin/bash

# Générer une paire de clés (privée et publique)
openssl genrsa -out localhost.key 2048

# Créer un certificat auto-signé
openssl req -new -x509 -key localhost.key -out localhost.crt -days 365 -subj "/CN=localhost"

# Copier les fichiers clés dans le répertoire Apache (assurez-vous que le répertoire existe)
sudo cp localhost.key /etc/apache2/ssl/private/
sudo cp localhost.crt /etc/apache2/ssl/certs/

# Modifier la configuration d'Apache pour utiliser le certificat
cat <<EOF | sudo tee /etc/apache2/sites-available/default-ssl.conf
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin webmaster@localhost
                DocumentRoot /var/www/html

                SSLEngine on
                SSLCertificateFile /etc/apache2/ssl/certs/localhost.crt
                SSLCertificateKeyFile /etc/apache2/ssl/private/localhost.key

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

                BrowserMatch "MSIE [2-6]" \
                                nokeepalive ssl-unclean-shutdown \
                                downgrade-1.0 force-response-1.0
                BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

        </VirtualHost>
</IfModule>
EOF

# Activer le module SSL
sudo a2enmod ssl

# Activer le site SSL
sudo a2ensite default-ssl.conf

# Redémarrer Apache pour appliquer les changements
sudo service apache2 restart
