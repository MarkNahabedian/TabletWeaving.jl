using TabletWeaving
using TabletWeaving: WantColorChoice
using TabletWeaving: next, previous, opposite
using Test
using Colors

include("test_elt.jl")
include("test_composition.jl")
include("test_tablets.jl")

@testset "TabletWeaving.jl" begin
    graycode(x) = xor(x, x >>> 1)
    gray_sequence = [digits(graycode(x); base = 2, pad = 8) for x in 0:63]

    COLORS = [ RGB(1, 0, 0), RGB(0, 1, 0), RGB(0, 0, 1)]

    GRAY_PATTERN = map(hcat(gray_sequence...)) do bit
	COLORS[bit + 1]
    end

    GRAY_WEAVE = let
	# Reflect GRAY_PATTERN on both axes and add leading and trailing background:
	pattern = GRAY_PATTERN
	for _ in 1:4
	    pattern = hcat(pattern[:, 1], pattern)
	end
	bottom = hcat(pattern, reverse(pattern; dims=2))
	vcat(reverse(bottom; dims=1), bottom)
    end

    GRAY_TABLETS = let
	border_color = RGB(0.5, 0.5, 0.5)
	border1 = Tablet(
	    a=border_color,
	    b=border_color,
	    c=border_color,
	    d=border_color,
	    threading=BackToFront())
	border2 = Tablet(
	    a=border1.a,
	    b=border1.b,
	    c=border1.c,
	    d=border1.d,
	    threading=other(border1.threading))
	((2 * border1)
         + symetric_threading!(tablets_for_image(
	     longer_dimension_counts_weft(GRAY_WEAVE));
			       leftthreading=other(border1.threading))
         + (2 * border2))
    end


    @testset "csscolor" begin
        @test csscolor(Gray(0.5)) == "hsl(0deg, 0%, 50%)"
        @test csscolor(RGB(1, 0, 0)) == "rgb(255, 0, 0)"
    end

    @testset "Tablet structure tests" begin
        @test TabletEdge(4) + 1 == TabletEdge(3)
        @test TabletEdge(4) - 1 == TabletEdge(1)
        @test TabletEdge(4) + 2 == TabletEdge(4) - 2

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

        @test TabletWeaving.next_hole(TabletEdge(1)) == TabletHole('B')
        @test TabletWeaving.next_hole(TabletEdge(2)) == TabletHole('C')
        @test TabletWeaving.next_hole(TabletEdge(3)) == TabletHole('D')
        @test TabletWeaving.next_hole(TabletEdge(4)) == TabletHole('A')
        @test TabletWeaving.previous_hole(TabletEdge(1)) == TabletHole('A')
        @test TabletWeaving.previous_hole(TabletEdge(2)) == TabletHole('B')
        @test TabletWeaving.previous_hole(TabletEdge(3)) == TabletHole('C')
        @test TabletWeaving.previous_hole(TabletEdge(4)) == TabletHole('D')
    end

    @testset "Tablet rotation tests" begin
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=BackToFront())
            @test top_edge(bf) == TabletEdge(4)
	    @test bf.this_shot_rotation == 0
            @test top_edge(bf) == TabletEdge(4)
	    rotate!(bf, Rotation(ABCD(), 1))
	    @test bf.this_shot_rotation == 1
            shot!(bf)
            @test top_edge(bf) == TabletEdge(4) + 1
	    rotate!(bf, Rotation(DCBA(), 1))
	    @test bf.this_shot_rotation == -1
            shot!(bf)
            @test top_edge(bf) == TabletEdge(4) + (1 - 1)
        end
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=BackToFront())
	    rotate!(bf, Rotation(Clockwise(), 1))
	    @test bf.this_shot_rotation == 1
	    rotate!(bf, Rotation(CounterClockwise(), 1))
	    @test bf.this_shot_rotation == 0
	    
	    fb = Tablet(; a=:A, b=:B, c=:C, d=:D, threading=FrontToBack())
	    rotate!(fb, Rotation(Clockwise(), 1))
	    @test fb.this_shot_rotation == -1
	    rotate!(fb, Rotation(CounterClockwise(), 1))
	    @test fb.this_shot_rotation == 0

	    html"Clockwise and CounterClockwise rotate! assertions passed."
        end
        let
	    bf = Tablet(; a=:A, b=:B, c=:C, d=:D,
			threading=BackToFront(),
			stacking=FrontToTheRight())
	    rotate!(bf, Rotation(Forward(), 1))
	    @test bf.this_shot_rotation == 1
	    rotate!(bf, Rotation(Backward(), 1))
	    @test bf.this_shot_rotation == 0
	    
	    fb = Tablet(; a=:A, b=:B, c=:C, d=:D,
			threading=FrontToBack(),
			stacking=FrontToTheRight())
	    rotate!(fb, Rotation(Forward(), 1))
	    @test fb.this_shot_rotation == 1
	    rotate!(fb, Rotation(Backward(), 1))
	    @test fb.this_shot_rotation == 0

	    bf.stacking = FrontToTheLeft()
	    rotate!(bf, Rotation(Forward(), 1))
	    @test bf.this_shot_rotation == -1
	    rotate!(bf, Rotation(Backward(), 1))
	    @test bf.this_shot_rotation == 0
	    
	    fb.stacking = FrontToTheLeft()
	    rotate!(fb, Rotation(Forward(), 1))
	    @test fb.this_shot_rotation == -1
	    rotate!(fb, Rotation(Backward(), 1))
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

    @testset "want_color test" begin
        let
            tablet = Tablet(a=:A, b=:B, c=:C, d=:D)
            edge = top_edge(tablet)
            @assert edge == TabletEdge(4)
            @test TabletWeaving.want_color(tablet, :A) == [
                WantColorChoice(Rotation(Backward(), 1), -1, -1, next(edge))
            ]
            @test TabletWeaving.want_color(tablet, :B) == [
                WantColorChoice(Rotation(Backward(), 2), -2, -2, next(next(edge)))
            ]
            @test TabletWeaving.want_color(tablet, :C) == [
                WantColorChoice(Rotation(Forward(), 2), 2, 2, previous(previous((edge))))
            ]
            @test TabletWeaving.want_color(tablet, :D) == [
                WantColorChoice(Rotation(Forward(), 1), 1, 1, previous((edge)))
            ]
        end
        let
            # tablets_for_image alternates colors around the Tablet.
            tablet = Tablet(a=:X, b=:Y, c=:X, d=:Y)
            edge = top_edge(tablet)
            @assert edge == TabletEdge(4)
	    @test TabletWeaving.want_color(tablet, :X) == [
                WantColorChoice(Rotation(Forward(), 2), 2, 2, previous(previous(edge))),
                # Rotation(Forward(), 1) is the wrong color.
                WantColorChoice(Rotation(Backward(), 1), -1, -1, next(edge))
                # Rotation(Backward(), 2) is the wrong color.
            ]
	    @test TabletWeaving.want_color(tablet, :Y) == [
                # Rotation(Forward(), 2) is the wrong color.
                WantColorChoice(Rotation(Forward(), 1), 1, 1, previous(edge)),
                # Rotation(Backward(), 1) is the wrong color.
                WantColorChoice(Rotation(Backward(), 2), -2, -2, next(next((edge))))
            ]
        end
    end

end

using Logging

@testset "Composition" begin
    a = [ 1 2 3; 4 5 6]
    b = [7 8; 9 10; 11 12]

    @test size(TabletWeaving.padding(a, safe_hcat, 0, 0), 1)  == 0

    @test TabletWeaving.padding(a, safe_hcat, 2, 0) == [0 0 0; 0 0 0]

    @test (AlignHeads())(safe_hcat, a, 2, 0) ==
        [1 2 3; 4 5 6; 0 0 0; 0 0 0]
    @test (AlignTails())(safe_hcat, a, 2, 0) ==
        [0 0 0; 0 0 0; 1 2 3; 4 5 6]
    @test (AlignCenters())(safe_hcat, a, 2, 0) ==
        [0 0 0; 1 2 3; 4 5 6; 0 0 0]

    @test safe_hcat(AlignHeads(), 0, a, b) ==
        [
            1 2 3 7 8;
            4 5 6 9 10;
            0 0 0 11 12
        ]
    @test safe_hcat(AlignTails(), 0, a, b) ==
        [
            0 0 0 7 8;
            1 2 3 9 10;
            4 5 6 11 12
        ]

end

include("test_tablet_charts.jl")
include("test_weave.jl")

