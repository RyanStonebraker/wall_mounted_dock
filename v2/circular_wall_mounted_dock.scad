/* Phone Dimensions */
phone_width = 80;
phone_height = 155;
phone_thickness = 20;

/* Charging Cord Dimensions */
coord_width = 6;
usb_connector_width = 14;
usb_connector_height = 12;
usb_connector_thickness = 7;

/* Command Hook Dimensions */
hook_width = 22;
hook_height = 72;
hook_min_thickness = 10;
hook_max_thickness = 30;
hook_overhang = hook_height/2 + hook_width/2;

/* Fine Tuning */
wall_padding = 5;
coord_inlay_percent = 3/4;
hook_edge_rounding = 2;
phone_edge_rounding = 5;
phone_visible_percentage = 7/8;
top_cutout = true;

/* Model Colors */
hull_color = [0.2, 0.7, 1];
front_bevel_color = [0.2, 0.7, 1];

/* Internal Variables */
hull_radius = phone_height/2 + usb_connector_height + wall_padding;

module outer_hull() {
  color(hull_color)
  hull () {
    translate([0, 0, phone_thickness + wall_padding])
      linear_extrude(height=wall_padding)
        circle(r=hull_radius - wall_padding * 2);
    linear_extrude(height=phone_thickness + wall_padding)
      circle(r=hull_radius);
  }
}

module coord(height=wall_padding) {
  cube([coord_width, coord_width, height], center=true);
}

module inverted_charging_port () {
  union() {
    hull () {
    translate([0, phone_thickness/2, 2 * wall_padding + usb_connector_height/2])
      cube([usb_connector_width, usb_connector_thickness, usb_connector_height + 0.01], center=true);

    /* Transition section between coord and coord connector */
    translate([0, phone_thickness/2, 2 * wall_padding * (1 - coord_inlay_percent)/2 + wall_padding * coord_inlay_percent])
      coord(wall_padding * (1 - coord_inlay_percent));
    }

    /* Slot to insert coord into dock */
    hull () {
      translate([0, 0, wall_padding * coord_inlay_percent/2])
        coord(wall_padding * coord_inlay_percent);
      translate([0, (phone_thickness)/2 + wall_padding, phone_thickness/2 + 2 * wall_padding])
        cube([usb_connector_thickness, phone_thickness + wall_padding, usb_connector_height], center=true);
      translate([0, (phone_thickness)/2 + wall_padding, wall_padding / 2])
        cube([coord_width, phone_thickness + wall_padding, wall_padding], center=true);
    }
  }
}

module phone (height=phone_height, thickness=phone_thickness) {
  linear_extrude(height=thickness)
  offset(r=phone_edge_rounding) offset(r=-phone_edge_rounding)
    square([phone_width, height], center=true);
}

module pill_shape (width=hook_width) {
  overhang_connector = hook_max_thickness - hook_min_thickness;
  for (mirrorx=[-1:2:+1]) scale([1, mirrorx, 1])
    translate([0, -hook_height/2 + width/2, hook_min_thickness + overhang_connector])
      sphere(d=width);

  translate([0, -hook_height/2 + hook_overhang/2 + width/2, hook_max_thickness])
    rotate([0, 90, 90])
      cylinder(d=width, h=hook_overhang, center=true);
}

module command_hook (width=hook_width) {
  linear_extrude(height=hook_min_thickness)
    offset(r=hook_edge_rounding) offset(r=-hook_edge_rounding)
      square([width, hook_height], center=true);

  overhang_connector = hook_max_thickness - hook_min_thickness;
  translate([0, -hook_height/2 + width/2, hook_min_thickness + overhang_connector/2])
  cylinder(d=width, h=overhang_connector + 0.01, center=true);

  color(front_bevel_color)
    pill_shape(width);
}

module command_hooks(width=hook_width) {
  for (mirrorx=[-1:2:+1]) scale([mirrorx, 1, 1])
    translate([(hull_radius + hook_width)/2, 0, -0.01])
      rotate([0, 0, 180])
      command_hook(width);
}


difference() {
  union() {
    outer_hull();
    command_hooks(hook_width + wall_padding);
  }

  translate([0, 0, wall_padding]) {
    phone();

    top_extend = top_cutout ? wall_padding + phone_height : 0;
    translate([0, -(phone_height * (1-phone_visible_percentage) + top_extend)/2, 0])
      phone(height=phone_height * phone_visible_percentage + top_extend, thickness=phone_thickness+wall_padding+0.01);
  }
  translate([0, hull_radius, wall_padding])
  rotate([90, 0, 0])
    inverted_charging_port();

  command_hooks();
}
