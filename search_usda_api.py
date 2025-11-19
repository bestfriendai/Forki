#!/usr/bin/env python3
"""
Search USDA FoodData Central API for specific foods
"""

import json
import requests
from pathlib import Path

# USDA API Configuration
API_KEY = "ZLUEyFZrfZbofCQOf7izACsPci1diQoK6amoMaeZ"
BASE_URL = "https://api.nal.usda.gov/fdc/v1"

def search_usda_api(query, data_type=None):
    """Search USDA FoodData Central API"""
    url = f"{BASE_URL}/foods/search"
    params = {
        "api_key": API_KEY,
        "query": query,
        "pageSize": 50,
        "pageNumber": 1
    }
    
    if data_type:
        params["dataType"] = data_type
    
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error searching for '{query}': {e}")
        return None

def get_food_details(fdc_id):
    """Get detailed food information by fdcId"""
    url = f"{BASE_URL}/food/{fdc_id}"
    params = {
        "api_key": API_KEY
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error getting details for fdcId {fdc_id}: {e}")
        return None

def extract_macros(food_data):
    """Extract macronutrients from food data"""
    nutrients = {
        'calories': None,
        'protein': None,
        'carbs': None,
        'fat': None
    }
    
    food_nutrients = food_data.get('foodNutrients', [])
    
    for nutrient in food_nutrients:
        nutrient_id = nutrient.get('nutrient', {}).get('id')
        amount = nutrient.get('amount')
        
        # USDA API uses different nutrient IDs than SR Legacy
        # Energy (kcal) = 1008, Protein = 1003, Carbs = 1005, Fat = 1004
        if nutrient_id == 1008:  # Energy (kcal)
            nutrients['calories'] = amount
        elif nutrient_id == 1003:  # Protein
            nutrients['protein'] = amount
        elif nutrient_id == 1005:  # Carbohydrate, by difference
            nutrients['carbs'] = amount
        elif nutrient_id == 1004:  # Total lipid (fat)
            nutrients['fat'] = amount
    
    return nutrients

def find_best_match(query, search_results):
    """Find the best match from search results"""
    if not search_results or 'foods' not in search_results:
        return None
    
    foods = search_results['foods']
    if not foods:
        return None
    
    # Look for exact or close matches
    query_lower = query.lower()
    best_match = None
    best_score = 0
    
    for food in foods:
        description = food.get('description', '').lower()
        data_type = food.get('dataType', '')
        
        # Prefer Foundation or SR Legacy over Branded
        score = 0
        if 'foundation' in data_type.lower():
            score += 100
        elif 'sr legacy' in data_type.lower():
            score += 50
        
        # Check if query terms are in description
        query_terms = query_lower.split()
        matches = sum(1 for term in query_terms if term in description)
        score += matches * 10
        
        # Prefer shorter, more specific descriptions
        if len(description.split()) <= 5:
            score += 20
        
        if score > best_score:
            best_score = score
            best_match = food
    
    return best_match

# Items to search for
items_to_find = [
    ("almond milk", "basic almond milk, no additives"),
    ("pomegranate seeds", "raw pomegranate seeds or arils"),
    ("chicken white meat", "chicken white meat, not nuggets"),
    ("chicken thigh", "chicken thigh"),
    ("dark meat chicken", "dark meat chicken")
]

print("=" * 60)
print("USDA FoodData Central API Search")
print("=" * 60)

results = []

for query, description in items_to_find:
    print(f"\nSearching for: {query}")
    print(f"Looking for: {description}")
    
    # Try Foundation first (most accurate)
    search_result = search_usda_api(query, data_type="Foundation")
    
    if not search_result or not search_result.get('foods'):
        # Try SR Legacy
        search_result = search_usda_api(query, data_type="SR Legacy")
    
    if not search_result or not search_result.get('foods'):
        # Try without data type restriction
        search_result = search_usda_api(query)
    
    if search_result and search_result.get('foods'):
        best_match = find_best_match(query, search_result)
        
        if best_match:
            fdc_id = best_match.get('fdcId')
            food_name = best_match.get('description', 'N/A')
            data_type = best_match.get('dataType', 'N/A')
            
            print(f"  ✓ Found: {food_name}")
            print(f"    fdcId: {fdc_id}, DataType: {data_type}")
            
            # Get detailed food information
            food_details = get_food_details(fdc_id)
            if food_details:
                nutrients = extract_macros(food_details)
                print(f"    Nutrients: Calories={nutrients['calories']}, Protein={nutrients['protein']}, Carbs={nutrients['carbs']}, Fat={nutrients['fat']}")
                
                # Get category
                category = "Uncategorized"
                if 'foodCategory' in food_details:
                    category = food_details['foodCategory'].get('description', 'Uncategorized')
                elif 'wweiaFoodCategory' in food_details:
                    wweia_cat = food_details['wweiaFoodCategory']
                    if isinstance(wweia_cat, dict):
                        category = wweia_cat.get('wweiaFoodCategoryDescription', 'Uncategorized')
                
                results.append({
                    "name": food_name,
                    "searchKey": query,
                    "fdcId": fdc_id,
                    "category": category,
                    "calories": nutrients['calories'] or 0,
                    "protein": nutrients['protein'] or 0,
                    "carbs": nutrients['carbs'] or 0,
                    "fat": nutrients['fat'] or 0,
                    "dataType": data_type
                })
        else:
            print(f"  ✗ No good match found")
    else:
        print(f"  ✗ No results found")

# Save results
if results:
    output_path = Path(__file__).parent / "usda_api_search_results.json"
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n" + "=" * 60)
    print(f"Found {len(results)} items")
    print(f"Results saved to: {output_path}")
    print("=" * 60)
else:
    print("\n" + "=" * 60)
    print("No items found")
    print("=" * 60)

