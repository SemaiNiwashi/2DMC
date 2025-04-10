%Description: A program that is a block-based game in which the player moves around (optionally by way of the peripheral device I have constructed), and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

%Make using GUI features possible
import GUI

%Program settings
var MainWinID : int := Window.Open ("position:top;right,graphics:640;400") %Smallest advisable:450,330
buttonchoose ("multibutton")
setscreen ("noecho")

%when offset is negative, >0.5 works bad, < 0.5 works good. When positive, opposite.

%Add making the screen scroll by not 1 pixel all the time
%    Run off screen come back get stuck in block.
%    Also world generation is messed up (left/right, because rest is still moving by 1 pixel).
%The great variable purge
%Add being able to click on a block if it is at all visible to the character - not just in a straight line to the mouse!
%Prevent that little "hop" when holding space when hits ground and dies
%Make character an instance of a class
%Add secod player
%Remove "groundlevel" (if unneeded)
%Add world generation number in preferences(?) file, (plus a seed?) default to 0 if no record
%   Create world-generation-version checker and handler
%   Change world generation in old version to only save blocks differing from the flat terrain generation
%   Change world generation in new version to only save blocks differing from the seed terrain generation
%Add different block types (solid, platform, decoration)

%Declaration Statements
%Constant declarations
const midx : int := maxx div 2
const midy : int := maxy div 2
const boolUnInit := 16#FF
const numblockscanjump : real := 2.3
const numblockscanreach : real := 5
const doubletapspeed : int := 100
const blockplacespeed : int := 130
const blockbreakspeed : int := 130
const playerSpeed : real := 0.05
const infinatePlacing : boolean := false
const charudpxrange := 50
const parallelinput : boolean := false
const keepmapblocksize : boolean := true
const pxscrollclearance : int := 70
const staticfalldamage : boolean := true
var gravAmount : real := 0.10
%Variable declarations
type vec2 :
    record
	x, y : real
    end record
type vec2i :
    record
	x, y : int
    end record
var blocksize : int := 16 %Must be > 15
var font1 := Font.New ("sans serif:40:bold")
var font2 := Font.New ("sans serif:8:bold")
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
var dead : int := Pic.FileNew ("Images\\dead.bmp")
var deadl : int := Pic.FileNew ("Images\\deadl.bmp")
var deadr : int := Pic.FileNew ("Images\\deadr.bmp")
var crosshairsbbpre : int := Pic.FileNew ("Images\\crosshairsbb.bmp")
var crosshairsbbpre2 : int := Pic.FileNew ("Images\\crosshairsbb2.bmp")
var crosshairspbpre : int := Pic.FileNew ("Images\\crosshairspb.bmp")
var crosshairspbpre2 : int := Pic.FileNew ("Images\\crosshairspb2.bmp")
var loadingScreen1 : int := Pic.FileNew ("Images\\loadingScreen.bmp")
var healthbarfrst : int := Pic.FileNew ("Images\\healthbar.bmp")
var loadingScreen : int := Pic.Scale (loadingScreen1, maxx - 20, maxy - 20)
var charwidth : int := Pic.Width (stand)
var charheight : int := Pic.Height (stand)
var arrow : array char of boolean
var deltaTime : int
var gametimeold : int := 0
var pos, oldPos : vec2
pos.x := midx + 2
pos.y := 200
oldPos.x := pos.x
oldPos.y := pos.y
var backpic : int := Pic.New (0, 0, 2, 2)
var screenpic : int := Pic.New (0, 0, 2, 2)
var healthbar : int := Pic.New (0, 0, 2, 2)
var healthbarback : int := Pic.New (0, 0, 2, 2)
var tempcoords : array 1 .. 5 of int
var xm, ym, cm, character, rcursorxbb, rcursorybb, rcursorxpb, rcursorypb, btnstrt, btncont, btnend, mainMenuButton, savenames, loadedsave,
    loadedsavepref, menuhead, menubg, menublk, menuload, saveButton, saveasguiheight, nameTextField, nameLabel, saveFile, autosave, menudelete,
    tempi, linegx, linegy, idelete, null, backpiccross, backpicbox, srx, sry, slx, sly, sux, suy, sdx, sdy, shiftspot, endspot, mstScrnHsGnUp,
    mstScrnHsGnDwn, val, autocoords, cbprev, cbfly, bigx, bigy : int
var sprintpossibled1, sprintpossibled2, sprintpossiblea1, sprintpossiblea2, blocknum, blkount, x, y,
    iprevsaves, ireassign, jumpheight, crosshairsbb2, crosshairsbb, crosshairspb2, crosshairspb, mclickr, mclickl, guidecolour,
    mstScrnHsGnLft, mstScrnHsGnRght, offsetprevlr, offsetprevud, healthold : int := 0
var onground, onleftwall, onrightwall, hitceiling, walkleft, walkright, oldface, sprintd, sprinta, recentstopd, recentstartd, recentstopa, recentstarta,
    mustcrawl, startgame, recentclick, loaded, quitthegame, norcursorinput, keyspc, keya, keys, keyd, keyp, preview, inmainmenu, resetdefaultbg,
    resetdefaulthead, resetdefaultblk, canfly, flying, menuReturn, forcedelete, returningFromPreview, inPauseMenu : boolean := false
var action : string := "standing"
var textfound, deletesaveread, headcolourstr, bgcolourstr, blockcolourstr : string
var facing, oldfacing, loadfile : string := ""
var headcolour, bgcolour, blockcolour : int := 983
var oldbackcolour : int := white
var oldblockcolour : int := black
var ponwlk, poncrl, isaves, wlk, crl : int := 1
var item1, item2, item3 : array 1 .. 16 of int
var item4 : array 0 .. 99 of int
var item5 : array 1 .. 99 of int
var oktosavenew, frstmthrgh, gmfrstmthrgh, survival : boolean := true
var previoussaves : array 1 .. 99 of string (30)
var xinc, yinc, reach, nullreal : real
var jumpcount, gravcount, frametimer, offsetx, offsety, offsetleftright, offsetupdown : real := 0
var groundlevel : int := 50
var health : int := 1000
var menuitemcolours : array 1 .. 16 of string (20) := init ("Default", "White", "Light Grey", "Dark Grey", "Black", "Brown", "Red", "Orange", "Yellow",
    "Green", "Dark Green", "Turquoise", "Blue", "Dark Blue", "Purple", "Pink")
var menuitemsaves : array 0 .. 99 of string (50)
var menuitemdelete : array 1 .. 99 of string (50)
menuitemsaves (1) := "New"
menuitemsaves (0) := "---"
menuitemdelete (99) := ""
if maxy >= 350 then
    saveasguiheight := maxy - 150
else
    saveasguiheight := maxy - 120
end if

var winID : int := Window.Open ("position:center;center,graphics:836;73")
Window.Hide (winID)
Window.SetActive (winID)
Pic.Draw (healthbarfrst, 0, 0, picCopy)
Window.SetActive (MainWinID)

%Range: x: -4999 to 5000, y: -2499 to 2500

function encode (xin, yin : real) : int
    %result (((yin - round (offsetupdown)) div blocksize + 2499) * 10000) + ((xin - round (offsetleftright)) div blocksize + 4999)
    result ((floor ((yin - offsetupdown) / blocksize) + 2499) * 10000) + (floor ((xin - offsetleftright) / blocksize) + 4999)
end encode

function encodeVec (inVec : vec2i) : int
    result encode (inVec.x, inVec.y)
end encodeVec

function encodeLite (xin, yin : int) : int
    result ((yin + 2499) * 10000) + (xin + 4999)
end encodeLite

function decodeX (coordcode : int, toPixels : boolean) : int
    if toPixels then
	result (coordcode - (floor (coordcode / 10000) * 10000) - 4999) * blocksize + round (offsetleftright)
    else
	result (coordcode - (floor (coordcode / 10000) * 10000) - 4999)
    end if
end decodeX

function decodeY (coordcode : int, toPixels : boolean) : int
    if toPixels then
	result (floor (coordcode / 10000) - 2499) * blocksize + round (offsetupdown)
    else
	result (floor (coordcode / 10000) - 2499)
    end if
end decodeY

function isWholeNumber (input : real) : boolean
    result input = round (input)
end isWholeNumber

%Floors this coordinate to the nearest block x, as pixels
function asBlockX (inVal : real) : int
    result floor ((inVal - offsetx) / blocksize) * blocksize + ceil (offsetx)
end asBlockX

%Floors this coordinate to the nearest block y, as pixels
function asBlockY (inVal : real) : int
    result floor ((inVal - offsety) / blocksize) * blocksize + ceil (offsety)
end asBlockY

%Rounds these coordinates to the nearest block, as pixels
function asBlock (xin : real, yin : real) : vec2i
    var temp : vec2i
    temp.x := asBlockX (xin)
    temp.y := asBlockY (yin)
    result temp
end asBlock

%Rounds these coordinates to the nearest block, as pixels
function asBlockVec (inVec : vec2) : vec2i
    result asBlock (inVec.x, inVec.y)
end asBlockVec

%Returns the x coordinate of the right side of the character
function rightSide (useOld : boolean) : real
    if useOld then
	result oldPos.x + charwidth div 2
    else
	result pos.x + charwidth div 2
    end if
