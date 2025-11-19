# Xcode Debug Console Troubleshooting Guide

## Issue: Logs not showing in Xcode Console

### Quick Fixes

1. **Check Console Filter Settings**
   - In Xcode Debug Area, look at the bottom right
   - Click the filter dropdown (usually says "All Output")
   - Make sure it's set to **"All Output"** or **"All Messages"**
   - Uncheck any filters that might hide NSLog messages

2. **Clear Console**
   - Press `Cmd + K` to clear the console
   - Sometimes old logs can cause display issues

3. **Restart Debug Session**
   - Stop the app (Cmd + .)
   - Clean build folder (Cmd + Shift + K)
   - Build again (Cmd + B)
   - Run again (Cmd + R)

4. **Check Scheme Settings**
   - Product → Scheme → Edit Scheme
   - Go to "Run" → "Arguments"
   - Make sure "OS_ACTIVITY_MODE" is NOT set to "disable"
   - If it exists, delete it or set to "default"

### Alternative: Use Terminal

Since Xcode console can be unreliable, use Terminal instead:

**Option 1: Use the provided script**
```bash
cd /Users/janicec/Documents/GitHub/HabitPet
./view_logs.sh
```

**Option 2: Manual command**
```bash
log stream --predicate 'processImage == "HabitPet"' --style compact
```

**Option 3: Console.app**
1. Open Console.app (Applications > Utilities > Console)
2. Select your iPhone from left sidebar
3. Filter by "HabitPet"
4. Look for logs with emojis (📐, 📊, ✅, ⚠️, etc.)

### Check Xcode Console Settings

1. **Show Debug Area**: `Cmd + Shift + Y`
2. **Console View**: Make sure you're in "Console" tab (not "Variables" or "Breakpoints")
3. **Filter**: Bottom right, set to "All Output"

### Verify Logging is Working

Add this test log to see if NSLog works:
```swift
NSLog("🧪 TEST LOG - If you see this, NSLog is working!")
print("🧪 TEST PRINT - If you see this, print() is working!")
```

### Common Issues

1. **OS_ACTIVITY_MODE disabled**: This prevents NSLog from showing
   - Fix: Remove from Scheme → Run → Arguments → Environment Variables

2. **Console filter too restrictive**: Only showing errors
   - Fix: Change filter to "All Output"

3. **Simulator vs Device**: Device logs sometimes don't show in Xcode
   - Fix: Use Terminal or Console.app for device logs

4. **Build Configuration**: Debug vs Release
   - Make sure you're running Debug build (not Release)
   - Release builds often strip NSLog

### Recommended: Use Terminal for Device Logs

For iPhone device logs, Terminal is more reliable:

```bash
# Real-time logs
log stream --predicate 'processImage == "HabitPet"' --style compact

# Or use the script
./view_logs.sh
```

