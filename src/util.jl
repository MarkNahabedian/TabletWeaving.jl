export longer_dimension_counts_weft
export csscolor

"""
	longer_dimension_counts_weft(image)

Return an image with the dimensions possibly permuted such that each increment
in the first dimension counts a new row of the weft.  The second dimension
indexes the color of the visible warp thread for that row.
"""
function longer_dimension_counts_weft(image)
	if size(image)[1] < size(image)[2]
		permutedims(image, [2, 1])
	else
		image
	end
end	


"""
    csscolor(color)
return (as a string) the CSS representation of the color.
"""
function csscolor end

function csscolor(color::Gray)
    l = Int(round(color.val * 255))
    "hsl(0deg, 0%, $(l)%)"
end

function csscolor(color::RGB)
    css(x) = Int(round(x * 255))
    "rgb($(css(color.r)), $(css(color.g)), $(css(color.b)))"
end

csscolor(color::Colorant) = "#$(hex(color))"

