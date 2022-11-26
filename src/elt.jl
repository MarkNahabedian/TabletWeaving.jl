
# ╔═╡ 0baa4c77-bf7a-4d39-b964-d4636975f8fa
# XML.jl convenience function for making elements:
function elt(tag::String, stuff...)
    attributes = Dict{Symbol, String}()
    children = []
    for s in stuff
        if s isa Pair
            attributes[s.first] = string(s.second)
        elseif s isa AbstractString
            push!(children, s)
        elseif s isa Number
            push!(children, string(s))
        elseif s isa XML.Node
            push!(children, s)
        else
            error("unsupported XML content: $s")
        end
    end
    XML.Node(XML.ELEMENT_NODE, tag, attributes, children)
end

