
export TabletThreading, BackToFront, FrontToBack
export threading_for_char, threading_char, other
export TabletStacking, FrontToTheRight, FrontToTheLeft, tablet_stacking_to_char
export Tablet


############################################################
# Tablet Threading:

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

There seems to be some confurion in the tablet weaving community about
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
threading_char(::BackToFront) = '\u2572'


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
# ablet

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

function copy(t::Tablet)
    @assert t.id == nothing
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


