%Description: A program that is a game in which the player moves around by way of the peripheral device I have constructed, and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

%Make using GUI features possible
import GUI

%Program settings
View.Set ("graphics:637;403")
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
    btnstrt, btncont, btnend, savenames, loadedsave, loadedsavepref, menuhead, menubg, menublk, menuload, quitButton, nameTextField, nameLabel,
    oldbackcolour, saveFile, autosave, menudelete, oldblockcolour, handheight, tempi, linegx, linegy, idelete, null, backpiccross, backpicbox : int
var sprintpossibled1, sprintpossibled2, sprintpossiblea1, sprintpossiblea2, blocknum, gravcount, jumpcount, movegap, wlk, crl, blkount, x, y,
    iprevsaves, ireassign, jumpheight, crosshairsbb2, crosshairsbb, crosshairspb2,
    crosshairspb, mclickr, mclickl, guidecolour : int := 0
var onground, onleftwall, onrightwall, hitceiling, walkleft, walkright, oldface, sprintd, sprinta, recentstopd, recentstartd, recentstopa, recentstarta,
    mustcrawl, startgame, recentclick, loaded, quitthegame, norcursorinput : boolean := false
var action : string := "standing"
var loadfile, textfound, autocoords, deletesaveread, nullget, headcolourstr, bgcolourstr, blockcolourstr, tempcolourstr : string
var facing, oldfacing : string := ""
var headcolour, bgcolour, blockcolour : int := 983
var ponwlk, poncrl, movegaptens, isaves : int := 1
var item1, item2, item3 : array 1 .. 16 of int
var item4, item5 : array 1 .. 99 of int
var oktosavenew, inmainmenu, forcedelete : boolean := true
var previoussaves : array 1 .. 99 of string (30)
var xinc, yinc, reach : real
var menuitemcolours : array 1 .. 16 of string (20) :=
    init ("Default", "White", "Light Grey", "Dark Grey", "Black", "Brown", "Red", "Orange", "Yellow", "Green", "Dark Green", "Turquoise", "Blue", "Dark Blue", "Purple", "Pink")
var menuitemsaves, menuitemdelete : array 1 .. 99 of string (50)
menuitemsaves (1) := "New"
menuitemdelete (99) := ""

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

%If user clicks "quit" button
procedure endgame
    startgame := true
    quitthegame := true
    GUI.Quit
    delay (10)
end endgame

%Loading screen
procedure loading (loadscreencolour : int)
    Draw.FillBox (0, 0, maxx, maxy, loadscreencolour)
    put "LOADING..."
    View.Update
end loading

%Does nothing, is just a necessary placeholder
procedure NameEntered (text : string)
end NameEntered

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
    if inmainmenu = false or forcedelete then
	open : savenames, ("Savenames.txt"), get, put, seek, mod
    end if
    seek : savenames, 0
    loop
	get : savenames, deletesaveread : *
	if menuitemdelete (idelete) not= deletesaveread then
	    ireassign += 1
	    previoussaves (ireassign) := deletesaveread
	end if
	exit when eof (savenames)
    end loop
    close : savenames
    open : savenames, ("Savenames.txt"), get, put, seek
    for i2 : 1 .. ireassign
	put : savenames, previoussaves (i2)
    end for
    if inmainmenu = false or forcedelete then
	close : savenames
    end if
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
    btnstrt := GUI.CreateButtonFull (midx - 150, maxy div 6, 300, "Start Game", start, 30, chr (13), false)

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
    for i : 1 .. isaves
	item4 (i) := GUI.CreateMenuItem (menuitemsaves (i), LoadSelected)
    end for
    loop
	if startgame = true then
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
DeleteSelected

%Wait for click
loop
    Mouse.Where (xm, ym, cm)
    if cm = 1 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10 and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and ym >= maxy div 6 + 32 and
	    ym <= maxy div 6 * 5 - 32 then
	recentclick := true
    else
	if recentclick = true and cm = 0 and xm >= midx - Font.Width ("Welcome to 2DMC!", font1) div 2 - 10 and xm <= midx + Font.Width ("Welcome to 2DMC!", font1) div 2 + 10 and
		ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
	    exit
	end if
	recentclick := false
    end if
