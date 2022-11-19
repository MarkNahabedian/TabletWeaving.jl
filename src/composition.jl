# Functions for juxtaposing pieces of a design

export SwatchAlignment, AlignHeads, AlignCenters, AlignTails
export SwatchComposer, HorizontalComposer, VerticalComposer
export safe_hcat, safe_vcat, blank_swatch, insert_between
export compose_line

blank_swatch(v) = fill(v, 1, 1)

abstract type SwatchComposer end


"""
    SwatchAlignment

An abstract supertype whose concrete instances are used to control the
alignment of swatches that are being composed by `safe_hcat` or
`safe_vcat`.

The three supported alignment types are
[`AlignHeads`](#ref),
[`AlignCenters`](#ref), and
[`AlignTails`](#ref),
"""
abstract type SwatchAlignment end


"""
    AlignHeads

An instantiable subtype of [`SwatchAlignment`](#ref) that aligns the
left or top edges of graphical elements when `safe_hcat` or
`safe_vcat` is used.  Padding is adddeed after the swatctch as needed.
"""
struct AlignHeads <: SwatchAlignment end


"""
    AlignCenters

An instantiable subtype of [`SwatchAlignment`](#ref) that aligns the
centers of graphical elements when `safe_hcat` or
`safe_vcat` is used.  Padding is added both before and after the swatch
as needed.
"""
struct AlignCenters <: SwatchAlignment end


"""
    AlignTails

An instantiable subtype of [`SwatchAlignment`](#ref) that aligns the
right or bottom edges of graphical elements when `safe_hcat` or
`safe_vcat` is used.  Padding is added before the swatch as needed.
"""
struct AlignTails <: SwatchAlignment end


function padding(swatch, c::SwatchComposer, add, padvalue)
    @assert add >= 0
    s = collect(size(swatch))
    s[padAxis(c)] = add
    fill(padvalue, s...)
end


"""
    (::SwatchAlignment)(::SwatchComposer, swatch::Array{Any, 2}, add,
                        padvalue)

Add padding to `swatch` so that its size will be compatible with 
those of other swatches when performing the SwatchComposer.
`add` is the number of rows or columns to be added to `swatch`.
The value of each element added in the padding is specified by `padvalue`.
"""
function (::SwatchAlignment) end


function (::AlignHeads)(c::SwatchComposer, swatch, add, padvalue)
    (padcat(c))(swatch,
                padding(swatch, c, add, padvalue))
end

function (::AlignTails)(c::SwatchComposer, swatch, add, padvalue)
    (padcat(c))(padding(swatch, c, add, padvalue),
                swatch)
end

function (::AlignCenters)(c::SwatchComposer, swatch, add, padvalue)
    f = floor(Int, add / 2)
    (padcat(c))(padding(swatch, c, f, padvalue),
                swatch,
                padding(swatch, c, add - f, padvalue))
end


"""
    HorizontalComposer

Juxtaposes the swarches horizontally, along the length of the warp.
See [`safe_hcat`](@ref).
"""
struct HorizontalComposer <: SwatchComposer end


"""
    VerticalComposer

Juxtaposes the swarches vertically, across the width of the warp.
See [`safe_vcat`](@ref).
"""
struct VerticalComposer <: SwatchComposer end

"""
    safe_hcat

safe_hcat is an alias for calling a [`HorizontalComposer`](@ref).
"""
safe_hcat = HorizontalComposer()

"""
    safe_vcat

safe_vcat is an alias for calling a [`VerticalComposer`](@ref).
"""
safe_vcat = VerticalComposer()

compositionAxis(::HorizontalComposer) = 2
compositionAxis(::VerticalComposer) = 1

padAxis(::HorizontalComposer) = 1
padAxis(::VerticalComposer) = 2

composecat(::HorizontalComposer) = hcat
composecat(::VerticalComposer) = vcat

padcat(::HorizontalComposer) = vcat
padcat(::VerticalComposer) = hcat

"""
    (::SwatchComposer)(align::SwatchAlignment,
                       padvalue, swatches)

Return a single two dimensional array composed by juxtaposing the
swatches according to `align`.  Swatches that are not compatible in
size are padded with `padvalue`.

`HorizontalComposer` composes the swatches horizontally -- along the
length of the warp.  [`safe_hcat`](@ref) is an alias for this composer.

`VerticalComposer` composes the swatches vertically -- across the
width of the warp.  [`safe_vcat`](@ref) is an alias for this composer.
"""
function (c::SwatchComposer)(align::SwatchAlignment,
                             padvalue, swatches)
    # How much do we need on padaxis
    sz(x) = size(x, padAxis(c))
    need = maximum(sz, (swatches))
    (composecat(c))(map(swatches) do swatch
                        align(c, swatch,  need - sz(swatch), padvalue)
                    end...)
end

function (c::SwatchComposer)(align::SwatchAlignment,
                             padvalue, swatches...)
    c(align, padvalue, swatches)
end


"""
    insert_between(swatches, between)

Intersperse `between` among `swatches`.

`swatches` is a vector of 2 dimenswional arrays that will be part of a
tablet weaving pattern.  A new vector is returned with `between`
inserted between each two adjacent arrays from `swatches`.

Suitable for adding spacing between letters or lines of text, but can
also be used to add spacing between arbitrary graphical elements.
"""
function insert_between(swatches, between)
    result = []
    for swatch in swatches
        if length(result) > 0
            push!(result, between)
        end
        push!(result, swatch)
    end
    result
end


"""
    compose_line(line)

Return a bit image from a line of text.  Uses the [`FONT_5x7`](@ref)
font.
"""
function compose_line(line)
    dotmatrix(c) = FONT_5x7[c]
    safe_hcat(AlignCenters(), UInt8(0),
              insert_between(
                  # render characters in font:
                  dotmatrix.(collect(line)),
                  # One "pixel" spacing between characters:
                  blank_swatch(UInt8(0))))
end
