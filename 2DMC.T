%Description: A program that is a game in which the player moves around by way of the peripheral device I have constructed, and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

%Program settings
View.Set ("graphics:637;403")
View.Set ("offscreenonly")
buttonchoose ("multibutton")
setscreen ("noecho")
%Declaration Statements
%Constant declarations
const midx : int := maxx div 2
const midy : int := maxy div 2
const numblockscanjump : int := 2
const doubletapspeed : int := 100
const blocksize : int := 16
const coords : boolean := true
%Variable declarations
var jumpheight : int := blocksize * numblockscanjump + blocksize div 3
var font1 := Font.New ("sans serif:40:bold")
var walkr : array 1 .. 4 of int
walkr (1) := Pic.FileNew ("Images\\walk1r.bmp")
walkr (2) := Pic.FileNew ("Images\\walk2r.bmp")
walkr (3) := Pic.FileNew ("Images\\walk3r.bmp")
walkr (4) := Pic.FileNew ("Images\\walk4r.bmp")
var walkl : array 1 .. 4 of int
walkl (1) := Pic.FileNew ("Images\\walk1l.bmp")
walkl (2) := Pic.FileNew ("Images\\walk2l.bmp")
walkl (3) := Pic.FileNew ("Images\\walk3l.bmp")
walkl (4) := Pic.FileNew ("Images\\walk4l.bmp")
var crawlr : array 1 .. 4 of int
crawlr (1) := Pic.FileNew ("Images\\crawl1r.bmp")
crawlr (2) := Pic.FileNew ("Images\\crawl2r.bmp")
crawlr (3) := Pic.FileNew ("Images\\crawl3r.bmp")
crawlr (4) := Pic.FileNew ("Images\\crawl4r.bmp")
var crawll : array 1 .. 4 of int
crawll (1) := Pic.FileNew ("Images\\crawl1l.bmp")
crawll (2) := Pic.FileNew ("Images\\crawl2l.bmp")
crawll (3) := Pic.FileNew ("Images\\crawl3l.bmp")
crawll (4) := Pic.FileNew ("Images\\crawl4l.bmp")
var walkrc : array 1 .. 4 of int
walkrc (1) := Pic.FileNew ("Images\\walk1rc.bmp") %click
walkrc (2) := Pic.FileNew ("Images\\walk2rc.bmp") %click
walkrc (3) := Pic.FileNew ("Images\\walk3rc.bmp") %click
walkrc (4) := Pic.FileNew ("Images\\walk4rc.bmp") %click
var walklc : array 1 .. 4 of int
walklc (1) := Pic.FileNew ("Images\\walk1lc.bmp") %click
walklc (2) := Pic.FileNew ("Images\\walk2lc.bmp") %click
walklc (3) := Pic.FileNew ("Images\\walk3lc.bmp") %click
walklc (4) := Pic.FileNew ("Images\\walk4lc.bmp") %click
var crawlrc : array 1 .. 4 of int
crawlrc (1) := Pic.FileNew ("Images\\crawl1rc.bmp") %click
crawlrc (2) := Pic.FileNew ("Images\\crawl2rc.bmp") %click
crawlrc (3) := Pic.FileNew ("Images\\crawl3rc.bmp") %click
crawlrc (4) := Pic.FileNew ("Images\\crawl4rc.bmp") %click
var crawllc : array 1 .. 4 of int
crawllc (1) := Pic.FileNew ("Images\\crawl1lc.bmp") %click
crawllc (2) := Pic.FileNew ("Images\\crawl2lc.bmp") %click
crawllc (3) := Pic.FileNew ("Images\\crawl3lc.bmp") %click
crawllc (4) := Pic.FileNew ("Images\\crawl4lc.bmp") %click
var jump : int := Pic.FileNew ("Images\\falljump.bmp")
var jumpcr : int := Pic.FileNew ("Images\\falljumpcr.bmp") %click
var jumpcl : int := Pic.FileNew ("Images\\falljumpcl.bmp") %click
var jumpr : int := Pic.FileNew ("Images\\jumpr.bmp")
var jumpl : int := Pic.FileNew ("Images\\jumpl.bmp")
var jumprc : int := Pic.FileNew ("Images\\jumprc.bmp") %click
var jumplc : int := Pic.FileNew ("Images\\jumplc.bmp") %click
var jumprl : int := Pic.FileNew ("Images\\jumprl.bmp") %click
var jumplr : int := Pic.FileNew ("Images\\jumplr.bmp") %click
var fallr : int := Pic.FileNew ("Images\\fallr.bmp")
var falll : int := Pic.FileNew ("Images\\falll.bmp")
var fallrc : int := Pic.FileNew ("Images\\fallrc.bmp") %click
var falllc : int := Pic.FileNew ("Images\\falllc.bmp") %click
var fallrl : int := Pic.FileNew ("Images\\fallrl.bmp") %click
var falllr : int := Pic.FileNew ("Images\\falllr.bmp") %click
var fall : int := Pic.FileNew ("Images\\falljump.bmp")
var fallcr : int := Pic.FileNew ("Images\\falljumpcr.bmp") %click
var fallcl : int := Pic.FileNew ("Images\\falljumpcl.bmp") %click
var stand : int := Pic.FileNew ("Images\\stand.bmp")
var standcr : int := Pic.FileNew ("Images\\standcr.bmp") %click
var standcl : int := Pic.FileNew ("Images\\standcl.bmp") %click
var charwidth : int := Pic.Width (stand)
var charheight : int := Pic.Height (stand)
var arrow : array char of boolean
var charx : int := midx + 2
var chary : int := 70
var backpic : int := Pic.New (0, 0, 2, 2)
var xm, ym, cm, character, rcharx, rchary, rheady, rcharyhorizontal : int
var blkx, blky : array 1 .. 9999999 of int
var sprintpossibled1, sprintpossibled2, sprintpossiblea1, sprintpossiblea2, blocknum, gravcount, jumpcount, movegap, wlk, crl, blkount, x, y : int := 0
var onground, onleftwall, onrightwall, hitceiling, walkleft, walkright, oldface, sprintd, sprinta, recentstopd, recentstartd, recentstopa, recentstarta,
    mustcrawl, bluedot, reddot, bluedotup, reddotup : boolean := false
