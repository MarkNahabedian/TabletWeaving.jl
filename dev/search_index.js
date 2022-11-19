var documenterSearchIndex = {"docs":
[{"location":"examples/simple_chevron/","page":"Simple Example","title":"Simple Example","text":"Here's a simple pattern, found at http://research.fibergeek.com/2002/10/10/first-tablet-weaving-double-diamonds/","category":"page"},{"location":"examples/simple_chevron/","page":"Simple Example","title":"Simple Example","text":"using Colors\nusing TabletWeaving\n\n# A function for setting up tablets to weave a simple symetric\n# diagonal line pattern that can weave chevrons or diamonds:\nfunction make_diamond_tablets()\n    f = RGB(0.0, 0.8, 0.0)\n    b = RGB(0.6, 0.3, 0.3)\n    id = 0  \n    function tab(a, b, c, d, threading)\n        id += 1\n        Tablet{Color}(; id=id, a=a, b=b, c=c, d=d, threading=threading)\n    end\n    s = threading_for_char('s')\n    z = threading_for_char('z')\n    [\n        # Border:\n        tab(b, b, b, b, z),   #  1\n        tab(b, b, b, b, z),   #  2\n        tab(f, f, f, f, z),   #  3\n        # Pattern:\n        tab(b, f, f, b, s),   #  4\n        tab(f, f, b, b, s),   #  5\n        tab(f, b, b, f, s),   #  6\n        tab(b, b, f, f, s),   #  7\n        tab(b, f, f, b, s),   #  8\n        tab(f, f, b, b, s),   #  9\n        tab(f, b, b, f, s),   # 10\n        tab(b, b, f, f, s),   # 11\n        # Reverse:\n        tab(b, b, f, f, z),   # 12\n        tab(f, b, b, f, z),   # 13\n        tab(f, f, b, b, z),   # 14\n        tab(b, f, f, b, z),   # 15\n        tab(b, b, f, f, z),   # 16\n        tab(f, b, b, f, z),   # 17\n        tab(f, f, b, b, z),   # 18\n        tab(b, f, f, b, z),   # 19\n        # Enough!\n        # border\n        tab(f, f, f, f, s),   # 20\n        tab(b, b, b, b, s),   # 21\n        tab(b, b, b, b, s)#   22\n    ]\nend\n\nlet\n    initial_tablets = make_diamond_tablets()\n    function rotation_plan(tablets, row_number, column_number)\n        if row_number in 1:8\n            Backward()\n        elseif row_number in 9:24\n            Forward()\n        else\n            nothing\n        end\n    end\n    tablets = copy.(initial_tablets)\n    top, bottom, instructions =\n\ttablet_weave(tablets, rotation_plan)\n    pattern =\n        TabletWeavingPattern(\"Diamond/Chevron Pattern\",\n                             nothing,\n                             initial_tablets,\n                             instructions,\n                             tablets,\n                             top, bottom)\n    HTML(string(pretty(pattern)))\nend","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"We can turn a two color image into a tablet weaving pattern.","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"First we need an image.  I was playing around with the idea of visualizing \"Gray Code\" in a weaving project.  Gray Code is a way of counting in binary where only one bit changes on each count.","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"We can use it to make an image, described by a two domensional Julia Array of RGB colors:","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"using Colors\nusing TabletWeaving\n\n# Turn a regular binary number to its corresponding Gray Code :\ngraycode(x) = xor(x, x >>> 1)\n\n# Weneed two colors for our image:\nCOLORS = [ RGB(1, 0, 0), RGB(0, 1, 0)]\n\ngray_sequence = [digits(graycode(x); base = 2, pad = 8) for x in 0:63]\n\n# Our basic Gray Code pattern:\nGRAY_PATTERN = map(hcat(gray_sequence...)) do bit\n\tCOLORS[bit + 1]\nend","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"I like that, but I think it would be cooler if it were reflected on both axes:","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"GRAY_WEAVE = let\n\t# Reflect GRAY_PATTERN on both axes and add leading and trailing background:\n\tpattern = GRAY_PATTERN\n\tfor _ in 1:4\n\t\tpattern = hcat(pattern[:, 1], pattern)\n\tend\n\tbottom = hcat(pattern, reverse(pattern; dims=2))\n\tvcat(reverse(bottom; dims=1), bottom)\nend","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"I like that.  How do I weave it.  This will show us the pattern:","category":"page"},{"location":"examples/from_an_image/","page":"From an Image","title":"From an Image","text":"WOVEN_GRAY_PATTERN = \n                   TabletWeavingPattern(\"Gray Code Pattern\", GRAY_WEAVE;\n                   \tthreading_function = symetric_threading!)\n\nHTML(string(pretty(WOVEN_GRAY_PATTERN)))","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = TabletWeaving","category":"page"},{"location":"#TabletWeaving","page":"Home","title":"TabletWeaving","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for TabletWeaving.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pages = [ \"index.md\" ]\nDepth = 6","category":"page"},{"location":"#Tablets","page":"Home","title":"Tablets","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A tablet or card is a square piece of card stock.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It has a front and a back.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It has a hole on each of it's four corners.","category":"page"},{"location":"","page":"Home","title":"Home","text":"When looking at the front of the card, the holes are labeled A, B, C, and D clockwise.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The edges of the card are numbered, with the edge from corner A to corner B numbered 1.  The edge between B and C numbered 2, and so on around the card.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For weaving, one warp thread passes through each hole.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The four warp threads for a tablet pass from the warp beam, through the tablet, to the cloth beam.  They can pass through the tablet from BackToFront or FrontToBack.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Which thread passes through which hole, and how the tablet is threaded, can not change once the loom is warped.","category":"page"},{"location":"","page":"Home","title":"Home","text":"It's easier to think about how the stitches are formed if the tablets are facing (either back or front depending on threading) the weaver.  For compactness though the cards are stacked so that the weaver is facing their edges.  When stacked, each tablet can be oriented FrontToTheRight or FrontToTheLeft.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Which direction a tablet is facing when it is stacked can be changed during weaving.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For each new row, each tablet must be rotated, and its stacking may be flipped.  These operations affect the locations of the labeled holes (and their warp threads) relative to the loom.","category":"page"},{"location":"#Tablet-Structure","page":"Home","title":"Tablet Structure","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We represent each edge of a tablet by a TabletEdge and each hole by a TabletHole:","category":"page"},{"location":"","page":"Home","title":"Home","text":"TabletHole\nTabletEdge","category":"page"},{"location":"#TabletWeaving.TabletHole","page":"Home","title":"TabletWeaving.TabletHole","text":"A TabletHole represents one of the corner holes in a tablet.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.TabletEdge","page":"Home","title":"TabletWeaving.TabletEdge","text":"A TabletEdge represents a single edge of a tablet.\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"The functions next, previous, and opposite can be applied to a TabletHole or a TabletEdge to get the next, previous, or opposite one respectively.","category":"page"},{"location":"","page":"Home","title":"Home","text":"next\nprevious\nopposite\nnext_hole\nprevious_hole","category":"page"},{"location":"#TabletWeaving.next","page":"Home","title":"TabletWeaving.next","text":"next(::TabletHole)::TabletHole\nnext(::TabletEdge)::TabletEdge\n\nReturn the next hole or edge from the argument,  clockwise around a tablet.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.previous","page":"Home","title":"TabletWeaving.previous","text":"previous(::TabletHole)::TabletHole\nprevious(::TabletEdge)::TabletEdge\n\nReturn the previous hole or edge from the argument,  counterclockwise around a tablet.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.opposite","page":"Home","title":"TabletWeaving.opposite","text":"opposite(::TabletHole)::TabletHole\nopposite(::TabletEdge)::TabletEdge\n\nReturn the opposite hole or edge from the argument.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.next_hole","page":"Home","title":"TabletWeaving.next_hole","text":"next_hole(::TabletEdge)\n\nReturn the hole following the specified edge.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.previous_hole","page":"Home","title":"TabletWeaving.previous_hole","text":"previous_hole(::TabletEdge)\n\nReturn the hole preceeding the specified edge.\n\n\n\n\n\n","category":"function"},{"location":"#Tablet-Threading","page":"Home","title":"Tablet Threading","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"How the warp threads pass through a tablet, the TabletThreading, can either be BackToFront or FrontToBack.","category":"page"},{"location":"","page":"Home","title":"Home","text":"for BackToFront threading, warp threads pass from the warp beam through the tablet from back to front and then to the cloth beam.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For FrontToBack threading, Warp threads pass from the warp beam through the tablet from front to back and then to the cloth beam.","category":"page"},{"location":"","page":"Home","title":"Home","text":"These threadings also have a concise textual representation.  BackToFront can be represented by / or z.  FrontToBack can be represented by \\\\ or s.","category":"page"},{"location":"","page":"Home","title":"Home","text":"BackToFront\nFrontToBack\nthreading_for_char\nthreading_char","category":"page"},{"location":"#TabletWeaving.BackToFront","page":"Home","title":"TabletWeaving.BackToFront","text":"Warp threads pass from the warp beam through the tablet from back to front.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.FrontToBack","page":"Home","title":"TabletWeaving.FrontToBack","text":"Warp threads pass from the warp beam through the tablet from front to back.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.threading_for_char","page":"Home","title":"TabletWeaving.threading_for_char","text":"threading_for_char(::AbstractChar)\n\nGiven an 's' or a 'z', return an instance of the the corresponding TabletThreading.\n\nThere seems to be some confusion in the tablet weaving community about which is which.  In this code base, 'z' corresponds to BackToFront threading.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.threading_char","page":"Home","title":"TabletWeaving.threading_char","text":"threading_char(::TabletThreading)\n\nReturn the character ('s' or 'z' corresponding to the specified tablet threading.  See threading_for_char.\n\n\n\n\n\n","category":"function"},{"location":"#Tablet-Stacking","page":"Home","title":"Tablet Stacking","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If the tablets are arranged with a flat side facing the weaver this would take too much space and also cause other inconveniences.  Instead, tablets are arrahged so that their flat faces face each other.  This forms a horizontal stack from one side of the loom to the other.","category":"page"},{"location":"","page":"Home","title":"Home","text":"When stacked like this, a tablet is said to be stacked FrontToTheRight if it's front face faces towards the right side of the from the weaver's perspective. A tablet facing the opposite direction is said to be threaded FrontToTheLeft.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For brevity in textual representations, FrontToTheRight is represented with a → right arrow and FrontToTheLeft with a ← left arrow.","category":"page"},{"location":"","page":"Home","title":"Home","text":"TabletStacking\nFrontToTheRight\nFrontToTheLeft\ntablet_stacking_to_char","category":"page"},{"location":"#TabletWeaving.TabletStacking","page":"Home","title":"TabletWeaving.TabletStacking","text":"TabletStacking is the abstract supertype for which way a tablet is facing when stacked.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.FrontToTheRight","page":"Home","title":"TabletWeaving.FrontToTheRight","text":"In FrontToTheRight stacking,  the tablet is stacked so that its front faces the weaver's right.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.FrontToTheLeft","page":"Home","title":"TabletWeaving.FrontToTheLeft","text":"In FrontToTheLeft stacking,  the tablet is stacked so that its front faces the weaver's left.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.tablet_stacking_to_char","page":"Home","title":"TabletWeaving.tablet_stacking_to_char","text":"tablet_stacking_to_char(::TabletStacking)\n\nReturn an arrow showing which direction the front of a tablet is currently facing.\n\n\n\n\n\n","category":"function"},{"location":"#Tablet","page":"Home","title":"Tablet","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Tablet\nwarp_color\ntop_edge","category":"page"},{"location":"#TabletWeaving.Tablet","page":"Home","title":"TabletWeaving.Tablet","text":"Tablet\n\nTablet describes the setup and current state of a single tablet weaving card.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.warp_color","page":"Home","title":"TabletWeaving.warp_color","text":"warp_color(::Tablet, ::TabletHole)\n\nReturn the color of the warp thread that passes through the specified hole of the specified tablet.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.top_edge","page":"Home","title":"TabletWeaving.top_edge","text":"top_edge(::Tablet)::TabletEdge\n\nReturn the TabletEdge of the top edge of the tablet. This edge is easier to see on the loom than the shed edge. It is also unaffected by the tablet's stacking.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"We use a Vector of Tablets to describe how the loom is set up for weaving.  for convenience, we can add these vectors together for a wider pattern.  We can also multiply them to repeat tablets.","category":"page"},{"location":"#Tablet-Rotation","page":"Home","title":"Tablet Rotation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Prior to each new throw of the weft, the tablets are rotated to open a new shed.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In practice (the stacked arrangement), a card will be rotated forward or backward.  Forward rotation moves the top corner of the card closest to the weaver away from the weaver towards the warp beam.  Backward rotation moves the top corner furthest from the weaver toards the weaver.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Whether forward rotation turns the card in the ABCD or the  DCBA direction depends on how the card is threaded and stacked.","category":"page"},{"location":"","page":"Home","title":"Home","text":"RotationDirection\nrotation\nABCD\nDCBA\nClockwise\nCounterClockwise\nForward\nBackward","category":"page"},{"location":"#TabletWeaving.RotationDirection","page":"Home","title":"TabletWeaving.RotationDirection","text":"RotationDirection\n\nRotationDirection is the abstract supertype of all tablet rotations.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.rotation","page":"Home","title":"TabletWeaving.rotation","text":"rotation(::Tablet, ::RotationDirection)\n\nReturn the change in the Tablet's accumulated_rotation if the specified `AbstractRotation is applied.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.ABCD","page":"Home","title":"TabletWeaving.ABCD","text":"The ABCD rotation causes the A corner of the tablet to move to the location in space previously occupied by the B corner.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.DCBA","page":"Home","title":"TabletWeaving.DCBA","text":"The DCBA rotation causes the A corner of the tablet to move to the location in space previously occupied by the D corner.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.Clockwise","page":"Home","title":"TabletWeaving.Clockwise","text":"The Clockwise direction refers to how the tablet would move if its front or back face (depending on threading) were facing the weaver.  Whether this results in ABCD or DCBA rotation depends on how the tablet is threaded.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.CounterClockwise","page":"Home","title":"TabletWeaving.CounterClockwise","text":"The CounterClockwise direction refers to how the tablet would move if its front or back face (depending on threading)  were facing the weaver.  Whether the front or the back of the tablet is facing the weaver depends on whether the card is BackToFrontorFrontToBack` threaded.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.Forward","page":"Home","title":"TabletWeaving.Forward","text":"The Forward rotation moves the top corner of the tablet closest to the weaver and the cloth beam to be the top corner farthest from the weaver.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.Backward","page":"Home","title":"TabletWeaving.Backward","text":"The Backward rotation moves the top corner of the tablet closest to the weaver and the cloth beam to be the bottom corner closest to the weaver.\n\n\n\n\n\n","category":"type"},{"location":"#Weaving","page":"Home","title":"Weaving","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To weave, the weaver first rotates the tablets according to some pattern.  Rotating the tablets opens a new shed.  The shuttle is then passed through the new shed to finish weaving that row.","category":"page"},{"location":"","page":"Home","title":"Home","text":"rotate!\nshot!  ","category":"page"},{"location":"#TabletWeaving.rotate!","page":"Home","title":"TabletWeaving.rotate!","text":"rotate!(::Tablet, ::RotationDirection)\n\nRotate the tablet by one position in the specified direction.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.shot!","page":"Home","title":"TabletWeaving.shot!","text":"shot!(::Tablet)\n\nApply the current rotation to the tablet and return the colors of the warp threads passing over the top and bottom of the fabric, and the crossing direction (as a StitchSlant) when looking at the front/top  face of the fabric.  Note that the slant on the bottom face will be the other of the slant on the top surface since the fabrick is flipped to see the other face.\n\n\n\n\n\n","category":"function"},{"location":"#Stitch-Slant","page":"Home","title":"Stitch Slant","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Rotation of a tablet introduces twist int o the four threads passing through that tablet.  That twist is locked in by the next weft thread. The twist causes one thread to cross over each surface and two threads to pass through from front to back or back to front.  The stitches that cross over the front or back surface of the woven fabric will appear slightly slanted.  We need vocabulary to describe the directions of those slants.","category":"page"},{"location":"","page":"Home","title":"Home","text":"StitchSlant\nSStitch\nZStitch\nstitch_slant_to_char\nstitch_slant_for_char","category":"page"},{"location":"#TabletWeaving.StitchSlant","page":"Home","title":"TabletWeaving.StitchSlant","text":"StitchSlant is the abstract supertype for describing the angular slant of a woven stitch.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.SStitch","page":"Home","title":"TabletWeaving.SStitch","text":"SStitch describes how a woven stitch is slanted when it  angles from the near right (for the corresponding weft) to tbe far left.  An SStitch is formed when the rotation of a tablet passes the thread to the weaver's left.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.ZStitch","page":"Home","title":"TabletWeaving.ZStitch","text":"ZStitch describes how a woven stitch is slanted when it  angles from the near left (for the corresponding weft) to tbe far right.  A ZStitch is formed when the rotation of a tablet passes the thread to the weaver's right.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.stitch_slant_to_char","page":"Home","title":"TabletWeaving.stitch_slant_to_char","text":"stitch_slant_to_char(::StitchSlant)::Char\n\nReturn a single character which consisely represents the slant of a stitch.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.stitch_slant_for_char","page":"Home","title":"TabletWeaving.stitch_slant_for_char","text":"stitch_slant_for_char(::AbstractCharacter)::StitchSlant\n\nGiven an 's', 'z', slash or backslash character, return the so-identified StitchSlant.\n\n\n\n\n\n","category":"function"},{"location":"#Describing-a-Pattern","page":"Home","title":"Describing a Pattern","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"How should we describe tablet motion during weaving?","category":"page"},{"location":"","page":"Home","title":"Home","text":"After each throw, each tablet must be rotated forward or backward to make a new shed.  In the simplest patterns, all tablets are rotated in the same direction.  For more complicated patterns however, tablets move in different directions for each shed.  How can we represent these rotations for ease of execution by the weaver?","category":"page"},{"location":"","page":"Home","title":"Home","text":"There is one set of tablet motions for each throw of the shuttle.  We should have a row number.  The weaver must keep track of which row they're working.","category":"page"},{"location":"","page":"Home","title":"Home","text":"There is motion for each tablet.  The motion of a single tablet can be concisely described by unicode arrows (🡑, 🡓) or by the edge number of the tablet that is facing the shed or on top.  The latter is less error prone since an incorrect starting position for a tablet will be detected.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The simplest representation is a Vector for the whole pattern.  Each element would be a Vector of digits from 1 to 4 indicating the edge of the tablet that's currently \"on top\".","category":"page"},{"location":"#Designing-a-Pattern","page":"Home","title":"Designing a Pattern","text":"","category":"section"},{"location":"#Simple-Patterns","page":"Home","title":"Simple Patterns","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"simple_rotation_plan\nf4b4_rotation_plan","category":"page"},{"location":"#TabletWeaving.simple_rotation_plan","page":"Home","title":"TabletWeaving.simple_rotation_plan","text":"simple_rotation_plan(row_count::Int, rotation_direction::RotationDirection)\n\nReturn a simple rotation plan function, as could be passed to tablet_weave.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.f4b4_rotation_plan","page":"Home","title":"TabletWeaving.f4b4_rotation_plan","text":"f4b4_rotation_plan(row_count::Int)\n\nReturn a rotation plan function that weaves the specified number of rows. All tablets in the first four rows will be rotated forward. All tablets in the next four rows are rotated backward, Rotation direction continues to alternate every four rows until the end of the pattern.\n\n\n\n\n\n","category":"function"},{"location":"#Going-from-an-Image-to-a-Pattern","page":"Home","title":"Going from an Image to a Pattern","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We have an array of the \"image\" we want to weave.  How do we translate that into a set of tablets, their warping, and their motions?","category":"page"},{"location":"","page":"Home","title":"Home","text":"How do we execute that \"plan\" to produce a stitch image to see how the pattern turned out.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For a two color pattern, we can warp each tablet with one color in holes A and C and the other in holes B and D. Whatever the previous stitch, the tablet can be rotated to either color.  The slant of the stitch can't be controlled though.","category":"page"},{"location":"","page":"Home","title":"Home","text":"tablets_for_image","category":"page"},{"location":"#TabletWeaving.tablets_for_image","page":"Home","title":"TabletWeaving.tablets_for_image","text":"tablets_for_image(image)\n\nReturn a Vector of the Tablets that could be used to weave the image, which should be a two dimensional array.  If the tablets can't be determined then an error is thrown.\n\nThe first dimension of image counts rows of weft.  The second dimension counts columns of warp, and therefore, tablets.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"tablets_for_image does nothing about tablet threading, only colors.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The tablet weaving patterns I've seen all seem to have one threading on one side of the pattern and another threading on the other side, with the possible exception of the borders having different threading from the field.","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can introduce a function that sets one threading from the edge to the middle and switches to the other threading for the other half.","category":"page"},{"location":"","page":"Home","title":"Home","text":"symetric_threading!\nalternating_threading!","category":"page"},{"location":"#TabletWeaving.symetric_threading!","page":"Home","title":"TabletWeaving.symetric_threading!","text":"symetric_threading!(Vector{<:Tablet};\n                    leftthreading::TabletThreading = BackToFront())\n\nSet the threading of the tablets to be bilaterally symetric .\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.alternating_threading!","page":"Home","title":"TabletWeaving.alternating_threading!","text":"alternating_threading!(tablets::Vector{<:Tablet};\n                       leftthreading::TabletThreading = BackToFront())\n\nSet the threading of each tablet so that each tablet has the opposite threading from its two neighbors.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"TabletWeavingPattern","category":"page"},{"location":"#TabletWeaving.TabletWeavingPattern","page":"Home","title":"TabletWeaving.TabletWeavingPattern","text":"TabletWeavingPattern\n\nTabletWeavingPattern represents a single tablet weaving project, from initial target image to tablets to pattern to images of the expected result.\n\n\n\n\n\n","category":"type"},{"location":"#Composition","page":"Home","title":"Composition","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We might want to combine a number of graphical elements in our weaving design.  Some utilities are provided to support this.","category":"page"},{"location":"","page":"Home","title":"Home","text":"safe_hcat and safe_vcat can be used to combine multiple images horizontally or vertically.  These are just instances of (an instantiable subtype of) SwatchComposer.","category":"page"},{"location":"","page":"Home","title":"Home","text":"SwatchComposer\nHorizontalComposer\nsafe_hcat\nVerticalComposer\nsafe_vcat\nSwatchAlignment\nAlignHeads\nAlignCenters\nAlignTails\ninsert_between","category":"page"},{"location":"#TabletWeaving.SwatchComposer","page":"Home","title":"TabletWeaving.SwatchComposer","text":"(::SwatchComposer)(align::SwatchAlignment,\n                   padvalue, swatches)\n\nReturn a single two dimensional array composed by juxtaposing the swatches according to align.  Swatches that are not compatible in size are padded with padvalue.\n\nHorizontalComposer composes the swatches horizontally – along the length of the warp.  safe_hcat is an alias for this composer.\n\nVerticalComposer composes the swatches vertically – across the width of the warp.  safe_vcat is an alias for this composer.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.HorizontalComposer","page":"Home","title":"TabletWeaving.HorizontalComposer","text":"HorizontalComposer\n\nJuxtaposes the swarches horizontally, along the length of the warp. See safe_hcat.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.safe_hcat","page":"Home","title":"TabletWeaving.safe_hcat","text":"safe_hcat\n\nsafe_hcat is an alias for calling a HorizontalComposer.\n\n\n\n\n\n","category":"constant"},{"location":"#TabletWeaving.VerticalComposer","page":"Home","title":"TabletWeaving.VerticalComposer","text":"VerticalComposer\n\nJuxtaposes the swarches vertically, across the width of the warp. See safe_vcat.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.safe_vcat","page":"Home","title":"TabletWeaving.safe_vcat","text":"safe_vcat\n\nsafe_vcat is an alias for calling a VerticalComposer.\n\n\n\n\n\n","category":"constant"},{"location":"#TabletWeaving.SwatchAlignment","page":"Home","title":"TabletWeaving.SwatchAlignment","text":"(::SwatchAlignment)(::SwatchComposer, swatch::Array{Any, 2}, add,\n                    padvalue)\n\nAdd padding to swatch so that its size will be compatible with  those of other swatches when performing the SwatchComposer. add is the number of rows or columns to be added to swatch. The value of each element added in the padding is specified by padvalue.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.AlignHeads","page":"Home","title":"TabletWeaving.AlignHeads","text":"AlignHeads\n\nAn instantiable subtype of SwatchAlignment that aligns the left or top edges of graphical elements when safe_hcat or safe_vcat is used.  Padding is adddeed after the swatctch as needed.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.AlignCenters","page":"Home","title":"TabletWeaving.AlignCenters","text":"AlignCenters\n\nAn instantiable subtype of SwatchAlignment that aligns the centers of graphical elements when safe_hcat or safe_vcat is used.  Padding is added both before and after the swatch as needed.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.AlignTails","page":"Home","title":"TabletWeaving.AlignTails","text":"AlignTails\n\nAn instantiable subtype of SwatchAlignment that aligns the right or bottom edges of graphical elements when safe_hcat or safe_vcat is used.  Padding is added before the swatch as needed.\n\n\n\n\n\n","category":"type"},{"location":"#TabletWeaving.insert_between","page":"Home","title":"TabletWeaving.insert_between","text":"insert_between(swatches, between)\n\nIntersperse between among swatches.\n\nswatches is a vector of 2 dimenswional arrays that will be part of a tablet weaving pattern.  A new vector is returned with between inserted between each two adjacent arrays from swatches.\n\nSuitable for adding spacing between letters or lines of text, but can also be used to add spacing between arbitrary graphical elements.\n\n\n\n\n\n","category":"function"},{"location":"#Text","page":"Home","title":"Text","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A simple dot matrix font is provided so that we can include text in our designs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"compose_line\nFONT_5x7","category":"page"},{"location":"#TabletWeaving.compose_line","page":"Home","title":"TabletWeaving.compose_line","text":"compose_line(line)\n\nReturn a bit image from a line of text.  Uses the FONT_5x7 font.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.FONT_5x7","page":"Home","title":"TabletWeaving.FONT_5x7","text":"FONT_5x7\n\nContains 5 wide by 7 high dot matrix bitmap images of uppercase letters, digits and punctuation.  Indexed by Char.\n\n\n\n\n\n","category":"constant"},{"location":"#Everything-Else","page":"Home","title":"Everything Else","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"svg_stitch\nother\ncsscolor\nchart_tablets\nwant_color\ntablet_weave\nchart_tablet\nlonger_dimension_counts_weft\nTabletThreading","category":"page"},{"location":"#TabletWeaving.svg_stitch","page":"Home","title":"TabletWeaving.svg_stitch","text":"svg_stitch(stitch_width, stitch_length, stitch_diameter, slant::Char)\n\nGenerate the SVG for drawing a stitch.\n\nstitch_width is the width of the stitch on the SVG X and weaving weft axis.\n\nstitch_diameter is how wide the stitch is.\n\nstitch_length is the length of the stitch in the SVG Y and warp axis.\n\nslant is as returned by shot!.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.other","page":"Home","title":"TabletWeaving.other","text":"other(::TabletThreading)\n\nGiven a TabletThreading, return the opposite one.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.csscolor","page":"Home","title":"TabletWeaving.csscolor","text":"csscolor(color)\n\nreturn (as a string) the CSS representation of the color.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.chart_tablets","page":"Home","title":"TabletWeaving.chart_tablets","text":"chart_tablets(::Vector{<:Tablet})\n\nReturn an SVG chart describing how the tablets are threaded.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.want_color","page":"Home","title":"TabletWeaving.want_color","text":"want_color(::Tablet, color)\n\nreturn the new top edge if the tablet is rotated so that the stitch will come out the specified color.  want_color is used to turn an image into a weaving pattern.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.tablet_weave","page":"Home","title":"TabletWeaving.tablet_weave","text":"tablet_weave(tablets::Vector{<:Tablet}, rotation_plan)\n\nSimulate the weaving of an item that is warped according to tablets and is woven according to rotation_plan.\n\nrotation_plan is a function of three arguments:\n\na vector of the tablets;\nthe row number of the warp being formed;\nthe number of the tablet, counted from the weaver's left.\n\nIt should return a RotationDirection, or nothing if the row number is past the end of the pattern.\n\ntablet_weave rotates the tablets according to the plan function, steping the row number until rotation_plan returns nothing.\n\ntablet_weave returns several values:\n\nan array of the stitch color and slant, from which an image of the top face of the result can be made;\nthe same, but for the bottom face of the result;\na vector with one element per weft row, each element of which is a vector with\n\none element per tablet, giving the rotation that was applied to that tablet and its new top edge after applying that rotation, as a tuple.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.chart_tablet","page":"Home","title":"TabletWeaving.chart_tablet","text":"chart_tablet(::Tablet; size=5, x=0)\n\nReturn an SVG element that describes how the tablet is threaded.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.longer_dimension_counts_weft","page":"Home","title":"TabletWeaving.longer_dimension_counts_weft","text":"longer_dimension_counts_weft(image)\n\nReturn an image with the dimensions possibly permuted such that each increment in the first dimension counts a new row of the weft.  The second dimension indexes the color of the visible warp thread for that row.\n\n\n\n\n\n","category":"function"},{"location":"#TabletWeaving.TabletThreading","page":"Home","title":"TabletWeaving.TabletThreading","text":"TabletThreading is the abstract supertype for the two ways that the warp threads can pass through a tablet.\n\n\n\n\n\n","category":"type"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"We could weave text.","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"I found a 5×7 dot matrix font that might be used to weave text.","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"using Colors\nusing TabletWeaving\n\ncolor(bit) = [ RGB(1, 1, 1), RGB(0, 0, 0) ][bit + 1]\n\ncolor.(compose_line(\"HELLO!\"))","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"We can also compose multiple lines:","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"using Base.Iterators\n\n# 0 is the background value in the font used by compose_line:\nPADVALUE = 0\n\nMESSAGE = color.(\n  safe_vcat(AlignCenters(), 0,\n            insert_between(\n                compose_line.([\"THIS IS\",\n                               \"A TEST\"]),\n                fill(PADVALUE, 2, 1))))","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"It would look better with a border:","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"MESSAGE =\n    let\n        # MESSAGE has already been colored so our padding\n        # needs to be colored too:\n        background = color(PADVALUE)\n        padding = fill(background, 2, 2)\n        safe_vcat(AlignHeads(), background,\n                  padding,\n                  safe_hcat(AlignHeads(), background,\n                            padding, MESSAGE, padding),\n                  padding)\n    end","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"How might it look woven:","category":"page"},{"location":"examples/text/","page":"Weaving Text","title":"Weaving Text","text":"WOVEN = \n    TabletWeavingPattern(\"Sample Text\", MESSAGE;\n                   \t threading_function = symetric_threading!)\n\nHTML(string(pretty(WOVEN)))","category":"page"}]
}
