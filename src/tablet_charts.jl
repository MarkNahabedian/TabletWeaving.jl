export chart_tablet, chart_tablets

"""
    chart_tablet(::Tablet; size=5, x=0)

Return an SVG element that describes how the tablet is threaded.
"""
function chart_tablet(tablet::Tablet; size=5, x=0)
    @assert tablet.accumulated_rotation == 0
    @assert tablet.this_shot_rotation == 0
    function swatch(i, c)
        elt("rect",
            :width => "$(size)mm",
            :height => "$(size)mm",
            :x => "$(x)mm",
            :y => "$(i * size)mm",
            :fill =>"$(csscolor(c))",
            :stroke => "gray")
    end
    function threading(th)
        x1 = x
        x2 = x1 + size
        y1 = 4 * size
        y2 = 5 * size
        # The direction that the thread passed through the card if the card
        # is facing to the right (FrontToTheRight stacking)
        if th isa BackToFront
            elt("line",
                :stroke => "gray",
                :strokeWidth =>"3px",
                :x1 => "$(x1)mm",
                :y1 => "$(y1)mm",
                :x2 => "$(x2)mm",
                :y2 => "$(y2)mm")
        else
            elt("line",
                :stroke => "gray",
                :strokeWidth => "5px",
                :x1 => "$(x2)mm",
                :y1 => "$(y1)mm",
                :x2 => "$(x1)mm",
                :y2 => "$(y2)mm" )
        end
    end
    elt("svg", :xmlns => "http://www.w3.org/2000/svg",
        elt("g",
            swatch(0, tablet.a), swatch(1, tablet.b),
            swatch(2, tablet.c), swatch(3, tablet.d),
            threading(tablet.threading)))
end


"""
    chart_tablets(::Vector{<:Tablet})

Return an SVG chart describing how the tablets are threaded.
"""
function chart_tablets(tablets::Vector{<:Tablet})
    size = 5
    elt("svg",
	:xmlns => "http://www.w3.org/2000/svg",
	:width => "95%",
	# :viewBox => "0 0 $(length(tablets) * size) $(5 * size)",
	[ chart_tablet(tablet; size=size, x=size*(i-1))
	  for (i, tablet) in enumerate(tablets) ]...)
end
