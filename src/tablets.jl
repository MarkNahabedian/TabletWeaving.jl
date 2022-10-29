
export TabletThreading, BackToFront, FrontToBack
export threading_for_char, threading_char, other
export TabletStacking, FrontToTheRight, FrontToTheLeft, tablet_stacking_to_char
export Tablet
export TABLET_HOLE_LABELS, TABLET_EDGE_LABELS, TabletHole, TabletEdge,
    next, previous, opposite
export RotationDirection, rotation, rotate!,
    ABCD, DCBA,
    Clockwise, CounterClockwise,
    Forward, Backward
export shot!


############################################################
# Tablet Structure

const TABLET_HOLE_LABELS = 'A':'D'
const TABLET_EDGE_LABELS = 1:4

"""
A `TabletHole` represents one of the corner holes in a tablet.
"""
struct TabletHole
    label::Char

    function TabletHole(label::Char)
	@assert label in TABLET_HOLE_LABELS
	new(label)
    end
end

"""
A TabletEdge` represents a single edge of a tablet.
"""
struct TabletEdge
    label::Int
    
    function TabletEdge(label::Int)
	@assert label in TABLET_EDGE_LABELS
	new(label)
    end
end

function modindex(index, seq)
    Int(mod(index - 1, length(seq)) + 1)
end


next(elt, seq) =
    seq[modindex(findfirst(x -> x == elt, seq) + 1, seq)]

previous(elt, seq) =
    seq[modindex(findfirst(x -> x == elt, seq) - 1, seq)]

function opposite(elt, seq)
    @assert iseven(length(seq))
    seq[
	modindex(findfirst(x -> x == elt, seq) + length(seq) / 2,
		 seq)
    ]
end

next(hole::TabletHole) = TabletHole(next(hole.label, TABLET_HOLE_LABELS))
previous(hole::TabletHole) = TabletHole(previous(hole.label, TABLET_HOLE_LABELS))
opposite(hole::TabletHole) = TabletHole(opposite(hole.label, TABLET_HOLE_LABELS))

next(edge::TabletEdge) = TabletEdge(next(edge.label, TABLET_EDGE_LABELS))
previous(edge::TabletEdge) = TabletEdge(previous(edge.label, TABLET_EDGE_LABELS))
opposite(edge::TabletEdge) = TabletEdge(opposite(edge.label, TABLET_EDGE_LABELS))


"""
    next_hole(::TabletEdge)

Return the hole following the specified edge.
"""
function next_hole(edge::TabletEdge)::TabletHole
    label = edge.label
    if label == 1 TabletHole('B')
    elseif label == 2 TabletHole('C')
    elseif label == 3 TabletHole('D')
    elseif label == 4 TabletHole('A')
    else error("Unsupported edge label: $label")
    end
end


"""
    previous_hole(::TabletEdge)

Return the hole preceeding the specified hole.
"""
function previous_hole(edge::TabletEdge)::TabletHole
    label = edge.label
    if label == 1 TabletHole('A')
    elseif label == 2 TabletHole('B')
    elseif label == 3 TabletHole('C')
    elseif label == 4 TabletHole('D')
    else error("Unsupported edge label: $label")
    end
end


############################################################
# Tablet Threading

"""
TabletThreading is the abstract supertype for the two ways that the
warp threads can pass through a tablet.
"""
abstract type TabletThreading end

"""
Warp threads pass from the warp beam through the tablet from back to front.
"""
struct BackToFront <: TabletThreading end


"""
Warp threads pass from the warp beam through the tablet from front to back.
"""
struct FrontToBack <: TabletThreading end

"""
    other(::TabletThreading)
Given a `TabletThreading`, return the opposite one.
"""
other(::BackToFront) = FrontToBack()
other(::FrontToBack) = BackToFront()


"""
    threading_for_char(::AbstractChar)

Given an 's' or a 'z', return an instance of the the corresponding
TabletThreading.

There seems to be some confusion in the tablet weaving community about
which is which.  In this code base, 'z' corresponds to
`BackToFront` threading.
"""
function threading_for_char(c::AbstractChar)
    if c == '/' || c == 'z' || c == 'Z'
	return BackToFront()
    end
    if c == '\\' || c == 's' || c == 'S'
	return FrontToBack()
    end
    error("Invalid threading designation: $c")
