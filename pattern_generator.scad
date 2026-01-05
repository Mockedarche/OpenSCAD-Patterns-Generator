/*
    Austin Lunbeck

    pattern_generator.scad - is a simple pattern generator library for openSCAD

    Goal is simply to create patterns typically just area with shapes inside dictated by the user
    Useful for drain holes, decoration, grips and likely 100 other usecases I can't even think of

*/


CIRCLE = 0;
SQUARE = 1;
TRIANGLE = 2;
HEXAGON = 3;
PENTAGON = 4;
OCTAGON = 5;
STAR = 6;
ELLIPSE = 7;
DIAMOND = 8;
HEPTAGON = 9;
RECTANGLE_CUTOUT = 10;


// CREDIT to
// https://gist.github.com/anoved/9622826#file-star-scad
module star(p, r1, r2, h) {
    // create the points outlining our star using how many points and some very tasteful math
    s = [for(i=[0:p*2])[
        (i % 2 == 0 ? r1 : r2)*cos(180*i/p),
        (i % 2 == 0 ? r1 : r2)*sin(180*i/p)
    ]];
    linear_extrude(h)
        polygon(s);
}

/*

Creates 3 rectangles of length d and height h that are d/6 wide

*/
module rectangle_cutout(h, d){
    translate([- (d / 2), (d / 6) - (d / 2), 0])
    rotate(-90)
        cube([d / 6, d, h]);

    translate([- (d / 2), (((d - (d / 6)) / 2) + d / 6) - (d / 2), 0])
    rotate(-90)
        cube([d / 6, d, h]);

    translate([- (d / 2), ((d - (d / 6)) + d / 6)  - (d / 2), 0])
    rotate(-90)
        cube([d / 6, d, h]);
}


// branch for the requested shape
module custom_shape(m_height, m_diameter, m_facet_count_points, m_shape, m_turn=0){

    // If else detailing what shape the user wants
    rotate(m_turn){
        if (m_shape == CIRCLE){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = m_facet_count_points
            );
        }
        else if (m_shape == SQUARE){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 4
            );
        }
        else if (m_shape == TRIANGLE){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 3
            );
        }
        else if (m_shape == HEXAGON){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 6
            );
        }
        else if (m_shape == PENTAGON){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 5
            );
        }
        else if (m_shape == OCTAGON){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 8
            );
        }
        else if (m_shape == STAR){
            outer = m_diameter / 2;
            inner = outer * 0.5;
            star(m_facet_count_points, outer, inner, m_height);
        }
        else if (m_shape == ELLIPSE){
            scale([1, 0.5, 1])  // x stays full, y is half, z is m_height
                cylinder(h = m_height, d = m_diameter, $fn = m_facet_count_points);
        }
        else if (m_shape == DIAMOND){
            scale([1, 0.5, 1])  // x stays full, y is half, z is m_height
                cylinder(h = m_height, d = m_diameter, $fn = 4);
        }
        else if (m_shape == HEPTAGON){
            cylinder(
                h = m_height,
                d = m_diameter,
                $fn = 7
            );
        }
        else if(m_shape == RECTANGLE_CUTOUT){
            rectangle_cutout(
                h = m_height,
                d = m_diameter

            );
        }
    }

}

/*

Wave / sinusoidal pattern - given wavelength and amplitude it places shapes to indicate a wave

 */
module wave_area(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn=0, amplitude=10, wavelength=40) {
    step_x = shape_diameter + distance_between;
    cols = floor(length / step_x) + 1;
    rows = floor(width / step_x) + 1;

    intersection() {
        for (row = [0 : rows-1]) {
            for (col = [0 : cols-1]) {
                x = col * step_x + shape_diameter/2;
                y = row * step_x + shape_diameter/2 + amplitude * sin(360 * x / wavelength);

                translate([x, y, 0])
                    rotate([0, 0, turn])
                        custom_shape(
                            m_height = height,
                            m_diameter = shape_diameter,
                            m_facet_count_points = facet_count_points,
                            m_shape = shape
                        );
            }
        }

        // clipping volume (does not appear in result)
        translate([0, 0, -1])
            cube([length, width, 12], center = false);

    }
}

/*

Wave / sinusoidal pattern - given wavelength and amplitude it places shapes to indicate a wave
takes the negative of this wave

 */
