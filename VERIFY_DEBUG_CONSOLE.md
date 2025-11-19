# Verify Xcode Debug Console for Myungsun iPhone

## Current Scheme Configuration ✅

Your scheme is correctly configured:
- ✅ **Debugger**: LLDB enabled (`Xcode.DebuggerFoundation.Debugger.LLDB`)
- ✅ **App Reference**: Points to `HabitPet.app` (correct)
- ✅ **Environment**: `OS_ACTIVITY_MODE` disabled (logs will show)
- ✅ **Build Configuration**: Debug mode

## Steps to Verify Device Connection

### 1. Check Device Selection in Xcode

1. **Open Xcode** with your project
2. **Look at the top toolbar** (next to the Run/Stop buttons)
3. **Click the device selector** (should show "Myungsun iPhone" or similar)
4. **Verify**:
   - ✅ "Myungsun iPhone" is selected (not Simulator)
   - ✅ Device shows as "Connected" (green indicator)
   - ✅ No warnings about device compatibility

### 2. Verify Debug Console is Open

1. **Open Debug Area**: Press `Cmd + Shift + Y` (or View → Debug Area → Show Debug Area)
2. **Check Console Tab**: Make sure you're on the "Console" tab (not "Variables" or "Breakpoints")
3. **Check Filter**: Bottom right of console, set to **"All Output"** (not "Errors Only")

### 3. Verify Device is Connected

1. **Window → Devices and Simulators** (or `Cmd + Shift + 2`)
2. **Select "Myungsun iPhone"** from left sidebar
3. **Check Status**:
   - ✅ Device shows as "Connected"
   - ✅ No error messages
   - ✅ Trusted (if prompted, click "Trust This Computer" on iPhone)

### 4. Test Log Output

When you run the app on Myungsun iPhone, you should see logs like:
```
🔄 [DualAnalyzer] Starting analyze()...
📐 [PRECISE] Running Geometry Estimator V2...
✅ [PRECISE] Using API label: 'Orange'
```

If you see these logs, the console is working correctly!

## Common Issues

### Issue 1: Console Shows "No Output"
**Fix**:
- Make sure device is selected (not Simulator)
- Check console filter is set to "All Output"
- Restart Xcode and reconnect device

### Issue 2: Logs Only Show Errors
**Fix**:
- Change console filter from "Errors Only" to "All Output"
- Check `OS_ACTIVITY_MODE` is not enabled (it's disabled in your scheme ✅)

### Issue 3: Device Not Showing in Xcode
**Fix**:
1. Unlock iPhone
2. Trust computer (if prompted)
3. Disconnect and reconnect USB cable
4. Restart Xcode

### Issue 4: Wrong Device Selected
**Fix**:
- Click device selector in Xcode toolbar
- Select "Myungsun iPhone" from dropdown
- Make sure it's not "Myungsun iPhone (Simulator)"

## Alternative: Use Terminal (More Reliable)

If Xcode console is unreliable, use Terminal:

```bash
# View logs from Myungsun iPhone
log stream --predicate 'processImage == "HabitPet"' --style compact

# Or use the script
./view_logs.sh
```

This is often more reliable than Xcode's console for device logs.

## Verification Checklist

- [ ] Device "Myungsun iPhone" is selected in Xcode toolbar
- [ ] Device shows as "Connected" in Devices window
- [ ] Debug Area is open (`Cmd + Shift + Y`)
- [ ] Console tab is selected (not Variables/Breakpoints)
- [ ] Console filter is set to "All Output"
- [ ] App is running on device (not Simulator)
- [ ] Logs appear when you use the app

## Quick Test

1. **Run app** on Myungsun iPhone (`Cmd + R`)
2. **Open Calorie Camera** in the app
3. **Capture a photo**
4. **Check console** - you should see:
   - `🔄 [DualAnalyzer] Starting analyze()...`
   - `📐 [PRECISE] Running Geometry Estimator V2...`
   - `✅ API SUCCESS! Label: '...'`

If you see these logs, your Debug Console is correctly configured! ✅

