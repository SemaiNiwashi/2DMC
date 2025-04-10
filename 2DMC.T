%Description: A program that is a game in which the player moves around by way of the peripheral device I have constructed, and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

%The reason that there is no "Return to main menu" feature is that when you try to put 1600+ lines of code in a loop, turing gives you an error.

%Make using GUI features possible
import GUI

%Program settings
View.Set ("graphics:640;400") %Smallest advisable:450,310
buttonchoose ("multibutton")
setscreen ("noecho")

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
const charudpxrange := 0
const parallelinput : boolean := false
const keepmapblocksize : boolean := false
const pxscrollclearance : int := 100
%Variable declarations
var blocksize : int := 16 %Must be > 15
var font1 := Font.New ("sans serif:40:bold")
var font2 := Font.New ("sans serif:8:bold")
var walkr : array 1 .. 4 of int
walkr (1) := Pic.FileNew ("walk1r.bmp")
walkr (2) := Pic.FileNew ("walk2r.bmp")
walkr (3) := Pic.FileNew ("walk3r.bmp")
walkr (4) := Pic.FileNew ("walk4r.bmp")
var walkl : array 1 .. 4 of int
walkl (1) := Pic.FileNew ("walk1l.bmp")
walkl (2) := Pic.FileNew ("walk2l.bmp")
walkl (3) := Pic.FileNew ("walk3l.bmp")
walkl (4) := Pic.FileNew ("walk4l.bmp")
var crawlr : array 1 .. 4 of int
crawlr (1) := Pic.FileNew ("crawl1r.bmp")
crawlr (2) := Pic.FileNew ("crawl2r.bmp")
crawlr (3) := Pic.FileNew ("crawl3r.bmp")
crawlr (4) := Pic.FileNew ("crawl4r.bmp")
var crawll : array 1 .. 4 of int
crawll (1) := Pic.FileNew ("crawl1l.bmp")
crawll (2) := Pic.FileNew ("crawl2l.bmp")
crawll (3) := Pic.FileNew ("crawl3l.bmp")
crawll (4) := Pic.FileNew ("crawl4l.bmp")
var walkrc : array 1 .. 4 of int
walkrc (1) := Pic.FileNew ("walk1rc.bmp") %click
walkrc (2) := Pic.FileNew ("walk2rc.bmp") %click
walkrc (3) := Pic.FileNew ("walk3rc.bmp") %click
walkrc (4) := Pic.FileNew ("walk4rc.bmp") %click
var walklc : array 1 .. 4 of int
walklc (1) := Pic.FileNew ("walk1lc.bmp") %click
walklc (2) := Pic.FileNew ("walk2lc.bmp") %click
walklc (3) := Pic.FileNew ("walk3lc.bmp") %click
walklc (4) := Pic.FileNew ("walk4lc.bmp") %click
var crawlrc : array 1 .. 4 of int
crawlrc (1) := Pic.FileNew ("crawl1rc.bmp") %click
crawlrc (2) := Pic.FileNew ("crawl2rc.bmp") %click
crawlrc (3) := Pic.FileNew ("crawl3rc.bmp") %click
crawlrc (4) := Pic.FileNew ("crawl4rc.bmp") %click
var crawllc : array 1 .. 4 of int
crawllc (1) := Pic.FileNew ("crawl1lc.bmp") %click
crawllc (2) := Pic.FileNew ("crawl2lc.bmp") %click
crawllc (3) := Pic.FileNew ("crawl3lc.bmp") %click
crawllc (4) := Pic.FileNew ("crawl4lc.bmp") %click
var jump : int := Pic.FileNew ("falljump.bmp")
var jumpcr : int := Pic.FileNew ("falljumpcr.bmp") %click
var jumpcl : int := Pic.FileNew ("falljumpcl.bmp") %click
var jumpr : int := Pic.FileNew ("jumpr.bmp")
var jumpl : int := Pic.FileNew ("jumpl.bmp")
var jumprc : int := Pic.FileNew ("jumprc.bmp") %click
var jumplc : int := Pic.FileNew ("jumplc.bmp") %click
var jumprl : int := Pic.FileNew ("jumprl.bmp") %click
var jumplr : int := Pic.FileNew ("jumplr.bmp") %click
var fallr : int := Pic.FileNew ("fallr.bmp")
var falll : int := Pic.FileNew ("falll.bmp")
var fallrc : int := Pic.FileNew ("fallrc.bmp") %click
var falllc : int := Pic.FileNew ("falllc.bmp") %click
var fallrl : int := Pic.FileNew ("fallrl.bmp") %click
var falllr : int := Pic.FileNew ("falllr.bmp") %click
var fall : int := Pic.FileNew ("falljump.bmp")
var fallcr : int := Pic.FileNew ("falljumpcr.bmp") %click
var fallcl : int := Pic.FileNew ("falljumpcl.bmp") %click
var stand : int := Pic.FileNew ("stand.bmp")
var standcr : int := Pic.FileNew ("standcr.bmp") %click
var standcl : int := Pic.FileNew ("standcl.bmp") %click
var crosshairsbbpre : int := Pic.FileNew ("crosshairsbb.bmp")
var crosshairsbbpre2 : int := Pic.FileNew ("crosshairsbb2.bmp")
var crosshairspbpre : int := Pic.FileNew ("crosshairspb.bmp")
var crosshairspbpre2 : int := Pic.FileNew ("crosshairspb2.bmp")
var charwidth : int := Pic.Width (stand)
var charheight : int := Pic.Height (stand)
var arrow : array char of boolean
var charx : int := midx + 2
var chary : int := 200
var backpic : int := Pic.New (0, 0, 2, 2)
var screenpic : int := Pic.New (0, 0, 2, 2)
var tempcoords : array 1 .. 5 of int
var xm, ym, cm, s, character, rcharxl, rcharyd, rcharxr, rcharyu, rcursorxbb, rcursorybb, rcursorxpb, rcursorypb, rcharydfloor, rcharyuceil,
    btnstrt, btncont, btnend, mainMenuButton, savenames, loadedsave, loadedsavepref, menuhead, menubg, menublk, menuload, saveButton, nameTextField, nameLabel,
    oldbackcolour, saveFile, autosave, menudelete, oldblockcolour, handheight, tempi, linegx, linegy, idelete, null, backpiccross, backpicbox,
    srx, sry, slx, sly, sux, suy, sdx, sdy, shiftspot, endspot, mstScrnHsGnUp, mstScrnHsGnDwn, val, autocoords, cbprev, cbfly, bigx, bigy : int
