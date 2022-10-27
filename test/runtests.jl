using TabletWeaving
using Test
using Colors

@testset "TabletWeaving.jl" begin

    @testset "Tablet Arithmetic" begin
        let
	    border_color = RGB(0.5, 0.5, 0.5)
	    border1 = Tablet(
		a=border_color,
		b=border_color,
		c=border_color,
		d=border_color,
		threading=BackToFront())

	    tplust = 2 * border1
	    @test tplust isa Vector{Tablet{<:Any}}
	    @test length(tplust) == 2

	    double = 2 * border1
	    @test double isa Vector{Tablet{<:Any}}
	    @test length(double) == 2

	    @test length(border1 + border1 + border1) == 3

	    @test length(2 * double) == 4

	    @test length(double + tplust) == 4

	    @test length(double + 3 * border1) == 5
        end

    end
end