end rightSide

%Returns the x coordinate of the left side of the character
function leftSide (useOld : boolean) : real
    if useOld then
	result oldPos.x - charwidth div 2
    else
	result pos.x - charwidth div 2
    end if
end leftSide

%Returns the x coordinate of the top of the character
function topSide (useOld : boolean) : real
    if useOld then
	result oldPos.y + charheight
    else
	result pos.y + charheight
    end if
end topSide

function isAction (testForAction : string) : boolean
    result length (action) >= length (testForAction) and action (1 .. length (testForAction)) = testForAction
end isAction

%Turn the integer value of a colour into a string
function colourstringify (clr : int) : string
    if clr = 0 then
	result "White"
    elsif clr = 8 then
	result "Light Grey"
    elsif clr = 15 then
	result "Dark Grey"
    elsif clr = 7 then
	result "Black"
    elsif clr = 114 then
	result "Brown"
    elsif clr = 12 then
	result "Red"
    elsif clr = 42 then
	result "Orange"
    elsif clr = 14 then
	result "Yellow"
    elsif clr = 10 then
	result "Green"
    elsif clr = 2 then
	result "Dark Green"
    elsif clr = 52 then
	result "Turquoise"
    elsif clr = 9 then
	result "Blue"
    elsif clr = 1 then
	result "Dark Blue"
    elsif clr = 34 then
	result "Purple"
    elsif clr = 13 then
	result "Pink"
    end if
end colourstringify

function numbercolourify (nbr : int) : int
    if nbr = 1 then
	result 983
    elsif nbr = 2 then
	result white
    elsif nbr = 3 then
	result grey
    elsif nbr = 4 then
	result darkgrey
    elsif nbr = 5 then
	result black
    elsif nbr = 6 then
	result 114
    elsif nbr = 7 then
	result brightred
    elsif nbr = 8 then
	result 42
    elsif nbr = 9 then
	result yellow
    elsif nbr = 10 then
	result brightgreen
    elsif nbr = 11 then
	result green
    elsif nbr = 12 then
	result 52
    elsif nbr = 13 then
	result brightblue
    elsif nbr = 14 then
	result blue
    elsif nbr = 15 then
	result 34
    elsif nbr = 16 then
	result brightpurple
    end if
end numbercolourify

%If the game is to continue and menus are to close
procedure start
    startgame := true
    delay (10)
end start

%If user clicks "Quit" button
procedure endgame
    startgame := true
    quitthegame := true
    GUI.Quit
    delay (10)
end endgame

%If user clicks "Return to Main Menu" button
procedure returnMain
    startgame := true
    menuReturn := true
    delay (10)
end returnMain

procedure drawTextSpecial (text : string, x, y : int, fontID, fontHeight, textcolor, justification : int, outlined : boolean, outlineThickness, outlineColor : int)
    %0 = default left-justified (bottom left)
    var xN : int := x %xNew/xNow
    var yN : int := y %yNew/yNow
    if justification = 1 then %right
	xN := x - Font.Width (text, fontID)
    elsif justification = 2 then %center
	xN := x - Font.Width (text, fontID) div 2
    elsif justification = 3 then %true center
	xN := x - Font.Width (text, fontID) div 2
	yN := y - fontHeight div 2
    end if
    if outlined then
	Draw.Text (text, xN - outlineThickness, yN - outlineThickness, font1, outlineColor)
	Draw.Text (text, xN - outlineThickness, yN + outlineThickness, font1, outlineColor)
	Draw.Text (text, xN + outlineThickness, yN - outlineThickness, font1, outlineColor)
	Draw.Text (text, xN + outlineThickness, yN + outlineThickness, font1, outlineColor)
    end if
    Draw.Text (text, xN, yN, font1, textcolor)
end drawTextSpecial

%Loading screen
procedure loading (loadscreencolour : int)
    Draw.FillBox (0, 0, maxx, maxy, loadscreencolour)
    Pic.Draw (loadingScreen, 10, 10, picCopy)
    %Draw.FillOval (midx, midy, maxx div 2 - 10, maxy div 2 - 10, red)
    Draw.Oval (midx, midy, maxx div 2 - 10, maxy div 2 - 10, black)
    drawTextSpecial ("LOADING...", midx, midy, font1, 40, loadscreencolour, 3, true, 1, black)
    View.Update
end loading

%Does nothing, is just a necessary placeholder
procedure NameEntered (text : string)
end NameEntered

%Does nothing, is just a necessary placeholder
procedure DoNothing (status : boolean)
end DoNothing

%If the user selects an opting in the "Head Colour" menu
procedure HeadSelected
    for i : 1 .. 16
	if item1 (i) = GUI.GetEventWidgetID then
	    headcolour := numbercolourify (i)
	    colourback (oldbackcolour)
	    if headcolour = 983 then
		Draw.FillBox (24, maxy - 57, 75, maxy - 46, oldbackcolour)
		Draw.FillBox (32, maxy - 67, 62, maxy - 37, oldbackcolour)
		Draw.Text ("DEFAULT", 25, maxy - 55, font2, black)
	    else
		Draw.FillBox (24, maxy - 57, 75, maxy - 46, oldbackcolour)
		Draw.FillBox (32, maxy - 67, 62, maxy - 37, headcolour)
		Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	    end if
	    Draw.FillBox (0, maxy - 94, 94, maxy - 80, oldbackcolour)
	    Draw.Text (menuitemcolours (i) + " head", 1, maxy - 90, font2, black)
	end if
    end for
end HeadSelected

%If the user selects an opting in the "Background Colour" menu
procedure BackgroundSelected
    for i : 1 .. 16
	if item2 (i) = GUI.GetEventWidgetID then
	    bgcolour := numbercolourify (i)
	    colourback (oldbackcolour)
	    if bgcolour = 983 then
		Draw.FillBox (137, maxy - 57, 188, maxy - 46, oldbackcolour)
		Draw.FillBox (145, maxy - 67, 175, maxy - 37, oldbackcolour)
		Draw.Text ("DEFAULT", 138, maxy - 55, font2, black)
	    else
		Draw.FillBox (137, maxy - 57, 188, maxy - 46, oldbackcolour)
		Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
		Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	    end if
	    Draw.FillBox (99, maxy - 94, 232, maxy - 80, oldbackcolour)
	    Draw.Text (menuitemcolours (i) + " background", 100, maxy - 90, font2, black)
	end if
    end for
end BackgroundSelected

%If the user selects an opting in the "Block Colour" menu
procedure BlocksSelected
    for i : 1 .. 16
	if item3 (i) = GUI.GetEventWidgetID then
	    blockcolour := numbercolourify (i)
	    colourback (oldbackcolour)
	    if blockcolour = 983 then
		Draw.FillBox (257, maxy - 57, 308, maxy - 46, oldbackcolour)
		Draw.FillBox (265, maxy - 67, 295, maxy - 37, oldbackcolour)
		Draw.Text ("DEFAULT", 258, maxy - 55, font2, black)
	    else
		Draw.FillBox (257, maxy - 57, 308, maxy - 46, oldbackcolour)
		Draw.FillBox (265, maxy - 67, 295, maxy - 37, blockcolour)
		Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	    end if
	    Draw.FillBox (237, maxy - 94, 340, maxy - 80, oldbackcolour)
	    Draw.Text (menuitemcolours (i) + " blocks", 238, maxy - 90, font2, black)
	end if
    end for
end BlocksSelected

%If the user selects an option in the "Delete" menu
procedure DeleteSelected
    if forcedelete then
	idelete := 99
    else
	for i : 1 .. isaves - 1
	    if item5 (i) = GUI.GetEventWidgetID then
		idelete := i
	    end if
	end for
    end if
    if menuitemdelete (idelete) = loadfile and loaded then
	loadfile := ""
	loaded := false
    end if
    open : savenames, ("Savenames.txt"), get, put, seek, mod
    seek : savenames, 0
    if eof (savenames) = false then
	loop
	    get : savenames, deletesaveread : *
	    if menuitemdelete (idelete) not= deletesaveread then
		ireassign += 1
		previoussaves (ireassign) := deletesaveread
	    end if
	    exit when eof (savenames)
	end loop
    end if
    close : savenames
    open : savenames, ("Savenames.txt"), get, put, seek
    for i2 : 1 .. ireassign
	put : savenames, previoussaves (i2)
    end for
    close : savenames
    ireassign := 0
    File.Delete ("Saves\\" + menuitemdelete (idelete) + ".txt")
    File.Delete ("Saves\\Preferences\\" + menuitemdelete (idelete) + ".txt")
    if forcedelete = false then
	GUI.Disable (item5 (idelete))
	GUI.Disable (item4 (idelete + 1))
	colourback (oldbackcolour)
	if inPauseMenu then
	    locate (10, 1)
	else
	    locate (12, 1)
	end if
	put "Deleted ", menuitemdelete (idelete) + "                      "
    end if
end DeleteSelected

