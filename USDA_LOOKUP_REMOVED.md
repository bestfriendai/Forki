# USDA Lookup Removed from V2 Calorie Camera Flow

## Why USDA Lookup Was Removed

The collaborator's V2 Calorie Camera feature **does not use USDA lookup**. The Supabase Edge Function (`analyze_food`) already provides all the nutrition data needed:

### What the API Provides

1. **Food Label**: Specific food name (e.g., "Orange", "Chicken Breast")
2. **Calories**: Estimated calories for the detected portion
3. **Macros**: Protein, carbs, and fats (already scaled to the detected portion)
4. **Priors**: Density and kcal/g for geometry estimation
5. **Confidence**: How confident the AI is in the identification

### Why USDA Lookup Was Redundant

1. **API Already Provides Macros**: The API returns macros that match the actual portion size detected, not per-100g values that need scaling
2. **Portion-Specific**: The API estimates calories and macros for the **actual portion** in the image, not a standard serving size
3. **More Accurate**: The API uses computer vision to estimate the actual portion, while USDA uses arbitrary "standard serving sizes" (100-150g)

### Problems USDA Lookup Caused

1. **Wrong Matches**: "Orange" was matching "Orange Juice" instead of "Orange"
2. **Replaced Accurate Data**: USDA lookup replaced accurate API macros with USDA macros that didn't match the actual portion
3. **Arbitrary Serving Sizes**: Used fixed serving sizes (100-150g) that didn't match the actual portion detected
4. **Unnecessary API Calls**: Added extra network requests and latency

## What Changed

### Before (With USDA Lookup)
```
1. API returns: "Orange", 62 cal, macros
2. HomeScreen sets aiPrefill with API data
3. USDA lookup runs in background
4. If match found: Replaces API data with USDA data (scaled to standard serving)
5. FoodLoggerView shows USDA data (may not match actual portion)
```

### After (Without USDA Lookup)
```
1. API returns: "Orange", 62 cal, macros (for actual portion)
2. HomeScreen sets aiPrefill with API data
3. FoodLoggerView shows API data (matches actual portion) ✅
```

## Files Modified

- `HabitPet/Home/HomeScreen.swift`:
  - Removed USDA lookup code (~100 lines)
  - Removed `usdaCancellable` property
  - Added comment explaining why USDA lookup was removed

## Benefits

1. ✅ **Faster**: No extra API calls
2. ✅ **More Accurate**: Uses portion-specific data from API
3. ✅ **Simpler**: Less code, fewer edge cases
4. ✅ **Matches V2 Design**: Aligns with collaborator's V2 implementation

## Note

USDA lookup is still available for **manual food entry** in `FoodLoggerView` (when users search for foods manually). It's only removed from the **automatic camera detection flow**.

