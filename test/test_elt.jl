
@testset "elt" begin
    e = TabletWeaving.elt("foo", "foobar", :class=>"x")
    @test e.tag == "foo"
    @test e.attributes[:class] == "x"
    @test length(e.children) == 1
    @test e.children[1] == "foobar"
end
