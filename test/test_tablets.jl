
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
    tablet = Tablet(; a = Gray(0.2), b = Gray(0.4), c = Gray(0.6), d = Gray(0.8))
    @test warp_color(tablet, TabletHole('B')) == Gray(0.4)
    @test top_edge(tablet) == TabletEdge(4)
    counts = count_warp_colors(tablet)
    @test  length(counts) == 4
    for (color, count) in counts
        @test count == 1
    end
    counts = count_warp_colors(3 * tablet)
    @test  length(counts) == 4
    for (color, count) in counts
        @test count == 3
    end    
end

@testset "Tablet Arithmetic" begin
end