end loop
cls

forcedelete := false

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

%Clear and open autosave file
open : autosave, ("Autosave.txt"), get, put, seek
close : autosave
open : autosave, ("Autosave.txt"), get, put, seek, mod

%open text file of all saved files' names
open : savenames, ("Savenames.txt"), get, put, seek, mod

%Create a list of all saved files' names
loop
    isaves += 1
    get : savenames, menuitemsaves (isaves) : *
    menuitemdelete (isaves - 1) := (menuitemsaves (isaves))
    exit when eof (savenames)
end loop

%Run the GUIs to be used in main and pause menus
fork guis

Draw.Text ("DEFAULT", 25, maxy - 55, font2, black)
Draw.Text ("Default head", 1, maxy - 90, font2, black)
Draw.Text ("DEFAULT", 138, maxy - 55, font2, black)
Draw.Text ("Default background", 100, maxy - 90, font2, black)
Draw.Text ("DEFAULT", 258, maxy - 55, font2, black)
Draw.Text ("Default blocks", 238, maxy - 90, font2, black)

%Wait until user clicks "start" button
loop
    exit when startgame = true
end loop

%close text file of all saved files' names
close : savenames

%Set program variables and disable and hide all GUIs
inmainmenu := false
startgame := false
GUI.Disable (menuload)
GUI.Disable (item1 (1))
GUI.Disable (item2 (1))
GUI.Disable (item3 (1))
GUI.Hide (btnstrt)
GUI.HideMenuBar
GUI.Quit
cls

%Allows for smooth animation
View.Set ("offscreenonly")

%Beginning loading screen
if bgcolour = 983 then
    loading (white)
else
    loading (bgcolour)
end if

%Declaration statement for the array of blocks: down here because it takes a really long time
var block : array 100000000 .. 499999999 of boolean

%Save feature
procedure saveWorld
    textfound := GUI.GetText (nameTextField)
    if textfound not= "" then
	iprevsaves := 0
	open : savenames, ("Savenames.txt"), get, put, seek, mod
	seek : savenames, 0
	loop
	    iprevsaves += 1
	    get : savenames, previoussaves (iprevsaves) : *
	    exit when eof (savenames)
	end loop
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
	put : loadedsavepref, charx
	put : loadedsavepref, chary
	put : loadedsavepref, headcolour
	put : loadedsavepref, bgcolour
	put : loadedsavepref, blockcolour
	put : loadedsavepref, blocksize
	close : loadedsavepref

	open : saveFile, ("Saves\\" + textfound + ".txt"), get, put, seek
	seek : autosave, 0
	loop
	    get : autosave, autocoords
	    if block (strint (autocoords)) then
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
    quitButton := GUI.CreateButton (midx - 50, midy + 30, 100, "Save", saveWorld)
    nameTextField := GUI.CreateTextFieldFull (midx - 100, midy + 60, 200, "", NameEntered, GUI.INDENT, 0, 0)
    nameLabel := GUI.CreateLabelFull (midx - 105, midy + 60, "Save as:", 0, 0, GUI.RIGHT, 0)
    btncont := GUI.CreateButtonFull (midx - 150, maxy div 3, 300, "Continue", start, 30, chr (13), false)
    btnend := GUI.CreateButtonFull (midx - 150, maxy div 6, 300, "Quit", endgame, 30, chr (13), false)
    GUI.SetText (nameTextField, textfound)
    loop
	if startgame = true then
	    exit
	end if
	exit when GUI.ProcessEvent
    end loop
end pauseguis

%Get preferences
if loaded then
    open : loadedsave, ("Saves\\" + loadfile + ".txt"), get, put, seek, mod
    open : loadedsavepref, ("Preferences\\" + loadfile + ".txt"), get, put, seek, mod
    seek : loadedsavepref, 0
    get : loadedsavepref, charx
    get : loadedsavepref, chary
    if headcolour = 983 then
	get : loadedsavepref, headcolour
    else
	get : loadedsavepref, nullget
    end if
    if bgcolour = 983 then
	get : loadedsavepref, bgcolour
    else
	get : loadedsavepref, nullget
    end if
    if blockcolour = 983 then
	get : loadedsavepref, blockcolour
    else
	get : loadedsavepref, nullget
    end if
    get : loadedsavepref, blocksize
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
end if

