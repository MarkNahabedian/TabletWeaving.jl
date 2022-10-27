
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
