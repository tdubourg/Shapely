"""
Occlusion library using Px language to speed up things and using the Shapely library
"""
from time import time
from geometry import Polygon
import ops

__all__= ['occlusion']

# def occlusion(int mpos_x, int mpos_y, obs):
#     return _occlusion(mpos_x, mpos_y, obs)
DEF coeff = 20
DEF SUBARRAY_SIZE = 8
def occlusion(int mpos_x, int mpos_y, sight_polygon_coordinates, obs, int sz):
    # cdef int coeff = 20
    cdef int m[2] 
    m[0] = mpos_x
    m[1] = mpos_y
    sight = Polygon(sight_polygon_coordinates)
    _l = sz
    polygons = []

    cdef int maxi = _l
    cdef int maxi2
    cdef int i = 0, i2 = 0
    cdef int x1, x2, y1, y2
    cdef float v_0, v_1, v2_0, v2_1
    # print "----------------------------------"
    while i < maxi: # go through the entire array
        # But deal with things on a SUBARRAY_SIZE-length subarray basis (=4 points consisting of an x and an y coordinates)
        j = i
        maxi2=(i+SUBARRAY_SIZE)
        while j<maxi2: # For each point inside the subarray
            # print (j, maxi2)
            x1 = obs[j]
            y1 = obs[j+1]
            i2 = (j+2)
            if (j+2) >= maxi2: # for the last point, loop back to the beginning of the obstacle's subarray points
                # print "Pouet"
                i2 = j-6
            x2 = obs[i2]
            y2 = obs[(i2+1)]
            # print (x1, y1), (x2, y2)
            v_0 = (x1 - m[0])*coeff
            v_1 = (y1 - m[1])*coeff
            v2_0 = (x2 - m[0])*coeff
            v2_1 = (y2 - m[1])*coeff
            points2 = [
                    [ x1, y1 ], # pt1
                    [ x1 + v_0, y1 + v_1 ], # pt1 + v
                    [ x2 + v2_0, y2 + v2_1 ], # pt2 + v2
                    [ x2, y2 ] # pt2
                    ]
            t = Polygon(points2)
            if t.is_valid:
                polygons.append(t)
            j += 2
        i += 8
    # /while
    union = None
    try:
        union = ops.cascaded_union(polygons)
    except ValueError as e:
        print "ValueError Exception when cascaded_union():", e
        # for p in polygons:
        #     print "------ polygon ------"
        #     for q in p.exterior.coords:
        #         print q
        #     print "------ polygon ------"
    try:
        sight = sight.difference(union)
    except ValueError as e:
        print "ValueError Exception when difference():", e
        sight = Polygon([[0,0], [1,1], [2,2]])
    try:
        blorg_points = [0.0] * (4*len(sight.exterior.coords))
        i=0
        for (x, y) in sight.exterior.coords:
            blorg_points[i] = x
            blorg_points[i+1] = y
            blorg_points[i+2] = 0.0
            blorg_points[i+3] = 0.0
            i += 4
        return blorg_points
    except AttributeError:  # it certainly is a multipolygon
        blorg_points = []
        for p in sight:
            for (x, y) in p.exterior.coords:
                blorg_points.append(x)
                blorg_points.append(y)
                blorg_points.append(0.0)
                blorg_points.append(0.0)
        return blorg_points
