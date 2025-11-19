#!/bin/bash

# Script to view HabitPet app logs in real-time
# Usage: ./view_logs.sh

echo "🔍 Starting log stream for HabitPet..."
echo "Press Ctrl+C to stop"
echo ""
echo "Filtering for: PRECISE, Bridge, DualAnalyzer, SIMPLIFIED, WARNING"
echo ""

# View logs with filtering
log stream --predicate 'processImage == "HabitPet"' --style compact | grep -E "(PRECISE|Bridge|DualAnalyzer|SIMPLIFIED|WARNING|CRITICAL|ERROR|✅|⚠️|❌|📐|📊|📸|🔍|🔑)" --color=always