%If the user selects an opting in the "Load" menu
procedure LoadSelected
    for i : 1 .. isaves
	if item4 (i) = GUI.GetEventWidgetID then
	    loadfile := menuitemsaves (i)
	    colourback (oldbackcolour)
	    locate (12, 1)
	    if i = 1 then
		loaded := false
		put "World: New                       "
	    else
		loaded := true
		put "World: ", menuitemsaves (i) + "                      "
	    end if
	end if
    end for
end LoadSelected

%The GUIs that are used for main and pause menus
process guis
    if gmfrstmthrgh then
	btnstrt := GUI.CreateButtonFull (midx - 150, maxy div 6, 300, "Start Game", start, 30, chr (13), false)
	btnend := GUI.CreateButtonFull (midx - 150, maxy div 9 - 20, 300, "Quit", endgame, 30, chr (13), false)

	cbprev := GUI.CreateCheckBox (maxx - 80, maxy - 70, "Preview", DoNothing)
	cbfly := GUI.CreateCheckBox (maxx - 80, maxy - 100, "Flying", DoNothing)

	menuhead := GUI.CreateMenu ("Head Colour")
	for i : 1 .. 16
	    item1 (i) := GUI.CreateMenuItem (menuitemcolours (i), HeadSelected)
	end for
	menubg := GUI.CreateMenu ("Background Colour")
	for i : 1 .. 16
	    item2 (i) := GUI.CreateMenuItem (menuitemcolours (i), BackgroundSelected)
	end for
	menublk := GUI.CreateMenu ("Block Colour")
	for i : 1 .. 16
	    item3 (i) := GUI.CreateMenuItem (menuitemcolours (i), BlocksSelected)
	end for
	menudelete := GUI.CreateMenu ("Delete")
	for i : 1 .. isaves - 1
	    item5 (i) := GUI.CreateMenuItem (menuitemdelete (i), DeleteSelected)
	end for
	menuload := GUI.CreateMenu ("Load")
	item4 (1) := GUI.CreateMenuItem (menuitemsaves (1), LoadSelected)
	item4 (0) := GUI.CreateMenuItem (menuitemsaves (0), LoadSelected)
	for i : 2 .. isaves
	    item4 (i) := GUI.CreateMenuItem (menuitemsaves (i), LoadSelected)
	end for
    end if
    loop
	if startgame then
	    exit
	end if
	exit when GUI.ProcessEvent
    end loop
end guis

%Welcome screen
Draw.Text ("Welcome to 2DMC!", midx - Font.Width ("Welcome to 2DMC!", font1) div 2, midy - 20, font1, black)
locatexy (midx - length ("Click to continue") * 8 div 2, midy - 40)
put "Click to continue"
Draw.Box (midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10, maxy div 6 + 32, midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10, maxy div 6 * 5 - 32, black)

%Delete blanks from saves
forcedelete := true
DeleteSelected
forcedelete := false

%Wait for click
loop
    Mouse.Where (xm, ym, cm)
    if cm = 1 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10
	    and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
	recentclick := true
    else
	if recentclick and cm = 0 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10
		and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
	    recentclick := false
	    exit
	end if
	recentclick := false
    end if
end loop
cls

%Beginning loading screen
loading (white)

%Declaration statement for the array of blocks: down here because it takes a really long time
var block : array 0 .. 49999999 of boolean

%Check block function
function isBlock (xin : real, yin : real) : boolean %Checks for a block at these equivalent coordinates
    var coordcode : int := encodeVec (asBlock (xin, yin))
    /*    if isExact then
     coordcode := encode (xin, yin)
     else
     coordcode := encodeVec (asBlock (xin, yin))
     end if*/
    result #block (coordcode) not= boolUnInit and block (coordcode)
end isBlock

%Save feature
procedure saveWorld
    loading (bgcolour)
    textfound := GUI.GetText (nameTextField)
    if textfound not= "" then
	iprevsaves := 0
	open : savenames, ("Savenames.txt"), get, put, seek, mod
	seek : savenames, 0
	if eof (savenames) = false then
	    loop
		iprevsaves += 1
		get : savenames, previoussaves (iprevsaves) : *
		exit when eof (savenames)
	    end loop
	end if
	oktosavenew := true
	for i : 1 .. iprevsaves
	    if previoussaves (i) = textfound then
		oktosavenew := false
	    end if
	end for
	if oktosavenew then
	    seek : savenames, *
	    put : savenames, ""
	    put : savenames, textfound
	end if
	close : savenames

	open : loadedsavepref, ("Saves\\Preferences\\" + textfound + ".txt"), get, put, seek
	put : loadedsavepref, pos.x / blocksize
	put : loadedsavepref, pos.y / blocksize
	put : loadedsavepref, headcolour
	put : loadedsavepref, bgcolour
	put : loadedsavepref, blockcolour
	put : loadedsavepref, blocksize
	put : loadedsavepref, offsetx / blocksize
	put : loadedsavepref, offsety / blocksize
	put : loadedsavepref, groundlevel / blocksize
	put : loadedsavepref, mstScrnHsGnUp / blocksize
	put : loadedsavepref, mstScrnHsGnDwn / blocksize
	put : loadedsavepref, mstScrnHsGnLft / blocksize
	put : loadedsavepref, mstScrnHsGnRght / blocksize
	put : loadedsavepref, offsetupdown / blocksize
	put : loadedsavepref, offsetleftright / blocksize
	put : loadedsavepref, health
	put : loadedsavepref, survival
	close : loadedsavepref

	open : saveFile, ("Saves\\" + textfound + ".txt"), get, put, seek
	seek : autosave, 0
	loop
	    get : autosave, autocoords
	    if block (autocoords) then
		put : saveFile, autocoords
	    end if
	    exit when eof (autosave)
	end loop
	close : saveFile
	GUI.Quit
    end if
    seek : autosave, *
	startgame := true
end saveWorld

%The GUIs that are only used on pause screen
process pauseguis
    saveButton := GUI.CreateButton (midx - 50, (saveasguiheight - 30), 100, "Save", saveWorld)
    nameTextField := GUI.CreateTextFieldFull (midx - 100, saveasguiheight, 200, "", NameEntered, GUI.INDENT, 0, 0)
    nameLabel := GUI.CreateLabelFull (midx - 105, saveasguiheight, "Save as:", 0, 0, GUI.RIGHT, 0)
    btncont := GUI.CreateButtonFull (midx - 150, maxy div 3, 300, "Continue", start, 30, chr (13), false)
    mainMenuButton := GUI.CreateButtonFull (midx - 150, maxy div 4.4 - 10, 300, "Return to Main Menu", returnMain, 30, chr (13), false)
    GUI.SetText (nameTextField, textfound)
    loop
	if startgame then
	    exit
	end if
	exit when GUI.ProcessEvent
    end loop
end pauseguis

%Screen scroll
procedure screenscroll (scrdirx : real, scrdiry : real)
    Draw.FillBox (0, 0, maxx, maxy, bgcolour)
    offsetx += scrdirx
    offsety += scrdiry
    offsetleftright += scrdirx
    offsetupdown += scrdiry
    if offsetupdown + groundlevel > mstScrnHsGnUp then
	mstScrnHsGnUp := ceil (offsetupdown + groundlevel)
    end if
    if offsetupdown + groundlevel < mstScrnHsGnDwn then
	mstScrnHsGnDwn := floor (offsetupdown + groundlevel)
    end if
    if offsetleftright > mstScrnHsGnRght then
	mstScrnHsGnRght := ceil (offsetleftright)
    end if
    if offsetleftright < mstScrnHsGnLft then
	mstScrnHsGnLft := floor (offsetleftright)
    end if
    seek : autosave, *

    %Generate new ground
    if scrdirx = 0 and scrdiry > 0 and offsetupdown + groundlevel + blocksize > 0 then %Screen up, make ground below
	x := -blocksize - blocksize + round (offsetx)
	y := -blocksize - blocksize + round (offsety)
	loop
	    if #block (encode (x, y)) = boolUnInit then
		blkount += 1
		block (encode (x, y)) := true
		put : autosave, encode (x, y)
	    end if
	    x += blocksize
	    exit when x >= maxx + blocksize
	end loop
    elsif scrdirx = -1 and scrdiry = 0 and offsetupdown + groundlevel > 0 then %Screen left, make ground right
	x := ((floor ((maxx - floor (offsetx)) / blocksize)) * blocksize + round (offsetx)) + blocksize
	y := -blocksize + round (offsety)
	loop
	    if #block (encode (x, y)) = boolUnInit then
		blkount += 1
		block (encode (x, y)) := true
		put : autosave, encode (x, y)
	    end if
	    y += blocksize
	    exit when y >= offsetupdown + groundlevel
	end loop
    elsif scrdirx = 1 and scrdiry = 0 and offsetupdown + groundlevel > 0 then %Screen right, make ground left
	x := -blocksize - blocksize + round (offsetx)
	y := -blocksize + round (offsety)
	loop
	    tempcoords (1) := encode (x, y)
	    if #block (tempcoords (1)) = boolUnInit then
		blkount += 1
		block (tempcoords (1)) := true
		put : autosave, tempcoords (1)
	    end if
	    y += blocksize
	    exit when y >= offsetupdown + groundlevel
	end loop
    end if

    %Draw blocks on screen
    bigx := (-offsetleftright) div blocksize - 1
    bigy := (-offsetupdown) div blocksize - 1
    loop
	tempcoords (1) := encodeLite (bigx, bigy)
	if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) then
	    x := decodeX (tempcoords (1), true)
	    y := decodeY (tempcoords (1), true)
	    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour) %Draws world 99% of the time
	end if
	bigx += 1
	if bigx > (maxx - offsetleftright) div blocksize then
	    if bigy > (maxy - offsetupdown) div blocksize then
		exit
	    else
		bigx := (-offsetleftright) div blocksize - 1
		bigy += 1
	    end if
	end if
    end loop