var sprintpossibled1, sprintpossibled2, sprintpossiblea1, sprintpossiblea2, blocknum, gravcount, jumpcount, movegap, wlk, crl, blkount, x, y,
    iprevsaves, ireassign, jumpheight, crosshairsbb2, crosshairsbb, crosshairspb2,
    crosshairspb, mclickr, mclickl, guidecolour, offsetx, offsety, offsetleftright, mstScrnHsGnLft, mstScrnHsGnRght, offsetupdown, offsetprevlr,
    offsetprevud : int := 0
var onground, onleftwall, onrightwall, hitceiling, walkleft, walkright, oldface, sprintd, sprinta, recentstopd, recentstartd, recentstopa, recentstarta,
    mustcrawl, startgame, recentclick, loaded, quitthegame, norcursorinput, keyspc, keya, keys, keyd, keyp, preview, inmainmenu, resetdefaultbg,
    resetdefaulthead, resetdefaultblk, canfly, flying, menuReturn, forcedelete : boolean := false
var action : string := "standing"
var textfound, deletesaveread, headcolourstr, bgcolourstr, blockcolourstr, tempcolourstr : string
var facing, oldfacing, loadfile : string := ""
var headcolour, bgcolour, blockcolour : int := 983
var ponwlk, poncrl, movegaptens, isaves : int := 1
var item1, item2, item3 : array 1 .. 16 of int
var item4 : array 0 .. 99 of int
var item5 : array 1 .. 99 of int
var oktosavenew, frstmthrgh, gmfrstmthrgh : boolean := true
var previoussaves : array 1 .. 99 of string (30)
var xinc, yinc, reach, nullreal : real
var groundlevel : int := 50
var menuitemcolours : array 1 .. 16 of string (20) :=
    init ("Default", "White", "Light Grey", "Dark Grey", "Black", "Brown", "Red", "Orange", "Yellow", "Green", "Dark Green", "Turquoise", "Blue", "Dark Blue", "Purple", "Pink")
var menuitemsaves : array 0 .. 99 of string (50)
var menuitemdelete : array 1 .. 99 of string (50)
menuitemsaves (1) := "New"
menuitemsaves (0) := "---"
menuitemdelete (99) := ""

%Range: x: -4999 to 5000, y: -2499 to 2500

%Turn the integer value of a colour into a string
procedure colourstringify (clr : int)
    if clr = 0 then
	tempcolourstr := "White"
    elsif clr = 8 then
	tempcolourstr := "Light Grey"
    elsif clr = 15 then
	tempcolourstr := "Dark Grey"
    elsif clr = 7 then
	tempcolourstr := "Black"
    elsif clr = 114 then
	tempcolourstr := "Brown"
    elsif clr = 12 then
	tempcolourstr := "Red"
    elsif clr = 42 then
	tempcolourstr := "Orange"
    elsif clr = 14 then
	tempcolourstr := "Yellow"
    elsif clr = 10 then
	tempcolourstr := "Green"
    elsif clr = 2 then
	tempcolourstr := "Dark Green"
    elsif clr = 52 then
	tempcolourstr := "Turquoise"
    elsif clr = 9 then
	tempcolourstr := "Blue"
    elsif clr = 1 then
	tempcolourstr := "Dark Blue"
    elsif clr = 34 then
	tempcolourstr := "Purple"
    elsif clr = 13 then
	tempcolourstr := "Pink"
    end if
end colourstringify

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

