We could weave text.

I found a 5×7 dot matrix font that might be used to weave text.

```@example 1
using Colors
using TabletWeaving

dotmatrix(c) = FONT_5x7[c]

color(bit) = [ RGB(1, 1, 1), RGB(0, 0, 0) ][bit + 1]

compose_line(line) =
    safe_hcat(AlignCenters(), UInt8(0),
              insert_between(
                  # render characters in font:
                  dotmatrix.(collect(line)),
                  # One "pixel" spacing between characters:
                  blank_swatch(UInt8(0))))

color.(compose_line("HELLO!"))
```

We can also compose multiple lines:

```@example 1
using Base.Iterators

#=
function compose(composed_lines; leading=1, align=0)
    len(line) = size(line)[2]
    padded_lines = []
    space = zeros(Int, 7)
    width = maximum(len, composed_lines)
    for line in composed_lines
        if length(padded_lines) > 0
            for i in leading
                push!(padded_lines, zeros(Int, 1, width))
            end
        end
        need = width - len(line)
        left = []
        right = []
        if align < 0        # left align, right pad
            left = repeated(space, need)
        elseif align > 0    # right align, left pad
            right = repeated(space, need)
        else                # center
            f = floor(Int, need/2)
            left = repeated(space, f)
            right = repeated(space, need - f)
        end

        push!(padded_lines,
              hcat(left..., line, right...))
    end
    vcat(padded_lines...)
end
=#

MESSAGE = color.(
  safe_vcat(AlignCenters(), 0,
            insert_between(
                compose_line.(["THIS IS",
                               "A TEST"]),
                fill(0, 2, 1))))
```

How might it look woven:

```@example 1
WOVEN = 
    TabletWeavingPattern("Sample Text", MESSAGE;
                   	 threading_function = symetric_threading!)

HTML(string(pretty(WOVEN)))
```

