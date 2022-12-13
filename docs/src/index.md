```@meta
CurrentModule = TabletWeaving
```

# TabletWeaving

Documentation for [TabletWeaving](https://github.com/MarkNahabedian/TabletWeaving.jl).


```@contents
Pages = [ "index.md" ]
Depth = 6
```


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


### Tablet Structure

We represent each edge of a tablet by a `TabletEdge` and each hole by a
`TabletHole`:

```@docs
TabletHole
TabletEdge
```

The functions [`next`](@ref), [`previous`](@ref), and [`opposite`](@ref)
can be applied to a
`TabletHole` or a `TabletEdge` to get the next, previous, or opposite
one respectively.

```@docs
next
previous
opposite
next_hole
previous_hole
```


### Tablet Threading

How the warp threads pass through a tablet, the [`TabletThreading`](@ref),
can either be [`BackToFront`](@ref) or [`FrontToBack`](@ref).

for `BackToFront` threading, warp threads pass from the warp beam through the
tablet from back to front and then to the cloth beam.

For `FrontToBack` threading, Warp threads pass from the warp beam through the
tablet from front to back and then to the cloth beam.

These threadings also have a concise textual representation.  `BackToFront` can
be represented by `/` or `z`.  `FrontToBack` can be represented by `\\` or `s`.

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
it's front face faces towards the right side of the from the weaver's
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


### Tablet

```@docs
Tablet
warp_color
top_edge
```

We use a `Vector` of `Tablet`s to describe how the loom is set up for
weaving.  for convenience, we can add these vectors together for a
wider pattern.  We can also multiply them to repeat tablets.



### Tablet Rotation

Prior to each new throw of the weft, the tablets are rotated to
open a new shed.

In practice (the stacked arrangement), a card will be rotated
**forward** or **backward**.  Forward rotation moves the top
corner of the card closest to the weaver away from the weaver
towards the warp beam.  Backward rotation moves the top corner
furthest from the weaver toards the weaver.

Whether **forward** rotation turns the card in the **ABCD** or the 
**DCBA** direction depends on how the card is threaded and stacked.

```@docs
RotationDirection
rotation
ABCD
DCBA
Clockwise
CounterClockwise
Forward
Backward
```

## Weaving

To weave, the weaver first rotates the tablets according to some
pattern.  Rotating the tablets opens a new shed.  The shuttle is then
passed through the new shed to finish weaving that row.

```@docs
rotate!
shot!  
```

### Stitch Slant

Rotation of a tablet introduces twist int o the four threads passing
through that tablet.  That twist is locked in by the next weft thread.
The twist causes one thread to cross over each surface and two threads
to pass through from front to back or back to front.  The stitches
that cross over the front or back surface of the woven fabric will
appear slightly slanted.  We need vocabulary to describe the directions
of those slants.

```@docs
StitchSlant
SStitch
ZStitch
stitch_slant_to_char
stitch_slant_for_char
```


## Describing a Pattern

How should we describe tablet motion during weaving?

After each throw, each tablet must be rotated **forward** or
**backward** to make a new shed.  In the simplest patterns, all
tablets are rotated in the same direction.  For more complicated patterns
however, tablets move in different directions for each shed.  How can
we represent these rotations for ease of execution by the weaver?

There is one set of tablet motions for each throw of the shuttle.  We
should have a row number.  The weaver must keep track of which row
they're working.

There is motion for each tablet.  The motion of a single tablet can be
concisely described by unicode arrows (🡑, 🡓) or by the edge number of
the tablet that is facing the shed or on top.  The latter is less
error prone since an incorrect starting position for a tablet will be
detected.

The simplest representation is a `Vector` for the whole pattern.  Each
element would be a `Vector` of digits from `1` to `4` indicating the
edge of the tablet that's currently "on top".


## Designing a Pattern

### Simple Patterns

```@docs
simple_rotation_plan
f4b4_rotation_plan
```

### Going from an Image to a Pattern

We have an array of the "image" we want to weave.  How do we translate
that into a set of tablets, their warping, and their motions?

How do we execute that "plan" to produce a stitch image to see how the
pattern turned out.

For a two color pattern, we can warp each tablet with one color in
holes **A** and **C** and the other in holes **B** and **D**.
Whatever the previous stitch, the tablet can be rotated to either
color.  The slant of the stitch can't be controlled though.

```@docs
tablets_for_image
```

`tablets_for_image` does nothing about tablet threading, only colors.

The tablet weaving patterns I've seen all seem to have one threading
on one side of the pattern and another threading on the other side,
with the possible exception of the borders having different threading
from the field.

We can introduce a function that sets one threading from the edge to
the middle and switches to the other threading for the other half.

```@docs
symetric_threading!
alternating_threading!
```

```@docs
TabletWeavingPattern
```

## Composition

We might want to combine a number of graphical elements in our weaving
design.  Some utilities are provided to support this.

[`safe_hcat`](@ref) and [`safe_vcat`](@ref) can be used to combine multiple images
horizontally or vertically.  These are just instances of (an
instantiable subtype of) [`SwatchComposer`](@ref).

```@docs
SwatchComposer
HorizontalComposer
safe_hcat
VerticalComposer
safe_vcat
SwatchAlignment
AlignHeads
AlignCenters
AlignTails
insert_between
```

## Text

A simple dot matrix font is provided so that we can include text in
our designs.

```@docs
compose_line
FONT_5x7
```

## Everything Else

```@docs
svg_stitch
other
csscolor
count_warp_colors
chart_tablets
want_color
tablet_weave
chart_tablet
longer_dimension_counts_weft
TabletThreading
```

## Index

```@index
```