%Loading screen
procedure loading (loadscreencolour : int)
    Draw.FillBox (0, 0, maxx, maxy, loadscreencolour)
    colourback (loadscreencolour)
    locate (1, 1)
    put "LOADING..."
    colourback (white)
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
	    if i = 1 then
		headcolour := 983
	    elsif i = 2 then
		headcolour := white
	    elsif i = 3 then
		headcolour := grey
	    elsif i = 4 then
		headcolour := darkgrey
	    elsif i = 5 then
		headcolour := black
	    elsif i = 6 then
		headcolour := 114
	    elsif i = 7 then
		headcolour := brightred
	    elsif i = 8 then
		headcolour := 42
	    elsif i = 9 then
		headcolour := yellow
	    elsif i = 10 then
		headcolour := brightgreen
	    elsif i = 11 then
		headcolour := green
	    elsif i = 12 then
		headcolour := 52
	    elsif i = 13 then
		headcolour := brightblue
	    elsif i = 14 then
		headcolour := blue
	    elsif i = 15 then
		headcolour := 34
	    elsif i = 16 then
		headcolour := brightpurple
	    end if
	    colorback (oldbackcolour)
	    if headcolour = 983 then
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
	    if i = 1 then
		bgcolour := 983
	    elsif i = 2 then
		bgcolour := white
	    elsif i = 3 then
		bgcolour := grey
	    elsif i = 4 then
		bgcolour := darkgrey
	    elsif i = 5 then
		bgcolour := black
	    elsif i = 6 then
		bgcolour := 114
	    elsif i = 7 then
		bgcolour := brightred
	    elsif i = 8 then
		bgcolour := 42
	    elsif i = 9 then
		bgcolour := yellow
	    elsif i = 10 then
		bgcolour := brightgreen
	    elsif i = 11 then
		bgcolour := green
	    elsif i = 12 then
		bgcolour := 52
	    elsif i = 13 then
		bgcolour := brightblue
	    elsif i = 14 then
		bgcolour := blue
	    elsif i = 15 then
		bgcolour := 34
	    elsif i = 16 then
		bgcolour := brightpurple
	    end if
	    colorback (oldbackcolour)
	    if bgcolour = 983 then
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
	    if i = 1 then
		blockcolour := 983
	    elsif i = 2 then
		blockcolour := white
	    elsif i = 3 then
		blockcolour := grey
	    elsif i = 4 then
		blockcolour := darkgrey
	    elsif i = 5 then
		blockcolour := black
	    elsif i = 6 then
		blockcolour := 114
	    elsif i = 7 then
		blockcolour := brightred
	    elsif i = 8 then
		blockcolour := 42
	    elsif i = 9 then
		blockcolour := yellow
	    elsif i = 10 then
		blockcolour := brightgreen
	    elsif i = 11 then
		blockcolour := green
	    elsif i = 12 then
		blockcolour := 52
	    elsif i = 13 then
		blockcolour := brightblue
	    elsif i = 14 then
		blockcolour := blue
	    elsif i = 15 then
		blockcolour := 34
	    elsif i = 16 then
		blockcolour := brightpurple
	    end if
	    colorback (oldbackcolour)
	    if blockcolour = 983 then
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
    File.Delete ("Preferences\\" + menuitemdelete (idelete) + ".txt")
    if forcedelete = false then
	GUI.Disable (item5 (idelete))
	GUI.Disable (item4 (idelete + 1))
	colorback (oldbackcolour)
	locate (13, 1)
	put "Deleted ", menuitemdelete (idelete) + "                      "
    end if
end DeleteSelected

%If the user selects an opting in the "Load" menu
procedure LoadSelected
    for i : 1 .. isaves
	if item4 (i) = GUI.GetEventWidgetID then
	    loadfile := menuitemsaves (i)
	    colorback (oldbackcolour)
	    locate (13, 1)
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
    if cm = 1 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10 and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and ym >= maxy div 6 + 32 and
	    ym <= maxy div 6 * 5 - 32 then
	recentclick := true
    else
	if recentclick and cm = 0 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10 and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and
		ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
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

	open : loadedsavepref, ("Preferences\\" + textfound + ".txt"), get, put, seek
	put : loadedsavepref, charx / blocksize
	put : loadedsavepref, chary / blocksize
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
    saveButton := GUI.CreateButton (midx - 50, midy + 30, 100, "Save", saveWorld)
    nameTextField := GUI.CreateTextFieldFull (midx - 100, midy + 60, 200, "", NameEntered, GUI.INDENT, 0, 0)
    nameLabel := GUI.CreateLabelFull (midx - 105, midy + 60, "Save as:", 0, 0, GUI.RIGHT, 0)
    btncont := GUI.CreateButtonFull (midx - 150, maxy div 3, 300, "Continue", start, 30, chr (13), false)
    mainMenuButton := GUI.CreateButtonFull (midx - 150, maxy div 4.4, 300, "Return to Main Menu", returnMain, 30, chr (13), false)
    btnend := GUI.CreateButtonFull (midx - 150, maxy div 9, 300, "Quit", endgame, 30, chr (13), false)
    GUI.SetText (nameTextField, textfound)
    loop
	if startgame then
	    exit
	end if
	exit when GUI.ProcessEvent
    end loop
end pauseguis

