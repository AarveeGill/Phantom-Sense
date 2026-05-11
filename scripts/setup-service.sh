#!/bin/bash
 # PhantomSense — restore VirtualHere systemd service after SteamOS update
 # Run this script after any SteamOS update to restore auto-start functionality
 # Usage: sudo ~/Documents/virtualhere/setup-service.sh
 
 set -e
 
 echo "PhantomSense — Installing VirtualHere systemd service..."
 
 # Check if VirtualHere binary exists
 if [ ! -f /home/deck/Documents/virtualhere/vhusbdx86_64 ]; then
 echo "Error: VirtualHere binary not found at /home/deck/Documents/virtualhere/vhusbdx86_64"
 echo "Please download it first:"
 echo " mkdir -p ~/Documents/virtualhere"
 echo " cd ~/Documents/virtualhere"
 echo " wget https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64"
 echo " chmod +x vhusbdx86_64"
 exit 1
 fi
 
 # Create the systemd service file
 cat << 'EOF' | sudo tee /etc/systemd/system/virtualhere.service
 [Unit]
 Description=VirtualHere USB Server
 After=network-online.target
 Wants=network-online.target
 
 [Service]
 ExecStart=/home/deck/Documents/virtualhere/vhusbdx86_64
 Restart=always
 RestartSec=3
 User=root
 
 [Install]
 WantedBy=multi-user.target
 EOF
 
 # Reload systemd, enable and start the service
 sudo systemctl daemon-reload
 sudo systemctl enable virtualhere.service
 sudo systemctl start virtualhere.service
 
 echo ""
 echo "VirtualHere service installed and running."
 echo "Status:"
 sudo systemctl status virtualhere.service --no-pager
