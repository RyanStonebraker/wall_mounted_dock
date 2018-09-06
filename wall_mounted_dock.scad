// All measurements in mm
width = 60;
height = 50;
thickness = 10;
padding = 2.5;
front_bevel_thickness = 1;

coord_width = 2;
coord_connector_width = 5;
coord_connector_height = 6;
coord_connector_thickness = 3;

letter_indent_amount = 3/4 * front_bevel_thickness;
left_letter = "R";
right_letter = "S";

module basic_mount_outline () {
    difference() {
        difference() {
            difference() {
                linear_extrude(height=thickness + 2 * padding)
                    square([width + 2 * padding, height + 2 * padding]);


                translate([padding, 1/4 * height + padding, padding])
                linear_extrude(height=thickness)
                    square([width, height+padding + 3]);
            }

            translate([padding, height * 3/4 + 2 * padding, padding])
            linear_extrude(height=thickness + padding + 0.001)
                square([width, height/4 + 2]);
        }

        translate([padding + width/4, 2 * padding + height * 1/5, padding])
        linear_extrude(height=thickness + padding + 2)
            square([width/2, height * 4/5]);
    }
}

module front_bevel (bevel_thickness=1) {
    if (bevel_thickness > 0)
        linear_extrude(height=bevel_thickness)
            square([width * 1/4 - padding, height * 4/5 - padding]);
    else
        translate([0, 0, bevel_thickness])
        linear_extrude(height=bevel_thickness*-1 + 0.001)
            square([width * 1/4 - padding, height * 4/5 - padding]);
}

module front_bevels (bevel_thickness=1) {
    translate([padding, padding, thickness + 2 * padding])
        front_bevel(1);
    translate([width * 3/4 + 2 * padding, padding, thickness + 2 * padding])
        front_bevel(1);
    
    translate([width * 1/5, padding, thickness + 2 * padding])
        linear_extrude(height=bevel_thickness) 
            square([height * 4/5, width * 1/4 - 2 * padding]);
}

module back_cutaway(offset=0) {
    half_dock = width/2 - 2 * padding - coord_connector_width/2;
    translate([offset + half_dock/2 + 2 * padding, 0, -0.001])
    linear_extrude(height=thickness)
        circle(d=half_dock);
}

module dock_outer_hull () {
    difference() {
        color("orange")
            basic_mount_outline();
        color("orange")
            back_cutaway();
        color("orange")
            back_cutaway(offset=width/2 + padding);
    }
    color("darkorange")
        front_bevels(front_bevel_thickness);
}

module charging_port () {
    coord_frame_center = padding + thickness/2 -coord_connector_thickness/2;
    translate([width/2 + padding - coord_width/2, -0.001, coord_frame_center])
    linear_extrude(0, 0, thickness + 2 * padding + front_bevel_thickness + 0.001)
        square([coord_width, 1/4 * height + padding + 0.002]);
    
    translate([width/2 + padding - coord_connector_width/2, 1/4 * height - coord_connector_height - 0.001, coord_frame_center])
    linear_extrude(0, 0, coord_connector_thickness)
        square([coord_connector_width, 1/4 * height + 0.002]);
}

module make_letter(letter) {
    color("red")
        linear_extrude(height=letter_indent_amount)
            text(letter, size = width/4 - 2 * padding, font = "Liberation Sans", valign = "center", $fn = 16);
}

letter_start_height = thickness + 2 * padding + front_bevel_thickness - letter_indent_amount + 0.001;
difference() {
    difference() {
        dock_outer_hull();
        color("orange")
            charging_port();
    }
    translate([3/2 * padding, height/2, letter_start_height])
        make_letter(left_letter);
    translate([5/2 * padding + 3/4 * width, height/2, letter_start_height])
        make_letter(right_letter);
}