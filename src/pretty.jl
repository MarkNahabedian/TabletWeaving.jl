export pretty_stitches, pretty_plan, pretty


function pretty_stitches(image_stitches, flip_right_to_left::Bool)
    # image_stitches is a Vector with one element per woven row.
    # Each row is a Vector of stitch colors.

    # image_stitches should be the top_image_stitches or bottom_image_stitches
    # of a TabletWeavingPattern.
    # In those Arrays, row 1 is at the top, but when woven,
    # the first row is at the bottom:
    image_stitches = reverse(image_stitches, dims=1)
    if flip_right_to_left
        image_stitches = [ reverse(row, dims=1)
                           for row in image_stitches ]
    end
    stitch_width = 2
    stitch_length = 3
    stitch_diameter = 1
    uses = []
    stitch_slant_fragment(::SStitch) = "#stitch2"
    stitch_slant_fragment(::ZStitch) = "#stitch1"
    function use(row, col, color, slant)
        push!(uses,
              elt("use",
	          :href => stitch_slant_fragment(slant),
	          :x => "$(col * stitch_width)",
	          :y => "$(row * stitch_length)",
	          :width => "$(stitch_width)",
	          :height => "$(stitch_length)",
	          :style => "stroke: none; fill: $(csscolor(color)); vector-effect: non-scaling-stroke"))
    end
    for (rownum, row) in enumerate(image_stitches)
	for (colnum, stitch) in enumerate(row)
	    (color, slant) = stitch
	    use(rownum, colnum, color, slant)
	end
    end
    println(length(uses))
    viewbox_width = stitch_width * length(image_stitches[1])
    viewbox_height = stitch_length * length(image_stitches)
    elt("svg", 
        :viewBox => "0 0 $viewbox_width $viewbox_height",
        elt("g",
   	    elt("symbol",
                :id => "stitch1",
    	        :preserveAspectRatio => "xMinYMin",
    	        :viewBox => "0 0 $(stitch_width) $(stitch_length)",
                :refX => "0",
                :refY => "0",
    	        svg_stitch(stitch_width, stitch_length, stitch_diameter, '/';),),
            elt("symbol",
                :id => "stitch2",
    	        :preserveAspectRatio => "xMinYMin",
    	        :viewBox => "0 0 $(stitch_width) $(stitch_length)",
    	        :refX => "0",
                :refY => "0",
    	        svg_stitch(stitch_width, stitch_length, stitch_diameter, '\\';),),
            uses...))
end


function pretty_plan(p::TabletWeavingPattern)
    summary(heading, reader) =
        elt("tr",
            elt("th", :align => "right", heading),
            map(p.end_tablets) do t
                elt("td", :align => "right", reader(t))
            end...)
    elt("table",
        # Show initial rotation of each tablet:
        elt("tr",
            elt("th", :align => "right", 0),
            [ elt("td", :align => "right",
                  top_edge(t).label)
              for t in p.initial_tablets ]...),
        # Each row of the plan:
        [ elt("tr",
              elt("th", :align => "right", i),
              [ elt("td", :align => "right",
                    string(tablet_rotation_char(t[1])),
                    t[2].label)
                for t in step
                    ]...)
          for (i, step) in enumerate(p.weaving_steps)
              ]...,
        # End summary:
        summary("end", t -> t.accumulated_rotation),
        summary("min", t -> t.min_rotation),
        summary("max", t -> t.max_rotation))
end


TABLET_THREADING_PROSE = """
The chart below shows how each tablet should be threaded.  The four
rows of colors are for the A, B, C and D holes respectively.

The threading direction indicated by the diagonal line in the 5th row.
When looking from the cloth beam towards the warp beam with the
tablets facing to one's right, the direction of the diagonal line
shows how each thread should pass through the tablet.
"""

PATTERN_WEAVING_PROSE = """
This nextchart shows how each row shoulf be woven.

The first column is the row number.  This is followed by a separate
column for each tablet.  For a given tablet, 

🡑 indicates that the tablet should be rotated forward, and 
🡓 indicates that the tablet should be rotated backward.

The number after the arrow says which edge of the tablet should be on
top after the rotation.  This can be used to verify that all tablets
are in the right place before throwing the weft.

The last three rows show the final, minimum and maximum accumulated
twist for each tablet.
"""

RENDERING_PROSE = """
Below is a rendering of what we anticipate the resulting weave might
look like.

Note that, for proper rendering, row 1 of the pattern is at the
bottom of each of these images.
"""

function pretty(p::TabletWeavingPattern)
    elt("div",
	elt("h2", p.title),
        elt("p", TABLET_THREADING_PROSE),
	elt("div", chart_tablets(p.initial_tablets)),
        elt("p", PATTERN_WEAVING_PROSE),
	elt("div", pretty_plan(p)),
        elt("p", RENDERING_PROSE),
        elt("table", :width=>"80%",
            elt("tr",
                elt("th", "Front"),
                elt("th", "Back")),
            elt("tr",
                elt("td", :width=>"40%",
	            pretty_stitches(p.top_image_stitches, false),),
                elt("td", :width=>"40%",
                    # We need to flip the bottom left to right so that
                    # it is shown looking from the back rather than
                    # looking through the front:
	            pretty_stitches(p.bottom_image_stitches, true)))))
end

