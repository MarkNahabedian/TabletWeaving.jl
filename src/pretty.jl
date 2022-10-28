export pretty_stitches, pretty_plan, pretty


function pretty_stitches(image_stitches, flip_right_to_left::Bool)
    # image_stitches should be the top_image_stitches or bottom_image_stitches
    # of a TabletWeavingPattern.
    stitch_width = 2
    stitch_length = 3
    stitch_diameter = 1
    uses = []
    function use(row, col, color, slant)
        push!(uses,
              elt("use",
	          :href => slant == '/' ? "#stitch1" : "#stitch2",
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
        # Each row of the plan
        [ elt("tr",
              elt("th", :align => "right", i),
              [ elt("td", :align => "right",
                    tablet_rotation_char(t[1]),
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


function pretty(p::TabletWeavingPattern)
    elt("div",
	elt("h2", p.title),
	elt("div", chart_tablets(p.initial_tablets)),
	elt("div", pretty_plan(p)),
	elt("h3", "Front"),
	pretty_stitches(p.top_image_stitches, false),
	elt("h3", "Back"),
	pretty_stitches(p.bottom_image_stitches, true))
end

