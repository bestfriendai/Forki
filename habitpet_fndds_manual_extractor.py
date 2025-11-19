#!/usr/bin/env python3
"""
HabitPet FNDDS Manual Extractor

Manually adds specific cultural foods from FNDDS database.
Skips items already present in existing databases.
"""

import json
from pathlib import Path
from rapidfuzz import fuzz

# ------------------------------
# normalize helper
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

# Foods we want to add manually
manual_items = [
    "kimchi",
    "bibimbap",
    "korean-style beef",
    "pho",
    "chicken curry",
    "fried rice",
    "tacos",
    "burritos",
    "arepas",
    "tamales",
    "shepherd's pie",
    "ramen",
    "pad thai",
    "teriyaki chicken",
    "kimchi fried rice",
    "mac and cheese",
    "sandwich",
    "pasta",
    "casserole",
    "stir fry",
    "breakfast sandwich",
    "breakfast burrito",
    "coffee",
    "latte",
    "cappuccino",
    "soup",
    "chicken noodle soup",
    "mixed dish"
]

manual_items = [normalize(i) for i in manual_items]

print("=" * 60)
print("HabitPet FNDDS Manual Extractor")
print("=" * 60)

# ------------------------------
# Load existing databases to check for duplicates
# ------------------------------
script_dir = Path(__file__).parent
existing_foods = set()

print(f"\n[1/5] Loading existing databases to check for duplicates...")

# Load SR Legacy foods
sr_legacy_path = script_dir / "habitpet_local_foods.json"
if sr_legacy_path.exists():
    with open(sr_legacy_path, 'r') as f:
        sr_data = json.load(f)
    for item in sr_data:
        existing_foods.add(normalize(item.get("name", "")))
    print(f"   Loaded {len(sr_data)} foods from SR Legacy database")

# Load FNDDS added foods
fndds_added_path = script_dir / "habitpet_fndds_added_foods.json"
if fndds_added_path.exists():
    with open(fndds_added_path, 'r') as f:
        fndds_data = json.load(f)
    for item in fndds_data:
        existing_foods.add(normalize(item.get("name", "")))
    print(f"   Loaded {len(fndds_data)} foods from FNDDS added database")

print(f"   Total existing foods indexed: {len(existing_foods)}")

# ------------------------------
# Load FNDDS JSON
# ------------------------------
fndds_path = Path("/Users/janicec/Downloads/fndds_2021_2023.json")
if not fndds_path.exists():
    fndds_path = script_dir / "fndds_2021_2023.json"

if not fndds_path.exists():
    print(f"\n❌ ERROR: FNDDS JSON file not found!")
    print(f"   Expected at: {fndds_path}")
    exit(1)

print(f"\n[2/5] Loading FNDDS JSON from {fndds_path}...")
print("   (This may take a minute for large files)...")
with open(fndds_path, "r") as f:
    fndds = json.load(f)

foods = fndds.get("SurveyFoods", [])
if not foods:
    # Try alternative structure
    if isinstance(fndds, list):
        foods = fndds
    else:
        for key, value in fndds.items():
            if isinstance(value, list):
                foods = value
                break

print(f"   Loaded {len(foods)} foods from FNDDS")

# Pre-index
print(f"\n[3/5] Indexing FNDDS foods for matching...")
indexed = []
for food in foods:
    d = food.get("description", "")
    indexed.append({
        "fdcId": food.get("fdcId"),
        "description": d,
        "norm": normalize(d),
        "nutrients": food.get("foodNutrients", [])
    })
print(f"   Indexed {len(indexed)} foods")

# Extract macros
def extract_macros(nutr):
    kcal = protein = carbs = fat = None
    for n in nutr:
        num = n.get("nutrient", {}).get("number")
        amt = n.get("amount")
        if num == "208": kcal = amt
        elif num == "203": protein = amt
        elif num == "205": carbs = amt
        elif num == "204": fat = amt
    return kcal or 0, protein or 0, carbs or 0, fat or 0

# Best fuzzy-match (using same logic as habitpet_fndds_extractor.py)
def best_match(query, candidates):
    best = None
    best_score = 0
    
    for c in candidates:
        # Use token_set_ratio as specified
        score = fuzz.token_set_ratio(query, c["norm"])
        if score > best_score:
            best_score = score
            best = c
    
    if best_score < 60:
        return None, 0
    
    return best, best_score

# ------------------------------
# Process manual items
# ------------------------------
print(f"\n[4/5] Matching {len(manual_items)} manual items against FNDDS...")
results = []
unmatched = []
skipped_duplicates = []

for idx, item in enumerate(manual_items):
    if (idx + 1) % 5 == 0:
        print(f"   Processed {idx + 1}/{len(manual_items)} items, found {len(results)} matches...")
    
    match, score = best_match(item, indexed)
    
    if not match:
        unmatched.append(item)
        continue
    
    # Check if this food already exists in our databases
    match_name_normalized = normalize(match["description"])
    if match_name_normalized in existing_foods:
        skipped_duplicates.append({
            "searchKey": item,
            "matchedName": match["description"],
            "reason": "Already in existing database"
        })
        continue
    
    kcal, protein, carbs, fat = extract_macros(match["nutrients"])
    
    # Skip if missing calories
    if kcal == 0 and protein == 0 and carbs == 0 and fat == 0:
        unmatched.append(item)
        continue
    
    results.append({
        "name": match["description"],
        "searchKey": item,
        "fdcId": match["fdcId"],
        "category": "FNDDS Manual Additions",
        "calories": kcal,
        "protein": protein,
        "carbs": carbs,
        "fat": fat
    })

# ------------------------------
# Save outputs
# ------------------------------
output_path = script_dir / "habitpet_fndds_manual_additions.json"
unmatched_path = script_dir / "fndds_manual_unmatched.txt"

print(f"\n[5/5] Saving results...")
with open(output_path, "w") as f:
    json.dump(results, f, indent=2)

with open(unmatched_path, "w") as f:
    for u in unmatched:
        f.write(u + "\n")

print("\n" + "=" * 60)
print("MANUAL EXTRACTION COMPLETE")
print("=" * 60)
print(f"Total foods matched:     {len(results)}")
print(f"Unmatched items:         {len(unmatched)}")
print(f"Skipped (duplicates):     {len(skipped_duplicates)}")
print(f"Output file:             {output_path}")
print(f"Output file size:        {output_path.stat().st_size / 1024:.1f} KB")
print(f"Unmatched items log:      {unmatched_path}")

if skipped_duplicates:
    print(f"\nSkipped duplicates (already in database):")
    for skip in skipped_duplicates[:10]:
        print(f"  - {skip['searchKey']} → {skip['matchedName'][:50]}...")

if unmatched:
    print(f"\nUnmatched items:")
    for item in unmatched[:10]:
        print(f"  - {item}")

print("\n" + "=" * 60)

