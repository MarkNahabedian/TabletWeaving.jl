export simple_rotation_plan, tablets_for_image, symetric_threading!


"""
    simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)

return a simple rotation plan function, as could be passed to `tablet_weaving`.
"""
function simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)
    function plan(tablets::Vector{<:Tablet}, row_number::Int, tablet_number::Int)
	if row_number <= row_count
	    return rotation_direction
	else
	    return nothing
	end
    end
end


"""
    tablets_for_image(image)

Return a `Vector` of the `Tablet`s that could be used to weave the
image, which should be a two dimensional array.  If the tablets can't
be determined then an error is thrown.

The first dimension of `image` counts rows of weft.  The second
dimension counts columns of warp, and therefore, tablets.
"""
function tablets_for_image(image)
    @assert length(size(image)) == 2
    cardcount = size(image)[2]
    throwcount = size(image)[1]
    @assert cardcount < throwcount
    # The possible colors for each "column" of warp:
    colors = [OrderedSet{Color}() for i in 1:cardcount]
    # Each color that's needed should get exactly one entry in colors:
    for rownum in 1:throwcount
	for cardnum in 1:cardcount
	    push!(colors[cardnum], image[rownum, cardnum])
	end
    end
    # Indexing into an OrderedSet is deprecated:
    colors = [ collect(o) for o in colors ]
    @assert all(x -> x > 0 && x <= 2, map(length, colors))
    map(colors) do c
	if length(c) == 1
	    Tablet(a = c[1], b = c[1], c = c[1], d = c[1])
	else
	    Tablet(a = c[1], b = c[2], c = c[1], d = c[2])
	end
    end
end


"""
    symetric_threading!(Vector{<:Tablet};

Set the threading of the tablets to be bilaterally symetric .
"""
function symetric_threading!(tablets::Vector{<:Tablet};
			     leftthreading::TabletThreading = BackToFront())
    l = length(tablets)
    middle = floor(Int, l / 2)
    for i in 1 : middle
	left = tablets[i]
	right = tablets[l + 1 - i]
	left.threading = leftthreading
	right.threading = other(leftthreading)
    end
    tablets
end


"""
    want_color(::Tablet, color)

return the new top edge if the tablet is rotated so that the stitch
will come out the specified color.  `want_color` is used to turn an
image into a weaving pattern.
"""
function want_color(tablet::Tablet{T}, color::T) where T
    e = top_edge(tablet)
    c_next = warp_color(tablet, next_hole(e))
    c_prev = warp_color(tablet, previous_hole(e))
    # If both colors are the same, which direction should we prefer?
    # Probably the one that is towards 0 accumulated twist.
    want_rotation =
	if c_next == c_prev
	    - sign(tablet.accumulated_rotation)
	elseif color == c_next
	    -1
	elseif color == c_prev
	    1
	else
	    error("Can't match color $c with tablet $tablet.")
	end
    if want_rotation == 0
	want_rotation = 1
    end
    new_edge = if want_rotation == 1
	previous(e)
    else
	next(e)
    end
    rot::RotationDirection = Forward()
    for r in [Forward(), Backward()]
	if rotation(tablet, r) == want_rotation
	    rot = r
	    break
	end
    end
    return new_edge, rot
end


"""
    TabletWeavingPattern

TabletWeavingPattern represents a single tablet weaving project, from
initial target image to tablets to pattern to images of the expected
result.
"""
struct TabletWeavingPattern{C} # where C causes "invalid type signature" error
    title::AbstractString
    image::Array{C, 2}
    initial_tablets::Vector{<:Tablet{<:C}}
    weaving_steps
    end_tablets
    # top_image_stitches and bottom_image_stitches each are a vector
    # (one element per row) of vectors (one element per stitch) of the
    # stitch color and slant, from which an image of the top or bottom
    # face of the result can be made:
    top_image_stitches
    bottom_image_stitches
end

function rotation_plan_from_image(image, tablets)
    tablets = copy.(tablets)
    function plan(tablets, row, column)
	if row > size(image)[1]
	    return nothing
	end
	color = image[row, column]
	(edge, rotation) = want_color(tablets[column], color)
	rotation
    end
    plan
end

function TabletWeavingPattern(title::AbstractString, image;
			      threading_function = identity)
    image = longer_dimension_counts_weft(image)
    initial_tablets = threading_function(tablets_for_image(image))
    tablets = copy.(initial_tablets)
    top, bottom, instructions =
	tablet_weave(tablets, rotation_plan_from_image(image, tablets))
    
    TabletWeavingPattern(title, image, initial_tablets, instructions, tablets,
			 top, bottom)
end

