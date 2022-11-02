# Functions for juxtaposing pieces of a design

export SwatchAlignment, AlignHeads, AlignCenters, AlignTails
export safe_hcat, safe_vcat, blank_swatch, insert_between

blank_swatch(v) = fill(v, 1, 1)

abstract type SwatchComposer end

abstract type SwatchAlignment end
struct AlignHeads <: SwatchAlignment end
struct AlignCenters <: SwatchAlignment end
struct AlignTails  <: SwatchAlignment end

function padding(swatch, c::SwatchComposer, add, padvalue)
    @assert add >= 0
    s = collect(size(swatch))
    s[padAxis(c)] = add
    fill(padvalue, s...)
end


"""
    (::SwatchAlignment)(::SwatchComposer, swatch::Array{Any, 2}, add,
                        padvalue)

Add padding to `swatch` so that its sice will be compatible with 
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


struct HorizontalComposer <: SwatchComposer end
struct VerticalComposer <: SwatchComposer end

safe_hcat = HorizontalComposer()
safe_vcat = VerticalComposer()

compositionAxis(::HorizontalComposer) = 2
compositionAxis(::VerticalComposer) = 1

padAxis(::HorizontalComposer) = 1
padAxis(::VerticalComposer) = 2

composecat(::HorizontalComposer) = hcat
composecat(::VerticalComposer) = vcat

padcat(::HorizontalComposer) = vcat
padcat(::VerticalComposer) = hcat

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

