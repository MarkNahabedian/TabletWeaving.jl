
"""
    svg_stitch(stitch_width, stitch_length, stitch_diameter, slant::Char)

Generate the SVG for drawing a stitch.

`stitch_width` is the width of the stitch on the SVG X and weaving
weft axis.

`stitch_diameter` is how wide the stitch is.

`stitch_length` is the length of the stitch in the SVG Y and warp
axis.

`slant` is as returned by `shot!`.
   
"""
function svg_stitch(stitch_width, stitch_length, 
                    stitch_diameter, slant::Char;
                    show_guides = false)
    stitch_radius = stitch_diameter / 2
    circle1 = [
        stitch_radius,
        stitch_length - stitch_radius
    ]
    circle2 = [
        stitch_width - stitch_radius,
        stitch_radius
    ]
    if slant == '\\'
        # Swap X coordinates:
        (circle1[1], circle2[1]) = (circle2[1], circle1[1])
    end
    # we can translate the center of each circle by +/= the vector
    # perpendicular to this angle:
    diagonal = circle2 - circle1
    trans = [ - diagonal[2], diagonal[1] ]    # perpendicular
    trans = trans / norm(trans)               # unit vector
    trans = trans * stitch_radius

    guide_style = join(
        [
            "stroke: blue",
            "stroke-width: 1px",
            "fill: none",
            "vector-effect: non-scaling-stroke"
        ], "; ")
    stitch_style = join(
        [
            # "stroke: yellow",
            "stroke-width: 1px",
            "vector-effect: non-scaling-stroke"
        ], "; ")

    function line(p1, p2, style)
        elt("line",
            :x1 => p1[1],
            :y1 => p1[2],
            :x2 => p2[1],
            :y2 => p2[2],
            :style => style)
    end

    guides = []
    if show_guides
        push!(guides,
              # bounding rectangle:
              elt("rect",
                  :x => 0,
                  :y => 0,
                  :width => stitch_width,
                  :height => stitch_length,
                  :style => guide_style),
              # Diagonal:
              line(circle1, circle2, guide_style),
              # Normals:
              line(circle1, circle1 + trans, guide_style),
              line(circle2, circle2 + trans, guide_style))
    end
    p1 = circle1 + trans
    p2 = circle2 + trans
    p3 = circle2 - trans
    p4 = circle1 - trans
    pathpoint(p) = join(string.(p), " ")

    elt("g",
        # viewBox="0 0 $(2 * stitch_width) $(2 * stitch_length)",
        # width="50%",
        guides...,
        elt("path",
            :style => stitch_style,
            :d => join([
                "M $(pathpoint(p1))",
                "L $(pathpoint(p2))",
                let
                    r = stitch_radius
                    "A $r $r 0 0 0 $(pathpoint(p3))"
                end,
                "L $(pathpoint(p4))",
                let
                    r = stitch_radius
                    "A $r $r 0 0 0 $(pathpoint(p1))"
                end,
            ], " ")))
end

