#!/bin/bash
# Flutter development helper script

echo "Starting Flutter development..."
echo "To capture logs, run: flutter run --verbose 2>&1 | tee flutter.log"
echo ""
echo "For hot restart: press 'R' in the terminal"
echo "For hot reload: press 'r' in the terminal"
echo "To quit: press 'q'"
echo ""

# Check if device is connected
echo "Checking connected devices..."
flutter devices

echo ""
echo "Running Flutter..."
flutter run --debug
