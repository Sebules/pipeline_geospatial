-- "C:\Users\sebas\Documents\geospatial_projects\pipeline_geospatial\pipeline_geospatial\models\staging\stg_extracted_geo_data.sql"
{{config(materialized='view')}}

SELECT 
    (data.value ->> 'id')::text AS osm_id,
    (data.value ->> 'type')::text AS osm_type,
    (data.value ->> 'bounds')::text AS osm_bounds,
    (data.value ->> 'geometry')::text AS osm_geometry,
    (data.value ->> 'nodes')::text AS nodes,
    (data.value ->> 'tags')::jsonb AS tags
FROM  {{source('pipeline_geospatial','extracted_geo_data')}} raw 
CROSS JOIN LATERAL jsonb_array_elements(raw.elements) AS data(value) -- jsonb_array_elements allows us to extract each element from the JSON array in the 'elements' column of the 'raw' table. Each element is treated as a separate row in the resulting view, enabling us to work with individual OpenStreetMap data entries.