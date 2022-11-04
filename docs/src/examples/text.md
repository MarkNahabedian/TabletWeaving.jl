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

# 0 is the background value in the font used by compose_line:
PADVALUE = 0

MESSAGE = color.(
  safe_vcat(AlignCenters(), 0,
            insert_between(
                compose_line.(["THIS IS",
                               "A TEST"]),
                fill(PADVALUE, 2, 1))))
```

It would look better with a border:

```@example 1
MESSAGE =
    let
        # MESSAGE has already been colored so our padding
        # needs to be colored too:
        background = color(PADVALUE)
        padding = fill(background, 2, 2)
        safe_vcat(AlignHeads(), background,
                  padding,
                  safe_hcat(AlignHeads(), background,
                            padding, MESSAGE, padding),
                  padding)
    end
```

How might it look woven:

```@example 1
WOVEN = 
    TabletWeavingPattern("Sample Text", MESSAGE;
                   	 threading_function = symetric_threading!)

HTML(string(pretty(WOVEN)))
```

