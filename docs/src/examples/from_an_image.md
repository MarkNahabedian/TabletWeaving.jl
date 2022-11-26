We can turn a two color image into a tablet weaving pattern.

First we need an image.  I was playing around with the idea of
visualizing "Gray Code" in a weaving project.  Gray Code is a way of
counting in binary where only one bit changes on each count.

We can use it to make an image, described by a two domensional Julia
`Array` of `RGB` colors:

```@example 1
using Colors
using TabletWeaving

# Turn a regular binary number to its corresponding Gray Code :
graycode(x) = xor(x, x >>> 1)

# Weneed two colors for our image:
COLORS = [ RGB(1, 0, 0), RGB(0, 1, 0)]

gray_sequence = [digits(graycode(x); base = 2, pad = 8) for x in 0:63]

# Our basic Gray Code pattern:
GRAY_PATTERN = map(hcat(gray_sequence...)) do bit
	COLORS[bit + 1]
end
```

I like that, but I think it would be cooler if it were reflected on
both axes:

```@example 1
GRAY_WEAVE = let
	# Reflect GRAY_PATTERN on both axes and add leading and trailing background:
	pattern = GRAY_PATTERN
	for _ in 1:4
		pattern = hcat(pattern[:, 1], pattern)
	end
	bottom = hcat(pattern, reverse(pattern; dims=2))
	vcat(reverse(bottom; dims=1), bottom)
end
```

I like that.  How do I weave it.  This will show us the pattern:

```@example 1
WOVEN_GRAY_PATTERN = 
                   TabletWeavingPattern("Gray Code Pattern", GRAY_WEAVE;
                   	threading_function = symetric_threading!)

open(joinpath(@__DIR__, "graycode_pattern.html"), "w") do io
    write(io, string(pretty(WOVEN_GRAY_PATTERN)))
end
```

You can see the resulting HTML pattern file
[here](graycode_pattern.html).

