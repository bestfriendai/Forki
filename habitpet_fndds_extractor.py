#!/usr/bin/env python3
"""
HabitPet FNDDS Extractor

Matches missing whitelist items against FNDDS database to find additional foods.
"""

import json
import difflib
from pathlib import Path
from rapidfuzz import fuzz

# ------------------------------
# Utility: normalize
# ------------------------------
def normalize(text):
    if not text:
        return ""
    return (
        text.lower()
        .replace(",", " ")
        .replace("-", " ")
        .replace("(", " ")
        .replace(")", " ")
        .strip()
    )

# ------------------------------
# Load missing whitelist items
# ------------------------------
script_dir = Path(__file__).parent
missing_path = script_dir / "missing_matches.txt"

print("=" * 60)
print("HabitPet FNDDS Extractor")
print("=" * 60)

print(f"\n[1/4] Loading missing matches from {missing_path}...")
with open(missing_path, "r") as f:
    missing_items = [normalize(line.strip()) for line in f.readlines() if line.strip()]
print(f"   Loaded {len(missing_items)} missing items to match")

# ------------------------------
# Load FNDDS JSON
# ------------------------------
# Try common FNDDS file locations
fndds_paths = [
    Path("/Users/janicec/Downloads/fndds_2021_2023.json"),
    script_dir / "fndds_2021_2023.json",
]

fndds_path = None
for path in fndds_paths:
    if path.exists():
        fndds_path = path
        break
    # Try glob pattern
    if "*" in str(path):
        import glob
        matches = glob.glob(str(path))
        if matches:
            fndds_path = Path(matches[0])
            break

if not fndds_path:
    # Try to find any FNDDS file in Downloads
    import glob
    downloads_fndds = glob.glob("/Users/janicec/Downloads/*fndds*.json")
    if downloads_fndds:
        fndds_path = Path(downloads_fndds[0])
        print(f"   Found FNDDS file: {fndds_path}")

if not fndds_path:
    print("\n❌ ERROR: FNDDS JSON file not found!")
    print("   Please ensure 'fndds_2021_2023.json' exists in:")
    print("   - Project root directory, or")
    print("   - /Users/janicec/Downloads/")
    exit(1)

print(f"\n[2/4] Loading FNDDS JSON from {fndds_path}...")
print("   (This may take a minute for large files)...")
with open(fndds_path, "r") as f:
    fndds_data = json.load(f)

survey_foods = fndds_data.get("SurveyFoods", [])
if not survey_foods:
    # Try alternative structure
    if isinstance(fndds_data, list):
        survey_foods = fndds_data
    else:
        # Try to get first list value
        for key, value in fndds_data.items():
            if isinstance(value, list):
                survey_foods = value
                break

print(f"   Loaded {len(survey_foods)} foods from FNDDS")

# ------------------------------
# Pre-index FNDDS foods
# ------------------------------
print(f"\n[3/4] Indexing FNDDS foods for matching...")
indexed_fndds = []
for food in survey_foods:
    desc = food.get("description", "")
    norm_desc = normalize(desc)
    indexed_fndds.append({
        "fdcId": food.get("fdcId"),
        "description": desc,
        "norm": norm_desc,
        "nutrients": food.get("foodNutrients", [])
    })
print(f"   Indexed {len(indexed_fndds)} foods")

# ----------------------------------------
# Nutrient extraction helper
# ----------------------------------------
def extract_macros(foodNutrients):
    kcal = protein = carbs = fat = None
    for n in foodNutrients:
        num = n.get("nutrient", {}).get("number")
        amt = n.get("amount")
        if num == "208": kcal = amt
        elif num == "203": protein = amt
        elif num == "205": carbs = amt
        elif num == "204": fat = amt
    return kcal, protein, carbs, fat

# ----------------------------------------
# Fuzzy match function (improved with multiple strategies)
# ----------------------------------------
def best_match(query, candidates):
    best = None
    best_score = 0
    
    for c in candidates:
        # Try multiple matching strategies
        score1 = fuzz.token_set_ratio(query, c["norm"])
        score2 = fuzz.partial_ratio(query, c["norm"])
        score3 = fuzz.token_sort_ratio(query, c["norm"])
        
        # Use the best score
        score = max(score1, score2, score3)
        
        if score > best_score:
            best_score = score
            best = c
    
    if best_score < 60:
        return None, 0
    
    return best, best_score

# ----------------------------------------
# Process missing matches
# ----------------------------------------
print(f"\n[4/4] Matching {len(missing_items)} missing items against FNDDS...")
results = []
unmatched = []

for idx, item in enumerate(missing_items):
    if (idx + 1) % 25 == 0:
        print(f"   Processed {idx + 1}/{len(missing_items)} items, found {len(results)} matches...")
    
    match, score = best_match(item, indexed_fndds)
    
    if not match:
        unmatched.append(item)
        continue
    
    kcal, protein, carbs, fat = extract_macros(match["nutrients"])
    
    # Skip if missing calories
    if kcal is None:
        unmatched.append(item)
        continue
    
    results.append({
        "name": match["description"],
        "searchKey": item,
        "fdcId": match["fdcId"],
        "category": "FNDDS Mixed Dish",
        "calories": kcal or 0,
        "protein": protein or 0,
        "carbs": carbs or 0,
        "fat": fat or 0
    })

# ----------------------------------------
# Save results
# ----------------------------------------
output_path = script_dir / "habitpet_fndds_added_foods.json"
unmatched_path = script_dir / "fndds_unmatched.txt"

print(f"\n[5/5] Saving results...")
with open(output_path, "w") as f:
    json.dump(results, f, indent=2)

with open(unmatched_path, "w") as f:
    for u in unmatched:
        f.write(u + "\n")

print("\n" + "=" * 60)
print("FNDDS EXTRACTION COMPLETE")
print("=" * 60)
print(f"Total foods matched:     {len(results)}")
print(f"Still unmatched:         {len(unmatched)}")
print(f"Output file:             {output_path}")
print(f"Output file size:        {output_path.stat().st_size / 1024:.1f} KB")
print(f"Unmatched items log:     {unmatched_path}")

if unmatched:
    print(f"\nFirst 10 unmatched items:")
    for item in unmatched[:10]:
        print(f"  - {item}")

print("\n" + "=" * 60)