module wave_area_negative(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn=0, amplitude=10, wavelength=40) {
    step_x = shape_diameter + distance_between;
    cols = floor(length / step_x) + 1;
    rows = floor(width / step_x) + 1;

    difference(){
        cube([length, width, height]);

        intersection() {
            for (row = [0 : rows-1]) {
                for (col = [0 : cols-1]) {
                    x = col * step_x + shape_diameter/2;
                    y = row * step_x + shape_diameter/2 + amplitude * sin(360 * x / wavelength);

                    translate([x, y, 0])
                        rotate([0, 0, turn])
                            custom_shape(
                                m_height = height,
                                m_diameter = shape_diameter,
                                m_facet_count_points = facet_count_points,
                                m_shape = shape
                            );
                }
            }

            // clipping volume (does not appear in result)
            translate([0, 0, -1])
                cube([length, width, 12], center = false);

        }
    }
}

/*

Spiral pattern - places shapes in a spiral outward with increased spacing the further from the center

*/
module spiral_area(area_diameter, height, shape_diameter, distance_aggressiveness, angle_step, facet_count_points, shape, turn=0) {

    step   = shape_diameter + distance_aggressiveness;
    radius = area_diameter / 2;

    r_per_turn = step;            // radial growth per full rotation
    max_steps  = ceil((radius / r_per_turn) * 360 / angle_step);

    for (i = [0 : max_steps]) {

        a = i * angle_step;
        r = (a / 360) * r_per_turn;

        if (r <= radius - shape_diameter/2)
            translate([radius, radius, 0])
                rotate([0, 0, a])
                    translate([r, 0, 0])
                        custom_shape(
                            m_height=height,
                            m_diameter=shape_diameter,
                            m_facet_count_points=facet_count_points,
                            m_shape=shape,
                            m_turn=turn
                        );
    }
}

/*

Spiral pattern - places shapes in a spiral outward with increased spacing the further from the center
takes the negative of this spiral

*/
module spiral_area_negative(area_diameter, height, shape_diameter, distance_aggressiveness, angle_step, facet_count_points, shape, turn=0) {

    step   = shape_diameter + distance_aggressiveness;
    radius = area_diameter / 2;

    r_per_turn = step;            // radial growth per full rotation
    max_steps  = ceil((radius / r_per_turn) * 360 / angle_step);

    difference(){
        translate([area_diameter / 2, area_diameter / 2, 0])
            linear_extrude(height)
                circle(d = area_diameter);


        for (i = [0 : max_steps]) {

            a = i * angle_step;
            r = (a / 360) * r_per_turn;

            if (r <= radius - shape_diameter/2)
                translate([radius, radius, 0])
                    rotate([0, 0, a])
                        translate([r, 0, 0])
                            custom_shape(
                                m_height=height,
                                m_diameter=shape_diameter,
                                m_facet_count_points=facet_count_points,
                                m_shape=shape,
                                m_turn=turn
                            );
        }
    }
}

/*

Hex - places shapes in a staggered row and colum such that it emulates a hex pattern

*/
module hex_rectangle_area(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn = 0){

    step_x = shape_diameter + distance_between;
    step_y = step_x * 0.866; // sqrt(3)/2

    cols = floor(length / step_x) + 2;
    rows = floor(width  / step_y) + 2;

    intersection(){

        for (row = [-1 : rows - 2]) {
            x_offset = (row % 2 == 0) ? 0 : step_x / 2;

            for (col = [-1 : cols - 2]) {
                translate([
                    col * step_x + x_offset + shape_diameter/2,
                    row * step_y + shape_diameter/2,
                    0
                ])
                rotate([0, 0, turn])
                    custom_shape(
                        m_height = height,
                        m_diameter = shape_diameter,
                        m_facet_count_points = facet_count_points,
                        m_shape = shape
                    );
            }
        }
        // clipping volume (does not appear in result)
        translate([0, 0, -1])
            cube([length, width, 12], center = false);

    }
}

/*

Hex - places shapes in a staggered row and colum such that it emulates a hex pattern
takes the negative of this hex grid

*/
module hex_rectangle_area_negative(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn = 0){

    step_x = shape_diameter + distance_between;
    step_y = step_x * 0.866; // sqrt(3)/2

    cols = floor(length / step_x) + 2;
    rows = floor(width  / step_y) + 2;

