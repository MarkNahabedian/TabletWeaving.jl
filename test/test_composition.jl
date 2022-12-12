
@testset "composition" begin
    composed = compose_line("ABCD")
    @test typeof(composed) == Matrix{UInt8}
    @test size(composed) == (7, 23)

    blank = blank_swatch(UInt8(0))
    two_lines = safe_vcat(AlignCenters(), UInt8(0),
                          [ blank, blank,
                            compose_line("AB"),
                            blank, blank,
                            compose_line("CDE"),
                            blank, blank,])
    @test typeof(two_lines) == Matrix{UInt8}
    @test size(two_lines) == ((2 * 7 + 3 * 2), (3 * 5 + 2))
end