end screenscroll

%Re-enables start GUIs
procedure ReEnableStartGUIs
    if gmfrstmthrgh = false then
	if returningFromPreview then
	    Pic.Draw (backpic, 0, maxy - 210, picCopy)
	    returningFromPreview := false
	end if
	GUI.Enable (menuload)
	GUI.Enable (item1 (1))
	GUI.Enable (item2 (1))
	GUI.Enable (item3 (1))
	GUI.Enable (cbprev)
	GUI.Enable (cbfly)
	GUI.Show (btnstrt)
	GUI.ShowMenuBar
	GUI.ResetQuit
	GUI.Refresh
    end if
end ReEnableStartGUIs

%Show colour preview as default
procedure ShowColourPreveiwDefault
    if frstmthrgh then
	Draw.Text ("DEFAULT", 25, maxy - 55, font2, black)
	Draw.Text ("Default head", 1, maxy - 90, font2, black)
	Draw.Text ("DEFAULT", 138, maxy - 55, font2, black)
	Draw.Text ("Default background", 100, maxy - 90, font2, black)
	Draw.Text ("DEFAULT", 258, maxy - 55, font2, black)
	Draw.Text ("Default blocks", 238, maxy - 90, font2, black)
	locate (12, 1)
	put "World: New"
    end if
end ShowColourPreveiwDefault

%Disable and hide all GUIs
procedure DisableAndHideGUIs
    GUI.Disable (menuload)
    GUI.Disable (item1 (1))
    GUI.Disable (item2 (1))
    GUI.Disable (item3 (1))
    GUI.Disable (cbprev)
    GUI.Disable (cbfly)
    GUI.Hide (btnstrt)
    GUI.Hide (btnend)
    GUI.HideMenuBar
    GUI.Quit
end DisableAndHideGUIs

%Get preferences
procedure GetPreferences
    if loaded then
	open : loadedsave, ("Saves\\" + loadfile + ".txt"), get, put, seek, mod
	open : loadedsavepref, ("Saves\\Preferences\\" + loadfile + ".txt"), get, put, seek, mod
	seek : loadedsavepref, 0
	get : loadedsavepref, nullreal
	pos.x := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	pos.y := round (nullreal * blocksize)
	if headcolour = 983 then
	    get : loadedsavepref, headcolour
	else
	    get : loadedsavepref, nullreal
	end if
	if bgcolour = 983 then
	    get : loadedsavepref, bgcolour
	else
	    get : loadedsavepref, nullreal
	end if
	if blockcolour = 983 then
	    get : loadedsavepref, blockcolour
	else
	    get : loadedsavepref, nullreal
	end if
	if keepmapblocksize then
	    get : loadedsavepref, blocksize
	else
	    get : loadedsavepref, nullreal
	end if
	get : loadedsavepref, nullreal
	offsetx := nullreal * blocksize
	get : loadedsavepref, nullreal
	offsety := nullreal * blocksize
	get : loadedsavepref, nullreal
	groundlevel := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	mstScrnHsGnUp := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	mstScrnHsGnDwn := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	mstScrnHsGnLft := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	mstScrnHsGnRght := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	offsetupdown := nullreal * blocksize
	get : loadedsavepref, nullreal
	offsetleftright := nullreal * blocksize
	get : loadedsavepref, health
	get : loadedsavepref, survival
	close : loadedsavepref
    else
	if headcolour = 983 then
	    headcolour := white
	end if
	if bgcolour = 983 then
	    bgcolour := white
	end if
	if blockcolour = 983 then
	    blockcolour := black
	end if
	groundlevel := ((floor (groundlevel / blocksize)) * blocksize)
	mstScrnHsGnUp := groundlevel
	mstScrnHsGnDwn := groundlevel
	pos.y := groundlevel + 10
    end if
end GetPreferences

%Assign values to variables that are calculated using "blocksize"
procedure AssignBlocksizeVariables
    crosshairsbb := Pic.Scale (crosshairsbbpre, blocksize, blocksize)
    crosshairsbb2 := Pic.Scale (crosshairsbbpre2, blocksize, blocksize)
    crosshairspb := Pic.Scale (crosshairspbpre, blocksize, blocksize)
    crosshairspb2 := Pic.Scale (crosshairspbpre2, blocksize, blocksize)
    Pic.SetTransparentColor (crosshairsbb2, 7)
    Pic.SetTransparentColor (crosshairspb2, 7)
    jumpheight := round (numblockscanjump * blocksize)
    reach := numblockscanreach * blocksize
end AssignBlocksizeVariables

%Generate world
procedure GenerateWorld
    if loaded then %Load world
	var rightest, leftest, downest : int
	var firstblock : boolean := true
	seek : loadedsave, 0
	if eof (loadedsave) = false then
	    loop
		get : loadedsave, textfound
		block (strint (textfound)) := true
		var xInd : int := decodeX (strint (textfound), false)
		var yInd : int := decodeY (strint (textfound), false)
		if firstblock then
		    firstblock := false
		    rightest := xInd
		    leftest := xInd
		    downest := yInd
		else
		    if xInd < leftest then
			leftest := xInd
		    end if
		    if xInd > rightest then
			rightest := xInd
		    end if
		    if yInd < downest then
			downest := yInd
		    end if
		end if
		x := xInd * blocksize + round (offsetleftright)
		y := yInd * blocksize + round (offsetupdown)
		Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
		put : autosave, textfound
		exit when eof (loadedsave)
	    end loop
	    textfound := loadfile
	end if
	close : loadedsave

	%Turn the "void"s in the loaded world into proper "0"s.
	for i : leftest .. rightest % or, (mostscnhasgoneleft - windowwidth div 2) * blocksize+1 and then also the other one
	    var startFilling : boolean := false
	    for i2 : downest .. groundlevel
		tempcoords (1) := encodeLite (i, i2)
		if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) = true then
		    startFilling := true
		end if
		if startFilling and #block (tempcoords (1)) = boolUnInit then
		    block (tempcoords (1)) := false
		end if
	    end for
	end for
    else %Generate ground
	x := -blocksize * 3
	y := -blocksize * 3
	loop
	    blkount += 1
	    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
	    tempcoords (1) := encode (x, y)
	    block (tempcoords (1)) := true
	    put : autosave, tempcoords (1)
	    x += blocksize
	    if x >= maxx + blocksize * 3 then
		x := -blocksize * 3
		y += blocksize
	    end if
	    exit when y >= groundlevel
	end loop
	textfound := ""
    end if
end GenerateWorld

%World preview feature
procedure WorldPreview
    if preview then
	cls
	loop
	    Draw.FillBox (0, 0, maxx, maxy, bgcolour)
	    Input.KeyDown (arrow)
	    seek : autosave, 0
	    if eof (autosave) = false then
		loop
		    get : autosave, autocoords
		    if block (autocoords) then
			x := decodeX (autocoords, false) + offsetprevlr + (midx - midx div 16)
			y := decodeY (autocoords, false) + offsetprevud + (midy - midy div 16)
			Draw.Dot (x, y, blockcolour)
		    end if
		    exit when eof (autosave)
		end loop
	    end if
	    View.Update
	    if arrow ('a') or arrow (KEY_LEFT_ARROW) then
		offsetprevlr -= 10
	    elsif arrow ('d') or arrow (KEY_RIGHT_ARROW) then
		offsetprevlr += 10
	    end if
	    if arrow ('w') or arrow (KEY_UP_ARROW) then
		offsetprevud += 10
	    elsif arrow ('s') or arrow (KEY_DOWN_ARROW) then
		offsetprevud -= 10
	    end if
	    if arrow ('p') then
		offsetprevlr := 0
		offsetprevud := 0
		gmfrstmthrgh := false
		returningFromPreview := true
		exit
	    end if
	end loop

	%Reset colour defaults
	if resetdefaultbg then
	    bgcolour := 983
	    resetdefaultbg := false
	end if
	if resetdefaulthead then
	    headcolour := 983
	    resetdefaulthead := false
	end if
	if resetdefaultblk then
	    blockcolour := 983
	    resetdefaultblk := false
	end if
	close : autosave
    end if
end WorldPreview

%Beginning of main loop processes

%If character must crawl
procedure CharMustCrawl
    if Pic.Height (stand) > blocksize then
	mustcrawl := false
	var headHeightLevel : real := topSide (false)
	if length (action) >= 8 and action (1 .. 8) = "crawling" then
	    headHeightLevel += blocksize
	end if
	var checkCount : int := ceil (charwidth / blocksize)
	if asBlockX (rightSide (false)) - asBlockX (leftSide (false)) > blocksize * (checkCount - 1) then
	    checkCount += 1
	end if
	for i : 0 .. checkCount - 1
	    if isBlock (leftSide (false) + i * blocksize, headHeightLevel) then
		mustcrawl := true
		exit
	    end if
	end for
    end if
