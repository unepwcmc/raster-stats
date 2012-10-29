raster-stats
============

Sinatra app to calculate intersection between polygons and rasters.


Start it
============

<pre><code>shotgun config.ru</code></pre>
The application will be running in port 9393:
<code>http://localhost:9393/stats/{polygon in GeoJSON}</code>


Set up
============

Place your raster layers inside the <em>rasters</em> folder. The rasters should be split into three folders, based on their resolution: <em>high_resolution</em>, <em>medium_resolution</em>, and <em>low_resolution</em>.


Example
===========

After starting the server up, point your browser to:

http://localhost:9393/stats/{"type": "FeatureCollection","features": [{ "type": "Feature", "id": 0, "properties": { "id": null, "name": 8, "AREA": 53262326429368.75, "PERIMETER": 25227163.252041 }, "geometry": { "type": "Polygon", "coordinates": [ [ [ -55.199133830905097, 14.166474645080788 ], [ -139.868730478081005, 21.093987098031544 ], [ -166.295907613411686, 80.619279286349169 ], [ -19.022124354384474, 82.671875568704948 ], [ -55.199133830905097, 14.166474645080788 ] ] ] } }]}