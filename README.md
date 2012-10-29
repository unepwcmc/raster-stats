raster-stats
============

Sinatra app to calculate intersection between polygons and rasters.


Start it
============

<pre><code>bundle install
shotgun config.ru</code></pre>
The application will be running in port 9393:
<code>http://localhost:9393/stats/{polygon in GeoJSON}</code>


Set up
============

Install starspan (http://starspan.projects.atlas.ca.gov/)

Place your raster layers inside the <em>rasters</em> folder. The rasters should be split into three folders, based on their resolution: <em>high_resolution</em>, <em>medium_resolution</em>, and <em>low_resolution</em>.


Example
===========

After starting the server, point your browser to:

http://localhost:9393/stats/{"type": "FeatureCollection","features": [{ "type": "Feature", "id": 0, "properties": { "id": null, "name": 8, "AREA": 53262326429368.75, "PERIMETER": 25227163.252041 }, "geometry": { "type": "Polygon", "coordinates": [ [ [ -55.199133830905097, 14.166474645080788 ], [ -139.868730478081005, 21.093987098031544 ], [ -166.295907613411686, 80.619279286349169 ], [ -19.022124354384474, 82.671875568704948 ], [ -55.199133830905097, 14.166474645080788 ] ] ] } }]}

This example uses a massive polygon, so the application will use the low resolution raster.


License
===========

Copyright (c) 2012, WCMC
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the <organization> nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

References
===============

Rueda, C.A., Greenberg, J.A., and Ustin, S.L. StarSpan: A Tool for Fast Selective Pixel Extraction from Remotely Sensed Data. (2005). Center for Spatial Technologies and Remote Sensing (CSTARS), University of California at Davis, Davis, CA.