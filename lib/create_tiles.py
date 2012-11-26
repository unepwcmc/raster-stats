#!/usr/bin/env python

from math import pi, cos, sin, log, exp, atan
from subprocess import call
from Queue import Queue
from optparse import OptionParser
import sys, os
import threading
import mapnik

DEG_TO_RAD = pi/180
RAD_TO_DEG = 180/pi

# Default number of rendering threads to spawn, should be roughly equal to number of CPU cores available
NUM_THREADS = 4

# Default number of zoom levels to render
MIN_ZOOM_LEVEL = 0
MAX_ZOOM_LEVEL = 5

# Change the following for different bounding boxes and zoom levels (default: World)
BBOX = (-180.0,-90.0, 180.0,90.0)

def minmax (a,b,c):
    a = max(a,b)
    a = min(a,c)
    return a

class GoogleProjection:
    def __init__(self, levels = 18):
        self.Bc = []
        self.Cc = []
        self.zc = []
        self.Ac = []
        c = 256

        for d in range(0, levels):
            e = c/2;
            self.Bc.append(c/360.0)
            self.Cc.append(c/(2 * pi))
            self.zc.append((e,e))
            self.Ac.append(c)
            c *= 2

    def fromLLtoPixel(self, ll, zoom):
         d = self.zc[zoom]
         e = round(d[0] + ll[0] * self.Bc[zoom])
         f = minmax(sin(DEG_TO_RAD * ll[1]),-0.9999,0.9999)
         g = round(d[1] + 0.5*log((1+f)/(1-f))*-self.Cc[zoom])
         return (e,g)

    def fromPixelToLL(self, px, zoom):
         e = self.zc[zoom]
         f = (px[0] - e[0])/self.Bc[zoom]
         g = (px[1] - e[1])/-self.Cc[zoom]
         h = RAD_TO_DEG * ( 2 * atan(exp(g)) - 0.5 * pi)
         return (f,h)

class RenderThread:
    def __init__(self, tile_dir, mapfile, q, printLock, maxZoom):
        self.tile_dir = tile_dir
        self.q = q
        self.m = mapnik.Map(256, 256)
        self.printLock = printLock

        # Load style XML
        mapnik.load_map(self.m, mapfile, True)

        # Obtain <Map> projection
        self.prj = mapnik.Projection(self.m.srs)

        # Projects between tile pixel co-ordinates and LatLong (EPSG:4326)
        self.tileproj = GoogleProjection(maxZoom + 1)

    def render_tile(self, tile_uri, x, y, z):
        # Calculate pixel positions of bottom-left & top-right
        p0 = (x * 256, (y + 1) * 256)
        p1 = ((x + 1) * 256, y * 256)

        # Convert to LatLong (EPSG:4326)
        l0 = self.tileproj.fromPixelToLL(p0, z)
        l1 = self.tileproj.fromPixelToLL(p1, z)

        # Convert to map projection (e.g. mercator co-ords EPSG:900913)
        c0 = self.prj.forward(mapnik.Coord(l0[0],l0[1]))
        c1 = self.prj.forward(mapnik.Coord(l1[0],l1[1]))

        # Bounding box for the tile
        if hasattr(mapnik,'mapnik_version') and mapnik.mapnik_version() >= 800:
            bbox = mapnik.Box2d(c0.x,c0.y, c1.x,c1.y)
        else:
            bbox = mapnik.Envelope(c0.x,c0.y, c1.x,c1.y)

        render_size = 256
        self.m.resize(render_size, render_size)
        self.m.zoom_to_box(bbox)
        self.m.buffer_size = 128

        # Render image with default Agg renderer
        im = mapnik.Image(render_size, render_size)
        mapnik.render(self.m, im)
        im.save(tile_uri, 'png256')

    def loop(self):
        while True:
            # Fetch a tile from the queue and render it
            r = self.q.get()

            if (r == None):
                self.q.task_done()
                break
            else:
                (name, tile_uri, x, y, z) = r

            exists = ''

            if os.path.isfile(tile_uri):
                exists = "exists"
            else:
                self.render_tile(tile_uri, x, y, z)

            bytes = os.stat(tile_uri)[6]
            empty = ''

            if bytes == 103:
                empty = " Empty Tile "

            self.printLock.acquire()
            print name, ":", z, x, y, exists, empty
            self.printLock.release()
            self.q.task_done()

