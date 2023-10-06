export simple_rotation_plan, tablets_for_image, TabletRotationPolicy
export symetric_threading!, alternating_threading!
export rotation_plan_from_image, f4b4_rotation_plan, TabletWeavingPattern


"""
    simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)

Return a simple rotation plan function, as could be passed to [`tablet_weave`](@ref).
"""
function simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)
    function plan(tablets::Vector{<:Tablet}, row_number::Int, tablet_number::Int)
	if row_number <= row_count
	    return Rotation(rotation_direction, 1)
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
            Rotation(Forward(), 1)
        else
            Rotation(Backward(), 1)
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


struct WantColorChoice
    rotation::Rotation
    # Positive rotation corresponds to Forward().
    rotation_count::Int64
    accumulated_rotation::Int64
    new_edge::TabletEdge
end

WantColorChoices = Vector{WantColorChoice}


"""
    want_color(::Tablet, color)::WantColorChoices

Return a Vector of `WantColorChoice`s describing the
possible rotations that will provide the specified color.
"""
function want_color(tablet::Tablet{T}, color::T)::WantColorChoices where T
    results = []
    function check(r::Rotation)
        rot = rotation(tablet, r)
        f, hf = rot < 0 ? (next, next_hole) : (previous, previous_hole)
        new_edge = top_edge(tablet)
        # For single rotations, just calling the hole function is
        # sufficient:
        for i in 2 : abs(rot)
            new_edge = f(new_edge)
        end
        if warp_color(tablet, hf(new_edge)) == color
            # We do need to apply the rotation function to cortrectly
            # etermine the new edge though:
            new_edge = f(new_edge)
            push!(results,
                  WantColorChoice(r, rot,
                                  rot + tablet.accumulated_rotation,
                                  new_edge))
        end
    end
    check(Rotation(Forward(), 2))
    check(Rotation(Forward(), 1))
    check(Rotation(Backward(), 1))
    check(Rotation(Backward(), 2))
    return results
end


"""
    TabletRotationPolicy

A structure that consolidates parameters for controlling which tablet
manipulation is preferred to achieve a given stitch color.
"""
@with_kw struct TabletRotationPolicy
    # Absolute value of the number of forward or backward rotations a
    # tablet can be turned between stitches.  Typically 1 or 2.
    max_turn_per_stitch::UInt8 = 2

    # whether the current rotation is allowed to reverse the rotation
    # of the previous row and leave the surface stitches unanchored:
    no_undo::Bool = true
end


"""
    (::TabletRotationPolicy)(choices)

Return the element of `choices` that best suits the policy.

`choices` should be a vector as returned by `want_color`.
"""
function (policy::TabletRotationPolicy)(choices::WantColorChoices,
                                        color, row::Integer, column::Integer, tablets,
                                        previous_row_rotation::Integer,
                                        previous_column_rotation::Integer
                                        )::WantColorChoice
    tablet = tablets[column]
    choices = filter(choices) do choice
        abs(rotation(tablet, choice.rotation)) <= policy.max_turn_per_stitch
    end
    if policy.no_undo
        choices = filter(choices) do choice
            rotation(tablet, choice.rotation) + previous_column_rotation != 0
        end
    end
    if length(choices) == 0
        error("Can't match color $color with tablet $tablet.")
    end
    
    #=
    # prefer the same rotation as for the previous tablet if
    # it's acceptable and we've not passed the middle of the
    # warp:
    side(column) = sign(length(tablets)/2 - column)
    if side(column) == side(column - 1)
        previous_column_rotation
    else
        other(previous_column_rotation)
    end
    =#
    
    # SHOULD THERE BE A PARAMETER FOR THIS?
    # Prefer minimizing accumulated_rotation.  Sorting is stable.
    sort!(choices; by = choice -> abs(choice.accumulated_rotation))
    return choices[1]
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
    tablet_rotation_policy::TabletRotationPolicy
    weaving_steps
    end_tablets
    # top_image_stitches and bottom_image_stitches each are a vector
    # (one element per row) of vectors (one element per stitch) of the
    # stitch color and slant, from which an image of the top or bottom
    # face of the result can be made:
    top_image_stitches
    bottom_image_stitches
end

function rotation_plan_from_image(image, tablets, policy::TabletRotationPolicy)
    # Remember what we've previously computed:
    results = Array{Int}(undef, size(image))
    function plan(tablets, row, column)
	if row < 1 || row > size(image)[1]
	    return nothing
	end
        tablet = tablets[column]
	color = image[row, column]
        choices = want_color(tablet, color)
        choice = policy(choices, color, row, column, tablets,
                        if row > 1
                            results[row - 1, column]
                        else
                            0
                        end,
                        if column > 1
                            results[row, column - 1]
                        else
                            0
                        end)
        results[row, column] = choice.rotation
        if choice.rotation > 0
            Rotation(Forward(), choice.rotation)
        else
            Rotation(Backward(), - choice.rotation)
        end
    end
    plan
end

function TabletWeavingPattern(title::AbstractString, image;
			      threading_function = identity,
                              policy = TabletRotationPolicy())
    image = longer_dimension_counts_weft(image)
    initial_tablets = threading_function(tablets_for_image(image))
    tablets = copy.(initial_tablets)
    top, bottom, instructions =
	tablet_weave(tablets, rotation_plan_from_image(image, tablets, policy))
    
    TabletWeavingPattern(title, image, initial_tablets,
                         policy,
                         instructions, tablets,
			 top, bottom)
end

