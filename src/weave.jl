export tablet_weave

"""
    tablet_weave(tablets::Vector{<:Tablet}, rotation_plan)

Simulate the weaving of an item that is warped according to `tablets` and is
woven according to `rotation_plan`.

`rotation_plan` is a function of three arguments:

* a vector of the tablets;

* the row number of the warp being formed;

* the number of the tablet, counted from the weaver's left.

It should return a RotationDirection, or `nothing` if the row number
is past the end of the pattern.

`tablet_weave` rotates the tablets according to the plan function, steping the
row number until `rotation_plan` returns `nothing`.

`tablet_weave` returns several values:

* an array of the stitch color and slant, from which an image of the top face of the result can be made;

* the same, but for the bottom face of the result;

* a vector with one element per weft row, each element of which is a vector with
one element per tablet, giving the rotation that was applied to that tablet and its new top edge after applying that rotation, as a tuple.
"""
function tablet_weave(tablets::Vector{<:Tablet}, rotation_plan)
    tapestry_top = []
    tapestry_bottom = []
    instructions = []
    row = 1
    while true
	rotations = []
	for column in 1 : length(tablets)
	    rot = rotation_plan(tablets, row, column)
	    if rot == nothing
		@goto done
	    end
	    rotate!(tablets[column], rot)
	    push!(rotations, rot)
	end
	weave = shot!.(tablets)
	push!(tapestry_top, map(weave) do (top, bottom, slant)
		  (top, slant)
	      end)
	push!(tapestry_bottom, map(weave) do (top, bottom, slant)
		  (bottom, other(slant))
	      end)
	push!(instructions, collect(zip(rotations, top_edge.(tablets))))
	row += 1
    end
    @label done
    return tapestry_top, tapestry_bottom, instructions
end
