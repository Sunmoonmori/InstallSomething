#!/bin/bash

wget https://release.larsjung.de/h5ai/h5ai-0.30.0.zip
unzip h5ai-0.30.0.zip
rm h5ai-0.30.0.zip
chmod 777 _h5ai/private/cache/
chmod 777 _h5ai/public/cache/
echo "DirectoryIndex  index.html  index.php  /_h5ai/public/index.php" >> .htaccess

mkdir /srv/h5ai
mv _h5ai /srv/h5ai
mv .htaccess /srv/h5ai