end CharMustCrawl

%Get input for keyboard and parallelport
procedure KeyAndParallelInput
    %Reset input variables
    keyspc := false
    keya := false
    keys := false
    keyd := false
    keyp := false

    %Assign input variables for keyboard
    if arrow (' ') then
	keyspc := true
    end if
    if arrow ('a') or arrow (KEY_LEFT_ARROW) then
	keya := true
    end if
    if arrow ('s') or arrow (KEY_DOWN_ARROW) then
	keys := true
    end if
    if arrow ('d') or arrow (KEY_RIGHT_ARROW) then
	keyd := true
    end if
    if arrow ('p') then
	keyp := true
    end if

    %If parallel port input is enabled
    if parallelinput then
	%Get parallel port input
	val := parallelget

	%Assign input variables for parallel port
	if val = 1 or val = 1 + 2 then %Etc., etc., ...
	    keyspc := true
	end if
	if val = 2 then
	    keya := true
	end if
	if val = 3 then
	    keys := true
	end if
	if val = 4 then
	    keyd := true
	end if
	if val = 5 then
	    keyp := true
	end if
    end if
end KeyAndParallelInput

%Screen sliding
procedure ScreenSlide
    seek : autosave, 0
    if eof (autosave) = false and (leftSide (false) <= pxscrollclearance or rightSide (false) >= maxx - pxscrollclearance
	    or pos.y <= pxscrollclearance or topSide (false) >= maxy - pxscrollclearance) then
	if leftSide (false) <= pxscrollclearance then
	    screenscroll (0.33, 0)
	    pos.x += 0.33
	    oldPos.x += 0.33
	elsif rightSide (false) >= maxx - pxscrollclearance then
	    screenscroll (-0.33, 0)
	    pos.x -= 0.33
	    oldPos.x -= 0.33
	end if
	if pos.y <= pxscrollclearance then
	    screenscroll (0, 1)
	    pos.y += 1
	    oldPos.y += 1
	elsif topSide (false) >= maxy - pxscrollclearance then
	    screenscroll (0, -1)
	    pos.y -= 1
	    oldPos.y -= 1
	end if

	%reset x and y offsets
	if offsetx >= blocksize then
	    offsetx -= blocksize
	elsif offsetx < 0 then
	    offsetx += blocksize
	end if
	if offsety >= blocksize then
	    offsety -= blocksize
	elsif offsety < 0 then
	    offsety += blocksize
	end if
    else
	seek : autosave, *
    end if
end ScreenSlide

%How the aim guide moves in accordance with the mouse
procedure AimGuideMovement
    %Height that the character's hands are
    var handheight := round (pos.y) + charheight div 3 * 2
    if Math.Distance (pos.x, handheight, xm, ym) = 0 then
	xinc := (xm - pos.x) / 0.1
    else
	xinc := (xm - pos.x) / Math.Distance (pos.x, handheight, xm, ym)
    end if
    if Math.Distance (pos.x, handheight, xm, ym) = 0 then
	yinc := (ym - handheight) / 0.1
    else
	yinc := (ym - handheight) / Math.Distance (pos.x, handheight, xm, ym)
    end if
    tempi := round (reach)
    if not infinatePlacing then
	for i : 1 .. round (reach)
	    if norcursorinput = false then
		rcursorxbb := ((floor ((pos.x + xinc * i - floor (offsetx)) / blocksize)) * blocksize) + round (offsetx)
		rcursorybb := ((floor ((handheight + yinc * i - floor (offsety)) / blocksize)) * blocksize) + round (offsety)
		rcursorxpb := rcursorxbb
		rcursorypb := rcursorybb
		tempcoords (1) := encode (rcursorxbb, rcursorybb)
		if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) then
		    tempi := i
		    rcursorxbb := (floor ((pos.x + xinc * i - floor (offsetx)) / blocksize)) * blocksize + round (offsetx)
		    rcursorybb := (floor ((handheight + yinc * i - floor (offsety)) / blocksize)) * blocksize + round (offsety)
		    rcursorxpb := (floor ((pos.x + xinc * (i - 1) - floor (offsetx)) / blocksize)) * blocksize + round (offsetx)
		    rcursorypb := (floor ((handheight + yinc * (i - 1) - floor (offsety)) / blocksize)) * blocksize + round (offsety)
		    norcursorinput := true
		end if
	    end if
	end for
    else
	rcursorxbb := ((floor ((xm - round (offsetx)) / blocksize)) * blocksize) + round (offsetx)
	rcursorybb := ((floor ((ym - round (offsety)) / blocksize)) * blocksize) + round (offsety)
	rcursorxpb := rcursorxbb
	rcursorypb := rcursorybb
    end if

    norcursorinput := false
    if Math.Distance (pos.x, handheight, xm, ym) < Math.Distance (pos.x, handheight, pos.x + xinc * tempi, handheight + yinc * tempi) then
	rcursorxbb := (floor ((xm - floor (offsetx)) / blocksize)) * blocksize + round (offsetx)
	rcursorybb := (floor ((ym - floor (offsety)) / blocksize)) * blocksize + round (offsety)
	rcursorxpb := (floor ((xm - floor (offsetx)) / blocksize)) * blocksize + round (offsetx)
	rcursorypb := (floor ((ym - floor (offsety)) / blocksize)) * blocksize + round (offsety)
    end if
end AimGuideMovement

%If player right-clicks
procedure PlayerRightClick
    if cm = 100 and health > 0 then
	if mclickr = 0 then
	    mclickr := blockplacespeed
	end if
	if mclickr = blockplacespeed then
	    if (rcursorxpb not= asBlockX (leftSide (false)) and rcursorxpb not= asBlockX (rightSide (false))) or rcursorypb not= asBlockY (pos.y) then
		tempcoords (1) := encode (rcursorxpb, rcursorypb)
		x := rcursorxpb
		y := rcursorypb
		tempcoords (2) := encode (x + blocksize, y)
		tempcoords (3) := encode (x - blocksize, y)
		tempcoords (4) := encode (x, y + blocksize)
		tempcoords (5) := encode (x, y - blocksize)
		if infinatePlacing or #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) or #block (tempcoords (3)) not= boolUnInit and block (tempcoords (3)) or
		    #block (tempcoords (4)) not= boolUnInit and block (tempcoords (4)) or #block (tempcoords (5)) not= boolUnInit and block (tempcoords (5)) then
		    if ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) then
			Draw.FillBox (rcursorxpb, rcursorypb, rcursorxpb + (blocksize - 1), rcursorypb + (blocksize - 1), blockcolour) %draws block you clicked, until a screen scroll/update
			block (tempcoords (1)) := true
			blkount += 1
			seek : autosave, *
			put : autosave, tempcoords (1)
		    end if
		end if
	    end if
	end if
	mclickr -= 1
	if mclickr = -1 then
	    mclickr := blockplacespeed
	end if
    else
	mclickr := 0
    end if
end PlayerRightClick

%If player left-clicks
procedure PlayerLeftClick
    if cm = 1 and health > 0 then
	if mclickl = 0 then
	    mclickl := blockbreakspeed
	end if
	if mclickl = blockbreakspeed then
	    tempcoords (1) := encode (rcursorxbb, rcursorybb)
	    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) then
		Draw.FillBox (rcursorxbb, rcursorybb, rcursorxbb + (blocksize - 1), rcursorybb + (blocksize - 1), bgcolour)
		block (tempcoords (1)) := false
		blkount -= 1
	    end if
	end if
	mclickl -= 1
	if mclickl = -1 then
	    mclickl := blockbreakspeed
	end if
    else
	mclickl := 0
    end if
end PlayerLeftClick

%If 'p' key is pressed
procedure PressPKey
    if keyp then
	inPauseMenu := true
	View.Set ("nooffscreenonly")
	oldbackcolour := bgcolour
	oldblockcolour := blockcolour
	fork pauseguis
	Pic.Free (screenpic)
	screenpic := Pic.New (0, 0, maxx, maxy)
	Draw.FillBox (0, 0, maxx, maxy, bgcolour)
	GUI.ResetQuit
	GUI.Show (btnend)
	GUI.ShowMenuBar
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, headcolour)
	Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	Draw.Text (colourstringify (headcolour) + " head", 1, maxy - 90, font2, black)
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	Draw.Text (colourstringify (bgcolour) + " background", 100, maxy - 90, font2, black)
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, blockcolour)
	Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	Draw.Text (colourstringify (blockcolour) + " blocks", 238, maxy - 90, font2, black)
	loop
	    exit when startgame
	end loop

	%If the quit button has not been clicked
	if not quitthegame then

	    %Temporarily disable and hide all GUIs
	    GUI.Quit
	    GUI.Hide (saveButton)
	    GUI.Hide (nameTextField)
	    GUI.Hide (nameLabel)
	    GUI.Hide (btncont)
	    GUI.Hide (btnend)
	    GUI.Hide (mainMenuButton)
	    GUI.HideMenuBar

	    %Reset game-continuing variable
	    startgame := false
	    View.Set ("offscreenonly")

	    %Loading screen
	    loading (bgcolour)

	    %Updates block and background colours
	    if oldblockcolour not= blockcolour or oldbackcolour not= bgcolour then
		Draw.FillBox (0, 0, maxx, maxy, bgcolour)
		seek : autosave, 0
		if eof (autosave) = false then
		    loop
			get : autosave, autocoords
			if block (autocoords) then
			    x := decodeX (autocoords, true)
			    y := decodeY (autocoords, true)
			    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
			end if
			exit when eof (autosave)
		    end loop
		end if
		seek : autosave, *
	    else
		Pic.Draw (screenpic, 0, 0, picCopy)
	    end if
	    View.Update
	end if
	inPauseMenu := false
    end if
