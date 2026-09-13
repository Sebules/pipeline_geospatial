-- "C:\Users\sebas\Documents\geospatial_projects\pipeline_geospatial\pipeline_geospatial\models\staging\stg_extracted_geo_data.sql"
{{config(materialized='view')}}

SELECT 
    (data.value ->> 'id')::text AS osm_id,
    (data.value ->> 'type')::text AS osm_type,
    (data.value ->> 'bounds')::text AS osm_bounds,
    (data.value ->> 'geometry')::text AS osm_geometry,
    ST_MakeLine(   
        ST_MakePoint(
            (geom.value ->> 'lon')::double precision, 
            (geom.value ->> 'lat')::double precision
        ) 
        ORDER BY geom.ordinality
    ) AS osm_line_geometry_point, -- ST_MakeLine creates a line geometry from the points extracted from the 'geometry' JSON object. Each point is created using ST_MakePoint with longitude and latitude values extracted from the 'geom' key-value pairs.
    (data.value ->> 'nodes')::text AS nodes,
    (data.value ->> 'tags')::jsonb AS tags,
    tags.key   AS tag_key,
    tags.value AS tag_value
FROM  {{source('pipeline_geospatial','extracted_geo_data')}} raw 
CROSS JOIN LATERAL jsonb_array_elements(raw.elements) AS data(value) -- jsonb_array_elements allows us to extract each element from the JSON array in the 'elements' column of the 'raw' table. Each element is treated as a separate row in the resulting view, enabling us to work with individual OpenStreetMap data entries.
CROSS JOIN LATERAL jsonb_array_elements(data.value -> 'geometry') WITH ORDINALITY AS geom(value,ordinality)
CROSS JOIN LATERAL jsonb_each_text(data.value -> 'tags') AS tags(key, value) -- jsonb_each allows us to extract key-value pairs from the 'tags' JSON object in the 'data.value' column. Each key-value pair is treated as a separate row in the resulting view, enabling us to work with individual tags associated with the OpenStreetMap data entries.
GROUP BY data.value, tags.key, tags.value
-- jsonb_array_elements allows us to extract elements from the 'geometry' JSON array in the 'raw' table. Each element is treated as a separate row in the resulting view, enabling us to work with individual geometry attributes of the OpenStreetMap data entries.
-- ordinality is used to maintain the order of the geometry points as they appear in the original JSON array, which is important for constructing the line geometry correctly.

-- if the script does not work, verify if postgis extension is installed in the database, as it is required for the ST_MakeLine and ST_MakePoint functions to work properly.
-- CREATE EXTENSION IF NOT EXISTS postgis; is the command to install the PostGIS extension in the database if it is not already installed. This extension provides spatial functions and types that are necessary for working with geospatial data in PostgreSQL.