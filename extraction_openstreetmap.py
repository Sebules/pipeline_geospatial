# the objective of this script is to extract OpenStreetMap data using the Overpass API and a specific bounding box query. The script sends a POST request to the Overpass API with a defined query, retrieves the data in JSON format, and prints the result in a readable format.
import json
import os
import time
import requests

# Define the Overpass API endpoint URL for querying OpenStreetMap data.
url = "https://overpass-api.de/api/interpreter"

# Define the Overpass QL query to retrieve ways within a specific bounding box.
# [bbox:30.618338,-96.323712,30.591028,-96.330826] Bounding box coordinates: (south, west, north, east) correspond to the area of interest.
# Coordinates are in the format: (latitude, longitude)
# south is the minimum latitude, west is the minimum longitude, north is the maximum latitude, and east is the maximum longitude.
# out:json specifies that the output format should be JSON.
# timeout:90 sets the maximum time (in seconds) that the query is allowed to run before timing out.
# way(...) specifies the way elements to retrieve, with the coordinates defining the area of interest.
# way(30.626917110746, -96.348809105664, 30.634468750236, -96.339893442898) defines a specific way to retrieve based on its coordinates.
# out geom specifies that the output should include the geometry of the ways.
query = """
  
  [out:json]
  [timeout:90]
  ;
  way(48.90102, 2.32236, 48.95071, 2.39068);
  out geom;
"""
# Send a POST request to the Overpass API with the defined query and appropriate headers.
# data={"data": query} sends the query as form data in the request body.
# headers={"Accept": "application/json", "User-Agent": "geospatial-project/1.0"} sets the request headers to specify that the client expects a JSON response and identifies the user agent.
# timeout=120 sets the maximum time (in seconds) that the request is allowed to take before timing out.
response = requests.post(
    url,
    data={"data": query},
  headers={
    "Accept": "application/json",
    "User-Agent": "geospatial-project/1.0",
  },
    timeout=120,
)
# Check if the request was successful (status code 200). If not, raise an HTTPError exception.
response.raise_for_status()
# Parse the JSON response from the Overpass API and store it in the variable 'result'.
result = response.json()

# Print the retrieved OpenStreetMap data in a readable JSON format with an indentation of 2 spaces.
# indent=2 makes the output more human-readable by adding line breaks and indentation.
print(json.dumps(result, indent=2))
# temps = time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime())

# Save the retrieved data to a JSON file named "extracted_data_<timestamp>.json" in the current working directory.
with open(f"extracted_data_bbox_example.json", "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=2)
print(f"Data saved to extracted_data_bbox_example.json")
print(os.path.abspath(f"extracted_data_bbox_example.json"))