%Screen scroll
procedure screenscroll (scrdirx : int, scrdiry : int)
    Draw.FillBox (0, 0, maxx, maxy, bgcolour)
    offsetx += scrdirx
    offsety += scrdiry
    offsetleftright += scrdirx
    offsetupdown += scrdiry
    if offsetupdown + groundlevel > mstScrnHsGnUp then
	mstScrnHsGnUp := offsetupdown + groundlevel
    end if
    if offsetupdown + groundlevel < mstScrnHsGnDwn then
	mstScrnHsGnDwn := offsetupdown + groundlevel
    end if
    if offsetleftright > mstScrnHsGnRght then
	mstScrnHsGnRght := offsetleftright
    end if
    if offsetleftright < mstScrnHsGnLft then
	mstScrnHsGnLft := offsetleftright
    end if
    seek : autosave, *

    %Generate new ground
    if scrdirx = 0 and scrdiry = 1 and offsetupdown + groundlevel + blocksize > 0 then   %Screen up, make ground below
	x := -blocksize - blocksize + offsetx
	y := -blocksize - blocksize + offsety
	loop
	    tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
	    if #block (tempcoords (1)) = boolUnInit then
		blkount += 1
		block (tempcoords (1)) := true
		put : autosave, tempcoords (1)
	    end if
	    x += blocksize
	    exit when x >= maxx + blocksize
	end loop
    elsif scrdirx = -1 and scrdiry = 0 and offsetupdown + groundlevel > 0 then   %Screen left, make ground right
	x := ((floor ((maxx - offsetx) / blocksize)) * blocksize + offsetx) + blocksize
	y := -blocksize + offsety
	loop
	    tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
	    if #block (tempcoords (1)) = boolUnInit then
		blkount += 1
		block (tempcoords (1)) := true
		put : autosave, tempcoords (1)
	    end if
	    y += blocksize
	    exit when y >= offsetupdown + groundlevel
	end loop
    elsif scrdirx = 1 and scrdiry = 0 and offsetupdown + groundlevel > 0 then   %Screen right, make ground left
	x := -blocksize - blocksize + offsetx
	y := -blocksize + offsety
	loop
	    tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
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
	tempcoords (1) := ((bigy + 2499) * 10000) + (bigx + 4999)
	if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) then
	    x := (tempcoords (1) - (floor (tempcoords (1) / 10000) * 10000) - 4999) * blocksize + offsetleftright
	    y := (floor (tempcoords (1) / 10000) - 2499) * blocksize + offsetupdown
	    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
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
	Pic.Draw (backpic, 0, maxy - 210, picCopy)
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
	locate (13, 1)
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
    GUI.HideMenuBar
    GUI.Quit
end DisableAndHideGUIs

%Get preferences
procedure GetPreferences
    if loaded then
	open : loadedsave, ("Saves\\" + loadfile + ".txt"), get, put, seek, mod
	open : loadedsavepref, ("Preferences\\" + loadfile + ".txt"), get, put, seek, mod
	seek : loadedsavepref, 0
	get : loadedsavepref, nullreal
	charx := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	chary := round (nullreal * blocksize)
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
	offsetx := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	offsety := round (nullreal * blocksize)
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
	offsetupdown := round (nullreal * blocksize)
	get : loadedsavepref, nullreal
	offsetleftright := round (nullreal * blocksize)
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
	groundlevel := ((floor ((groundlevel) / blocksize)) * blocksize)
	mstScrnHsGnUp := groundlevel
	mstScrnHsGnDwn := groundlevel
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
	seek : loadedsave, 0
	if eof (loadedsave) = false then
	    loop
		get : loadedsave, textfound
		block (strint (textfound)) := true
		x := (strint (textfound) - (floor (strint (textfound) / 10000) * 10000) - 4999) * blocksize + offsetleftright
		y := (floor (strint (textfound) / 10000) - 2499) * blocksize + offsetupdown
		Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
		put : autosave, textfound
		exit when eof (loadedsave)
	    end loop
	    textfound := loadfile
	end if
	close : loadedsave
    else %Generate ground
	x := 0
	y := 0
	loop
	    blkount += 1
	    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
	    tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
	    block (tempcoords (1)) := true
	    put : autosave, tempcoords (1)
	    x += blocksize
	    if x >= maxx then
		x := 0
		y += blocksize
	    end if
	    exit when y >= groundlevel
	end loop
	textfound := ""
    end if
end GenerateWorld

%Generate out-of-screen blocks
procedure GenerateOutScreenBlocks
    if preview = false then
	%Generate one row of below-screen ground if screen is at it's lowest.
	if mstScrnHsGnUp = offsetupdown + groundlevel then
	    x := -blocksize + offsetx
	    y := -blocksize + offsety
	    loop
		tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
		if #block (tempcoords (1)) = boolUnInit then
		    blkount += 1
		    block (tempcoords (1)) := true
		    put : autosave, tempcoords (1)
		end if
		x += blocksize
		exit when x >= maxx
	    end loop
	end if

	%Generate one row of to-the-right-of-screen ground if screen is at the furthest it has gone right.
	if mstScrnHsGnLft = offsetleftright then
	    x := ((ceil ((maxx - offsetx) / blocksize)) * blocksize + offsetx)
	    y := -blocksize + offsety
	    loop
		tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
		if #block (tempcoords (1)) = boolUnInit then
		    blkount += 1
		    block (tempcoords (1)) := true
		    put : autosave, tempcoords (1)
		end if
		y += blocksize
		exit when y >= offsetupdown + groundlevel
	    end loop
	end if

	%Generate one row of to-the-left-of-screen ground if screen is at the furthest it has gone left.
	if mstScrnHsGnRght = offsetleftright then
	    x := -blocksize + offsetx
	    y := -blocksize + offsety
	    loop
		tempcoords (1) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
		if #block (tempcoords (1)) = boolUnInit then
		    blkount += 1
		    block (tempcoords (1)) := true
		    put : autosave, tempcoords (1)
		end if
		y += blocksize
		exit when y >= offsetupdown + groundlevel
	    end loop
	end if
    end if
