We could weave text.

I found a 5×7 dot matrix font that might be used to weave text.

```@example 1
using Colors
using TabletWeaving

color(bit) = [ RGB(1, 1, 1), RGB(0, 0, 0) ][bit + 1]

color.(compose_line("HELLO!"))
```

We can also compose multiple lines:

```@example 1
using Base.Iterators

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

