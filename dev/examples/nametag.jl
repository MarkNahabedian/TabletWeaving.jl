
using Pkg
Pkg.activate(abspath(joinpath(@__DIR__, "../../Project.toml")))

using ArgParse
using Colors
using TabletWeaving

FOREGROUND::Color = RGB(1.0, 0.0, 0.0)
BACKGROUND::Color = RGB(0.0, 1.0, 0.0)


THREADING = Dict{String, Function}(
    "symetric" => symetric_threading!,
    "alternating" => alternating_threading!
)

COLOR_PARSERS = Dict{AbstractString, Function}(
    "RGB" => function parse_RGB(params::AbstractString)
        s = split(params, " ")
        if length(s) != 3
            error("Thh RGB color format expects three decimal fraction parameters separated by spaces.")
        end
        s = map(s) do v
            parse(Float16, v)
        end
        RGB(s...)
    end,
    "Gray" => function parse_Gray(params::AbstractString)
        Gray(parse(Float16, params))
    end
)

argparse_settings = ArgParseSettings()

@add_arg_table! argparse_settings begin
    "--output", "-o"
    help = "File to output HTML to"
    arg_type = AbstractString
    default = "nametag.html"

    "--foreground"
    help = "The foreground color, as a string.  Supported color constructors: $(join(keys(COLOR_PARSERS), ", "))."
    arg_type = Color
    default = FOREGROUND
 
    "--background"
    help = "The background color, as a string.  Supported color constructors: $(join(keys(COLOR_PARSERS), ", "))."
    arg_type = Color
    default = BACKGROUND

    "--threading"
    help = "How the tablets should be threaded, one of: $(join(keys(THREADING), ", "))."
    arg_type = String
    default = first(keys(THREADING))

    "--end_wefts"
    help = "How many rows of background color before and after the text"
    arg_type = Int
    default = 0

    "name"
    help = "The text to be woven"
    arg_type = AbstractString    
end

string_to_glyphs(s::AbstractString)::Vector =
    [ FONT_5x7[c]
      for c in s ]

colorize(pixel::UInt8) =
    pixel == 0 ? BACKGROUND : FOREGROUND

const COLOR_REGEXP = r"(?<CTYPE>[^(]+)[(](?<PARAMS>[^)]*)[)]"

let
    m = match(COLOR_REGEXP, "RGB(0.5 1.0 0)")
    @assert m["CTYPE"] == "RGB"
    @assert m["PARAMS"] == "0.5 1.0 0"
end

function ArgParse.parse_item(::Type{C}, arg::AbstractString) where C <: Color
    m = match(COLOR_REGEXP, arg)
    if m === nothing
        error("$arg is not a valid color specifier")
    end
    ctype = m["CTYPE"]
    parser = get(COLOR_PARSERS, ctype, nothing)
    if parser === nothing
        error("$ctype is not a recognized color format. Supported formats: $(keys(COLOR_PARSERS))")
    end
    parser(m["PARAMS"])
end

let
    c = ArgParse.parse_item(Color, "RGB(1.0 0.2 0)")
    @assert c == RGB{Float16}(1.0, 0.2, 0.0)
end

function main()
    parsed_args = parse_args(argparse_settings)
    global FOREGROUND = parsed_args["foreground"]
    global BACKGROUND = parsed_args["background"]
    text = parsed_args["name"]
    # Image of vertically oriented text:
    image = safe_vcat(AlignCenters(),
		      UInt8(0),
		      insert_between(string_to_glyphs(text),
                                     fill(UInt8(0), 1, 1))...)
    # Add right and left borders:
    image = safe_hcat(AlignHeads(), UInt8(0),
		      fill(UInt8(0), 2, 2),
                      image,
		      fill(UInt8(0), 2, 2))
    # Add top and bottom borders:
    ends = fill(UInt8(0), parsed_args["end_wefts"], size(image, 2))
    image = safe_vcat(AlignHeads(), UInt8(0),
                      ends, image, ends)
    image = colorize.(image)
    w = TabletWeavingPattern("nametag: $text", image;
                             threading_function = THREADING[parsed_args["threading"]])
    outfile = parsed_args["output"]
    open(outfile, "w") do io
        write(io, string(pretty(w)))
    end
    println("Weaving instructions written to $(abspath(outfile)).")
end

main()