end GenerateOutScreenBlocks

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
			x := (autocoords - (floor (autocoords / 10000) * 10000) - 4999) + offsetprevlr + (midx - midx div 16)
			y := (floor (autocoords / 10000) - 2499) + offsetprevud + (midy - midy div 16)
			Draw.Dot (x, y, blockcolour)
		    end if
		    exit when eof (autosave)
		end loop
	    end if
	    View.Update
	    if arrow ('a') then
		offsetprevlr -= 10
	    elsif arrow ('d') then
		offsetprevlr += 10
	    end if
	    if arrow ('w') then
		offsetprevud += 10
	    elsif arrow ('s') then
		offsetprevud -= 10
	    end if
	    if arrow ('p') then
		offsetprevlr := 0
		offsetprevud := 0
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

%The coordinates of different points on the character
procedure CharPointCoords
    %Height that the character's hands are
    handheight := chary + charheight div 3 * 2

    %Character rounded position
    rcharxl := (floor ((charx - charwidth div 2 - offsetx) / blocksize)) * blocksize + offsetx
    rcharyd := (ceil ((chary - offsety) / blocksize)) * blocksize + offsety
    rcharxr := (floor ((charx + charwidth div 2 - offsetx) / blocksize)) * blocksize + offsetx
    rcharyu := (floor ((chary + charheight + 1 - offsety) / blocksize)) * blocksize + offsety
    rcharyuceil := (ceil ((chary + charheight + 1 - offsety) / blocksize)) * blocksize + offsety
    rcharydfloor := (floor ((chary - offsety) / blocksize)) * blocksize + offsety
end CharPointCoords