end


"""
    threading_char(::TabletThreading)

Return the character ('s' or 'z' corresponding to the specified tablet
threading.  See `threading_for_char`.
"""
threading_char(::BackToFront) = '\u2571'
threading_char(::FrontToBack) = '\u2572'


############################################################
# Tablet Stacking

"""
TabletStacking is the abstract supertype for which way a tablet is
facing when stacked.
"""
abstract type TabletStacking end

"""
In `FrontToTheRight` stacking, 
the tablet is stacked so that its front faces the weaver's right.
"""
struct FrontToTheRight <: TabletStacking end

"""
In `FrontToTheRight` stacking, 
the tablet is stacked so that its front faces the weaver's left.
"""
struct FrontToTheLeft <: TabletStacking end

other(::FrontToTheRight) = FrontToTheLeft()
other(::FrontToTheLeft) = FrontToTheRight()


"""
    tablet_stacking_to_char(::TabletStacking)
Return an arrow showing which direction the front of a
tablet is currently facing.
"""
tablet_stacking_to_char(::FrontToTheRight) = '→'
tablet_stacking_to_char(::FrontToTheLeft) = '←'


############################################################
# Tablet

"""
    Tablet
Tablet describes the setup and current state of a single tablet
weaving card.
"""
@with_kw mutable struct Tablet{T}
    id = nothing
    a::T
    b::T
    c::T
    d::T
    threading::TabletThreading = BackToFront()
    # The above properties can not be changed after the loom has been warped.
    stacking::TabletStacking = FrontToTheRight()
    accumulated_rotation::Int = 0
    this_shot_rotation::Int = 0
    # It is helpful to know the range of thread twist imposed by a weaving pattern:
    min_rotation = 0
    max_rotation = 0
end

function Base.copy(t::Tablet)
    @assert t.accumulated_rotation == 0
    @assert t.this_shot_rotation == 0
    @assert t.min_rotation == 0
    @assert t.max_rotation == 0
    Tablet(;
	   id = t.id,
	   a = t.a,
	   b = t.b,
	   c = t.c,
	   d = t.d,
	   threading = t.threading,
	   stacking = t.stacking)
end

"""
    warp_color(::Tablet, ::TabletHole)

Return the color of the warp thread that passes through the specified
hole of the specified tablet.
"""
function warp_color(t::Tablet{T}, hole::TabletHole)::T where T
	h = hole.label
	if h == 'A' t.a
	elseif h == 'B' t.b
	elseif h == 'C' t.c
	elseif h == 'D' t.d
	else error("Unsuppoorted hole label: $h")
	end
end


"""
    top_edge(::Tablet)::TabletEdge

Return the TabletEdge of the top edge of the tablet.
This edge is easier to see on the loom than the shed edge
It is also unaffected by the tablet's `stacking`.
"""
function top_edge(t::Tablet)::TabletEdge
	# t.stacking affects which edge faces the shed but not which is on top
	# since changing t.stacking can only be done by flipping the card on its
	# vertical axis.
	r = mod(t.accumulated_rotation, 4)
	if r == 0 TabletEdge(1)
	elseif r == 1 TabletEdge(4)
	elseif r == 2 TabletEdge(3)
	else TabletEdge(2)
	end
end


############################################################
# Tablet Arithmetic

function (Base.:+)(a::Tablet{<:Any}, b::Tablet{<:Any})
    [a; b]
end

function (Base.:+)(a::Tablet{<:Any}, v::Vector{<:Tablet{<:Any}})
    [a; v...]
end

function (Base.:+)(v::Vector{<:Tablet{<:Any}}, b::Tablet{<:Any})
    [v...; b]
end

function (Base.:+)(v1::Vector{<:Tablet{<:Any}}, v2::Vector{<:Tablet{<:Any}})
    [v1...; v2...]
end

function (Base.:+)(v1::Vector{<:Tablet{<:Any}}, vs::Vector{<:Tablet{<:Any}}...)
    result = v1
    for v2 in vs
	result += v2
    end
    result
end

function (Base.:*)(repeat::Int, t::Tablet{<:Any})
    result = Vector{Tablet{<:Any}}()
    for i in 1:repeat
	push!(result, copy(t))
    end
    result
end