end PressPKey

%If 'd' key is pressed
procedure PressDKey
    if keyd and health > 0 then
	if recentstartd then
	    recentstartd := false
	    if sprintpossibled2 = 0 then
		sprintpossibled1 := doubletapspeed
	    end if
	end if
	if sprintpossibled2 not= 0 and (onground or flying) then
	    sprintpossibled1 := 0
	    sprintpossibled2 := 0
	    sprintd := true
	end if
	if keys and onground or mustcrawl then
	    if flying then
		if not onrightwall then
		    pos.x += playerSpeed * 4 * deltaTime
		end if
	    else
		if not onrightwall then
		    pos.x += playerSpeed / 2 * deltaTime
		end if
	    end if
	elsif sprintd then
	    if flying then
		if not onrightwall then
		    pos.x += playerSpeed * 8 * deltaTime
		end if
	    else
		if not onrightwall then
		    pos.x += playerSpeed * 2 * deltaTime
		end if
	    end if
	else
	    if flying then
		if not onrightwall then
		    pos.x += playerSpeed * 4 * deltaTime
		end if
	    else
		if not onrightwall then
		    pos.x += playerSpeed * deltaTime
		end if
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
    %Timers for double-tapping to sprint right
    if sprintpossibled1 not= 0 then
	sprintpossibled1 -= 1
    end if
    if sprintpossibled2 not= 0 then
	sprintpossibled2 -= 1
    end if
end PressDKey

%If 'a' key is pressed
procedure PressAKey
    if keya and health > 0 then
	if recentstarta then
	    recentstarta := false
	    if sprintpossiblea2 = 0 then
		sprintpossiblea1 := doubletapspeed
	    end if
	end if
	if sprintpossiblea2 not= 0 and (onground or flying) then
	    sprintpossiblea1 := 0
	    sprintpossiblea2 := 0
	    sprinta := true
	end if
	if keys and onground or mustcrawl then
	    if flying then
		if not onleftwall then
		    pos.x -= playerSpeed * 4 * deltaTime
		end if
	    else
		if not onleftwall then
		    pos.x -= playerSpeed / 2 * deltaTime
		end if
	    end if
	else
	    if sprinta then
		if flying then
		    if not onleftwall then
			pos.x -= playerSpeed * 8 * deltaTime
		    end if
		else
		    if not onleftwall then
			pos.x -= playerSpeed * 2 * deltaTime
		    end if
		end if
	    else
		if flying then
		    if not onleftwall then
			pos.x -= playerSpeed * 4 * deltaTime
		    end if
		else
		    if not onleftwall then
			pos.x -= playerSpeed * deltaTime
		    end if
		end if
	    end if
	end if
	action := "walking"
	facing := "left"
	recentstopa := true
    else
	recentstarta := true
	sprinta := false
	if recentstopa and sprintpossiblea1 not= 0 then
	    recentstopa := false
	    sprintpossiblea2 := doubletapspeed
	end if
    end if
    %Timers for double-tapping to sprint left
    if sprintpossiblea1 not= 0 then
	sprintpossiblea1 -= 1
    end if
    if sprintpossiblea2 not= 0 then
	sprintpossiblea2 -= 1
    end if
end PressAKey

%If spacebar is pressed
procedure PressSpaceKey
    if keyspc and health > 0 and (onground or flying) and mustcrawl = false and hitceiling = false then
	if flying then
	    pos.y += playerSpeed * 8 * deltaTime
	else
	    jumpcount := jumpheight
	end if
    end if
end PressSpaceKey

%If 's' key is pressed
procedure PressSKey
    if keys and health > 0 then
	if onground then
	    if keya or keyd then
		action := "crawling"
	    else
		action := "crawlingstop"
	    end if
	elsif flying then
	    pos.y -= playerSpeed * 8 * deltaTime
	end if
    end if
end PressSKey

%Jumping
procedure CharJump
    if mustcrawl = false and flying = false then
	if jumpcount = jumpheight then
	    facing := ""
	end if
	if jumpcount > 0 then
	    action := "jumping"
	    if hitceiling then
		jumpcount := 0
	    else
		if jumpcount >= 18 then %movegap: every 2.5th frame (2, then 3, then 2, then 3)
		    pos.y += gravAmount * deltaTime
		    jumpcount -= gravAmount * deltaTime
		elsif jumpcount >= 9 and jumpcount < 18 then %movegap: every 4th frame
		    pos.y += gravAmount * 0.6 * deltaTime
		    jumpcount -= gravAmount * 0.6 * deltaTime
		elsif jumpcount < 9 then %movegap: every 8th frame
		    pos.y += gravAmount * 0.3 * deltaTime
		    jumpcount -= gravAmount * 0.3 * deltaTime
		end if
	    end if
	elsif jumpcount < 0 then
	    jumpcount := 0
	end if
    end if
end CharJump

%If character is on the ground
procedure CharOnGround
    %if this frame's blockrounded ground position is in a block, and last frame's isn't, then move to between those two positions
    %such that you are not inside a block. Easy to do - just round current position to last position's block.
    var fellIntoBlock : boolean := false
    var blockBelow : boolean := false
    var checkCount : int := ceil (charwidth / blocksize)
    if asBlockX (rightSide (false)) - asBlockX (leftSide (false)) > blocksize * (checkCount - 1) then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	if isBlock (leftSide (false) + i * blocksize, pos.y) and not isBlock (leftSide (false) + i * blocksize, oldPos.y) then
	    fellIntoBlock := true
	    exit
	elsif isBlock (leftSide (false) + i * blocksize, pos.y - blocksize) then
	    blockBelow := true
	end if
    end for

    if fellIntoBlock then
	onground := true
	pos.y := asBlockY (oldPos.y)
    else
	if blockBelow and pos.y = asBlockY (pos.y) then
	    onground := true
	else
	    onground := false
	end if
    end if
end CharOnGround

%If character is against a wall to the left
procedure CharOnLeftWall
    var movedIntoBlock : boolean := false
    var blockBeside : boolean := false
    var checkCount : int := ceil (charheight / blocksize)
    if asBlockY (topSide (false)) - asBlockY (pos.y) > blocksize * (checkCount - 1) then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	if isBlock (leftSide (false), pos.y + i * blocksize) and not isBlock (leftSide (true), pos.y + i * blocksize) then
	    movedIntoBlock := true
	    exit
	elsif isBlock (leftSide (false) - blocksize, pos.y + i * blocksize) then
	    blockBeside := true
	end if
    end for

    if movedIntoBlock then
	onleftwall := true
	put "aaaaaaaa"
	pos.x := asBlockX (leftSide (true)) + charwidth div 2
    else
	if blockBeside and leftSide (false) = asBlockX (leftSide (false)) then
	    onleftwall := true
	else
	    onleftwall := false
	end if
    end if
end CharOnLeftWall

%If character is against a wall to the right
procedure CharOnRightWall
    var movedIntoBlock : boolean := false
    var blockBeside : boolean := false
    var checkCount : int := ceil (charheight / blocksize)
    if asBlockY (topSide (false)) - asBlockY (pos.y) > blocksize * (checkCount - 1) then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	if isBlock (rightSide (false), pos.y + i * blocksize) and not isBlock (rightSide (true), pos.y + i * blocksize) then
	    movedIntoBlock := true
	    exit
	elsif isBlock (rightSide (false) + blocksize, pos.y + i * blocksize) then
	    blockBeside := true
	end if
    end for

    if movedIntoBlock then
	onrightwall := true
	pos.x := asBlockX (rightSide (true)) + blocksize - charwidth div 2 - 1
    else
	if blockBeside and rightSide (false) = asBlockX (rightSide (false)) + blocksize - 1 then
	    onrightwall := true
	else
	    onrightwall := false
	end if
    end if
end CharOnRightWall

%If character is against the ceiling
procedure CharHitCeiling
    var flewIntoBlock : boolean := false
    var blockAbove : boolean := false
    var checkCount : int := ceil (charwidth / blocksize)
    if asBlockX (rightSide (false)) - asBlockX (leftSide (false)) > blocksize * (checkCount - 1) then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	if isBlock (leftSide (false) + i * blocksize, topSide (false)) and not isBlock (leftSide (false) + i * blocksize, topSide (true)) then
	    flewIntoBlock := true
	    exit
	elsif isBlock (leftSide (false) + i * blocksize, topSide (false) + blocksize) then
	    blockAbove := true
	end if
    end for

    if flewIntoBlock then
	hitceiling := true
	pos.y := asBlockY (topSide (true)) + blocksize - charheight - 1
    else
	if blockAbove and topSide (false) = asBlockY (topSide (false)) + blocksize - 1 then
	    hitceiling := true
	else
	    hitceiling := false
	end if
    end if
