// ============================================================
// 4" DWV PVC to 5" Lid Adapter — parametric remix of the original
//
// Preserves the cone / ridge / shoulder geometry from the STL you
// supplied (wedges into a 5" drilled hole naturally).
//
// CHANGE vs. previous version: the bottom face of the ridge is
// now a FLAT annular shoulder (not a tapered cone surface), so
// it seats flush on top of the lid for clean caulking.
//
// Designed for Bambu ABS with stock filament profile.
// Print narrow-end-down on the build plate.
// The flat caulking face is a ~2.2mm horizontal overhang — FDM
// handles this fine with maybe a small cosmetic sag that caulk
// will hide. If you want it perfect, flip orientation and print
// narrow-end-up with a brim on the cone tip.
// ============================================================

// ---------- PVC FIT (Tune to your usecase. I measured with a Reekon T1 Tomahawk) ----------

pvc_od              = 112.78;   // 4.440"  — your measured PVC OD
pvc_clearance       =   0.25;   // +0.010" snug friction fit
                                // bump to 0.35 for looser,
                                // drop to 0.15 for tighter

// ---------- EXTERNAL CONE/RIDGE/SHOULDER  ----------

cone_bottom_od      = 122.6;    //  4.83"  OD at the narrow (bottom) end
cone_top_od         = 125.0;    //  4.92"  OD where the gentle cone levels off
ridge_od            = 129.4;    //  5.09"  OD at the retention ridge —
                                //         wedges against the 5" lid hole

cone_height         =  42;      // mm — gentle taper (cone_bottom_od -> cone_top_od)
straight_height     =   6;      // mm — straight section at cone_top_od below the ridge
ridge_height        =   6;      // mm — cylindrical ridge at ridge_od;
                                //      its BOTTOM face is a flat annular shoulder
                                //      that seats on the lid for caulking
ridge_fall          =   6;      // mm — taper above the ridge, back down to cone_top_od
                                //      (this part sits above the lid; can be 0 if you
                                //      want a second flat step instead)
shoulder_height     =  18;      // mm — taper from cone_top_od down to socket_od
socket_height       =  38;      // mm — PVC socket depth (deeper than the original's
                                //      ~13mm of full-ID grip)

// ---------- INTERNAL ----------

through_bore        = 102;      // mm — internal flow bore below the socket (~4.0")
socket_wall_thick   = 3.0;      // mm — socket wall thickness (original was ~3mm)

// ---------- COSMETIC ----------

socket_chamfer      = 1.5;      // chamfer at the socket mouth for easy PVC entry
base_chamfer        = 1.0;      // small chamfer at the narrow bottom edge

// ---------- PRINT QUALITY ----------

$fn = 180;

// ---------- DERIVED ----------

socket_id = pvc_od + pvc_clearance;
socket_od = socket_id + 2 * socket_wall_thick;

z_cone_top     = cone_height;
z_straight     = z_cone_top + straight_height;
z_ridge_top    = z_straight + ridge_height;
z_ridge_bot    = z_ridge_top + ridge_fall;   // bottom of shoulder taper
z_shoulder     = z_ridge_bot + shoulder_height;
z_top          = z_shoulder + socket_height;

echo(str("Socket ID:     ", socket_id, " mm (", socket_id/25.4, " in)"));
echo(str("Socket OD:     ", socket_od, " mm (", socket_od/25.4, " in)"));
echo(str("Ridge OD:      ", ridge_od,  " mm (", ridge_od/25.4,  " in)"));
echo(str("Wedge z:       ", z_straight, " mm (flat shoulder sits on lid)"));
echo(str("Total height:  ", z_top,     " mm (", z_top/25.4,     " in)"));

// ---------- GEOMETRY ----------

module adapter() {
    difference() {
        union() {
            // Gentle cone (narrow bottom -> cone_top_od at its top)
            cylinder(h=cone_height, d1=cone_bottom_od, d2=cone_top_od);

            // Straight cylinder immediately below the ridge
            translate([0,0,z_cone_top])
                cylinder(h=straight_height, d=cone_top_od);

            // Ridge cylinder at the wider diameter.
            // Because it sits on top of the narrower cylinder below, the
            // transition is automatically a flat horizontal annular face —
            // this is the surface that seats on the lid for caulking.
            translate([0,0,z_straight])
                cylinder(h=ridge_height, d=ridge_od);

            // Above-lid taper: ridge_od back down to cone_top_od
            translate([0,0,z_ridge_top])
                cylinder(h=ridge_fall, d1=ridge_od, d2=cone_top_od);

            // Shoulder taper down to socket_od
            translate([0,0,z_ridge_bot])
                cylinder(h=shoulder_height, d1=cone_top_od, d2=socket_od);

            // PVC socket
            translate([0,0,z_shoulder])
                cylinder(h=socket_height, d=socket_od);
        }

        // Internal flow bore (from bottom up to the socket step)
        translate([0,0,-0.1])
            cylinder(h=z_shoulder + 0.1, d=through_bore);

        // PVC socket bore — step at the bottom that the PVC seats against
        translate([0,0,z_shoulder])
            cylinder(h=socket_height + 0.2, d=socket_id);

        // Chamfer at socket mouth (lead-in for PVC insertion)
        translate([0,0,z_top - socket_chamfer])
            cylinder(h=socket_chamfer + 0.01,
                     d1=socket_id, d2=socket_id + 2*socket_chamfer);

        // Chamfer at the narrow base (cleaner first-layer edge)
        if (base_chamfer > 0) {
            translate([0,0,-0.01])
                difference() {
                    cylinder(h=base_chamfer + 0.01,
                             d=cone_bottom_od + 2);
                    cylinder(h=base_chamfer + 0.02,
                             d1=cone_bottom_od - 2*base_chamfer,
                             d2=cone_bottom_od);
                }
        }
    }
}

adapter();
