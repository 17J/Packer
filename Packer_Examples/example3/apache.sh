#!/bin/bash

sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello from Apache!</h1>" | sudo tee /var/www/html/index.html