function (Base.:*)(repeat::Int, v::Vector{<:Tablet{<:Any}})
    result = Vector{Tablet{<:Any}}()
    for i in 1:repeat
	append!(result, copy.(v))
    end
    result
end


############################################################
# Tablet Rotation

"""
    RotationDirection

`RotationDirection` is the abstract supertype of all tablet rotations.
"""
abstract type RotationDirection end

# ╔═╡ f1c8a4c6-6c22-49f4-9df1-ef3ae5e3cb40
"""
    rotation(::Tablet, ::RotationDirection)

Return the change in the `Tablet`'s `accumulated_rotation` if the specified
`AbstractRotation is applied.
"""
function rotation(::Tablet, ::RotationDirection) end


"""
    rotate!(::Tablet, ::RotationDirection)

Rotate the tablet by one position in the specified direction.
"""
function rotate!(t::Tablet, d::RotationDirection)
	new_rotation = rotation(t, d)
	t.this_shot_rotation += new_rotation
	return t
end


"""
The ABCD rotation causes the A corner of the tablet to move to
the location in space previously occupied by the B corner.
"""
struct ABCD <: RotationDirection end

rotation(::Tablet, ::ABCD) = 1


"""
The DCBA rotation causes the A corner of the tablet to move to
the location in space previously occupied by the D corner.
"""
struct DCBA <: RotationDirection end

rotation(t::Tablet, ::DCBA) = -1


"""
The `Clockwise` direction refers to how the tablet would move if its front or
back face (depending on threading) were facing the weaver.  Whether this
results in ABCD or DCBA rotation depends on how the card is threaded.
"""
struct Clockwise <: RotationDirection end

function rotation(t::Tablet, ::Clockwise)
	if t.threading isa BackToFront
		rotation(t, ABCD())
	else
		rotation(t, DCBA())
	end
end


"""
The `CounterClockwise` direction refers to how the tablet would move if its front
or back face (depending on threading)  were facing the weaver.  Whether the front
or the back of the tablet is facing the weaver depends on whether the card is
BackToFront` or `FrontToBack` threaded.
"""
struct CounterClockwise <: RotationDirection end

function rotation(t::Tablet, ::CounterClockwise)
	if isa(t.threading, FrontToBack)
		rotation(t, ABCD())
	else
		rotation(t, DCBA())
	end
end


"""
The Forward rotation moves the top corner of the tablet closest to the
weaver and the cloth beam to be the bottom corner closest to the weaver.
"""
struct Forward <: RotationDirection end

function rotation(t::Tablet, ::Forward)
	if isa(t.stacking, FrontToTheRight)
		rotation(t, ABCD())
	else
		rotation(t, DCBA())
	end
end


"""
The Backward rotation moves the top corner of the tablet closest to the
weaver and the cloth beam to be the bottom corner closest to the weaver.
"""
struct Backward <: RotationDirection end

function rotation(t::Tablet, ::Backward)
	if isa(t.stacking, FrontToTheLeft)
		rotation(t, ABCD())
	else
		rotation(t, DCBA())
	end
end

tablet_rotation_char(::Forward) = "🡑"
tablet_rotation_char(::Backward) = "🡓"


############################################################
# Throwing a Weft

"""
    shot!(::Tablet)

Apply the current rotation to the tablet and return the colors of the warp
threads passing over the top and bottom of the fabric, and the crossing
direction (as a forward or backslash character) when looking at that face
of the fabric.
"""
function shot!(t::Tablet)
	@assert(abs(t.this_shot_rotation) == 1,
		"in shot!, this_shot_rotation = $(t.this_shot_rotation)")
	te = top_edge(t)
	be = opposite(te)
	t.accumulated_rotation += t.this_shot_rotation
	t.min_rotation = min(t.min_rotation, t.accumulated_rotation)
	t.max_rotation = min(t.max_rotation, t.accumulated_rotation)
	hole = if t.this_shot_rotation > 0
		if t.threading isa BackToFront
			stitchslant = '/'
		else
			stitchslant = '\\'
		end
		previous_hole
	else
		if t.threading isa BackToFront
			stitchslant = '\\'
		else
			stitchslant = '/'
		end
		next_hole
	end
	t.this_shot_rotation = 0
	wc(edge) = warp_color(t, hole(edge))
	return wc(te), wc(be), stitchslant
end

