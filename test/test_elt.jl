using XML

@testset "elt" begin
    e = TabletWeaving.elt("foo", "foobar", :class=>"x")
    @test XML.tag(e) == "foo"
    @test XML.attributes(e)["class"] == "x"
    @test length(XML.children(e)) == 1
    @test XML.value(XML.children(e)[1]) == "foobar"
end
