Here's a simple pattern, found at
[http://research.fibergeek.com/2002/10/10/first-tablet-weaving-double-diamonds/]
(http://research.fibergeek.com/2002/10/10/first-tablet-weaving-double-diamonds/)

```@example
using Colors
using TabletWeaving

# A function for setting up tablets to weave a simple symetric
# diagonal line pattern that can weave chevrons or diamonds:
function make_diamond_tablets()
    f = RGB(0.0, 0.8, 0.0)
    b = RGB(0.6, 0.3, 0.3)
    id = 0  
    function tab(a, b, c, d, threading)
        id += 1
        Tablet{Color}(; id=id, a=a, b=b, c=c, d=d, threading=threading)
    end
    s = threading_for_char('s')
    z = threading_for_char('z')
    [
        # Border:
        tab(b, b, b, b, z),   #  1
        tab(b, b, b, b, z),   #  2
        tab(f, f, f, f, z),   #  3
        # Pattern:
        tab(b, f, f, b, s),   #  4
        tab(f, f, b, b, s),   #  5
        tab(f, b, b, f, s),   #  6
        tab(b, b, f, f, s),   #  7
        tab(b, f, f, b, s),   #  8
        tab(f, f, b, b, s),   #  9
        tab(f, b, b, f, s),   # 10
        tab(b, b, f, f, s),   # 11
        # Reverse:
        tab(b, b, f, f, z),   # 12
        tab(f, b, b, f, z),   # 13
        tab(f, f, b, b, z),   # 14
        tab(b, f, f, b, z),   # 15
        tab(b, b, f, f, z),   # 16
        tab(f, b, b, f, z),   # 17
        tab(f, f, b, b, z),   # 18
        tab(b, f, f, b, z),   # 19
        # Enough!
        # border
        tab(f, f, f, f, s),   # 20
        tab(b, b, b, b, s),   # 21
        tab(b, b, b, b, s)#   22
    ]
end

let
    initial_tablets = make_diamond_tablets()
    function rotation_plan(tablets, row_number, column_number)
        if row_number in 1:8
            Backward()
        elseif row_number in 9:24
            Forward()
        else
            nothing
        end
    end
    tablets = copy.(initial_tablets)
    top, bottom, instructions =
	tablet_weave(tablets, rotation_plan)
    pattern =
        TabletWeavingPattern("Diamond/Chevron Pattern",
                             nothing,
                             initial_tablets,
                             instructions,
                             tablets,
                             top, bottom)
    open(joinpath(@__DIR__, "diamond-chevron.html"), "w") do io
        write(io, string(pretty(pattern)))
    end
end
```

You can see the resulting HTML pattern file
[here](diamond-chevron.html).

