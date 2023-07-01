
using EzXML

@testset "Weaving and pretty output" begin
    color1 = RGB(1, 0, 0)
    color2 = RGB(0, 1, 0)
    image = [ color1 color1;
              color1 color2;
              color2 color1;
              color1 color2;
              color2 color1 ]
    pattern = TabletWeavingPattern("test", image;
                                   threading_function = symetric_threading!)
    doc = parsexml(XML.write(pretty(pattern)))
    plan = findfirst("//*[@id='plan']", doc)

    # row 0:
    @test nodecontent(findfirst("tr[1]/th", plan)) == "0"
    for t in findall("tr[1]/td", plan)
        @test nodecontent(t) == "4"   # all tablets start with edge 4 on top
    end

    # weaving steps:
    expected_steps = [ [ "B1" "B1" ],
                       [ "F4" "B2" ],
                       [ "F3" "B3" ],
                       [ "F2" "B4" ],
                       [ "F1" "B1" ] ]
    for (row, step) in enumerate(findall("tr[@class='step']", plan))
        # @test nodecontent(findfirst("th/text()", step)) == string(row)
        for (col, t) in enumerate(findall("td/text()", step))
            @test nodecontent(t) == expected_steps[row][col]
        end
    end

    # rotation statistics
    @test nodecontent.(findall("tr[th/text() = 'end']/td", plan)) == [ "3", "-5" ]
    @test nodecontent.(findall("tr[th/text() = 'min']/td", plan)) == [ "-1", "-5" ]
    @test nodecontent.(findall("tr[th/text() = 'max']/td", plan)) == [ "-1", "-5" ]
end

