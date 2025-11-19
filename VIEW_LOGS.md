# How to View Debug Logs Without Xcode

## Option 1: Terminal (Recommended)

Connect your iPhone and run this command in Terminal:

```bash
# View logs from your iPhone in real-time
xcrun devicectl device process launch --device "00008030-001A2DDE21F0802E" --start-stopped com.IYA.JaniceChung.HabitPet 2>&1 | grep -E "(PRECISE|Bridge|DualAnalyzer|SIMPLIFIED)"
```

Or view all logs:
```bash
log stream --predicate 'processImage == "HabitPet"' --style compact
```

## Option 2: Console.app (Mac)

1. Open **Console.app** (Applications > Utilities > Console)
2. Select your iPhone from the left sidebar
3. Filter by "HabitPet" in the search box
4. Look for logs with:
   - `[PRECISE]` - Geometry Estimator V2 logs
   - `[Bridge]` - CalorieCameraBridge logs
   - `[DualAnalyzer]` - API call logs
   - `[SIMPLIFIED]` - Simplified flow logs

## Option 3: Device Logs via Terminal

```bash
# View recent logs
xcrun devicectl device process launch --device "00008030-001A2DDE21F0802E" --start-stopped com.IYA.JaniceChung.HabitPet 2>&1 | tail -100
```

## What to Look For

After scanning food, look for these log patterns:

- `✅ [PRECISE] Using API label: '...'` - API label is being used
- `📐 [PRECISE] Frame X/Y: volume=...mL, calories=...` - Geometry V2 working
- `⚠️⚠️⚠️ [PRECISE] WARNING: Geometry V2 returned suspiciously low values!` - Geometry failed
- `✅ [PRECISE] Using API fallback` - API values being used instead of geometry
- `📸 [Bridge] Food label: '...'` - Final label being sent to UI

