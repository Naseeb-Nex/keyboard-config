#!/bin/bash

echo "Restarting Kanata Service..."
sudo launchctl stop com.example.kanata
sudo launchctl start com.example.kanata
echo "Kanata service restarted."