def render_tiles(mapfile, tile_dir, bbox = BBOX, minZoom = MIN_ZOOM_LEVEL, maxZoom = MAX_ZOOM_LEVEL, name = "World", num_threads = NUM_THREADS, tms_scheme = False):
    # Launch rendering threads
    queue = Queue(32)
    printLock = threading.Lock()
    renderers = {}

    for i in range(num_threads):
        renderer = RenderThread(tile_dir, mapfile, queue, printLock, maxZoom)
        render_thread = threading.Thread(target = renderer.loop)
        render_thread.start()
        renderers[i] = render_thread

    if not os.path.isdir(tile_dir):
         os.mkdir(tile_dir)

    gprj = GoogleProjection(maxZoom + 1) 

    ll0 = (bbox[0], bbox[3])
    ll1 = (bbox[2], bbox[1])

    for z in range(minZoom, maxZoom + 1):
        px0 = gprj.fromLLtoPixel(ll0, z)
        px1 = gprj.fromLLtoPixel(ll1, z)

        # Check if we have directories in place
        zoom = "%s" % z

        if not os.path.isdir(tile_dir + zoom):
            os.mkdir(tile_dir + zoom)

        for x in range(int(px0[0] / 256.0), int(px1[0] / 256.0) + 1):
            # Validate x coordinate
            if (x < 0) or (x >= 2**z):
                continue

            # Check if we have directories in place
            str_x = "%s" % x

            if not os.path.isdir(tile_dir + zoom + '/' + str_x):
                os.mkdir(tile_dir + zoom + '/' + str_x)

            for y in range(int(px0[1]/256.0),int(px1[1]/256.0)+1):
                # Validate y coordinate
                if (y < 0) or (y >= 2**z):
                    continue

                # Flip y to match OSGEO TMS spec
                if tms_scheme:
                    str_y = "%s" % ((2**z - 1) - y)
                else:
                    str_y = "%s" % y

                tile_uri = tile_dir + zoom + '/' + str_x + '/' + str_y + '.png'

                # Submit tile to be rendered into the queue
                t = (name, tile_uri, x, y, z)

                try:
                    queue.put(t)
                except KeyboardInterrupt:
                    raise SystemExit("Ctrl-c detected, exiting...")

    # Signal render threads to exit by sending empty request to queue
    for i in range(num_threads):
        queue.put(None)

    # wait for pending rendering jobs to complete
    queue.join()

    for i in range(num_threads):
        renderers[i].join()

def render_tile(mapfile, tile_dir, z, x, y, bbox = BBOX, name = "World", tms_scheme = False):
    # Convert z, x and y to integers
    z = int(z)
    x = int(x)
    y = int(y)

    renderer = RenderThread(tile_dir, mapfile, None, None, z)

    if not os.path.isdir(tile_dir):
         os.mkdir(tile_dir)

    # Check if we have directories in place
    zoom = "%s" % z

    if not os.path.isdir(tile_dir + zoom):
        os.mkdir(tile_dir + zoom)

    # Validate x coordinate
    if (x < 0) or (x >= 2**z):
        return

    # Check if we have directories in place
    str_x = "%s" % x

    if not os.path.isdir(tile_dir + zoom + '/' + str_x):
        os.mkdir(tile_dir + zoom + '/' + str_x)

    # Validate y coordinate
    if (y < 0) or (y >= 2**z):
        return

    # Flip y to match OSGEO TMS spec
    if tms_scheme:
        str_y = "%s" % ((2**z - 1) - y)
    else:
        str_y = "%s" % y

    tile_uri = tile_dir + zoom + '/' + str_x + '/' + str_y + '.png'

    # Render tile
    renderer.render_tile(tile_uri, x, y, z)

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option('--xml', action = 'store', dest = 'raster_path', help = 'defines rasters path')
    parser.add_option('--tiles', action = 'store', dest = 'tile_path', help = 'defines tiles path')
    parser.add_option('-z', action = 'store', dest = 'zoom', help = 'defines zoom level')
    parser.add_option('-x', action = 'store', dest = 'x_coord', help = 'defines X coordinate')
    parser.add_option('-y', action = 'store', dest = 'y_coord', help = 'defines Y coordinate')
    (opts, args) = parser.parse_args()

    mapfile = opts.raster_path

    tile_dir = opts.tile_path

    if not tile_dir.endswith('/'):
        tile_dir = tile_dir + '/'

    try:
      opts.zoom
      opts.x_coord
      opts.y_coord
    except:
      render_tiles(mapfile, tile_dir)
    else:
      render_tile(mapfile, tile_dir, opts.zoom, opts.x_coord, opts.y_coord)