    difference() {
        cube([length, width, height]);

        intersection(){

            for (row = [-1 : rows - 2]) {
                x_offset = (row % 2 == 0) ? 0 : step_x / 2;

                for (col = [-1 : cols - 2]) {
                    translate([
                        col * step_x + x_offset + shape_diameter/2,
                        row * step_y + shape_diameter/2,
                        0
                    ])
                    rotate([0, 0, turn])
                        custom_shape(
                            m_height = height,
                            m_diameter = shape_diameter,
                            m_facet_count_points = facet_count_points,
                            m_shape = shape
                        );
                }
            }
            // clipping volume (does not appear in result)
            translate([0, 0, -1])
                cube([length, width, 12], center = false);

        }
    }
}

/*

circular - places shapes in a circular pattern with 1 in the center then a circular placement of rings outward

*/
module circular_area(area_diameter, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    step   = shape_diameter + distance_between;
    radius = area_diameter / 2;

    // center
    translate([radius, radius, 0])
        custom_shape(m_height=height, m_diameter=shape_diameter,
                     m_facet_count_points=facet_count_points,
                     m_shape=shape, m_turn=turn);

    // rings
    for (r = [step : step : radius - shape_diameter/2]) {
        count = max(1, floor((2 * PI * r) / step));
        angle = 360 / count;

        for (i = [0 : count - 1])
            translate([radius, radius, 0])
                rotate([0, 0, i * angle])
                    translate([r, 0, 0])
                        custom_shape(
                            m_height = height,
                            m_diameter = shape_diameter,
                            m_facet_count_points = facet_count_points,
                            m_shape = shape,
                            m_turn = turn);
    }
}

/*

circular - places shapes in a circular pattern with 1 in the center then a circular placement of rings outward
takes the negative of the circular pattern

*/
module circular_area_negative(area_diameter, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    step   = shape_diameter + distance_between;
    radius = area_diameter / 2;

    difference(){
        translate([area_diameter / 2, area_diameter / 2, 0])
            linear_extrude(height)
                circle(d = area_diameter);


        // center
        translate([radius, radius, 0])
            custom_shape(m_height=height, m_diameter=shape_diameter,
                        m_facet_count_points=facet_count_points,
                        m_shape=shape, m_turn=turn);

        // rings
        for (r = [step : step : radius - shape_diameter/2]) {
            count = max(1, floor((2 * PI * r) / step));
            angle = 360 / count;

            for (i = [0 : count - 1])
                translate([radius, radius, 0])
                    rotate([0, 0, i * angle])
                        translate([r, 0, 0])
                            custom_shape(
                                m_height = height,
                                m_diameter = shape_diameter,
                                m_facet_count_points = facet_count_points,
                                m_shape = shape,
                                m_turn = turn);
        }
    }
}


/*

row _ col - places shapes in a simple row column with no staggering

*/
module rectangle_area(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    per_row  = floor(length / (shape_diameter + distance_between));
    num_rows = floor(width  / (shape_diameter + distance_between));

    for (row = [0 : num_rows - 1]) {
        for (col = [0 : per_row - 1]) {
            translate([
                col * (shape_diameter + distance_between) + shape_diameter/2,
                row * (shape_diameter + distance_between) + shape_diameter/2,
                0
            ])
                custom_shape(
                    m_height = height,
                    m_diameter = shape_diameter,
                    m_facet_count_points = facet_count_points,
                    m_shape = shape,
                    m_turn = turn

                );
        }
    }
}


/*

row _ col - places shapes in a simple row column with no staggering
takes the negative of the row and columns of shapes

*/
module rectangle_area_negative(length, width, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    difference(){
        cube([length, width, height]);

        per_row  = floor(length / (shape_diameter + distance_between));
        num_rows = floor(width  / (shape_diameter + distance_between));

        for (row = [0 : num_rows - 1]) {
            for (col = [0 : per_row - 1]) {
                translate([
                    col * (shape_diameter + distance_between) + shape_diameter/2,
                    row * (shape_diameter + distance_between) + shape_diameter/2,
                    0
                ])
                    custom_shape(
                        m_height = height,
                        m_diameter = shape_diameter,
                        m_facet_count_points = facet_count_points,
                        m_shape = shape,
                        m_turn = turn

                    );
            }
        }
    }
}

