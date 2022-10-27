```@meta
CurrentModule = TabletWeaving
```

# TabletWeaving

Documentation for [TabletWeaving](https://github.com/MarkNahabedian/TabletWeaving.jl).


## Tablets

A tablet or card is a square piece of card stock.

It has a front and a back.

It has a hole on each of it's four corners.

When looking at the front of the card, the holes are labeled **A**,
**B**, **C**, and **D** clockwise.

The edges of the card are numbered, with the edge from corner **A** to
corner **B** numbered **1**.  The edge between **B** and **C** numbered **2**,
and so on around the card.

For weaving, one warp thread passes through each hole.

The four warp threads for a tablet pass from the warp beam,
through the tablet, to the cloth beam.  They can pass through the
tablet from `BackToFront` or `FrontToBack`.

Which thread passes through which hole, and how the tablet is
threaded, can not change once the loom is warped.

It's easier to think about how the stitches are formed if the
tablets are facing (either back or front depending on threading)
the weaver.  For compactness though the cards are stacked so that
the weaver is facing their edges.  When stacked, each tablet can
be oriented FrontToTheRight or FrontToTheLeft.

Which direction a tablet is facing when it is stacked can be changed
during weaving.

For each new row, each tablet must be rotated, and its stacking may
be flipped.  These operations affect the locations of the labeled
holes (and their warp threads) relative to the loom.


### Tablet Threading

How the warp threads pass through a tablet, the `TabletThreading`, can either be
`BackToFront` or `FrontToBack`.

for `BackToFront` threading, warp threads pass from the warp beam through the
tablet from back to front and then to the cloth beam.

For `FrontToBack` threading, Warp threads pass from the warp beam through the
tablet from front to back and then to the cloth beam.

These threadings also have a concise textual representation.  `BackToFront` can
be represented by `/`or `z`.  `BackToFront` can be represented by `\\` or `s`.

```@docs
BackToFront
FrontToBack
threading_for_char
threading_char
```


### Tablet Stacking

If the tablets are arranged with a flat side facing the weaver this would take
too much space and also cause other inconveniences.  Instead, tablets are
arrahged so that their flat faces face each other.  This forms a horizontal
stack from one side of the loom to the other.

When stacked like this, a tablet is said to be stacked `FrontToTheRight` if
it's front face faces towards the right side of the loom rom the weaver's
perspective. A tablet facing the opposite direction is said to be threaded
`FrontToTheLeft`.

For brevity in textual representations, `FrontToTheRight` is represented with
a `→` right arrow and `FrontToTheLeft` with a `←` left arrow.

```@docs
TabletStacking
FrontToTheRight
FrontToTheLeft
tablet_stacking_to_char
```


```@index
```

```@autodocs
Modules = [TabletWeaving]
```

### Tablet

```@docs
Tablet
```

We use a `Vector` of `Tablet`s to describe how the loom is set up for
weaving.  for convenience, we can add these vectors together for a
wider pattern.  We can also multiply them to repeat tablets.