%Assign values to variables that are calculated using "blocksize"
crosshairsbb := Pic.Scale (crosshairsbbpre, blocksize, blocksize)
crosshairsbb2 := Pic.Scale (crosshairsbbpre2, blocksize, blocksize)
crosshairspb := Pic.Scale (crosshairspbpre, blocksize, blocksize)
crosshairspb2 := Pic.Scale (crosshairspbpre2, blocksize, blocksize)
Pic.SetTransparentColor (crosshairsbb2, 7)
Pic.SetTransparentColor (crosshairspb2, 7)
jumpheight := round (numblockscanjump * blocksize)
reach := numblockscanreach * blocksize

%Update background colour
Draw.FillBox (0, 0, maxx, maxy, bgcolour)

if loaded then %Load world
    if eof (loadedsave) = false then
	seek : loadedsave, 0
	loop
	    get : loadedsave, textfound
	    block (strint (textfound)) := true
	    x := floor (strint (textfound) / 10000) - 24999 - 10000
	    y := strint (textfound) - (floor (strint (textfound) / 10000)) * 10000 - 4999
	    Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
	    put : autosave, textfound
	    exit when eof (loadedsave)
	end loop
	textfound := loadfile
    end if
    x := 0
    y := 0
    loaded := false
    close : loadedsave
else %Generate ground
    loop
	blkount += 1
	Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
	tempcoords (1) := 100000000 + (x + 24999) * 10000 + (y + 4999)
	block (tempcoords (1)) := true
	put : autosave, tempcoords (1)
	x += blocksize
	if x >= maxx then
	    x := 0
	    y += blocksize
	end if
	exit when y >= blocksize * 3
    end loop
    x := 0
    y := 0
    textfound := ""
end if

%Show world
View.Update

