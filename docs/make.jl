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
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/TabletWeaving.jl",
    devbranch="master",
)