end CharHitCeiling

procedure WorldCollisions
    CharOnGround

    CharOnLeftWall

    CharOnRightWall

    CharHitCeiling

end WorldCollisions

%Gravity
procedure Gravity
    if onground = false and jumpcount = 0 and flying = false then
	action := "falling"
	if gravcount < 9 then %movegap: every 8th frame
	    pos.y -= gravAmount * 0.3 * deltaTime
	    gravcount += gravAmount * 0.3 * deltaTime
	elsif gravcount >= 9 and gravcount < 18 then %movegap: every 4th frame
	    pos.y -= gravAmount * 0.6 * deltaTime
	    gravcount += gravAmount * 0.6 * deltaTime
	elsif gravcount >= 18 and gravcount < 30 then %movegap: every 2.5th frame
	    pos.y -= gravAmount * deltaTime
	    gravcount += gravAmount * deltaTime
	elsif gravcount >= 30 and gravcount < 70 then %movegap: every other frame
	    pos.y -= gravAmount * 1.25 * deltaTime
	    gravcount += gravAmount * 1.25 * deltaTime
	elsif gravcount >= 70 then
	    pos.y -= gravAmount * 2.5 * deltaTime
	    gravcount += gravAmount * 2.5 * deltaTime
	end if
    end if

    %On solid ground reset gravity and calculate fall damage
    if onground and gravcount not= 0 then
	if survival then
	    if staticfalldamage then
		if gravcount >= blocksize * 5 then
		    locate (1, 1)
		    %put round (((gravcount - blocksize * 4) / (blocksize * 15)) * 1000)
		    health -= round (((gravcount - blocksize * 4) / (blocksize * 15)) * 1000)
		end if
	    else
		if gravcount >= blocksize * 5 then
		    health -= 100
		end if
	    end if
	end if
	gravcount := 0
    end if
end Gravity

procedure SetHealth
    if health < 0 then
	health := 0
    end if
end SetHealth

%Finish the first part of assigning a usable value to "action"
procedure FinalizeAction1
    %Incorporate looking direction into action when not jumping or falling
    if health > 0 and action (1 .. 7) not= "jumping" and action (1 .. 7) not= "falling" then
	if cm not= 0 then
	    if xm >= pos.x then
		facing := "right"
	    else
		facing := "left"
	    end if
	end if
    end if

    if health = 0 then
	action := "dying"
    end if

    %Incorporate motion direction into action
    if health = 0 and onground or health not= 0 then
	if facing not= "" then
	    action += " "
	end if
	action += facing
    end if

    if action = "dying" then
	action += "xx"
    end if

    %Incorporate looking direction into action when jumping or falling
    if action (1 .. 7) = "jumping" or action (1 .. 7) = "falling" then
	if cm not= 0 then
	    if xm >= pos.x then
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
end FinalizeAction1

%Crawling and walking animations
procedure Animations
    %Walking animation
    if frametimer >= 30 and not isAction ("crawling") and (sprinta or sprintd) or frametimer >= 50 and not isAction ("crawling") then
	frametimer := 0
	if wlk = 4 then
	    ponwlk := -1
	elsif wlk = 1 then
	    ponwlk := 1
	end if
	wlk += ponwlk
    end if

    %Crawling animation
    if frametimer >= 80 and isAction ("crawling") then
	frametimer := 0
	if crl = 4 then
	    poncrl := -1
	elsif crl = 1 then
	    poncrl := 1
	end if
	crl += poncrl
    end if
end Animations

%Finish the second part of assigning a usable value to "action"
procedure FinalizeAction2
    %Directionless fall
    if (action = "falling left" or action = "falling right") and keya = false and keyd = false and onground = false then
	action := "falling"
    end if

    %Character image used if forced crawling
    if mustcrawl then
	if action = "standing" then
	    action := "crawlingstop"
	elsif action = "walking left" then
	    action := "crawling left"
	elsif action = "walking right" then
	    action := "crawling right"
	elsif action = "standing left" then
	    action := "crawlingstop left"
	elsif action = "standing right" then
	    action := "crawlingstop right"
	end if
    end if
end FinalizeAction2

%What character image is being used
procedure CharImage
    if health not= 0 then
	if cm = 0 then %Image if not clicking
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
	else %Image if clicking
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
		if xm >= pos.x then
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
		if xm >= pos.x then
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
    else
	if action = "dyingxx" then
	    character := dead
	elsif action = "dying left" then
	    character := deadl
	elsif action = "dying right" then
	    character := deadr
	end if
    end if
end CharImage

%Draw character image and head colour
procedure CharDraw
    %Draw character's head colour
    if action = "dying left" then
	Draw.FillOval (round (pos.x) - 4, round (pos.y) + 4, 3, 3, headcolour)
    elsif action = "dying right" then
	Draw.FillOval (round (pos.x) + 4, round (pos.y) + 4, 3, 3, headcolour)
    elsif action = "crawling left" or action = "crawlingstop left" then
	Draw.FillOval (round (pos.x) - 4, round (pos.y) + 8, 3, 3, headcolour)
    elsif action = "crawling right" or action = "crawlingstop right" or action = "crawlingstop" then
	Draw.FillOval (round (pos.x) + 4, round (pos.y) + 8, 3, 3, headcolour)
    else
	Draw.FillOval (round (pos.x), round (pos.y) + 21, 3, 3, headcolour)
    end if

    %Draw character
    Pic.Draw (character, round (pos.x - charwidth div 2), round (pos.y), picMerge)
end CharDraw

%Save background behind aim guides and draw them
procedure AimGuideBacksaveAndDraw
    if health > 0 then
	%Get blocks at block placing box and block breaking crosshairs
	tempcoords (1) := encode (rcursorxbb, rcursorybb)
	tempcoords (2) := encode (rcursorxpb, rcursorypb)

	if tempcoords (1) not= tempcoords (2) then
	    %Save background behind crosshairs
	    backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	    %Save background behind box
	    backpicbox := Pic.New (rcursorxpb, rcursorypb, rcursorxpb + blocksize - 1, rcursorypb + blocksize - 1)

	    %Draw crosshairs for breaking blocks
	    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) and blockcolour = black
		    or ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and bgcolour = black then
		Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
	    else
		Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
	    end if

	    %Draw box for placing blocks
	    if #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) and blockcolour = black
		    or ( #block (tempcoords (2)) = boolUnInit or block (tempcoords (2)) = false) and bgcolour = black then
		Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	    else
		Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	    end if
	else
	    %Save background behind crosshairs and box
	    backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	    %Draw crosshairs for breaking blocks and box for placing blocks
	    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) and blockcolour = black
		    or ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and bgcolour = black then
		Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
		Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	    else
		Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
		Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	    end if
	end if
    end if
end AimGuideBacksaveAndDraw

%Draw the health bar and save its background
procedure DrawHealthBar
    if survival then
	Pic.Free (healthbarback)
	healthbarback := Pic.New (maxx div 8 - 1, 19, (maxx div 4 * 3) + maxx div 8 + 1, 41)
	if health not= 0 then
	    if health not= healthold then
		var mainmaxx : int := maxx
		Window.SetActive (winID)
		Pic.Free (healthbar)
		healthbar := Pic.New (0, 0, round ((mainmaxx div 4 * 3 / 100) * (health / 10)), 20)
		Window.SetActive (MainWinID)
		healthold := health
	    end if
	    Pic.Draw (healthbar, maxx div 8, 20, picMerge)
	    Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, 10)
	else
	    Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, brightred)
	end if
    end if
end DrawHealthBar

procedure IfDeadGameOver
    if health = 0 then
	Draw.Text ("Game Over", midx - 150, midy, font1, red)
    end if
end IfDeadGameOver

%Erase the health bar by redrawing its background
procedure EraseHealthBar
    if survival then
	Pic.Draw (healthbarback, maxx div 8 - 1, 19, picCopy)
    end if
end EraseHealthBar

%Erase guide graphics
procedure EraseAimGuide
    if health > 0 then
	if tempcoords (1) not= tempcoords (2) then
	    %Draw old unaltered block over crosshairs for breaking blocks
	    Pic.Draw (backpiccross, rcursorxbb, rcursorybb, picCopy)
	    Pic.Free (backpiccross)

	    %Draw old unaltered block over box for placing blocks
	    Pic.Draw (backpicbox, rcursorxpb, rcursorypb, picCopy)
	    Pic.Free (backpicbox)
	else
	    %Draw old unaltered block over crosshairs for breaking blocks and box for placing blocks
	    Pic.Draw (backpiccross, rcursorxbb, rcursorybb, picCopy)
	    Pic.Free (backpiccross)
	end if
    end if
end EraseAimGuide

%End of main loop procedures

