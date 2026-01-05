OpenSCAD library for quickly making patterns of various shapes, intricacies, and layout!
![](https://github.com/Mockedarche/OpenSCAD-Patterns-Generator/blob/main/Media/output.gif?raw=true)

EXAMPLES - code used to generated above minus some translates and curshape being changed per photo


Poly area is all about giving a polygon and to have shapes places inside its area
```
base_points = [
    [0, 0],
    [120, 0],
    [120, 120],
    [5, 120],
    [5, 80],
    [90, 80],
    [90, 60],
    [5, 60],
    [0, 60]

];

curshape = TRIANGLE;
cur_facet_or_points = 100;
cur_turn = 0;

poly_area(base_points, shape_height=5, shape_diameter=9, spacing=1, shape=curshape, facet_count_points = cur_facet_or_points, turn = cur_turn);
```

Hex - places shapes in a staggered row and colum such that it emulates a hex pattern
```
hex_rectangle_area(
    length = 120,
    width = 120,
    height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points,
    shape = curshape,
    turn = cur_turn
);
```
Row Col - places shapes in a simple row column with no staggering
```
rectangle_area(
    length = 120,
    width = 120,
    height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn
);
```
Wave / sinusoidal pattern - given wavelength and amplitude it places shapes to indicate a wave
```
wave_area(
    length = 120,
    width = 120,
    height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn,
    amplitude = 50,
    wavelength = 200
);
```
Hex triangle area - places shapes in a hex pattern in the outline of a triangle
```
triangle_area(
    length = 120,
    height = 120,
    shape_height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn
);
```
Hex circular outline - places shapes roughly hex in a circular outline
```
circle_area(
    area_diameter = 120,
    height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn
);
```
Circular - places shapes in a circular pattern with 1 in the center then a circular placement of rings outward
```
circular_area(
    area_diameter = 120,
    height = 5,
    shape_diameter = 9,
    distance_between = 1,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn
);
```
Spiral pattern - places shapes in a spiral outward with increased spacing the further from the center
```
spiral_area(
    area_diameter = 120,
    height = 5,
    shape_diameter = 9,
    distance_aggressiveness = 1,
    angle_step = 10,
    facet_count_points = cur_facet_or_points ,
    shape = curshape,
    turn = cur_turn
);
```