%If character must crawl
procedure CharMustCrawl
    if Pic.Height (stand) > blocksize then
	if length (action) >= 8 and action (1 .. 8) = "crawling" then
	    tempcoords (1) := (((rcharyuceil - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
	else
	    tempcoords (1) := (((rcharyu - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
	end if
	if length (action) >= 8 and action (1 .. 8) = "crawling" then
	    tempcoords (2) := (((rcharyuceil - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
	else
	    tempcoords (2) := (((rcharyu - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
	end if
	if ( #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) or #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2))) and onground then
	    mustcrawl := true
	else
	    mustcrawl := false
	end if
	if ( #block (tempcoords (2)) = boolUnInit or block (tempcoords (2)) = false) and ((charx + 1 - charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + 1 - charwidth div 2 -
		offsetx) / blocksize + offsetx)) then
	    mustcrawl := false
	end if
	if ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and ((charx + charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + charwidth div 2 - offsetx) /
		blocksize + offsetx)) then
	    mustcrawl := false
	end if
    end if
end CharMustCrawl

%If character is on the ground
procedure CharOnGround
    tempcoords (1) := (((rcharyd - blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
    tempcoords (2) := (((rcharyd - blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
    if ( #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) or #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2))) and (chary - offsety) / blocksize + offsety = (chary
	    - offsety) div blocksize + offsety or chary = 0 then
	onground := true
    else
	onground := false
    end if
    if ( #block (tempcoords (2)) = boolUnInit or block (tempcoords (2)) = false) and ((charx + 1 - charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + 1 - charwidth div 2 - offsetx)
	    / blocksize + offsetx)) and chary > 0 then
	onground := false
    end if
    if ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and ((charx + charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + charwidth div 2 - offsetx) /
	    blocksize + offsetx)) and chary > 0 then
	onground := false
    end if
end CharOnGround

%If character is against a wall to the left
procedure CharOnLeftWall
    tempcoords (1) := (((rcharydfloor - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
    tempcoords (2) := (((rcharydfloor + blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) or charx - charwidth div 2 = 0 then
	onleftwall := true
    elsif charheight > blocksize and #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) then
	onleftwall := true
    else
	onleftwall := false
    end if
end CharOnLeftWall

%If character is against a wall to the right
procedure CharOnRightWall
    tempcoords (1) := (((rcharydfloor - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
    tempcoords (2) := (((rcharydfloor + blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) or charx + charwidth div 2 = maxx then
	onrightwall := true
    elsif charheight > blocksize and #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) then
	onrightwall := true
    else
	onrightwall := false
    end if
end CharOnRightWall

%If character is against the ceiling
procedure CharHitCeiling
    tempcoords (1) := (((rcharyu - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxl - offsetleftright) div blocksize + 4999)
    tempcoords (2) := (((rcharyu - offsetupdown) div blocksize + 2499) * 10000) + ((rcharxr - offsetleftright) div blocksize + 4999)
    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) or #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) or rcharyu >= maxy then
	hitceiling := true
    else
	hitceiling := false
    end if
    if ( #block (tempcoords (2)) = boolUnInit or block (tempcoords (2)) = false) and ((charx + 1 - charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + 1 - charwidth div 2 - offsetx)
	    / blocksize + offsetx)) and rcharyu < maxy then
	hitceiling := false
    end if
    if ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and ((charx + charwidth div 2 - offsetx) / blocksize + offsetx) = (round ((charx + charwidth div 2 - offsetx) /
	    blocksize + offsetx)) and rcharyu < maxy then
	hitceiling := false
    end if
end CharHitCeiling

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
    if arrow ('a') then
	keya := true
    end if
    if arrow ('s') then
	keys := true
    end if
    if arrow ('d') then
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
    if eof (autosave) = false and (charx - charwidth <= pxscrollclearance or charx + charwidth >= maxx - pxscrollclearance or chary <= pxscrollclearance or chary + charheight >= maxy -
	    pxscrollclearance) then
	if charx - charwidth div 2 <= pxscrollclearance then
	    screenscroll (1, 0)
	    charx += 1
	elsif charx + charwidth div 2 >= maxx - pxscrollclearance then
	    screenscroll (-1, 0)
	    charx -= 1
	end if
	if chary <= pxscrollclearance then
	    screenscroll (0, 1)
	    chary += 1
	elsif chary + charheight >= maxy - pxscrollclearance then
	    screenscroll (0, -1)
	    chary -= 1
	end if

	%reset x and y offsets
	if offsetx > blocksize - 1 then
	    offsetx := 0
	elsif offsetx < 0 then
	    offsetx := blocksize - 1
	end if
	if offsety > blocksize - 1 then
	    offsety := 0
	elsif offsety < 0 then
	    offsety := blocksize - 1
	end if
    else
	seek : autosave, *
    end if
end ScreenSlide

%How the aim guide moves in accordance with the mouse
procedure AimGuideMovement
    if Math.Distance (charx, handheight, xm, ym) = 0 then
	xinc := (xm - charx) / 0.1
    else
	xinc := (xm - charx) / Math.Distance (charx, handheight, xm, ym)
    end if
    if Math.Distance (charx, handheight, xm, ym) = 0 then
	yinc := (ym - handheight) / 0.1
    else
	yinc := (ym - handheight) / Math.Distance (charx, handheight, xm, ym)
    end if
    tempi := round (reach)
    for i : 1 .. round (reach)
	if norcursorinput = false then
	    rcursorxbb := ((floor ((charx + xinc * i - offsetx) / blocksize)) * blocksize) + offsetx
	    rcursorybb := ((floor ((handheight + yinc * i - offsety) / blocksize)) * blocksize) + offsety
	    rcursorxpb := rcursorxbb
	    rcursorypb := rcursorybb
	    tempcoords (1) := (((rcursorybb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxbb - offsetleftright) div blocksize + 4999)
	    if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) then
		tempi := i
		rcursorxbb := (floor ((charx + xinc * i - offsetx) / blocksize)) * blocksize + offsetx
		rcursorybb := (floor ((handheight + yinc * i - offsety) / blocksize)) * blocksize + offsety
		rcursorxpb := (floor ((charx + xinc * (i - 1) - offsetx) / blocksize)) * blocksize + offsetx
		rcursorypb := (floor ((handheight + yinc * (i - 1) - offsety) / blocksize)) * blocksize + offsety
		norcursorinput := true
	    end if
	else %This is just to slow it down so that there is the same delay whether you are looking at a block or not. I am not convinced that it is nessecary.
	    null := ((floor ((charx + xinc * i - offsetx) / blocksize)) * blocksize) + offsetx
	    null := ((floor ((handheight + yinc * i - offsety) / blocksize)) * blocksize) + offsety
	    null := rcursorxbb
	    null := rcursorybb
	    null := (((rcursorybb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxbb - offsetleftright) div blocksize + 4999)
	    if #block (null) not= boolUnInit and block (null) then
		null := i
		null := (floor ((charx + xinc * i - offsetx) / blocksize)) * blocksize + offsetx
		null := (floor ((handheight + yinc * i - offsety) / blocksize)) * blocksize + offsety
		null := (floor ((charx + xinc * (i - 1) - offsetx) / blocksize)) * blocksize + offsetx
		null := (floor ((handheight + yinc * (i - 1) - offsety) / blocksize)) * blocksize + offsety
		null := 1
	    end if
	end if
    end for
    norcursorinput := false
    if Math.Distance (charx, handheight, xm, ym) < Math.Distance (charx, handheight, charx + xinc * tempi, handheight + yinc * tempi) then
	rcursorxbb := (floor ((xm - offsetx) / blocksize)) * blocksize + offsetx
	rcursorybb := (floor ((ym - offsety) / blocksize)) * blocksize + offsety
	rcursorxpb := (floor ((xm - offsetx) / blocksize)) * blocksize + offsetx
	rcursorypb := (floor ((ym - offsety) / blocksize)) * blocksize + offsety
    end if
end AimGuideMovement

%If player right-clicks
procedure PlayerRightClick
    if cm = 100 then
	if mclickr = 0 then
	    mclickr := blockplacespeed
	end if
	if mclickr = blockplacespeed then
	    if (rcursorxpb not= rcharxl and rcursorxpb not= rcharxr) or rcursorypb not= rcharydfloor then
		tempcoords (1) := (((rcursorypb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxpb - offsetleftright) div blocksize + 4999)
		x := (tempcoords (1) - (floor (tempcoords (1) / 10000) * 10000) - 4999) * blocksize + offsetleftright
		y := (floor (tempcoords (1) / 10000) - 2499) * blocksize + offsetupdown
		tempcoords (2) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x + blocksize - offsetleftright) div blocksize + 4999)
		tempcoords (3) := (((y - offsetupdown) div blocksize + 2499) * 10000) + ((x - blocksize - offsetleftright) div blocksize + 4999)
		tempcoords (4) := (((y + blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
		tempcoords (5) := (((y - blocksize - offsetupdown) div blocksize + 2499) * 10000) + ((x - offsetleftright) div blocksize + 4999)
		if #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) or #block (tempcoords (3)) not= boolUnInit and block (tempcoords (3)) or
		    #block (tempcoords (4)) not= boolUnInit and block (tempcoords (4)) or #block (tempcoords (5)) not= boolUnInit and block (tempcoords (5)) then
		    if ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) then
			Draw.FillBox (rcursorxpb, rcursorypb, rcursorxpb + (blocksize - 1), rcursorypb + (blocksize - 1), blockcolour)
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
    if cm = 1 then
	if mclickl = 0 then
	    mclickl := blockbreakspeed
	end if
	if mclickl = blockbreakspeed then
	    tempcoords (1) := (((rcursorybb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxbb - offsetleftright) div blocksize + 4999)
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
	View.Set ("nooffscreenonly")
	oldbackcolour := bgcolour
	oldblockcolour := blockcolour
	fork pauseguis
	Pic.Free (screenpic)
	screenpic := Pic.New (0, 0, maxx, maxy)
	Draw.FillBox (0, 0, maxx, maxy, bgcolour)
	GUI.ResetQuit
	GUI.ShowMenuBar
	colourstringify (headcolour)
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, headcolour)
	Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	Draw.Text (tempcolourstr + " head", 1, maxy - 90, font2, black)
	colourstringify (bgcolour)
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	Draw.Text (tempcolourstr + " background", 100, maxy - 90, font2, black)
	colourstringify (blockcolour)
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, blockcolour)
	Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	Draw.Text (tempcolourstr + " blocks", 238, maxy - 90, font2, black)
	loop
	    exit when startgame
	end loop

	%If the quit button has been clicked
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
			    x := (autocoords - (floor (autocoords / 10000) * 10000) - 4999) * blocksize + offsetleftright
			    y := (floor (autocoords / 10000) - 2499) * blocksize + offsetupdown
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
    end if
end PressPKey

%If 'd' key is pressed
procedure PressDKey
    if keyd then
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
		if movegap / 2 = movegap div 2 and not onrightwall then
		    charx += 1
		end if
	    else
		if movegap = 0 and not onrightwall then
		    charx += 1
		end if
	    end if
	elsif sprintd then
	    if flying then
		if not onrightwall then
		    charx += 1
		end if
	    else
		if (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and not onrightwall then
		    charx += 1
		end if
	    end if
	else
	    if flying then
		if movegap / 2 = movegap div 2 and not onrightwall then
		    charx += 1
		end if
	    else
		if (movegap = 0 or movegap = 8) and not onrightwall then
		    charx += 1
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
    if keya then
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
		if movegap / 2 = movegap div 2 and not onleftwall then
		    charx -= 1
		end if
	    else
		if movegap = 0 and not onleftwall then
		    charx -= 1
		end if
	    end if
	else
	    if sprinta then
		if flying then
		    if not onleftwall then
			charx -= 1
		    end if
		else
		    if (movegap = 0 or movegap = 4 or movegap = 8 or movegap = 12) and not onleftwall then
			charx -= 1
		    end if
		end if
	    else
		if flying then
		    if movegap / 2 = movegap div 2 and not onleftwall then
			charx -= 1
		    end if
		else
		    if (movegap = 0 or movegap = 8) and not onleftwall then
			charx -= 1
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
    if keyspc and (onground or flying) and mustcrawl = false and hitceiling = false then
	if flying then
	    chary += 1
	else
	    jumpcount := jumpheight
	end if
    end if
end PressSpaceKey


%If 's' key is pressed
procedure PressSKey
    if keys then
	if onground then
	    if keya or keyd then
		action := "crawling"
	    else
		action := "crawlingstop"
	    end if
	elsif flying then
	    chary -= 1
	end if
    end if
end PressSKey

%Jumping
procedure CharJump
    if mustcrawl = false and flying = false then
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
end CharJump

%Gravity
procedure Gravity
    if onground = false and jumpcount = 0 and flying = false then
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
end Gravity

%Finish the first part of assigning a usable value to "action"
procedure FinalizeAction1
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
end FinalizeAction1

%Crawling and walking animations
procedure Animations
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
    if cm = 0 then  %Image if not clicking
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
    else  %Image if clicking
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
end CharImage

%Draw character image and head colour
procedure CharDraw
    %Draw character's head colour
    if action = "crawling left" or action = "crawlingstop left" then
	Draw.FillOval (charx - 4, chary + 8, 3, 3, headcolour)
    elsif action = "crawling right" or action = "crawlingstop right" or action = "crawlingstop" then
	Draw.FillOval (charx + 4, chary + 8, 3, 3, headcolour)
    else
	Draw.FillOval (charx, chary + 21, 3, 3, headcolour)
    end if

    %Draw character
    Pic.Draw (character, charx - charwidth div 2, chary, picMerge)
end CharDraw

%Save background behind aim guides and draw them
procedure AimGuideBacksaveAndDraw
    %Get blocks at block placing box and block breaking crosshairs
    tempcoords (1) := (((rcursorybb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxbb - offsetleftright) div blocksize + 4999)
    tempcoords (2) := (((rcursorypb - offsetupdown) div blocksize + 2499) * 10000) + ((rcursorxpb - offsetleftright) div blocksize + 4999)

    if tempcoords (1) not= tempcoords (2) then
	%Save background behind crosshairs
	backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	%Save background behind box
	backpicbox := Pic.New (rcursorxpb, rcursorypb, rcursorxpb + blocksize - 1, rcursorypb + blocksize - 1)

	%Draw crosshairs for breaking blocks
	if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) and blockcolour = black or ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and bgcolour = black
		then
	    Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
	else
	    Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
	end if

	%Draw box for placing blocks
	if #block (tempcoords (2)) not= boolUnInit and block (tempcoords (2)) and blockcolour = black or ( #block (tempcoords (2)) = boolUnInit or block (tempcoords (2)) = false) and bgcolour = black
		then
	    Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	else
	    Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	end if
    else
	%Save background behind crosshairs and box
	backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	%Draw crosshairs for breaking blocks and box for placing blocks
	if #block (tempcoords (1)) not= boolUnInit and block (tempcoords (1)) and blockcolour = black or ( #block (tempcoords (1)) = boolUnInit or block (tempcoords (1)) = false) and bgcolour = black
		then
	    Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
	    Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	else
	    Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
	    Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	end if
    end if
end AimGuideBacksaveAndDraw

%Erase guide graphics
procedure EraseAimGuide
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
    movegap := 0
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
    oldbackcolour := white
    oldblockcolour := black
    offsetleftright := 0
    mstScrnHsGnLft := 0
    mstScrnHsGnRght := 0
    offsetprevlr := 0
    offsetprevud := 0
    offsetupdown := 0
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
    charx := midx + 2
    chary := 200
    action := "standing"
    facing := ""
    oldfacing := ""
    loadfile := ""
    headcolour := 983
    bgcolour := 983
    blockcolour := 983
    ponwlk := 1
    poncrl := 1
    movegaptens := 1
    isaves := 1
    oktosavenew := true
    frstmthrgh := true
    loading (white)
    View.Update
    for i : (2498 - (round ((mstScrnHsGnUp) / blocksize) + 1)) * 10000 .. (2500 + (round (((mstScrnHsGnDwn * (-1)) + maxx) / blocksize) + 1)) * 10000
	#block (i) := boolUnInit
    end for
end resetVariables

%Set colour-change-detecting variables
if bgcolour = 983 then
    oldbackcolour := white
else
    oldbackcolour := bgcolour
end if
if blockcolour = 983 then
    oldblockcolour := black
else
    oldblockcolour := blockcolour
end if

%Entire program loop
loop
    %Main menu loop
    loop

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

	%Clear and open autosave file
	open : autosave, ("Autosave.txt"), get, put, seek
	cls

	%Disables buffer drawing
	View.Set ("nooffscreenonly")

	ReEnableStartGUIs

	inmainmenu := true

	%Run the GUIs to be used in main and pause menus
	fork guis

	ShowColourPreveiwDefault

	%Wait until user clicks "start" button
	loop
	    exit when startgame
	end loop

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

	GenerateOutScreenBlocks

	WorldPreview

	frstmthrgh := false
	if preview = false then
	    exit
	end if
    end loop

    if canfly then
	flying := true
    end if

    loaded := false

    %Show world
    View.Update

    %Game program loop
    loop

	CharPointCoords

	CharMustCrawl

	%Character standing by default
	action := "standing"

	CharOnGround

	CharOnLeftWall

	CharOnRightWall

	CharHitCeiling

	%Get mouse input
	Mouse.Where (xm, ym, cm)

	%Get keyboard input
	Input.KeyDown (arrow)

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

	%Turn on/off flying here

	Gravity

	FinalizeAction1

	Animations

	%Stop sprinting if crawling
	if length (action) >= 8 and action (1 .. 8) = "crawling" then
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
	backpic := Pic.New (charx - charwidth div 2 - charudpxrange, chary - charudpxrange, charx + charwidth div 2 + charudpxrange, chary + charheight + charudpxrange)

	CharDraw

	AimGuideBacksaveAndDraw

	%Show new screen
	View.Update

	EraseAimGuide

	%Draw old unaltered background over character
	Pic.Draw (backpic, charx - charwidth div 2 - charudpxrange, chary - charudpxrange, picCopy)

	%Movement timer
	movegap += 1
	if movegap = 16 then
	    movegap := 0
	    movegaptens += 1
	    if movegaptens = 9 then
		movegaptens := 1
	    end if
	end if

	delay (0) %This delay to be adjusted with screen size and computer performance speed.
    end loop
    if quitthegame then
	exit
    end if
    resetVariables
end loop

View.Set ("nooffscreenonly")
colorback (white)
cls

%Erase contents of autosave files
close : autosave
open : autosave, ("Autosave.txt"), get, put, seek
close : autosave

%Disable all active GUI functions
GUI.Disable (menuhead)
GUI.Disable (menubg)
GUI.Disable (menublk)
GUI.Disable (btncont)
GUI.Disable (btnend)
GUI.Disable (mainMenuButton)
GUI.Hide (btncont)
GUI.Hide (btnend)
GUI.Hide (mainMenuButton)
GUI.HideMenuBar
cls

put "TGIO (Thank Goodness It's Over!)"