procedure resetVariables
    close : autosave
    sprintpossibled1 := 0
    sprintpossibled2 := 0
    sprintpossiblea1 := 0
    sprintpossiblea2 := 0
    blocknum := 0
    gravcount := 0
    jumpcount := 0
    frametimer := 0
    wlk := 0
    crl := 0
    blkount := 0
    x := 0
    y := 0
    iprevsaves := 0
    ireassign := 0
    jumpheight := 0
    crosshairsbb2 := 0
    crosshairsbb := 0
    crosshairspb2 := 0
    crosshairspb := 0
    mclickr := 0
    mclickl := 0
    guidecolour := 0
    offsetx := 0
    offsety := 0
    offsetleftright := 0
    mstScrnHsGnLft := 0
    mstScrnHsGnRght := 0
    offsetprevlr := 0
    offsetprevud := 0
    offsetupdown := 0
    healthold := 0
    oldbackcolour := white
    oldblockcolour := black
    gmfrstmthrgh := false
    onground := false
    onleftwall := false
    onrightwall := false
    hitceiling := false
    walkleft := false
    walkright := false
    oldface := false
    sprintd := false
    sprinta := false
    recentstopd := false
    recentstartd := false
    recentstopa := false
    recentstarta := false
    mustcrawl := false
    startgame := false
    recentclick := false
    loaded := false
    quitthegame := false
    norcursorinput := false
    keyspc := false
    keya := false
    keys := false
    keyd := false
    keyp := false
    preview := false
    inmainmenu := false
    resetdefaultbg := false
    resetdefaulthead := false
    resetdefaultblk := false
    canfly := false
    flying := false
    menuReturn := false
    forcedelete := false
    charwidth := Pic.Width (stand)
    charheight := Pic.Height (stand)
    pos.x := midx + 2
    pos.y := 200
    health := 1000
    action := "standing"
    facing := ""
    oldfacing := ""
    loadfile := ""
    headcolour := 983
    bgcolour := 983
    blockcolour := 983
    ponwlk := 1
    poncrl := 1
    isaves := 1
    oktosavenew := true
    frstmthrgh := true
    loading (white)
    View.Update
    for i : (2498 - (round ((mstScrnHsGnUp) / blocksize) + 1)) * 10000 .. (2500 + (round (((mstScrnHsGnDwn * (-1)) + maxx) / blocksize) + 1)) * 10000
	#block (i) := boolUnInit
    end for
end resetVariables

%Entire program loop
loop
    %Main menu loop
    loop

	if not returningFromPreview then
	    %open text file of all saved files' names
	    open : savenames, ("Savenames.txt"), get, put, seek, mod

	    %Create a list of all saved files' names
	    if eof (savenames) = false then
		loop
		    isaves += 1
		    get : savenames, menuitemsaves (isaves) : *
		    menuitemdelete (isaves - 1) := (menuitemsaves (isaves))
		    exit when eof (savenames)
		end loop
	    end if

	    %close text file of all saved files' names
	    close : savenames
	end if

	%Clear and open autosave file
	open : autosave, ("Autosave.txt"), get, put, seek
	cls

	%Disables buffer drawing
	View.Set ("nooffscreenonly")

	colourback (white)
	Draw.FillBox (0, 0, maxx, maxy, white)

	ReEnableStartGUIs

	inmainmenu := true

	%Run the GUIs to be used in main and pause menus
	fork guis
	if #btnend not= 16#80000000 then
	    GUI.Show (btnend)
	end if

	ShowColourPreveiwDefault

	%Wait until user clicks "start" button
	loop
	    exit when startgame
	end loop

	if quitthegame then
	    exit
	end if

	%Save main menu screen
	Pic.Free (backpic)
	backpic := Pic.New (0, maxy - 210, 340, maxy - 35)

	%Get preview checkbox state
	if GUI.GetCheckBox (cbprev) then
	    preview := true
	else
	    preview := false
	end if

	%Get canfly checkbox state
	if GUI.GetCheckBox (cbfly) then
	    canfly := true
	else
	    canfly := false
	end if

	%Set default indicators
	if bgcolour = 983 then
	    resetdefaultbg := true
	end if
	if headcolour = 983 then
	    resetdefaulthead := true
	end if
	if blockcolour = 983 then
	    resetdefaultblk := true
	end if

	%Set program variables
	inmainmenu := false
	startgame := false

	DisableAndHideGUIs

	cls

	%Allows for smooth animation
	View.Set ("offscreenonly")

	%Second loading screen
	loading (white)

	GetPreferences

	AssignBlocksizeVariables

	%Update background colour
	Draw.FillBox (0, 0, maxx, maxy, bgcolour)

	GenerateWorld

	WorldPreview

	frstmthrgh := false
	if preview = false then
	    exit
	end if
    end loop

    if quitthegame then
	exit
    end if

    if canfly then
	flying := true
    end if

    loaded := false

    %Show world
    View.Update

    %Setting oldPos
    oldPos.x := pos.x
    oldPos.y := pos.y

    %Game program loop
    loop
	deltaTime := Time.Elapsed - gametimeold
	gametimeold := Time.Elapsed
	if deltaTime > 100 or deltaTime < 1 then
	    deltaTime := 1
	end if

	%Get mouse input
	Mouse.Where (xm, ym, cm)

	%Get keyboard input
	Input.KeyDown (arrow)

	CharMustCrawl

	%Character standing by default
	action := "standing"

	KeyAndParallelInput

	ScreenSlide

	AimGuideMovement

	PlayerRightClick

	PlayerLeftClick

	PressPKey
	if quitthegame then
	    GUI.Quit
	    exit
	elsif menuReturn then
	    menuReturn := false
	    exit
	end if

	PressDKey

	PressAKey

	PressSpaceKey

	PressSKey

	CharJump

	Gravity

	WorldCollisions

	FinalizeAction1

	Animations

	%Stop sprinting if crawling
	if isAction ("crawling") then
	    sprintd := false
	    sprinta := false
	end if

	FinalizeAction2

	CharImage

	%Get character dimensions
	charwidth := Pic.Width (character)
	charheight := Pic.Height (character)

	%Save background behind character
	Pic.Free (backpic)
	backpic := Pic.New (round (pos.x - charwidth div 2 - charudpxrange), round (pos.y) - charudpxrange,
	    round (pos.x + charwidth div 2 + charudpxrange), round (pos.y) + charheight + charudpxrange)

	SetHealth

	CharDraw

	AimGuideBacksaveAndDraw

	DrawHealthBar

	IfDeadGameOver

	locate (1, 1)
	put offsetleftright, "   ", pos.x, " ", pos.y
	put encode (pos.x, pos.y)
	put encodeVec (asBlock (pos.x, pos.y))
	put isBlock (leftSide (false), pos.y)
	%Drawing debug character inhabited boxes
	
	 Draw.FillOval (asBlockX (leftSide (false)), asBlockY (pos.y), 4, 4, yellow)
	 Draw.FillOval (asBlockX (rightSide (false)), asBlockY (pos.y), 4, 4, brightgreen)
	 Draw.FillOval (asBlockX (leftSide (false)), asBlockY (topSide (false)), 4, 4, brightblue)
	 Draw.FillOval (asBlockX (rightSide (false)), asBlockY (topSide (false)), 4, 4, brightred)
	 Draw.Box (asBlockX (leftSide (false)), asBlockY (pos.y), asBlockX (leftSide (false)) + blocksize, asBlockY (pos.y) + blocksize, yellow)
	 Draw.Box (asBlockX (rightSide (false)), asBlockY (pos.y), asBlockX (rightSide (false)) + blocksize, asBlockY (pos.y) + blocksize, brightgreen)
	 Draw.Box (asBlockX (leftSide (false)), asBlockY (topSide (false)), asBlockX (leftSide (false)) + blocksize, asBlockY (topSide (false)) + blocksize, brightblue)
	 Draw.Box (asBlockX (rightSide (false)), asBlockY (topSide (false)), asBlockX (rightSide (false)) + blocksize, asBlockY (topSide (false)) + blocksize, brightred)
	

	%Show new screen
	View.Update

	EraseHealthBar

	EraseAimGuide

	%Draw old unaltered background over character
	Pic.Draw (backpic, round (pos.x - charwidth div 2 - charudpxrange), round (pos.y) - charudpxrange, picCopy)

	%Setting oldPos
	oldPos.x := pos.x
	oldPos.y := pos.y

	%Movement timer
	frametimer += playerSpeed * 17 * deltaTime
    end loop
    if quitthegame then
	exit
    end if
    resetVariables
end loop

View.Set ("nooffscreenonly")
colourback (white)
cls

%Erase contents of autosave file
close : autosave
open : autosave, ("Autosave.txt"), get, put, seek
close : autosave

%Disable all active GUI functions
GUI.Disable (menuhead)
GUI.Disable (menubg)
GUI.Disable (menublk)
GUI.Disable (btnend)
if #btncont not= 16#80000000 then
    GUI.Disable (btncont)
    GUI.Hide (btncont)
end if
if #mainMenuButton not= 16#80000000 then
    GUI.Disable (mainMenuButton)
    GUI.Hide (mainMenuButton)
end if
GUI.Hide (btnend)
GUI.HideMenuBar
cls

put "Thanks For Playing!"
