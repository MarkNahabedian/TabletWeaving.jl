export simple_rotation_plan, tablets_for_image
export symetric_threading!, alternating_threading!
export rotation_plan_from_image, f4b4_rotation_plan, TabletWeavingPattern


"""
    simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)

Return a simple rotation plan function, as could be passed to [`tablet_weave`](@ref).
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
    f4b4_rotation_plan(row_count::Int)

Return a rotation plan function that weaves the specified number of rows.
All tablets in the first four rows will be rotated forward.
All tablets in the next four rows are rotated backward,
Rotation direction continues to alternate every four rows until the end
of the pattern.
"""
function f4b4_rotation_plan(row_count::Int)
    function plan(tablets::Vector{<:Tablet}, row_number::Int, tablet_number::Int)
        if row_number > row_count
            return nothing
        end
        if (row_number % 8) in 0:3
            Forward()
        else
            Backward()
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
                        leftthreading::TabletThreading = BackToFront())

Set the threading of the tablets to be bilaterally symetric.
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
    alternating_threading!(tablets::Vector{<:Tablet};
                           leftthreading::TabletThreading = BackToFront())

Set the threading of each tablet so that each tablet has the opposite
threading from its two neighbors.
"""
function alternating_threading!(tablets::Vector{<:Tablet};
                                leftthreading::TabletThreading = BackToFront())
    threading = leftthreading
    for tablet in tablets
        tablet.threading = threading
        threading = other(threading)
    end
    tablets
end


"""
    want_color(::Tablet, color)

Return a Vector containing named tuples (of new edge,
AbstractRotation, and change in tablet rotation) describing the
possible rotations that will provide the specified color.
"""
function want_color(tablet::Tablet{T}, color::T) where T
    results = []
    e = top_edge(tablet)
    function check(hole_function, edge_function, rotation_change)
        if warp_color(tablet, hole_function(e)) == color
            push!(results,
                  (rotation = first(filter([Forward(), Backward()]) do r
                                        rotation(tablet, r) == rotation_change
                                    end),
                   accumulated_rotation = rotation_change + tablet.accumulated_rotation,
                   edge = edge_function(e)))
        end
    end
    check(next_hole, next, -1)
    check(previous_hole, previous, 1)
    sort(results, by = x -> abs(x. accumulated_rotation))
end


"""
    TabletWeavingPattern

TabletWeavingPattern represents a single tablet weaving project, from
initial target image to tablets to pattern to images of the expected
result.
"""
struct TabletWeavingPattern # {C} # where C causes "invalid type signature" error
    title::AbstractString
    image # ::Union{Nothing, Array{C, 2}}
    initial_tablets # ::Vector{<:Tablet{F} where {F <: C}}
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
    # Remember what we've previously computed:
    results = Array{Union{Nothing, RotationDirection}}(nothing, size(image))
    function plan(tablets, row, column)
	if row < 1 || row > size(image)[1]
	    return nothing
	end
        side(column) = sign(length(tablets)/2 - column)
        tablet = tablets[column]
	color = image[row, column]
        choices = map(r -> r.rotation, want_color(tablet, color))
        left_neighbor_rotation = (
            if column > 1
                results[row, column - 1]
            else
                nothing
            end)
        if length(choices) == 0
            error("Can't match color $color with tablet $tablet.")
        elseif length(choices) == 1
            rotation = choices[1]
        elseif left_neighbor_rotation == nothing
            # Prefer minimizing accumulated_rotation.  want_color
            # sorts by this.
            rotation = choices[1]
        elseif side(column) == side(column - 1)
            # prefer the same rotation as for the previous tablet if
            # it's acceptable and we've not passed the middle of the
            # warp:
            rotation = left_neighbor_rotation
        elseif other(left_neighbor_rotation) in choices
            rotation = other(left_neighbor_rotation)
        else
            rotation = choices[1]
        end
        cached = (row=row, column=column, rotation=rotation)
        results[row, column] = rotation
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