loop
    handheight := chary + charheight div 3 * 2

    %Character standing by default
    action := "standing"

    %Character rounded position
    rcharxl := (floor ((charx - charwidth div 2) / blocksize)) * blocksize
    rcharyd := (ceil ((chary) / blocksize)) * blocksize
    rcharxr := (floor ((charx + charwidth div 2) / blocksize)) * blocksize
    rcharyu := (floor ((chary + charheight + 1) / blocksize)) * blocksize
    rcharyuceil := (ceil ((chary + charheight + 1) / blocksize)) * blocksize
    rcharydfloor := (floor (chary / blocksize)) * blocksize

    %If character must crawl
    if charheight <= blocksize then
	tempcoords (1) := 100000000 + (rcharxl + 24999) * 10000 + (rcharyuceil + 4999)
    else
	tempcoords (1) := 100000000 + (rcharxl + 24999) * 10000 + (rcharyu + 4999)
    end if
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    if charheight <= blocksize then
	tempcoords (2) := 100000000 + (rcharxr + 24999) * 10000 + (rcharyuceil + 4999)
    else
	tempcoords (2) := 100000000 + (rcharxr + 24999) * 10000 + (rcharyu + 4999)
    end if
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if (block (tempcoords (1)) or block (tempcoords (2))) and onground then
	mustcrawl := true
    else
	mustcrawl := false
    end if
    if block (tempcoords (2)) = false and ((charx + 1 - charwidth div 2) / blocksize) = (round ((charx + 1 - charwidth div 2) / blocksize)) then
	mustcrawl := false
    end if
    if block (tempcoords (1)) = false and ((charx + charwidth div 2) / blocksize) = (round ((charx + charwidth div 2) / blocksize)) then
	mustcrawl := false
    end if

    %If character is on the ground
    tempcoords (1) := 100000000 + (rcharxl + 24999) * 10000 + (rcharyd - blocksize + 4999)
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    tempcoords (2) := 100000000 + (rcharxr + 24999) * 10000 + (rcharyd - blocksize + 4999)
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if (block (tempcoords (1)) or block (tempcoords (2))) and chary / blocksize = chary div blocksize or chary = 0 then
	onground := true
    else
	onground := false
    end if
    if block (tempcoords (2)) = false and ((charx + 1 - charwidth div 2) / blocksize) = (round ((charx + 1 - charwidth div 2) / blocksize)) and chary > 0 then
	onground := false
    end if
    if block (tempcoords (1)) = false and ((charx + charwidth div 2) / blocksize) = (round ((charx + charwidth div 2) / blocksize)) and chary > 0 then
	onground := false
    end if

    %If character is against a wall to the left
    tempcoords (1) := 100000000 + (rcharxl + 24999) * 10000 + (rcharydfloor + 4999)
    tempcoords (2) := 100000000 + (rcharxl + 24999) * 10000 + (rcharydfloor + blocksize + 4999)
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if block (tempcoords (1)) or charx - charwidth div 2 = 0 then
	onleftwall := true
    elsif charheight > blocksize and block (tempcoords (2)) then
	onleftwall := true
    else
	onleftwall := false
    end if

    %If character is against a wall to the right
    tempcoords (1) := 100000000 + (rcharxr + 24999) * 10000 + (rcharydfloor + 4999)
    tempcoords (2) := 100000000 + (rcharxr + 24999) * 10000 + (rcharydfloor + blocksize + 4999)
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if block (tempcoords (1)) or charx + charwidth div 2 = maxx then
	onrightwall := true
    elsif charheight > blocksize and block (tempcoords (2)) then
	onrightwall := true
    else
	onrightwall := false
    end if

    %If character is against the ceiling
    tempcoords (1) := 100000000 + (rcharxl + 24999) * 10000 + (rcharyu + 4999)
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    tempcoords (2) := 100000000 + (rcharxr + 24999) * 10000 + (rcharyu + 4999)
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if block (tempcoords (1)) or block (tempcoords (2)) or rcharyu >= maxy then
	hitceiling := true
    else
	hitceiling := false
    end if
    if block (tempcoords (2)) = false and ((charx + 1 - charwidth div 2) / blocksize) = (round ((charx + 1 - charwidth div 2) / blocksize)) and rcharyu < maxy then
	hitceiling := false
    end if
    if block (tempcoords (1)) = false and ((charx + charwidth div 2) / blocksize) = (round ((charx + charwidth div 2) / blocksize)) and rcharyu < maxy then
	hitceiling := false
    end if

    %Get mouse input
    Mouse.Where (xm, ym, cm)

    %Get keyboard input
    Input.KeyDown (arrow)

    %How the aim guide moves in accordance with the mouse
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
	    rcursorxbb := ((floor ((charx + xinc * i) / blocksize)) * blocksize)
	    rcursorybb := ((floor ((handheight + yinc * i) / blocksize)) * blocksize)
	    rcursorxpb := rcursorxbb
	    rcursorypb := rcursorybb
	    tempcoords (1) := 100000000 + (rcursorxbb + 24999) * 10000 + (rcursorybb + 4999)
	    if #block (tempcoords (1)) = boolUnInit then
		block (tempcoords (1)) := false
	    end if
	    if block (tempcoords (1)) then
		tempi := i
		rcursorxbb := ((floor ((charx + xinc * i) / blocksize)) * blocksize)
		rcursorybb := ((floor ((handheight + yinc * i) / blocksize)) * blocksize)
		rcursorxpb := ((floor ((charx + xinc * (i - 1)) / blocksize)) * blocksize)
		rcursorypb := ((floor ((handheight + yinc * (i - 1)) / blocksize)) * blocksize)
		norcursorinput := true
	    end if
	else
	    null := ((floor ((charx + xinc * i) / blocksize)) * blocksize)
	    null := ((floor ((handheight + yinc * i) / blocksize)) * blocksize)
	    null := 100000000 + (rcursorxbb + 24999) * 10000 + (rcursorybb + 4999)
	    if 1 = 1 then
		null := i
		null := ((floor ((charx + xinc * i) / blocksize)) * blocksize)
		null := ((floor ((handheight + yinc * i) / blocksize)) * blocksize)
		null := ((floor ((charx + xinc * (i - 1)) / blocksize)) * blocksize)
		null := ((floor ((handheight + yinc * (i - 1)) / blocksize)) * blocksize)
	    end if
	end if
    end for
    norcursorinput := false
    if Math.Distance (charx, handheight, xm, ym) < Math.Distance (charx, handheight, charx + xinc * tempi, handheight + yinc * tempi) then
	rcursorxbb := (floor (xm / blocksize)) * blocksize
	rcursorybb := (floor (ym / blocksize)) * blocksize
	rcursorxpb := (floor (xm / blocksize)) * blocksize
	rcursorypb := (floor (ym / blocksize)) * blocksize
    end if

    %If player right-clicks
    if cm = 100 then
	if mclickr = 0 then
	    mclickr := blockplacespeed
	end if
	if mclickr = blockplacespeed then
	    if (rcursorxpb not= rcharxl and rcursorxpb not= rcharxr) or rcursorypb not= rcharydfloor then
		tempcoords (1) := 100000000 + (rcursorxpb + 24999) * 10000 + (rcursorypb + 4999)
		if #block (tempcoords (1)) = boolUnInit then
		    block (tempcoords (1)) := false
		end if
		x := floor (tempcoords (1) / 10000) - 24999 - 10000
		y := tempcoords (1) - (floor (tempcoords (1) / 10000)) * 10000 - 4999
		tempcoords (2) := 100000000 + ((x + blocksize) + 24999) * 10000 + ((y) + 4999)
		tempcoords (3) := 100000000 + ((x - blocksize) + 24999) * 10000 + ((y) + 4999)
		tempcoords (4) := 100000000 + ((x) + 24999) * 10000 + ((y + blocksize) + 4999)
		tempcoords (5) := 100000000 + ((x) + 24999) * 10000 + ((y - blocksize) + 4999)
		if #block (tempcoords (2)) = boolUnInit then
		    block (tempcoords (2)) := false
		end if
		if #block (tempcoords (3)) = boolUnInit then
		    block (tempcoords (3)) := false
		end if
		if #block (tempcoords (4)) = boolUnInit then
		    block (tempcoords (4)) := false
		end if
		if #block (tempcoords (5)) = boolUnInit then
		    block (tempcoords (5)) := false
		end if
		if block (tempcoords (2)) or block (tempcoords (3)) or block (tempcoords (4)) or block (tempcoords (5)) then
		    if block (tempcoords (1)) = false then
			Draw.FillBox (rcursorxpb, rcursorypb, rcursorxpb + (blocksize - 1), rcursorypb + (blocksize - 1), blockcolour)
			block (tempcoords (1)) := true
			blkount += 1
			put : autosave, tempcoords (1)
		    end if
		    x := 0
		    y := 0
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

    %If player left-clicks
    if cm = 1 then
	if mclickl = 0 then
	    mclickl := blockbreakspeed
	end if
	if mclickl = blockbreakspeed then
	    tempcoords (1) := 100000000 + (rcursorxbb + 24999) * 10000 + (rcursorybb + 4999)
	    if #block (tempcoords (1)) = boolUnInit then
		block (tempcoords (1)) := false
	    end if
	    if block (tempcoords (1)) = true then
		Draw.FillBox (rcursorxbb, rcursorybb, rcursorxbb + (blocksize - 1), rcursorybb + (blocksize - 1), bgcolour)
		block (tempcoords (1)) := false
		%View.UpdateArea (rcursorxbb, rcursorybb, rcursorxbb + (blocksize - 1), rcursorybb + (blocksize - 1))
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

    %If 'p' key is pressed
    if arrow ('p') then
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
	    exit when startgame = true
	end loop

	%If the quit button has been clicked
	if quitthegame then
	    GUI.Quit
	    exit
	end if

	%Temporarily disable and hide all GUIs
	GUI.Quit
	GUI.Hide (quitButton)
	GUI.Hide (nameTextField)
	GUI.Hide (nameLabel)
	GUI.Hide (btncont)
	GUI.Hide (btnend)
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
		    if block (strint (autocoords)) then
			x := floor (strint (autocoords) / 10000) - 24999 - 10000
			y := strint (autocoords) - (floor (strint (autocoords) / 10000)) * 10000 - 4999
			Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
		    end if
		    exit when eof (autosave)
		end loop
	    end if
	    x := 0
	    y := 0
	    seek : autosave, *
	else
	    Pic.Draw (screenpic, 0, 0, picCopy)
	end if
	View.Update
    end if

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



    %Screen sliding
    if charx <= 20 then
	charx += 1
    elsif charx >= maxx - 20 then
	charx -= 1
    end if
    if chary <= 20 then
	chary += 1
    elsif chary >= maxy - 20 then
	chary -= 1
    end if
    /*
     seek : autosave, 0
     if eof (autosave) = false then
     loop
     get : autosave, autocoords
     if block (strint (autocoords)) then
     x := floor (strint (autocoords) / 10000) - 24999 - 10000
     y := strint (autocoords) - (floor (strint (autocoords) / 10000)) * 10000 - 4999
     Draw.FillBox (x, y, x + (blocksize - 1), y + (blocksize - 1), blockcolour)
     end if
     exit when eof (autosave)
     end loop
     end if
     x := 0
     y := 0
     seek : autosave, *
     */

    %Get character dimensions
    charwidth := Pic.Width (character)
    charheight := Pic.Height (character)

    %Save background behind character
    Pic.Free (backpic)
    backpic := Pic.New (charx - charwidth div 2 - charudpxrange, chary - charudpxrange, charx + charwidth div 2 + charudpxrange, chary + charheight + charudpxrange)

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

    %Get blocks at block placing box and block breaking crosshairs
    tempcoords (1) := 100000000 + (rcursorxbb + 24999) * 10000 + (rcursorybb + 4999)
    if #block (tempcoords (1)) = boolUnInit then
	block (tempcoords (1)) := false
    end if
    tempcoords (2) := 100000000 + (rcursorxpb + 24999) * 10000 + (rcursorypb + 4999)
    if #block (tempcoords (2)) = boolUnInit then
	block (tempcoords (2)) := false
    end if
    if tempcoords (1) not= tempcoords (2) then
	%Save background behind crosshairs
	backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	%Save background behind box
	backpicbox := Pic.New (rcursorxpb, rcursorypb, rcursorxpb + blocksize - 1, rcursorypb + blocksize - 1)

	%Draw crosshairs for breaking blocks
	if block (tempcoords (1)) and blockcolour = black or block (tempcoords (1)) = false and bgcolour = black then
	    Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
	else
	    Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
	end if

	%Draw box for placing blocks
	if block (tempcoords (2)) and blockcolour = black or block (tempcoords (2)) = false and bgcolour = black then
	    Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	else
	    Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	end if
    else
	%Save background behind crosshairs and box
	backpiccross := Pic.New (rcursorxbb, rcursorybb, rcursorxbb + blocksize - 1, rcursorybb + blocksize - 1)

	%Draw crosshairs for breaking blocks and box for placing blocks
	if block (tempcoords (1)) and blockcolour = black or block (tempcoords (1)) = false and bgcolour = black then
	    Pic.Draw (crosshairsbb2, rcursorxbb, rcursorybb, picMerge)
	    Pic.Draw (crosshairspb2, rcursorxpb, rcursorypb, picMerge)
	else
	    Pic.Draw (crosshairsbb, rcursorxbb, rcursorybb, picMerge)
	    Pic.Draw (crosshairspb, rcursorxpb, rcursorypb, picMerge)
	end if
    end if
    %end if

    %Show new screen
    View.Update

    %Erase guide graphics
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
    %end if

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

    delay (1)     %This delay to be adjusted with screen size and computer performance speed.
end loop

%Disable all active GUI functions
close : autosave
GUI.Disable (menuhead)
GUI.Disable (menubg)
GUI.Disable (menublk)
GUI.Disable (btncont)
GUI.Disable (btnend)
GUI.Hide (btncont)
GUI.Hide (btnend)
GUI.HideMenuBar
View.Set ("nooffscreenonly")
colorback (white)
cls
put "TGIO (Thank Goodness It's Over!)"


