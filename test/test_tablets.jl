
@testset "Tablet Threading" begin
    @test other(BackToFront()) == FrontToBack()
    @test other(FrontToBack()) == BackToFront()
    @test threading_for_char('/') == BackToFront()
    @test threading_for_char('z') == BackToFront()
    @test threading_for_char('Z') == BackToFront()
    @test threading_for_char('\\') == FrontToBack()
    @test threading_for_char('s') == FrontToBack()
    @test threading_for_char('S') == FrontToBack()
    @test threading_for_char(threading_char(BackToFront())) == BackToFront()
    @test threading_for_char(threading_char(FrontToBack())) == FrontToBack()
end

@testset "Tablet Stacking" begin
    @test other(FrontToTheRight()) == FrontToTheLeft()
    @test other(FrontToTheLeft()) == FrontToTheRight()
end

@testset "Tablet" begin
    tablet = Tablet(; a = Gray(0.2), Gray(0.4), Gray(0.6), Gray(0.8))
    @test count_warp_colors(tablet) == 4
    @test warp_color(tablet, TabletHole('B')) == Gray(0.4)
    @test top_edge(tablet) == TabletEdge(4)
end

@testset "Tablet Arithmetic" begin
end

