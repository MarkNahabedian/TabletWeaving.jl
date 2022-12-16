
using Base.Iterators: drop, cycle, zip
using TabletWeaving: elt
using XML

TEST_TABLET_CHARTS_EXPECTED =
    elt("svg",
	:xmlns => "http://www.w3.org/2000/svg",
	:width => "95%",
        elt("svg", :xmlns=>"http://www.w3.org/2000/svg",
            (elt("g",
                 elt("rect", :x=>"0mm", :y=>"0mm", :stroke=>"gray", :height=>"5mm",
                     :fill=>"hsl(0deg, 0%, 20%)", :width=>"5mm"),
                 elt("rect", :x=>"0mm", :y=>"5mm", :stroke=>"gray", :height=>"5mm",
                     :fill=>"hsl(0deg, 0%, 40%)", :width=>"5mm"),
                 elt("rect", :x=>"0mm", :y=>"10mm", :stroke=>"gray", :height=>"5mm",
                     :fill=>"hsl(0deg, 0%, 60%)", :width=>"5mm"),
                 elt("rect", :x=>"0mm", :y=>"15mm", :stroke=>"gray", :height=>"5mm",
                     :fill=>"hsl(0deg, 0%, 80%)", :width=>"5mm"),
                 elt("line", :stroke=>"gray", :y1=>"20mm", :x2=>"5mm", :strokeWidth=>"3px",
                     :y2=>"25mm", :x1=>"0mm"))
             )),
        elt("svg", :xmlns=>"http://www.w3.org/2000/svg",
            elt("g",
                elt("rect", :x=>"5mm", :y=>"0mm", :stroke=>"gray", :height=>"5mm",
                    :fill=>"hsl(0deg, 0%, 60%)", :width=>"5mm"),
                elt("rect", :x=>"5mm", :y=>"5mm", :stroke=>"gray", :height=>"5mm",
                    :fill=>"hsl(0deg, 0%, 80%)", :width=>"5mm"),
                elt("rect", :x=>"5mm", :y=>"10mm", :stroke=>"gray", :height=>"5mm",
                    :fill=>"hsl(0deg, 0%, 20%)", :width=>"5mm"),
                elt("rect", :x=>"5mm", :y=>"15mm", :stroke=>"gray", :height=>"5mm",
                    :fill=>"hsl(0deg, 0%, 40%)", :width=>"5mm"),
                elt("line", :stroke=>"gray", :y1=>"20mm", :x2=>"5mm", :strokeWidth=>"5px",
                    :y2=>"25mm", :x1=>"10mm"))))

function node_equal(a::XML.Node, b::XML.Node)
    function attrs_equal(a1, a2)
        if a1 == nothing && a2 == nothing
            return true
        end
        if a1 == nothing || a2 == nothing
            return false
        end
        for key in union(keys(a1), keys(a2))
            if get(a1, key, nothing) != get(a2, key, nothing)
                return false
            end
        end
        return true
    end
    a.type == b.type &&
        a.tag == b.tag &&
        attrs_equal(a.attributes, b.attributes) &&
        a.children == b.children
end
         
@testset "Tablet charts" begin
    colors(shift) = Dict(
        map(zip(drop(cycle(Symbol.('a':1:'d')), shift),
                [Gray(Float16(x)) for x in 0.2:0.2:0.8])
            ) do z
                (hole, color) = z
                hole => color
            end)
    tablets =
        Tablet(; colors(0)..., threading=BackToFront()) +
        Tablet(; colors(2)..., threading=FrontToBack())
    chart = chart_tablets(tablets)
    @test node_equal(chart, TEST_TABLET_CHARTS_EXPECTED)
end