var action : string := "standing"
var facing, oldfacing : string := ""
var headcolour : int := white
var ponwlk, poncrl, movegaptens : int := 1

/*
 %Artificially high block count
 for i : 1 .. 1000
 blkx (i) := -blocksize
 blky (i) := -blocksize
 end for
 */

%Setup world
headcolour := 52

%Create box-y environment
loop
    blkount += 1
    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), black)
    blkx (blkount) := x
    blky (blkount) := y
    x += blocksize
    if x >= maxx then
	x := 0
	y += blocksize
    end if
    View.Update
    exit when y >= blocksize * 3 and x > 66
end loop
/*
 %Artificially high block count
 blkount := 1000
 */

%QuickBlocks%
var TotlBlks := 11
var xcoord : array 1 .. TotlBlks of int
var ycoord : array 1 .. TotlBlks of int

xcoord (1) := 14
ycoord (1) := 4

xcoord (2) := 16
ycoord (2) := 3

xcoord (3) := 27
ycoord (3) := 3

xcoord (4) := 29
ycoord (4) := 4

xcoord (5) := 30
ycoord (5) := 5

xcoord (6) := 37
ycoord (6) := 3

xcoord (7) := 35
ycoord (7) := 4

xcoord (8) := 34
ycoord (8) := 5

xcoord (9) := 33
ycoord (9) := 6

xcoord (10) := 12
ycoord (10) := 4

xcoord (11) := 13
ycoord (11) := 4

for i : 1 .. TotlBlks
    blkount += 1
    xcoord (i) *= blocksize
    ycoord (i) *= blocksize
    Draw.FillBox (xcoord (i), ycoord (i), xcoord (i) + (blocksize - 1), ycoord (i) + (blocksize - 1), black)
    blkx (blkount) := xcoord (i)
    blky (blkount) := ycoord (i)
