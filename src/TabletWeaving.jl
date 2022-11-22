module TabletWeaving

using Parameters
using Colors
using DataStructures
using Markdown
using XML
using OrderedCollections
using LinearAlgebra

include("util.jl")
include("tablets.jl")
include("weave.jl")
include("pattern.jl")

include("elt.jl")
include("svg.jl")

include("tablet_charts.jl")
include("pretty.jl")

include("composition.jl")

include("image_data_uri.jl")
include("font-5x7.jl")

end

