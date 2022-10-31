using TabletWeaving
using Documenter

DocMeta.setdocmeta!(TabletWeaving, :DocTestSetup, :(using TabletWeaving); recursive=true)

makedocs(;
    modules=[TabletWeaving],
    authors="MarkNahabedian <naha@mit.edu> and contributors",
    repo="https://github.com/MarkNahabedian/TabletWeaving.jl/blob/{commit}{path}#{line}",
    sitename="TabletWeaving.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MarkNahabedian.github.io/TabletWeaving.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => Any[
            "Simple Example" => "examples/simple_chevron.md",
            "From an Image" => "examples/from_an_image.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/TabletWeaving.jl",
    devbranch="main",
)