end for
%QuickBlocks%

%Show world
View.Update

loop
    if coords then
	%Character standing by default
	action := "standing"


	if charheight <= blocksize then
	    mustcrawl := false
	    for i : 1 .. blkount
		if (blkx (i) = rcharx or blkx (i) = rcharx + blocksize) and blky (i) = rchary + blocksize or chary = 0 then
		    mustcrawl := true
		end if
	    end for
	end if

	%Character rounded position
	rcharx := (floor ((charx - charwidth div 2) / blocksize)) * blocksize
	rchary := (ceil ((chary) / blocksize)) * blocksize
	rcharyhorizontal := (floor (chary / blocksize)) * blocksize
	rheady := (ceil ((chary + charheight) / blocksize)) * blocksize

	%If character is on the ground
	reddot := false
	bluedot := false
	for i : 1 .. blkount
	    if blkx (i) = rcharx and blky (i) = rchary - blocksize then
		reddot := true
	    end if
	    if blkx (i) = rcharx + blocksize and blky (i) = rchary - blocksize then
		bluedot := true
	    end if
	end for
	onground := false
	for i : 1 .. blkount
	    if (blkx (i) = rcharx or blkx (i) = rcharx + blocksize) and blky (i) = rchary - blocksize and chary / blocksize = chary div blocksize or chary = 0 then
		onground := true
	    end if
	end for
	if bluedot = false and ((charx + 1 - charwidth div 2) / blocksize) = (round ((charx + 1 - charwidth div 2) / blocksize)) then
	    onground := false
	end if
	if reddot = false and ((charx - charwidth div 2) / blocksize) = (round ((charx - charwidth div 2) / blocksize)) then
	    onground := false
	end if

	%If character is against a wall to the left
	onleftwall := false
	for i : 1 .. blkount
	    if blkx (i) = rcharx and blky (i) = rcharyhorizontal or charx - charwidth div 2 = 0 then
		onleftwall := true
	    elsif charheight > blocksize and blkx (i) = rcharx and blky (i) = rcharyhorizontal + blocksize then
		onleftwall := true
	    end if
	end for

	%If character is against a wall to the right
	onrightwall := false
	for i : 1 .. blkount
	    if blkx (i) = rcharx + blocksize and blky (i) = rcharyhorizontal or charx + charwidth div 2 = maxx then
		onrightwall := true
	    elsif charheight > 20 and blkx (i) = rcharx + blocksize and blky (i) = rcharyhorizontal + blocksize then
		onrightwall := true
	    end if
	end for

	%If character is against the ceiling
	reddotup := false
	bluedotup := false
	for i : 1 .. blkount
	    if blkx (i) = rcharx and blky (i) = rheady - blocksize then
		reddotup := true
	    end if
	    if blkx (i) = rcharx + blocksize and blky (i) = rheady - blocksize then
		bluedotup := true
	    end if
	end for
	hitceiling := false
	for i : 1 .. blkount
	    if (blkx (i) = rcharx or blkx (i) = rcharx + blocksize) and blky (i) = rheady - blocksize /* and (chary + charheight) / blocksize = (chary + charheight) div blocksize*/ or rheady >= maxy
		    then
		hitceiling := true
	    end if
	end for
	if bluedotup = false and ((charx + 1 - charwidth div 2) / blocksize) = (round ((charx + 1 - charwidth div 2) / blocksize)) then
	    hitceiling := false
	end if
	if reddotup = false and ((charx - charwidth div 2) / blocksize) = (round ((charx - charwidth div 2) / blocksize)) then
	    hitceiling := false
	end if
    else
	%Character standing by default
	if action = "crawlingstop" or action = "crawlingstop left" or action = "crawlingstop right" or action = "crawling left" or action = "crawling right" then
	    for i : 0 .. charwidth
		mustcrawl := false
		if View.WhatDotColour (charx - charwidth div 2 + i, chary + charheight + 5) not= white then
		    mustcrawl := true
		    exit
		else
		    action := "standing"
		end if
	    end for
	else
	    action := "standing"
	end if
	%If character is in the air
	for i : 0 .. charwidth
	    onground := false
	    if View.WhatDotColour (charx - charwidth div 2 + i, chary - 1) not= white or chary = 0 then
		onground := true
		exit
	    end if
	end for

	%If character is against a wall to the left
	for i : 0 .. charheight
	    onleftwall := false
	    if View.WhatDotColour (charx - 1 - charwidth div 2, chary + i) not= white or charx - charwidth div 2 = 0 then
		onleftwall := true
		exit
	    end if
	end for

	%If character is against a wall to the right
	for i : 0 .. charheight
	    onrightwall := false
	    if View.WhatDotColour (charx + 1 + charwidth div 2, chary + i) not= white or charx + charwidth div 2 = maxx then
		onrightwall := true
		exit
	    end if
	end for

	%If character is against the ceiling
	for i : 0 .. charwidth
	    hitceiling := false
	    if View.WhatDotColour (charx - charwidth div 2 + i, chary + charheight + 1) not= white or chary + charheight = maxy then
		hitceiling := true
		exit
	    end if
	end for
    end if

    %Get mouse input
    Mouse.Where (xm, ym, cm)

    %Get keyboard input
    Input.KeyDown (arrow)

    %If 'd' key is pressed
    if arrow ('d') then
	if recentstartd then
	    recentstartd := false
	    if sprintpossibled2 = 0 then
		sprintpossibled1 := doubletapspeed
	    end if
	end if
	if sprintpossibled2 not= 0 and onground then
	    sprintpossibled1 := 0
	    sprintpossibled2 := 0
	    sprintd := true
	end if
	if arrow ('s') and onground or mustcrawl then
	    if movegap = 0 and not onrightwall then
		charx += 1
	    end if
	elsif sprintd then
	    if (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and not onrightwall then
		charx += 1
	    end if
	else
	    if (movegap = 0 or movegap = 8) and not onrightwall then
		charx += 1
	    end if
	end if
	action := "walking"
	facing := "right"
	recentstopd := true
    else
	recentstartd := true
	sprintd := false
	if recentstopd and sprintpossibled1 not= 0 then
	    recentstopd := false
	    sprintpossibled2 := doubletapspeed
	end if
    end if

    %If 'a' key is pressed
    if arrow ('a') then
	if recentstarta then
	    recentstarta := false
	    if sprintpossiblea2 = 0 and onground then
		sprintpossiblea1 := doubletapspeed
	    end if
	end if
	if sprintpossiblea2 not= 0 then
	    sprintpossiblea1 := 0
	    sprintpossiblea2 := 0
	    sprinta := true
	end if
	if arrow ('s') and onground or mustcrawl then
	    if movegap = 0 and not onleftwall then
		charx -= 1
	    end if
	else
	    if sprinta then
		if (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and not onleftwall then
		    charx -= 1
		end if
	    else
		if (movegap = 0 or movegap = 8) and not onleftwall then
		    charx -= 1
		end if
	    end if
	end if
	action := "walking"
	facing := "left"
	recentstopa := true
    else
	recentstarta := true
	sprinta := false
	if recentstopa and onground and sprintpossiblea1 not= 0 then
	    recentstopa := false
	    sprintpossiblea2 := doubletapspeed
	end if
    end if

    %If spacebar is pressed
    if arrow (' ') and onground and mustcrawl = false then
	jumpcount := jumpheight
    end if

    %If 's' key is pressed
    if arrow ('s') and onground then
	action := "crawling"
    end if


    %Timer for double-tapping to sprint
    if sprintpossibled1 not= 0 then
	sprintpossibled1 -= 1
    end if
    if sprintpossibled2 not= 0 then
	sprintpossibled2 -= 1
    end if
    if sprintpossiblea1 not= 0 then
	sprintpossiblea1 -= 1
    end if
    if sprintpossiblea2 not= 0 then
	sprintpossiblea2 -= 1
    end if

    %Stationary crouching
    if arrow ('s') and onground and arrow ('a') = false and arrow ('d') = false then
	action := "crawlingstop"
    end if

    %Jumping
    if mustcrawl = false then
	if jumpcount = jumpheight then
	    facing := ""
	end if
	if jumpcount not= 0 then
	    action := "jumping"
	    if hitceiling then
		jumpcount := 0
	    else
		if (movegap = 0 or movegap = 3 or movegap = 5 or movegap = 8 or movegap = 10 or movegap = 13) and jumpcount >= 18 then
		    chary += 1
		    jumpcount -= 1
		elsif (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and jumpcount >= 9 and jumpcount < 18 then
		    chary += 1
		    jumpcount -= 1
		elsif (movegap = 0 or movegap = 8) and jumpcount < 9 then
		    chary += 1
		    jumpcount -= 1
		end if
	    end if
	end if
    end if

    %Gravity
    if onground = false and jumpcount = 0 then
	action := "falling"
	if (movegap = 0 or movegap = 8) and gravcount < 9 then
	    chary -= 1
	    gravcount += 1
	elsif (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and gravcount >= 9 and gravcount < 18 then
	    chary -= 1
	    gravcount += 1
	elsif (movegap = 0 or movegap = 3 or movegap = 5 or movegap = 8 or movegap = 10 or movegap = 13) and gravcount >= 18 and gravcount < 30 then
	    chary -= 1
	    gravcount += 1
	elsif (movegap = 0 or movegap = 2 or movegap = 4 or movegap = 6 or movegap = 8 or movegap = 10 or movegap = 12 or movegap = 14) and gravcount >= 30 and gravcount < 70 then
	    chary -= 1
	    gravcount += 1
	elsif gravcount >= 70 then
	    chary -= 1
	    gravcount += 1
	end if
    end if

    %On solid ground reset gravity
    if onground then
	gravcount := 0
    end if

    %Incorporate looking direction into action when not jumping or falling
    if action (1 .. 7) not= "jumping" and action (1 .. 7) not= "falling" then
	if cm not= 0 then
	    if xm >= charx then
		facing := "right"
	    else
		facing := "left"
	    end if
	end if
    end if

    %Incorporate motion direction into action
    if facing not= "" then
	action += " "
    end if
    action += facing

    %Incorporate looking direction into action when jumping or falling
    if action (1 .. 7) = "jumping" or action (1 .. 7) = "falling" then
	if cm not= 0 then
	    if xm >= charx then
		if action = "falling left" or action = "jumping left" then
		    action += " "
		    action += "facing right"
		end if
	    else
		if action = "falling right" or action = "jumping right" then
		    action += " "
		    action += "facing left"
		end if
	    end if
	end if
    end if

    %Walking animation
    if movegap = 0 and (movegaptens = 2 or movegaptens = 4 or movegaptens = 6 or movegaptens = 8) then
	if wlk = 4 then
	    ponwlk := -1
	elsif wlk = 1 then
	    ponwlk := 1
	end if
	wlk += ponwlk
    end if

    %Crawling animation
    if movegap = 0 and (movegaptens = 4 or movegaptens = 8) then
	if crl = 4 then
	    poncrl := -1
	elsif crl = 1 then
	    poncrl := 1
	end if
	crl += poncrl
    end if

    %Stop sprinting if crawling
    if action = "crawlingstop" or action = "crawlingstop left" or action = "crawlingstop right" or action = "crawling left" or action = "crawling right" then
	sprintd := false
	sprinta := false
    end if

    %Directionless fall
    if (action = "falling left" or action = "falling right") and arrow ('a') = false and arrow ('d') = false and onground = false then
	action := "falling"
    end if

    if mustcrawl then
	if action = "walking left" then
	    action := "crawling left"
	elsif action = "walking right" then
	    action := "crawling right"
	elsif action = "standing left" then
	    action := "crawlingstop left"
	elsif action = "standing right" then
	    action := "crawlingstop right"
	end if
    end if

    %What character image is being used
    if cm = 0 then     %Image if not clicking
	if action = "walking left" then
	    character := walkl (wlk)
	elsif action = "walking right" then
	    character := walkr (wlk)
	elsif action = "crawlingstop" then
	    character := crawlr (2)
	elsif action = "crawlingstop left" then
	    character := crawll (2)
	elsif action = "crawlingstop right" then
	    character := crawlr (2)
	elsif action = "crawling left" then
	    character := crawll (crl)
	elsif action = "crawling right" then
	    character := crawlr (crl)
	elsif action = "falling" then
	    character := fall
	elsif action = "falling left" then
	    character := falll
	elsif action = "falling right" then
	    character := fallr
	elsif action = "jumping" then
	    character := jump
	elsif action = "jumping left" then
	    character := jumpl
	elsif action = "jumping right" then
	    character := jumpr
	elsif action = "standing left" then
	    character := walkl (2)
	elsif action = "standing right" then
	    character := walkr (2)
	elsif action = "standing" then
	    character := stand
	end if
    else     %Image if clicking
	if action = "walking left" then
	    character := walklc (wlk)
	elsif action = "walking right" then
	    character := walkrc (wlk)
	elsif action = "crawlingstop" then
	    character := crawlrc (2)
	elsif action = "crawlingstop left" then
	    character := crawllc (2)
	elsif action = "crawlingstop right" then
	    character := crawlrc (2)
	elsif action = "crawling left" then
	    character := crawllc (crl)
	elsif action = "crawling right" then
	    character := crawlrc (crl)
	elsif action = "falling" then
	    if xm >= charx then
		character := fallcr
	    else
		character := fallcl
	    end if
	elsif action = "falling left" then
	    character := falllc
	elsif action = "falling right" then
	    character := fallrc
	elsif action = "falling left facing right" then
	    character := falllr
	elsif action = "falling right facing left" then
	    character := fallrl
	elsif action = "jumping" then
	    if xm >= charx then
		character := jumpcr
	    else
		character := jumpcl
	    end if
	elsif action = "jumping left" then
	    character := jumplc
	elsif action = "jumping right" then
	    character := jumprc
	elsif action = "jumping left facing right" then
	    character := jumplr
	elsif action = "jumping right facing left" then
	    character := jumprl
	elsif action = "standing left" then
	    character := walklc (2)
	elsif action = "standing right" then
	    character := walkrc (2)
	end if
    end if
    %Get character dimensions
    charwidth := Pic.Width (character)
    charheight := Pic.Height (character)

    %Save Background behind character
    Pic.Free (backpic)
    backpic := Pic.New (charx - 15, chary - 15, charx + 15, chary + 40)
    %backpic := Pic.New (charx - 25, chary - 25, charx + 25, chary + 50)


    %Draw character's head colour
    if action = "crawling left" or action = "crawlingstop left" then
	Draw.FillOval (charx - 4, chary + 8, 3, 3, headcolour)
    elsif action = "crawling right" or action = "crawlingstop right" or action = "crawlingstop" then
	Draw.FillOval (charx + 4, chary + 8, 3, 3, headcolour)
    else
	Draw.FillOval (charx, chary + 21, 3, 3, headcolour)
    end if

    %Draw character
    %Draw.FillOval (rcharx, rheady - blocksize, 2, 2, red)
    %Draw.FillOval (rcharx + blocksize, rheady - blocksize, 1, 1, blue)
    Pic.Draw (character, charx - charwidth div 2, chary, picMerge)
    View.UpdateArea (charx - 20, chary - 20, charx + 20, chary + 45)
    %View.Update %Area (charx - 25, chary - 25, charx + 25, chary + 50)

    %Draw old unaltered background over character
    Pic.Draw (backpic, charx - 15, chary - 15, picCopy)
    %Pic.Draw (backpic, charx - 25, chary - 25, picCopy)

    %Movement timer
    movegap += 1
    if movegap = 16 then
	movegap := 0
	movegaptens += 1
	if movegaptens = 9 then
	    movegaptens := 1
	end if
    end if

    delay (0)     % This delay to be adjusted with screen size and computer performance speed.
end loop
