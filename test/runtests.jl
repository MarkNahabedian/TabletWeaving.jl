using TabletWeaving
using Test
using Colors

@testset "TabletWeaving.jl" begin

    @testset "Tablet structure tests" begin
	for hole in TabletHole.(TABLET_HOLE_LABELS)
	    @test next(previous(hole))== hole
	    @test previous(next(hole)) == hole
	    @test opposite(opposite(hole)) == hole
	end
	
	for edge in TabletEdge.(TABLET_EDGE_LABELS)
	    @test next(previous(edge))== edge
	    @test previous(next(edge)) == edge
	    @test opposite(opposite(edge)) == edge
	end
    end

    @testset "Tablet rotation tests" begin
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=BackToFront())
	    rotate!(bf, ABCD())
	    @test bf.this_shot_rotation == 1
	    rotate!(bf, DCBA())
	    @test bf.this_shot_rotation == 0
        end
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=BackToFront())
	    rotate!(bf, Clockwise())
	    @assert bf.this_shot_rotation == 1
	    rotate!(bf, CounterClockwise())
	    @assert bf.this_shot_rotation == 0
	    
	    fb = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=FrontToBack())
	    rotate!(fb, Clockwise())
	    @assert fb.this_shot_rotation == -1
	    rotate!(fb, CounterClockwise())
	    @assert fb.this_shot_rotation == 0

	    html"Clockwise and CounterClockwise rotate! assertions passed."
        end
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D,
			threading=BackToFront(),
			stacking=FrontToTheRight())
	    rotate!(bf, Forward())
	    @test bf.this_shot_rotation == 1
	    rotate!(bf, Backward())
	    @test bf.this_shot_rotation == 0
	    
	    fb = Tablet(; a=:A, b=:B, c=:C, d=:D,
			threading=FrontToBack(),
			stacking=FrontToTheRight())
	    rotate!(fb, Forward())
	    @test fb.this_shot_rotation == 1
	    rotate!(fb, Backward())
	    @test fb.this_shot_rotation == 0

	    bf.stacking = FrontToTheLeft()
	    rotate!(bf, Forward())
	    @test bf.this_shot_rotation == -1
	    rotate!(bf, Backward())
	    @test bf.this_shot_rotation == 0
	    
	    fb.stacking = FrontToTheLeft()
	    rotate!(fb, Forward())
	    @test fb.this_shot_rotation == -1
	    rotate!(fb, Backward())
	    @test fb.this_shot_rotation == 0
        end
    end

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