/*

hex _triangle area - places shapes in a hex pattern in the outline of a triangle

*/
module triangle_area(length, height, shape_height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    step_x = shape_diameter + distance_between;
    step_y = (shape_diameter + distance_between); // sqrt(3)/2

    max_cols = floor(length / step_x);
    num_rows = floor(height / step_y);

    for (row = [0 : num_rows - 1]) {

        cols_this_row = max_cols - row;
        x_offset = (row * step_x) / 2;

        for (col = [0 : cols_this_row - 1]) {
            translate([
                col * step_x + x_offset + shape_diameter/2,
                row * step_y + shape_diameter/2,
                0
            ])
                custom_shape(
                    m_height = shape_height,
                    m_diameter = shape_diameter,
                    m_facet_count_points = facet_count_points,
                    m_shape = shape,
                    m_turn = turn

                );
        }
    }
}

/*

hex _triangle area - places shapes in a hex pattern in the outline of a triangle
takes the negative of the hex pattern in the outline of a triangle

*/
module triangle_area_negative(length, height, shape_height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {

    step_x = shape_diameter + distance_between;
    step_y = (shape_diameter + distance_between); // sqrt(3)/2

    max_cols = floor(length / step_x);
    num_rows = floor(height / step_y);

    difference(){

    linear_extrude(shape_height)
        polygon([
            [0,0],
            [length / 2, height],
            [length, 0]
            ]);

    for (row = [0 : num_rows - 1]) {

        cols_this_row = max_cols - row;
        x_offset = (row * step_x) / 2;

        for (col = [0 : cols_this_row - 1]) {
            translate([
                col * step_x + x_offset + shape_diameter/2,
                row * step_y + shape_diameter/2,
                0
            ])
                custom_shape(
                    m_height = shape_height,
                    m_diameter = shape_diameter,
                    m_facet_count_points = facet_count_points,
                    m_shape = shape,
                    m_turn = turn

                );
        }
    }
    }
}


/*

hex circular outline - places shapes roughly hex in a circular outline

*/
module circle_area(area_diameter, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {
    step_x = shape_diameter + distance_between;
    step_y = step_x; // hex packing vertical spacing
    radius = area_diameter / 2;

    // estimate number of rows above and below center
    max_rows = floor(area_diameter / step_y);

    for (row = [-max_rows : max_rows]) {
        y = row * step_y;

        // horizontal width for this row
        row_width = 2 * sqrt(max(0, radius*radius - y*y));
        cols_this_row = floor(row_width / step_x);

        // center the row
        x_offset = -((cols_this_row - 1) * step_x) / 2;

        for (col = [0 : cols_this_row - 1]) {
            x = col * step_x + x_offset;

            // only place cylinder if inside circle
            if (sqrt(x*x + y*y) <= radius - shape_diameter/2)
                translate([x + radius, y + radius, 0])
                    custom_shape(
                        m_height = height,
                        m_diameter = shape_diameter,
                        m_facet_count_points = facet_count_points,
                        m_shape = shape,
                        m_turn = turn

                    );
        }
    }
}

/*

hex circular outline - places shapes roughly hex in a circular outline
takes the negative of the circular outline
*/
module circle_area_negative(area_diameter, height, shape_diameter, distance_between, facet_count_points, shape, turn=0) {
    step_x = shape_diameter + distance_between;
    step_y = step_x; // hex packing vertical spacing
    radius = area_diameter / 2;

    // estimate number of rows above and below center
    max_rows = floor(area_diameter / step_y);

    difference(){

        translate([area_diameter / 2, area_diameter / 2, 0])
        linear_extrude(height)
            circle(d = area_diameter);



        for (row = [-max_rows : max_rows]) {
            y = row * step_y;

            // horizontal width for this row
            row_width = 2 * sqrt(max(0, radius*radius - y*y));
            cols_this_row = floor(row_width / step_x);

            // center the row
            x_offset = -((cols_this_row - 1) * step_x) / 2;

            for (col = [0 : cols_this_row - 1]) {
                x = col * step_x + x_offset;

                // only place cylinder if inside circle
                if (sqrt(x*x + y*y) <= radius - shape_diameter/2)
                    translate([x + radius, y + radius, 0])
                        custom_shape(
                            m_height = height,
                            m_diameter = shape_diameter,
                            m_facet_count_points = facet_count_points,
                            m_shape = shape,
                            m_turn = turn

                        );
            }
        }
    }
}


/*

row col in poly defined area - places shapes in a row and column but
to the limitation of the bound specified by the given polygon

*/
module poly_area(poly, shape_height, shape_diameter, spacing, facet_count_points, shape, turn=0) {

    min_x = min([ for (p = poly) p[0]]);
    max_x = max([ for (p = poly) p[0]]);
    min_y = min([ for (p = poly) p[1]]);
    max_y = max([ for (p = poly) p[1]]);

    length = max_x - min_x;
    width  = max_y - min_y;

    step = shape_diameter + spacing;

    per_row  = floor(length / step);
    num_rows = floor(width  / step);

    for (row = [0 : num_rows - 1]) {
        for (col = [0 : per_row - 1]) {

            x = min_x + col * step + shape_diameter / 2;
            y = min_y + row * step + shape_diameter / 2;

            if (shape_fits_in_poly([x, y], poly, shape_diameter)) {
                translate([x, y, 0])
                    custom_shape(
                        m_height = shape_height,
                        m_diameter = shape_diameter,
                        m_shape = shape,
                        m_facet_count_points = facet_count_points,
                        m_turn = turn
                    );
            }
        }
    }
}



// ---------------- start poly area helpers ----------------

// external function for actual usage
// utilizes internal helpers to determine if the shape fits in the polygon
// Refernece: https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
// Refernece: https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
function shape_fits_in_poly(pt, poly, diameter) =
    // we short circuit on point in poly WHICH means we can know if distance from edges is valid
    let(radius = diameter / 2)
    point_in_poly(pt, poly) &&
    circle_clear_of_edges(pt, poly, radius);


// ---------------- internal helpers ----------------

// checks that the circle is clear of all polygon edges
function circle_clear_of_edges(pt, poly, r, i=0) =
    i >= len(poly) ? true :
    let (
        j = (i + 1) % len(poly),
        d = dist_point_seg(pt, poly[i], poly[j])
    )
    (d >= r) && circle_clear_of_edges(pt, poly, r, i + 1);

// computes distance from point to polygon edge
function dist_point_seg(p, a, b) =
    let (
        abx = b[0] - a[0],
        aby = b[1] - a[1],
        apx = p[0] - a[0],
        apy = p[1] - a[1],
        ab2 = abx*abx + aby*aby,
        t = ab2 == 0 ? 0 :
            max(0, min(1, (apx*abx + apy*aby) / ab2)),
        cx = a[0] + t*abx,
        cy = a[1] + t*aby
    )
    sqrt((p[0]-cx)*(p[0]-cx) + (p[1]-cy)*(p[1]-cy));


// ---------------- point in polygon ----------------
// Refernece: https://www.geeksforgeeks.org/cpp/point-in-polygon-in-cpp/
// Refernece: https://medium.com/@girishajmera/exploring-algorithms-to-determine-points-inside-or-outside-a-polygon-038952946f87
function point_in_poly(pt, poly, i=0, inside=false) =
    i >= len(poly) ? inside :
    let (
        j = (i + 1) % len(poly),
        xi = poly[i][0], yi = poly[i][1],
        xj = poly[j][0], yj = poly[j][1],
        intersect =
            ((yi > pt[1]) != (yj > pt[1])) &&
            (pt[0] < (xj - xi) * (pt[1] - yi) / (yj - yi) + xi)
    )
    point_in_poly(pt, poly, i + 1, intersect ? !inside : inside);

// ---------------- end poly area helpers ----------------



// ---------------- TEST CASES ---------------------------
/*

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



render() {

    translate([0, 250, 0])
        poly_area(base_points, shape_height=5, shape_diameter=9, spacing=1, shape=curshape, facet_count_points = cur_facet_or_points, turn = cur_turn);


    translate([0, 125, 0])
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

    translate([0, -125, 0])
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

    translate([120, 0, 0])
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

    translate([240, 0, 0])
    circle_area(
        area_diameter = 120,
        height = 5,
        shape_diameter = 9,
        distance_between = 1,
        facet_count_points = cur_facet_or_points ,
        shape = curshape,
        turn = cur_turn
    );
    translate([240, -120, 0])
    circular_area(
        area_diameter = 120,
        height = 5,
        shape_diameter = 9,
        distance_between = 1,
        facet_count_points = cur_facet_or_points ,
        shape = curshape,
        turn = cur_turn
    );
    translate([240, 120, 0])
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
}
*/
