%Description: A program that is a block-based game in which the player moves around
%(optionally by way of the peripheral device I have constructed), and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

%Make using GUI features possible
import GUI

%Program settings
View.Set ("position:top;right,graphics:640;400") %Smallest advisable:450,330
buttonchoose ("multibutton")
setscreen ("noecho")
%Framerate goal: deltatime of 6-7 on still, 17-20 on screen scrolling


%Fix loading file overwrite your choice for creative or not (when you click load on the world, make it check or uncheck the box for you, but you can still change it before clicking play)
/*
 -Background makes block not infinite
 -No background blocks underground
 -Only naturally occuring terrain blocks can be infinite (dirt, stone, sand, water (not ores?))
 -ORRRR! Background blocks only have a go-around effect (or can only be placed(X)) if [there is no solid block on them] || [there is an air block on the foreground within 2 squares of them]!
 -Trees on whole regular blocks, no "nat wood" - this way, can climb them and jump from treetop to treetop
 -Wood: Can be climbed like a ladder if just a pole (new animation for this?)
 -Hotbar 1,2,3 are three tools: foreground, background, and terrain(terrain tool is just foreground tool, but removes any background blocks behind it)
 -Tools other than foreground have to be unlocked/acquired/crafted
 -Rest of hotbar is blocks
 -First try struct of two int1s - bg and block
 */
%Add physics to sand and water!
%Add fire switching to different shades of red, orange, and yellow randomly
%Make time affect sky color (rgb.addcolor 256, set to whatever)
%Add swimming
%Add alter jump height by amount space pressed
%Make character an instance of a class
%Add second player
%Add seed in preferences(?) file?
%Add different block types (solid, platform, decoration)
%Add background blocks?
%Add physics blocks!
%Add entity class (for things like train)!
%Add ability to step "around" objects - would work really well if I have background tiles like terraria, where they could
%   be assumed duplicated to the front, too. Only visible when the player steps forward, then they can't step back in
%   there. Go "around" the house! :D

%I think this was for attempts at fixing the player screenscroll jitter (?)
var tempMin, tempMax : real := 68
var timer : int := 0

%Declaration Statements
%Constant declarations
const midx : int := maxx div 2
const midy : int := maxy div 2
const boolUnInit := 16#FF
const thisGenVersion : int := 3
const jumpheight : real := 2.3
const reach : real := 5
const doubletapspeed : int := 300
var blockplacespeed : int := 130
var blockbreakspeed : int := 130
const playerSpeed : real := 5 / 1000
const charudpxrange := 30
var infinatePlacing : boolean := false
var bareBonesPreview : boolean := true
const parallelinput : boolean := false
const keepmapblocksize : boolean := true
const pxscrollclearance : int := 70
const staticfalldamage : boolean := true
const lethalFallHeight : int := 5
const gravAmount : real := 0.025
var trainx : real := 10
var trainy : real := 3
var trainLeft : boolean := true
var trainbackpic : int := Pic.New (0, 0, 2, 2)

%Block class
type blockStruct :
    record
	id : int
	name : string
	solid : boolean
	physics : boolean
	clr : int
    end record

type blockVec :
    record
	block : int1
	bg : int1
    end record

type blockGroup :
    record
	any : int1
	solid : int1
    end record
var blkGroup : blockGroup
blkGroup.any := -1
blkGroup.solid := -2

type layerId : enum (background, foreground, both)

%Block entry spot 1
type blk : enum (void, boarder, air, error, dirt, stone, sand, mud, grass,
    leaves, wood, platform, water, lava, fire, oil, rail, ladder, wire,
    pressure_plate, tnt)

var numBlockTypes : int := ord (upper (blk)) + 1
var blockType : array 0 .. numBlockTypes - 1 of blockStruct

procedure setBlockInfo (var blockIn : int, nameIn : string, solidIn : boolean, physicsIn : boolean, r, g, b : int)
    if blockIn > numBlockTypes then
	put "ERROR! \"blk\" enum list does not match \"setBlockInfo\" list!"
	delay (3000)
	quit
    end if
    blockType (blockIn).id := blockIn
    blockType (blockIn).name := nameIn
    blockType (blockIn).solid := solidIn
    blockType (blockIn).physics := physicsIn
    if 32 + blockIn > maxcolor then
	var res : int := RGB.AddColor (r / 255, g / 255, b / 255)
	if res = 1 then
	    put "Color add failed on color number ", maxcolor + 1
	    quit
	end if
    end if
    RGB.SetColor (104 + blockIn, r / 255, g / 255, b / 255)
    blockType (blockIn).clr := 104 + blockIn
    blockIn += 1
end setBlockInfo

var iter : int := 0
%Block entry spot 2
%Legend: name, isSolid, hasPhysics, color(r,g,b)
setBlockInfo (iter, "void", false, false, 255, 255, 255)
setBlockInfo (iter, "boarder", true, false, 56, 56, 56)
setBlockInfo (iter, "air", false, false, 0, 255, 255)
setBlockInfo (iter, "error", true, false, 255, 0, 255)
setBlockInfo (iter, "dirt", true, false, 113, 56, 0)
setBlockInfo (iter, "stone", true, false, 192, 192, 192)
setBlockInfo (iter, "sand", true, true, 255, 235, 182)
setBlockInfo (iter, "mud", true, true, 255, 235, 182)
setBlockInfo (iter, "grass", true, false, 0, 128, 0)
setBlockInfo (iter, "leaves", true, false, 0, 255, 0)
setBlockInfo (iter, "wood", true, false, 65, 32, 0)
setBlockInfo (iter, "platform", false, false, 113, 56, 0)
setBlockInfo (iter, "water", false, true, 0, 125, 255)
setBlockInfo (iter, "lava", false, true, 0, 125, 255)
setBlockInfo (iter, "fire", false, false, 0, 125, 255)
setBlockInfo (iter, "oil", false, false, 0, 125, 255)
setBlockInfo (iter, "rail", false, false, 203, 203, 203)
setBlockInfo (iter, "ladder", false, false, 113, 97, 56)
setBlockInfo (iter, "wire", false, false, 255, 0, 0)
setBlockInfo (iter, "pressure_plate", false, false, 81, 89, 113)
setBlockInfo (iter, "tnt", false, false, 255, 0, 0)

if iter not= numBlockTypes then
    put "ERROR! \"blk\" enum list does not match \"setBlockInfo\" list!"
    delay (3000)
    quit
end if

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
var charwidth : real := Pic.Width (stand) / blocksize
var charheight : real := Pic.Height (stand) / blocksize
var arrow : array char of boolean
var pos, oldPos : vec2
var rcursorbb, rcursorpb : vec2i
pos.x := 0
pos.y := 0
oldPos.x := pos.x
oldPos.y := pos.y
var backpic : int := Pic.New (0, 0, 2, 2)
var screenpic : int := Pic.New (0, 0, 2, 2)
var healthbar : int := Pic.New (0, 0, 2, 2)
var healthbarback : int := Pic.New (0, 0, 2, 2)
var deltaTime, xm, ym, cm, character, btnstrt, btncont, btnend, mainMenuButton, loadedsave, loadedsavepref, menuhead, menubg, menublk,
    menuload, saveButton, saveasguiheight, nameTextField, nameLabel, saveFile, menudelete, backpiccross, backpicbox, autocoords,
    cbprev, cbcreative, genVersion, seed, popupWinID : int
var gametimeold, sprintpossibled, sprintpossiblea, flypossible, mclickr, mclickl,
    healthold, crosshairsbb2, crosshairsbb, crosshairspb2, crosshairspb, mstScrnHsGnLft, mstScrnHsGnRght, mstScrnHsGnUp,
    mstScrnHsGnDwn : int := 0
var onground, inground, onleftwall, onrightwall, hitceiling, sprintd, sprinta, recentstartd, recentstarta, recentstartspace,
    mustcrawl, recentclick, loaded, quitthegame, keyspc, keya, keys, keyd, keyp, keyalt, preview, resetdefaulthead, flying,
    menuReturn, returningFromPreview, inPauseMenu, scrollSlow, yesDelete : boolean := false
var gmfrstmthrgh, survival : boolean := true
var jumpcount, gravcount, frametimer, offsetleftright, offsetupdown, slowScrollSpeed, timeOfDay : real := 0
var ponwlk, poncrl, isaves, wlk, crl : int := 1
var headcolour : int := 983
var oldbackcolour, bgcolour : int := white
var health : int := 1000
var placingBlock : blockStruct
var textfound : string
var facing, oldfacing, loadfile, importedBlockList : string := ""
var action, actionCurrent : string := "standing"
var item1 : array 1 .. 16 of int
var item2 : array 1 .. 12 of int
var item3 : array 1 .. numBlockTypes of int
var item4 : array 0 .. 99 of int
var item5 : array 1 .. 99 of int
var menuitemcolours : array 1 .. 16 of string (20) := init ("Default", "White", "Light Grey", "Dark Grey", "Black",
    "Brown", "Red", "Orange", "Yellow", "Green", "Dark Green", "Turquoise", "Blue", "Dark Blue", "Purple", "Pink")
var menuitemtime : array 1 .. 12 of string (10) := init ("12:00am", "2:00am", "4:00am", "6:00am", "8:00am", "10:00am", "12:00pm", "2:00pm", "4:00pm", "6:00pm", "8:00pm", "10:00pm")
var menuitemblock : array 1 .. numBlockTypes of string
for i : 1 .. numBlockTypes
    menuitemblock (i) := blockType (i - 1).name
end for
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

function LERP (data1, data2 : int, u : real) : int
    result round (intreal (data1) * (1.0 - u) + intreal (data2) * u)
end LERP

%Range: x: -4999 to 5000, y: -2499 to 2500
function blockID (blockName : string) : int
    for i : 0 .. numBlockTypes - 1
	if blockName = blockType (i).name then
	    result i
	end if
    end for
    result 0
end blockID

function toScrnCdX (val : real) : int
    result ceil ((val - offsetleftright) * blocksize)
end toScrnCdX

function toScrnCdY (val : real) : int
    result ceil ((val - offsetupdown) * blocksize)
end toScrnCdY
/*
 function toScrnCdMeasure (val : real) : real
 result ceil (val * blocksize)
 end toScrnCdMeasure
 */
function toGameCdX (val : real) : real
    result val / blocksize + offsetleftright
end toGameCdX

function toGameCdY (val : real) : real
    result val / blocksize + offsetupdown
end toGameCdY

%Floors this coordinate to the nearest block
function toBlock (inVal : real) : int
    result floor (inVal)
end toBlock

function toGameCdXR (val : real) : int
    result toBlock (toGameCdX (val))
end toGameCdXR

function toGameCdYR (val : real) : int
    result toBlock (toGameCdY (val))
end toGameCdYR

function toGameCdMeasure (val : real) : real
    result val / blocksize
end toGameCdMeasure

var crouchheight : real := toGameCdMeasure (Pic.Height (crawlr (1)))
var standheight : real := toGameCdMeasure (Pic.Height (stand))

function decodeX (coordcode : int) : int
    result coordcode - (floor (coordcode / 10000) * 10000) - 4999
end decodeX

function decodeY (coordcode : int) : int
    result floor (coordcode / 10000) - 2499
end decodeY

function isWholeNumber (input : real) : boolean
    result input = round (input)
end isWholeNumber

%Returns the x coordinate of the right side of the character
function rightSide () : real
    result pos.x + charwidth / 2 % - toGameCdMeasure (1)
end rightSide

function rightSideOld () : real
    result oldPos.x + charwidth / 2 % - toGameCdMeasure (1)
end rightSideOld

%Returns the x coordinate of the left side of the character
function leftSide () : real
    result pos.x - charwidth / 2
end leftSide

function leftSideOld () : real
    result oldPos.x - charwidth / 2
end leftSideOld

%Returns the x coordinate of the top of the character
function topSide () : real
    result pos.y + charheight
end topSide

function topSideOld () : real
    result oldPos.y + charheight
end topSideOld

function topSideCrouch () : real
    result pos.y + crouchheight
end topSideCrouch

function isAction (testForAction : string) : boolean
    result length (action) >= length (testForAction) and action (1 .. length (testForAction)) = testForAction
end isAction

function isActionCurrent (testForAction : string) : boolean
    result length (actionCurrent) >= length (testForAction) and actionCurrent (1 .. length (testForAction)) = testForAction
end isActionCurrent

function smallestOf (in1, in2 : real) : real
    if in1 <= in2 then
	result in1
    else
	result in2
    end if
end smallestOf

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

function timestringify (timeCurr : real) : string
    var am : boolean := timeCurr < 12
    var hour : string := intstr (floor (timeCurr))
    if strint (hour) > 12 then
	hour := intstr (strint (hour) - 12)
    end if
    if hour = "0" then
	hour := "12"
    end if
    var minute : string := intstr (LERP (0, 59, timeCurr - floor (timeCurr)))
    if length (minute) < 2 then
	minute := "0" + minute
    end if
    if am then
	result hour + ":" + minute + "am"
    else
	result hour + ":" + minute + "pm"
    end if
end timestringify

function timecolourify (nbr : real) : int
    result brightcyan
end timecolourify

function timemenu (nbr : int) : int
    result (nbr - 1) * 2
end timemenu

function blockmenu (nbr : int) : int
    result nbr - 1
end blockmenu

procedure PicDrawTranslucentBox (x1, y1, x2, y2, clr : int, alpha : real)
    if alpha <= 0 then
	return
    end if
    var width, height : int
    width := x2 - x1
    height := y2 - y1
    var backPicTemp : int := Pic.New (x1, y1, x2, y2)
    Draw.FillBox (x1, y1, x2, y2, clr)
    var tempID : int := Pic.New (x1, y1, x2, y2)
    Pic.Draw (backPicTemp, x1, y1, picCopy)
    Pic.Free (backPicTemp)
    var newAlpha : int := round (alpha * 99) + 1
    if newAlpha > 100 then
	newAlpha := 100
    end if
    Pic.DrawSpecial (tempID, x1, y1, picCopy, picBlend + newAlpha, 0)
    Pic.Free (tempID)
end PicDrawTranslucentBox

%If the game is to continue and menus are to close
procedure start
    GUI.Quit
    delay (10)
end start

%If user clicks "Quit" button
procedure endgame
    quitthegame := true
    GUI.Quit
    delay (5)
end endgame

%If user clicks "Return to Main Menu" button
procedure returnMain
    GUI.Quit
    menuReturn := true
    delay (10)
end returnMain

procedure drawTextSpecial (text : string, x, y : int, fontID, fontHeight, textcolor,
	justification : int, outlined : boolean, outlineThickness, outlineColor : int)
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
    Draw.FillBox (0, 0, maxx, maxy, loadscreencolour) %a cls
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
procedure TimeSelected
    for i : 1 .. 12
	if item2 (i) = GUI.GetEventWidgetID then
	    timeOfDay := timemenu (i)
	    bgcolour := timecolourify (timeOfDay)
	    colourback (oldbackcolour)
	    Draw.FillBox (137, maxy - 57, 188, maxy - 46, oldbackcolour)
	    Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	    Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	    Draw.FillBox (99, maxy - 94, 232, maxy - 80, oldbackcolour)
	    Draw.Text ("Time: " + timestringify (timeOfDay), 100, maxy - 90, font2, black)
	end if
    end for
end TimeSelected

%If the user selects an opting in the "Block Colour" menu
procedure BlocksSelected
    for i : 1 .. numBlockTypes
	if item3 (i) = GUI.GetEventWidgetID then
	    placingBlock := blockType (blockmenu (i))
	    colourback (oldbackcolour)
	    Draw.FillBox (257, maxy - 57, 308, maxy - 46, oldbackcolour)
	    Draw.FillBox (265, maxy - 67, 295, maxy - 37, placingBlock.clr)
	    Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	    Draw.FillBox (237, maxy - 94, 340, maxy - 80, oldbackcolour)
	    Draw.Text (placingBlock.name + " blocks", 238, maxy - 90, font2, black)
	end if
    end for
end BlocksSelected

procedure setDeleteFlag
    yesDelete := true
    GUI.Quit
end setDeleteFlag

%If the user selects an option in the "Delete" menu
procedure DeleteSelected
    var idelete : int
    for i : 1 .. isaves - 1
	if item5 (i) = GUI.GetEventWidgetID then
	    idelete := i
	end if
    end for

    %"Are you sure?" prompt
    yesDelete := false
    var popupWinID : int := Window.Open ("position:center;center,graphics:200;100,popup")
    colorback (grey)
    cls
    var font : int := Font.New ("serif:13")
    var message : string := "\"" + menuitemdelete (idelete) + "\"?"
    Draw.Text ("Are you sure you want", 10, maxy - 15, font, black)
    if Font.Width ("to delete world", font) + Font.Width (message, font) < maxx - 20 then
	Draw.Text ("to delete world " + message, 10, maxy - 35, font, black)
    else
	Draw.Text ("to delete world", 10, maxy - 35, font, black)
	Draw.Text (message, 10, maxy - 55, font, black)
    end if
    %Font.Free(font)
    GUI.SetDisplayWhenCreated (true)
    var deleteBtn : int := GUI.CreateButton (20, 10, 0, "Delete", setDeleteFlag)
    var quitBtn : int := GUI.CreateButton (110, 10, 0, "Cancel", GUI.Quit)

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.CloseWindow (popupWinID)
    GUI.ResetQuit

    if yesDelete then
	if menuitemdelete (idelete) = loadfile and loaded then
	    loadfile := ""
	    loaded := false
	end if
	File.Delete ("Saves\\" + menuitemdelete (idelete) + ".txt")
	File.Delete ("Saves\\Preferences\\" + menuitemdelete (idelete) + ".txt")

	GUI.Disable (item5 (idelete))
	GUI.Disable (item4 (idelete + 1))
	colourback (oldbackcolour)
	if inPauseMenu then
	    locate (10, 1)
	else
	    locate (12, 1)
	end if
	put "Deleted ", menuitemdelete (idelete) + "                      "
	GUI.Quit
	View.Update
	delay (500)
	endgame
    end if
end DeleteSelected

%If the user selects an option in the "Load" menu
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
		put "World: ", loadfile + "                      "
	    end if
	end if
    end for
end LoadSelected

%Welcome screen
var welcomeWidth : int := Font.Width ("Welcome to 2DMC!", font1)
Draw.Text ("Welcome to 2DMC!", midx - welcomeWidth div 2, midy - 20, font1, black)
locatexy (midx - length ("Click to continue") * 8 div 2, midy - 40)
put "Click to continue"
Draw.Box (midx - welcomeWidth div 2 - 10, maxy div 6 + 32, midx + welcomeWidth div 2 + 10, maxy div 6 * 5 - 32, black)

%Wait for click
loop
    Mouse.Where (xm, ym, cm)
    if cm = 1 and xm >= midx - welcomeWidth div 2 - 10
	    and xm <= midx + welcomeWidth div 2 + 10 and ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
	recentclick := true
    else
	if recentclick and cm = 0 and xm >= midx - welcomeWidth div 2 - 10
		and xm <= midx + welcomeWidth div 2 + 10 and ym >= maxy div 6 + 32 and ym <= maxy div 6 * 5 - 32 then
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
%Or rather, it USED to! Wow, it's snappy fast as an int1 (-128 to 127)!
const XLIMIT : int := 5000 % = total of 5000 + 5000 + 1 = 10001 blocks
const YLIMIT : int := 2500 % = total of 2500 + 2500 + 1 = 5001 blocks
var block : array - XLIMIT .. XLIMIT of array - YLIMIT .. YLIMIT of blockVec

%Terrain generation rules
function terrainQueryText (x, y : int, layer : int1) : string
    if genVersion < 4 then %Flat world terrain gen
	if layer not= ord(layerId.background) then %foreground, or both - only okay because background gen is always void!
	    if y < 0 then
		result "dirt"
	    else
		result "air"
	    end if
	else
	    result "void"
	end if
    end if
    result "air"
end terrainQueryText

function terrainQuery (x, y : int, layer : int1) : int
    result blockID (terrainQueryText (x, y, layer))
end terrainQuery

%Check block function
function isBlock (cdx, cdy : int, blockIn : int1, layer : int1, useTerrain : boolean) : boolean
    if cdx < -XLIMIT or cdx > XLIMIT or cdy < -YLIMIT or cdy > YLIMIT then
	if layer not= ord (layerId.background) then
	    result blockIn = ord (blk.boarder)
	else
	    result blockIn = ord (blk.void)
	end if
    end if

    var foundType : int
    if layer not= ord (layerId.background) then
	foundType := block (cdx) (cdy).block
    end if
    if layer = ord (layerId.background) or layer = ord (layerId.both) and foundType <= ord (blk.air) then %If found invisible block (void, boarder, air)
	foundType := block (cdx) (cdy).bg
    end if

    if useTerrain and foundType = ord (blk.void) then
	foundType := terrainQuery (cdx, cdy, layer)
    end if

    if blockIn = blkGroup.any then
	result foundType not= ord (blk.air) and foundType not= ord (blk.void)
    elsif blockIn = blkGroup.solid then
	result blockType (foundType).solid
    else
	result foundType = blockIn
    end if
end isBlock

function isBlockR (xin, yin : real, blockIn : int1, layer : int1, useTerrain : boolean) : boolean
    result isBlock (toBlock (xin), toBlock (yin), blockIn, layer, useTerrain)
end isBlockR

function getBlock (x, y : real, background, useTerrain : boolean) : blockStruct
    var cdx : int := toBlock (x)
    var cdy : int := toBlock (y)

    if cdx < -XLIMIT or cdx > XLIMIT or cdy < -YLIMIT or cdy > YLIMIT then
	result blockType (blockID ("boarder"))
    end if
    var returnBlock : blockStruct
    if background then
	returnBlock := blockType (block (cdx) (cdy).bg)
    else
	returnBlock := blockType (block (cdx) (cdy).block)
    end if
    if useTerrain and returnBlock.name = "void" then
	var layer : int1 := 0
	if not background then
	    layer := 1
	end if
	returnBlock := blockType (terrainQuery (cdx, cdy, layer))
    end if
    result returnBlock
end getBlock

function raycastLine (x1, y1, x2, y2, rangeIn : real, var rayHit, rayBefore : vec2, onlyThisSegment : boolean) : boolean
    var xinc, yinc : real := 0
    rayHit.x := x1
    rayHit.y := y1
    var range : real := rangeIn
    var reachingLength : real := Math.Distance (x1, y1, x2, y2)
    if reachingLength = 0 then
	range := 0
    else
	if onlyThisSegment and reachingLength < rangeIn then
	    range := reachingLength
	end if
	xinc := (x2 - x1) / reachingLength
	yinc := (y2 - y1) / reachingLength
    end if
    var i : real := 0
    loop
	rayHit.x := x1 + xinc * i
	rayHit.y := y1 + yinc * i
	%Draw.Dot (toScrnCdX (rayHit.x), toScrnCdY (rayHit.y), brightgreen)
	if isBlock (toBlock (rayHit.x), toBlock (rayHit.y), blkGroup.solid, 1, true) then
	    rayBefore.x := x1 + xinc * (i - toGameCdMeasure (1))
	    rayBefore.y := y1 + yinc * (i - toGameCdMeasure (1))
	    result true
	end if
	if i = range then
	    rayHit.x := x1 + xinc * range
	    rayHit.y := y1 + yinc * range
	    rayBefore.x := rayHit.x
	    rayBefore.y := rayHit.y
	    result false
	end if
	i += toGameCdMeasure (1)
	if i > range then
	    i := range
	end if
    end loop
end raycastLine

procedure setBlock (x, y : real, blockIn : int1, background : boolean)
    var cdx : int := toBlock (x)
    var cdy : int := toBlock (y)
    if cdx < -XLIMIT or cdx > XLIMIT or cdy < -YLIMIT or cdy > YLIMIT then
	return
    end if

    if background then
	block (cdx) (cdy).bg := blockIn
    else
	block (cdx) (cdy).block := blockIn
    end if
end setBlock

procedure DrawBlockScrn (x, y, clr : int)
    Draw.FillBox (x, y, x + blocksize - 1, y + blocksize - 1, clr)
end DrawBlockScrn

procedure DrawBlock (x, y : int, useTerrain : boolean)
    var foundTypeBlock : blockStruct := getBlock (x, y, false, useTerrain)
    if not isBlock (x, y, blkGroup.any, 1, useTerrain) then %slower than necessary?
	var foundTypeBg : blockStruct := getBlock (x, y, true, useTerrain)
	if foundTypeBg.id not= ord (blk.void) then
	    DrawBlockScrn (toScrnCdX (x), toScrnCdY (y), foundTypeBg.clr)
	    return
	end if
    end if
    DrawBlockScrn (toScrnCdX (x), toScrnCdY (y), foundTypeBlock.clr)
end DrawBlock

procedure DrawBlockClr (x, y : real, clr : int)
    DrawBlockScrn (toScrnCdX (x), toScrnCdY (y), clr)
end DrawBlockClr

procedure DrawBlockR (x, y : real, useTerrain : boolean)
    DrawBlock (toBlock (x), toBlock (y), useTerrain)
end DrawBlockR

%Save feature
procedure saveWorld
    %Save menu screen
    Pic.Free (backpic)
    backpic := Pic.New (0, 0, maxx, maxy) %Pic.New (0, maxy - 210, 340, maxy - 35)
    loading (bgcolour)
    textfound := GUI.GetText (nameTextField)
    var pauseMessage : string := ""
    if textfound = "" then
	pauseMessage := "ERROR: No file name entered                      "
    elsif length (textfound) > 40 then
	pauseMessage := "ERROR: File name too long! (max 40 characters)   "
    else
	var exportBlockString : string := ""
	for i : 0 .. numBlockTypes - 1
	    exportBlockString += "," + blockType (i).name
	end for

	open : loadedsavepref, ("Saves\\Preferences\\" + textfound + ".txt"), get, put, seek

	put : loadedsavepref, "Gen_Ver_", thisGenVersion
	put : loadedsavepref, pos.x
	put : loadedsavepref, pos.y
	put : loadedsavepref, headcolour
	put : loadedsavepref, timeOfDay
	put : loadedsavepref, placingBlock.id
	put : loadedsavepref, blocksize
	put : loadedsavepref, offsetupdown
	put : loadedsavepref, offsetleftright
	put : loadedsavepref, health
	put : loadedsavepref, survival
	put : loadedsavepref, exportBlockString
	close : loadedsavepref

	open : saveFile, ("Saves\\" + textfound + ".txt"), get, put, seek
	for x : mstScrnHsGnLft .. mstScrnHsGnRght
	    for y : mstScrnHsGnDwn .. mstScrnHsGnUp
		var blockBlock, bgBlock : int1 := 0
		if not isBlock (x, y, ord (blk.void), 1, false) and block (x) (y).block not= terrainQuery (x, y, 1) then
		    blockBlock := block (x) (y).block
		end if
		if not isBlock (x, y, ord (blk.void), 0, false) and block (x) (y).bg not= terrainQuery (x, y, 0) then
		    bgBlock := block (x) (y).bg
		end if
		if blockBlock not= 0 or bgBlock not= 0 then
		    put : saveFile, x, " ", y, " ", blockBlock, " ", bgBlock
		end if
	    end for
	end for
	close : saveFile
	pauseMessage := textfound + " saved!                                            "
    end if
    Pic.Draw (backpic, 0, 0, picCopy)
    locate (10, 1)
    put pauseMessage
    GUI.Refresh
end saveWorld

procedure createguis
    GUI.SetDisplayWhenCreated (false)

    btnstrt := GUI.CreateButtonFull (midx - 150, maxy div 6, 300, "Start Game", start, 30, chr (13), false)
    btnend := GUI.CreateButtonFull (midx - 150, maxy div 9 - 20, 300, "Quit", endgame, 30, chr (13), false)

    cbprev := GUI.CreateCheckBox (maxx - 80, maxy - 70, "Preview", DoNothing)
    cbcreative := GUI.CreateCheckBox (maxx - 80, maxy - 100, "Creative", DoNothing)

    menuhead := GUI.CreateMenu ("Head Colour")
    for i : 1 .. 16
	item1 (i) := GUI.CreateMenuItem (menuitemcolours (i), HeadSelected)
    end for
    menubg := GUI.CreateMenu ("     Time of Day   ")
    for i : 1 .. 12
	item2 (i) := GUI.CreateMenuItem (menuitemtime (i), TimeSelected)
    end for
    menublk := GUI.CreateMenu ("   Block Held   ")
    for i : 1 .. numBlockTypes
	item3 (i) := GUI.CreateMenuItem (menuitemblock (i), BlocksSelected)
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

    saveButton := GUI.CreateButton (midx - 50, (saveasguiheight - 30), 100, "Save", saveWorld)
    nameTextField := GUI.CreateTextFieldFull (midx - 100, saveasguiheight, 200, "", NameEntered, GUI.INDENT, 0, 0)
    nameLabel := GUI.CreateLabelFull (midx - 105, saveasguiheight, "Save as:", 0, 0, GUI.RIGHT, 0)
    btncont := GUI.CreateButtonFull (midx - 150, maxy div 3, 300, "Continue", start, 30, chr (13), false)
    mainMenuButton := GUI.CreateButtonFull (midx - 150, maxy div 4.4 - 10, 300, "Return to Main Menu", returnMain, 30, chr (13), false)
    GUI.Hide (nameTextField)
end createguis

%The GUIs that are used for main menu
procedure showMainMenuGUIs
    GUI.Show (btnstrt)
    GUI.Show (btnend)
    GUI.Show (cbprev)
    GUI.Show (cbcreative)
    GUI.ShowMenuBar
    GUI.Enable (menuload)
    GUI.Enable (menudelete)
    GUI.ResetQuit
    GUI.Refresh
end showMainMenuGUIs

procedure hideMainMenuGUIs
    GUI.Disable (menuload)
    GUI.Disable (menudelete)
    GUI.Hide (btnstrt)
    GUI.Hide (btnend)
    GUI.Hide (cbprev)
    GUI.Hide (cbcreative)
    GUI.HideMenuBar
end hideMainMenuGUIs

%The GUIs that are only used on pause screen
procedure showPauseGUIs
    GUI.Show (saveButton)
    GUI.Show (nameTextField)
    GUI.SetText (nameTextField, textfound)
    GUI.Show (nameLabel)
    GUI.Show (btncont)
    GUI.Show (btnend)
    GUI.Show (mainMenuButton)
    GUI.ShowMenuBar
    GUI.ResetQuit
    GUI.Refresh
end showPauseGUIs

procedure hidePauseGUIs
    GUI.Hide (saveButton)
    GUI.Hide (nameTextField)
    GUI.Hide (nameLabel)
    GUI.Hide (btncont)
    GUI.Hide (btnend)
    GUI.Hide (mainMenuButton)
    GUI.HideMenuBar
end hidePauseGUIs

%Draw blocks on screen
procedure showWorld ()
    var x : int := toGameCdXR (0) - 1
    var y : int := toGameCdYR (0) - 1
    loop
	if isBlock (x, y, blkGroup.any, 2, true) then % or isBlock (x, y, blkGroup.any, true, true) then %Edit: uhhh...?
	    DrawBlock (x, y, true)
	end if
	x += 1
	if x > toGameCdX (maxx) + 1 then
	    x := toGameCdXR (0) - 1
	    y += 1
	    exit when y > toGameCdY (maxy)
	end if
    end loop
end showWorld

procedure UpdateMostTravelled
    if offsetupdown + toGameCdMeasure (maxy) > mstScrnHsGnUp then
	mstScrnHsGnUp := ceil (offsetupdown + toGameCdMeasure (maxy))
    end if
    if offsetupdown < mstScrnHsGnDwn then
	mstScrnHsGnDwn := floor (offsetupdown)
    end if
    if offsetleftright + toGameCdMeasure (maxx) > mstScrnHsGnRght then
	mstScrnHsGnRght := ceil (offsetleftright + toGameCdMeasure (maxx))
    end if
    if offsetleftright < mstScrnHsGnLft then
	mstScrnHsGnLft := floor (offsetleftright)
    end if
end UpdateMostTravelled

%Screen scroll
procedure screenscroll (Scrdirx : real, Scrdiry : real)
    var scrdirx : real := Scrdirx
    var scrdiry : real := Scrdiry
    if scrollSlow then
	if scrdirx > slowScrollSpeed then
	    scrdirx := slowScrollSpeed
	elsif scrdirx < -slowScrollSpeed then
	    scrdirx := -slowScrollSpeed
	end if
	if scrdiry > slowScrollSpeed then
	    scrdiry := slowScrollSpeed
	elsif scrdiry < -slowScrollSpeed then
	    scrdiry := -slowScrollSpeed
	end if
    end if

    Draw.FillBox (0, 0, maxx, maxy, blockType (blockID ("air")).clr) %a cls
    offsetleftright += scrdirx
    offsetupdown += scrdiry
    UpdateMostTravelled

    %Generate new ground
    /*var x, y : int
     if scrdirx = 0 and scrdiry < 0 then  %Screen up, make ground below
     x := toGameCdXR (0) - 1
     y := toGameCdYR (0) - 1
     loop
     if blockType (block (x) (y)).name = "void" then
     setBlock (x, y, terrainQueryText (x, y))
     end if
     x += 1
     exit when x > toGameCdX (maxx)
     end loop
     elsif scrdirx > 0 and scrdiry = 0 then  %Screen left, make ground right
     x := toGameCdXR (maxx)
     y := toGameCdYR (0) - 1
     loop
     if blockType (block (x) (y)).name = "void" then
     setBlock (x, y, terrainQueryText (x, y))
     end if
     y += 1
     exit when y > toGameCdY (maxy)
     end loop
     elsif scrdirx < 0 and scrdiry = 0 then  %Screen right, make ground left
     x := toGameCdXR (0) - 1
     y := toGameCdYR (0) - 1
     loop
     if blockType (block (x) (y)).name = "void" then
     setBlock (x, y, terrainQueryText (x, y))
     end if
     y += 1
     exit when y > toGameCdY (maxy)
     end loop
     end if*/

    showWorld ()
end screenscroll


%Show colour preview as default
procedure ShowColourPreveiwDefault
    Draw.Text ("DEFAULT", 25, maxy - 55, font2, black)
    Draw.Text ("Default head", 1, maxy - 90, font2, black)
    Draw.Text ("DEFAULT", 138, maxy - 55, font2, black)
    Draw.Text ("Default background", 100, maxy - 90, font2, black)
    Draw.Text ("DEFAULT", 258, maxy - 55, font2, black)
    Draw.Text ("Default blocks", 238, maxy - 90, font2, black)
    locate (12, 1)
    if loadfile not= "" then
	put "World: ", loadfile
    else
	put "World: New"
    end if
end ShowColourPreveiwDefault

procedure CenterCamera
    offsetleftright := pos.x - toGameCdMeasure (maxx div 2)
    offsetupdown := pos.y - toGameCdMeasure (pxscrollclearance) %maxy div 2) - charheight
    UpdateMostTravelled
end CenterCamera

procedure ClampOffsetToScreen
    if toScrnCdX (leftSide ()) < pxscrollclearance then
	offsetleftright -= toGameCdMeasure (pxscrollclearance - toScrnCdX (leftSide ()))
    elsif toScrnCdX (rightSide ()) > maxx - pxscrollclearance then
	offsetleftright += toGameCdMeasure (toScrnCdX (rightSide ()) - (maxx - pxscrollclearance))
    end if
    put toScrnCdY (pos.y) < pxscrollclearance, ", ", toScrnCdY (topSide ()) > maxy - pxscrollclearance
    if toScrnCdY (pos.y) < pxscrollclearance then
	offsetupdown -= toGameCdMeasure (pxscrollclearance - toScrnCdY (pos.y))
    elsif toScrnCdY (topSide ()) > maxy - pxscrollclearance then
	offsetupdown += toGameCdMeasure (toScrnCdY (topSide ()) - (maxy - pxscrollclearance))
    end if
    UpdateMostTravelled
end ClampOffsetToScreen

%Get preferences / load world preferences
procedure GetPreferences
    if loaded then
	open : loadedsavepref, ("Saves\\Preferences\\" + loadfile + ".txt"), get, put, seek, mod
	seek : loadedsavepref, 0

	var instring : string
	get : loadedsavepref, instring
	if strrealok (instring) then
	    genVersion := 0
	else
	    genVersion := strint (instring (9 .. *))
	end if

	var nullreal : real
	var tempInt : int
	if genVersion = 0 then
	    pos.x := strreal (instring)
	else
	    get : loadedsavepref, pos.x
	end if
	get : loadedsavepref, pos.y
	if headcolour = 983 then
	    get : loadedsavepref, headcolour
	else
	    get : loadedsavepref, nullreal
	end if
	get : loadedsavepref, timeOfDay
	if genVersion < 3 then
	    timeOfDay := 6 %whatevernoonis
	end if
	get : loadedsavepref, instring
	tempInt := strint (instring)
	if tempInt < 0 or tempInt >= numBlockTypes then
	    tempInt := ord (blk.dirt)
	end if
	placingBlock := blockType (tempInt)
	if genVersion < 3 then
	    placingBlock := blockType (blockID ("stone"))
	end if
	if keepmapblocksize then
	    get : loadedsavepref, blocksize
	else
	    get : loadedsavepref, nullreal
	end if
	var groundLevel : int := 0
	if genVersion = 0 then
	    get : loadedsavepref, nullreal
	    get : loadedsavepref, nullreal
	    get : loadedsavepref, groundLevel
	    get : loadedsavepref, nullreal
	    mstScrnHsGnUp := round (nullreal + toGameCdMeasure (maxy div 2))
	    get : loadedsavepref, nullreal
	    mstScrnHsGnDwn := round (nullreal - toGameCdMeasure (maxy div 2))
	    get : loadedsavepref, nullreal
	    mstScrnHsGnLft := round (nullreal - toGameCdMeasure (maxx div 2))
	    get : loadedsavepref, nullreal
	    mstScrnHsGnRght := round (nullreal + toGameCdMeasure (maxx div 2))
	    get : loadedsavepref, offsetupdown
	    offsetupdown /= -blocksize
	    get : loadedsavepref, offsetleftright
	    offsetleftright /= -blocksize
	    get : loadedsavepref, health
	    get : loadedsavepref, survival
	else
	    get : loadedsavepref, offsetupdown
	    get : loadedsavepref, offsetleftright
	    get : loadedsavepref, health
	    get : loadedsavepref, survival
	end if
	loop
	    exit when eof (loadedsavepref)
	    get : loadedsavepref, importedBlockList : *
	    if importedBlockList not= "" and importedBlockList (1) not= "," then
		importedBlockList := ""
	    end if
	    exit
	end loop
	if importedBlockList = "" then
	    importedBlockList := ",void,boarder,air,dirt,stone,grass,leaves_nat,leaves,wood_nat,wood,platform,water,rail,ladder,wire,pressure_plate"
	end if
	%Convert incorrect ground levels to 0
	if groundLevel not= 0 then
	    pos.y -= groundLevel
	    seek : loadedsavepref, 0
	    var realRead : real
	    var currentPos : int
	    for i : 0 .. 13
		tell : loadedsavepref, currentPos
		get : loadedsavepref, realRead
		if i = 1 or i = 8 or i = 9 or i = 10 or i = 13 then
		    %Get all following lines and save them in an array of strings
		    var lineArray : array 0 .. 16 of string
		    var a : int := 0
		    loop
			get : loadedsavepref, lineArray (a)
			exit when eof (loadedsavepref)
			a += 1
		    end loop
		    seek : loadedsavepref, currentPos
		    if realRead = round (realRead) then
			put : loadedsavepref, round (realRead - groundLevel)
		    else
			put : loadedsavepref, realRead - groundLevel
		    end if
		    %write all previous lines from array
		    tell : loadedsavepref, currentPos
		    for i2 : 0 .. a
			put : loadedsavepref, lineArray (i2)
		    end for
		    seek : loadedsavepref, currentPos
		end if
	    end for
	    close : loadedsavepref

	    open : loadedsave, ("Saves\\" + loadfile + ".txt"), get, put, seek, mod
	    seek : loadedsave, 0
	    loop
		var coordcode : int
		tell : loadedsave, currentPos
		get : loadedsave, coordcode
		seek : loadedsave, currentPos
		coordcode -= groundLevel * 10000
		put : loadedsave, coordcode
		exit when eof (loadedsave)
	    end loop
	    close : loadedsave
	else
	    close : loadedsavepref
	end if
    else
	genVersion := thisGenVersion
	if headcolour = 983 then
	    headcolour := white
	end if
	timeOfDay := 0
	placingBlock := blockType (blockID ("stone"))
	CenterCamera
    end if
    ClampOffsetToScreen
end GetPreferences

%Assign values to variables that are calculated using "blocksize"
procedure AssignStartingVariables
    crosshairsbb := Pic.Scale (crosshairsbbpre, blocksize, blocksize)
    crosshairsbb2 := Pic.Scale (crosshairsbbpre2, blocksize, blocksize)
    crosshairspb := Pic.Scale (crosshairspbpre, blocksize, blocksize)
    crosshairspb2 := Pic.Scale (crosshairspbpre2, blocksize, blocksize)
    Pic.SetTransparentColor (crosshairsbb2, 7)
    Pic.SetTransparentColor (crosshairspb2, 7)
    crouchheight := toGameCdMeasure (Pic.Height (crawlr (1)))
    standheight := toGameCdMeasure (Pic.Height (stand))
end AssignStartingVariables

function strContains (str1, str2 : string) : boolean
    for i : 1 .. length (str1) - length (str2)
	if str1 (i .. i + length (str2) - 1) = str2 then
	    result true
	end if
    end for
    result false
end strContains

function getBestBlockIdMatch (blkName : string) : int
    var bestMatchSoFar : int := ord (blk.error)
    var bestMatchScore := 999
    for i : 0 .. numBlockTypes - 1
	if blockType (i).name = blkName then
	    result i
	end if
	if strContains (blockType (i).name, blkName) or strContains (blkName, blockType (i).name) then
	    var thisMatchScore : int := abs (length (blockType (i).name) - length (blkName))
	    if thisMatchScore < bestMatchScore then %Closer to 0 difference is better
		bestMatchSoFar := i
		bestMatchScore := thisMatchScore
	    end if
	end if
    end for
    result bestMatchSoFar
end getBestBlockIdMatch

%Generate world
procedure GenerateWorld
    /*if genVersion >= 2 then
     %Generate ground on screen
     var x : int := round (smallestOf (-toGameCdXR (maxx div 2) - 1, toGameCdXR (0) - 1))
     var y : int := round (smallestOf (-3, toGameCdYR (0)))
     loop
     setBlock (x, y, terrainQueryText (x, y))
     x += 1
     if x > toGameCdXR (maxx) then
     x := round (smallestOf (-toGameCdXR (maxx div 2) - 1, toGameCdXR (0) - 1))
     y += 1
     end if
     exit when y > toGameCdYR (maxy)
     end loop
     end if*/

    if loaded then %Load world
	var numItems : int := 0
	for i : 1 .. length (importedBlockList)
	    if importedBlockList (i) = "," then
		numItems += 1
	    end if
	end for
	var importedBlockArray : array 0 .. numItems - 1 of string
	var pos1 : int := 1
	var pos2 : int := 1
	numItems := 0
	for i : 2 .. length (importedBlockList)
	    if importedBlockList (i) = "," or i = length (importedBlockList) then
		pos1 := pos2
		pos2 := i
		if i = length (importedBlockList) then
		    pos2 += 1
		end if
		var blockInList : string := importedBlockList (pos1 + 1 .. pos2 - 1)
		importedBlockArray (numItems) := blockInList
		numItems += 1
	    end if
	end for
	var bestMatch : array 0 .. numItems - 1 of int
	for i : 0 .. numItems - 1
	    bestMatch (i) := getBestBlockIdMatch (importedBlockArray (i))
	end for

	open : loadedsave, ("Saves\\" + loadfile + ".txt"), get, put, seek, mod
	var firstblock : boolean := true
	seek : loadedsave, 0
	if not eof (loadedsave) then
	    loop
		var xInd : int
		var yInd : int
		if genVersion < 2 then %Ver 0 & 1
		    get : loadedsave, textfound
		    xInd := decodeX (strint (textfound))
		    yInd := decodeY (strint (textfound))
		    setBlock (xInd, yInd, ord (blk.dirt), false)
		else %Ver 2 and up
		    get : loadedsave, xInd
		    get : loadedsave, yInd
		    var thisBlockID : int
		    get : loadedsave, thisBlockID
		    setBlock (xInd, yInd, bestMatch (thisBlockID), false)
		    /*if thisBlockID not= 0 then
		     if thisBlockID > 2 then
		     thisBlockID += 1
		     elsif thisBlockID > 4 then
		     thisBlockID += 3
		     elsif thisBlockID > 6 then
		     thisBlockID += 2
		     elsif thisBlockID > 8 then
		     thisBlockID += 1
		     elsif thisBlockID > 11 then
		     thisBlockID += 4
		     elsif thisBlockID > 15 then
		     thisBlockID := 3
		     end if
		     if thisBlockID >= numBlockTypes then
		     thisBlockID := 3
		     end if
		     setBlock (xInd, yInd, thisBlockID, false)
		     end if*/
		    if genVersion > 2 then %Ver 3 and up (this gets the background block)
			get : loadedsave, thisBlockID
			/*if thisBlockID not= 0 then
			 if thisBlockID >= numBlockTypes then
			 thisBlockID := ord(blk.error)
			 end if*/
			setBlock (xInd, yInd, bestMatch (thisBlockID), true)
			%end if
		    end if
		end if
		if firstblock then
		    firstblock := false
		    mstScrnHsGnRght := xInd
		    mstScrnHsGnLft := xInd
		    mstScrnHsGnDwn := yInd
		    mstScrnHsGnUp := yInd
		else
		    if xInd < mstScrnHsGnLft then
			mstScrnHsGnLft := xInd
		    end if
		    if xInd > mstScrnHsGnRght then
			mstScrnHsGnRght := xInd
		    end if
		    if yInd < mstScrnHsGnDwn then
			mstScrnHsGnDwn := yInd
		    end if
		    if yInd > mstScrnHsGnUp then
			mstScrnHsGnUp := yInd
		    end if
		end if
		exit when eof (loadedsave)
	    end loop
	    textfound := loadfile
	end if
	close : loadedsave

	if genVersion < 2 then %Ver 0 & 1
	    %Turn the "void"s in the loaded world into proper "0"s.
	    for i : mstScrnHsGnLft .. mstScrnHsGnRght
		var startFilling : boolean := false
		for i2 : mstScrnHsGnDwn .. mstScrnHsGnUp
		    if not isBlock (i, i2, ord (blk.void), 1, false) then
			startFilling := true
		    elsif startFilling then
			setBlock (i, i2, ord (blk.air), false)
		    end if
		end for
	    end for
	end if
    else
	textfound := ""
    end if

    showWorld ()
end GenerateWorld

%World preview feature
procedure WorldPreview
    if preview then
	cls
	offsetleftright := 0
	offsetupdown := 0
	deltaTime := Time.Elapsed - gametimeold
	gametimeold := Time.Elapsed
	if deltaTime > 100 or deltaTime < 1 then
	    deltaTime := 1
	end if
	var newWinMaxx : int := mstScrnHsGnRght - mstScrnHsGnLft
	var newWinMaxy : int := mstScrnHsGnUp - mstScrnHsGnDwn
	var previewPictureWin : int := Window.Open ("graphics:" + intstr (newWinMaxx) + ";" + intstr (newWinMaxy) + ",invisible")
	if bareBonesPreview then
	    Draw.FillBox (0, 0, newWinMaxx, newWinMaxy, blockType (blockID ("void")).clr) %a cls
	else
	    Draw.FillBox (0, 0, newWinMaxx, newWinMaxy, blockType (blockID ("air")).clr) %a cls
	end if
	for cdx : mstScrnHsGnLft .. mstScrnHsGnRght
	    for cdy : mstScrnHsGnDwn .. mstScrnHsGnUp
		var drawCondition : boolean
		if bareBonesPreview then
		    drawCondition := not isBlock (cdx, cdy, ord (blk.void), 2, false)
		else
		    drawCondition := isBlock (cdx, cdy, blkGroup.any, 2, true)
		end if
		if drawCondition then
		    var x : int := cdx - mstScrnHsGnLft
		    var y : int := cdy - mstScrnHsGnDwn
		    var foundType : int := block (cdx) (cdy).block
		    if not bareBonesPreview then
			if blockType (foundType).name = "void" then
			    foundType := terrainQuery (cdx, cdy, 1)
			    if blockType (foundType).name = "air" then
				foundType := block (cdx) (cdy).bg
				if blockType (foundType).name = "void" then
				    foundType := terrainQuery (cdx, cdy, 0)
				    if blockType (foundType).name = "void" then
					foundType := blockID ("air")
				    end if
				end if
			    end if
			end if
		    end if
		    Draw.Dot (x, y, blockType (foundType).clr)
		end if
	    end for
	end for
	var x1 : int := mstScrnHsGnLft + round (offsetleftright) + (midx - midx div 16)
	var y1 : int := mstScrnHsGnDwn + round (offsetupdown) + (midy - midy div 16)
	var x2 : int := mstScrnHsGnRght + round (offsetleftright) + (midx - midx div 16)
	var y2 : int := mstScrnHsGnUp + round (offsetupdown) + (midy - midy div 16)

	var previewPic : int := Pic.New (0, 0, newWinMaxx, newWinMaxy)

	Window.Close (previewPictureWin)

	loop
	    x1 := mstScrnHsGnLft + round (offsetleftright) + (midx - midx div 16)
	    y1 := mstScrnHsGnDwn + round (offsetupdown) + (midy - midy div 16)
	    x2 := mstScrnHsGnRght + round (offsetleftright) + (midx - midx div 16)
	    y2 := mstScrnHsGnUp + round (offsetupdown) + (midy - midy div 16)

	    Draw.FillBox (0, 0, maxx, maxy, blockType (blockID ("void")).clr) %a cls
	    Pic.Draw (previewPic, x1, y1, picCopy)
	    Draw.Box (x1 - 1, y1 - 1, x2 + 1, y2 + 1, brightred)
	    View.Update
	    Input.KeyDown (arrow)
	    if arrow ('a') or arrow (KEY_LEFT_ARROW) then
		offsetleftright -= 0.3 * deltaTime
	    elsif arrow ('d') or arrow (KEY_RIGHT_ARROW) then
		offsetleftright += 0.3 * deltaTime
	    end if
	    if arrow ('w') or arrow (KEY_UP_ARROW) then
		offsetupdown += 0.3 * deltaTime
	    elsif arrow ('s') or arrow (KEY_DOWN_ARROW) then
		offsetupdown -= 0.3 * deltaTime
	    end if
	    if arrow ('p') then
		gmfrstmthrgh := false
		returningFromPreview := true
		exit
	    end if
	end loop
	Pic.Free (previewPic)

	offsetleftright := 0
	offsetupdown := 0

	%Reset head colour default
	if resetdefaulthead then
	    headcolour := 983
	    resetdefaulthead := false
	end if
    end if
end WorldPreview

%Beginning of main loop processes

%Get input for keyboard and parallelport
procedure KeyAndParallelInput
    %Reset input variables
    keyspc := false
    keya := false
    keys := false
    keyd := false
    keyp := false
    keyalt := false

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
    if arrow (KEY_ALT) then
	keyalt := true
    end if
    if arrow ('l') then
	for i : 0 .. 5
	    for i2 : 0 .. 5
		setBlock (pos.x - 3 + i, pos.y - 3 + i2, ord (blk.dirt), false)
	    end for
	end for
	showWorld ()
    end if
    if arrow ('k') then
	setBlock (pos.x, pos.y, ord (blk.air), false)
    end if
    if arrow ('o') then
	trainx := pos.x
	trainy := pos.y
    end if
    for i : 0 .. 9
	var c : char := intstr (i)
	if arrow (c) then
	    placingBlock := blockType (i)
	end if
    end for

    %If parallel port input is enabled
    if parallelinput then
	%Get parallel port input
	var val : int := parallelget

	%Assign input variables for parallel port
	if val = 1 or val = 1 + 2 then     %Etc., etc., ...
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
    if (toScrnCdX (leftSide ()) < pxscrollclearance or toScrnCdX (rightSide ()) > maxx - pxscrollclearance
	    or toScrnCdY (pos.y) < pxscrollclearance or toScrnCdY (topSide ()) > maxy - pxscrollclearance) then
	if toScrnCdX (leftSide ()) < pxscrollclearance then
	    screenscroll (- (toGameCdX (pxscrollclearance) - leftSide ()), 0)
	elsif toScrnCdX (rightSide ()) > maxx - pxscrollclearance then
	    screenscroll (rightSide () - toGameCdX ((maxx - pxscrollclearance)), 0)
	end if
	if toScrnCdY (pos.y) < pxscrollclearance then
	    screenscroll (0, - (toGameCdY (pxscrollclearance) - pos.y))
	elsif toScrnCdY (topSide ()) > maxy - pxscrollclearance then
	    screenscroll (0, topSide () - toGameCdY (maxy - pxscrollclearance))
	end if
	if scrollSlow then
	    slowScrollSpeed *= 1.05
	end if
    else
	scrollSlow := false
	slowScrollSpeed := 0.02
    end if
end ScreenSlide

%How the aim guide moves in accordance with the mouse
procedure AimGuideMovement
    var handheight : real := pos.y + charheight / 3 * 2     %Height that the character's hands are
    if infinatePlacing then
	rcursorbb.x := toScrnCdX (toGameCdXR (xm))
	rcursorbb.y := toScrnCdY (toGameCdYR (ym))
	rcursorpb.x := rcursorbb.x
	rcursorpb.y := rcursorbb.y
    else
	var rayHit, rayBefore : vec2
	var collides : boolean := raycastLine (pos.x, handheight, toGameCdX (xm), toGameCdY (ym), reach, rayHit, rayBefore, true)
	rcursorbb.x := toScrnCdX (toBlock (rayHit.x))
	rcursorbb.y := toScrnCdY (toBlock (rayHit.y))
	rcursorpb.x := toScrnCdX (toBlock (rayBefore.x))
	rcursorpb.y := toScrnCdY (toBlock (rayBefore.y))
	%If the block the ray hit is not the one the user was aiming for
	if not (toBlock (rayHit.x) = toBlock (toGameCdX (xm)) and toBlock (rayHit.y) = toBlock (toGameCdY (ym))) then
	    var closestCorner : vec2
	    closestCorner.x := toBlock (toGameCdX (xm))
	    closestCorner.y := toBlock (toGameCdY (ym))
	    if handheight > closestCorner.y + 0.5 then
		closestCorner.y += 1
	    end if
	    if pos.x > closestCorner.x + 0.5 then
		closestCorner.x += 1
	    end if
	    %If you could technically be able to reach the block
	    if Math.Distance (pos.x, handheight, closestCorner.x, closestCorner.y) <= reach then
		var tempReach : real := reach
		var dist : real := Math.Distance (pos.x, handheight, closestCorner.x, closestCorner.y) + 0.5
		if dist < reach then
		    tempReach := dist
		end if
		collides := raycastLine (pos.x, handheight, closestCorner.x, closestCorner.y, tempReach, rayHit, rayBefore, false)
		%if the closest point on the block your mouse is on is in line of sight
		if not collides or (toBlock (rayHit.x) = toBlock (toGameCdX (xm)) and toBlock (rayHit.y) = toBlock (toGameCdY (ym))) then
		    rcursorbb.x := toScrnCdX (toBlock (toGameCdX (xm)))
		    rcursorbb.y := toScrnCdY (toBlock (toGameCdY (ym)))
		    if not collides then
			rcursorpb.x := rcursorbb.x
			rcursorpb.y := rcursorbb.y
		    end if
		end if
	    end if
	end if

	%Fix block placing indicator if diagonal
	if abs (toGameCdX (rcursorbb.x) - toGameCdX (rcursorpb.x)) + abs (toGameCdY (rcursorbb.y) - toGameCdY (rcursorpb.y)) > 1 then
	    if not isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.solid, 1, true) then
		rcursorpb.x := rcursorbb.x
		rcursorpb.y := rcursorbb.y
	    else
		var optionA, optionB, playerClosestSide : vec2i
		var mouseClosestSide : vec2
		mouseClosestSide.x := toGameCdX (xm) - (toBlock (toGameCdX (rcursorbb.x)) + 0.5)
		mouseClosestSide.y := toGameCdY (ym) - (toBlock (toGameCdY (rcursorbb.y)) + 0.5)
		playerClosestSide.x := toBlock (pos.x) - toBlock (toGameCdX (rcursorbb.x))
		playerClosestSide.y := toBlock (handheight) - toBlock (toGameCdY (rcursorbb.y))
		var noOptionB : boolean := false
		if playerClosestSide.x = 0 or playerClosestSide.y = 0 then
		    noOptionB := true
		end if
		if abs (mouseClosestSide.x) > abs (mouseClosestSide.y) then
		    if playerClosestSide.x > 0 then
			optionA.x := toBlock (toGameCdX (rcursorbb.x)) + 1
		    elsif playerClosestSide.x < 0 then
			optionA.x := toBlock (toGameCdX (rcursorbb.x)) - 1
		    end if
		    optionA.y := toBlock (toGameCdY (rcursorbb.y))
		    if playerClosestSide.y > 0 then
			optionB.y := toBlock (toGameCdY (rcursorbb.y)) + 1
		    elsif playerClosestSide.y < 0 then
			optionB.y := toBlock (toGameCdY (rcursorbb.y)) - 1
		    end if
		    optionB.x := toBlock (toGameCdX (rcursorbb.x))
		else
		    if playerClosestSide.y > 0 then
			optionA.y := toBlock (toGameCdY (rcursorbb.y)) + 1
		    elsif playerClosestSide.y < 0 then
			optionA.y := toBlock (toGameCdY (rcursorbb.y)) - 1
		    end if
		    optionA.x := toBlock (toGameCdX (rcursorbb.x))
		    if playerClosestSide.x > 0 then
			optionB.x := toBlock (toGameCdX (rcursorbb.x)) + 1
		    elsif playerClosestSide.x < 0 then
			optionB.x := toBlock (toGameCdX (rcursorbb.x)) - 1
		    end if
		    optionB.y := toBlock (toGameCdY (rcursorbb.y))
		end if
		if not isBlock (optionA.x, optionA.y, blkGroup.solid, 1, true) then
		    rcursorpb.x := toScrnCdX (optionA.x)
		    rcursorpb.y := toScrnCdY (optionA.y)
		elsif not noOptionB and not isBlock (optionB.x, optionB.y, blkGroup.solid, 1, true) then
		    rcursorpb.x := toScrnCdX (optionB.x)
		    rcursorpb.y := toScrnCdY (optionB.y)
		end if
	    end if
	end if
    end if
end AimGuideMovement

%If player right-clicks
procedure PlayerRightClick
    if cm = 100 and health > 0 and xm >= 0 and xm <= maxx and ym >= 0 and ym <= maxy then
	if mclickr = 0 then
	    mclickr := blockplacespeed
	end if
	if mclickr = blockplacespeed then
	    var mouseGX : int := toGameCdXR (rcursorpb.x)
	    var mouseGY : int := toGameCdYR (rcursorpb.y)
	    var mouseOnPlayer : boolean := false
	    if placingBlock.solid then
		mouseOnPlayer := mouseGX + 1 > leftSide () and mouseGX <= rightSide ()
		    and mouseGY + 1 > pos.y and mouseGY <= topSideCrouch ()
	    end if
	    if not mouseOnPlayer and not isBlock (mouseGX, mouseGY, blkGroup.solid, 1, true) then
		var againstValidBlock : boolean :=
		    isBlock (mouseGX + 1, mouseGY, blkGroup.any, 1, true) or
		    isBlock (mouseGX - 1, mouseGY, blkGroup.any, 1, true) or
		    isBlock (mouseGX, mouseGY + 1, blkGroup.any, 1, true) or
		    isBlock (mouseGX, mouseGY - 1, blkGroup.any, 1, true)
		if infinatePlacing or placingBlock.physics or againstValidBlock then
		    setBlock (mouseGX, mouseGY, placingBlock.id, false)
		    DrawBlock (mouseGX, mouseGY, true)     %draws block you clicked, until a screen scroll/update
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
    if cm = 1 and health > 0 and xm >= 0 and xm <= maxx and ym >= 0 and ym <= maxy then
	if keyalt then
	    placingBlock := getBlock (toGameCdX (rcursorbb.x), toGameCdY (rcursorbb.y), false, true)
	else
	    if mclickl = 0 then
		mclickl := blockbreakspeed
	    end if
	    if mclickl = blockbreakspeed then
		if isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 1, true) then
		    setBlock (toGameCdX (rcursorbb.x), toGameCdY (rcursorbb.y), ord (blk.air), false)
		    DrawBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), true)
		end if
	    end if
	    mclickl -= 1
	    if mclickl = -1 then
		mclickl := blockbreakspeed
	    end if
	end if
    else
	mclickl := 0
    end if
end PlayerLeftClick

%If 'p' key is pressed
procedure PressPKey
    if keyp then
	for i : 0 .. 9 % I hate this, but otherwise, when you click where the "return to menu"
	    %or any other button will be, then pause, it will act as if you clicked the button.
	    var t : boolean := GUI.ProcessEvent %Gobbles up 10 last events to prevent processing
	end for
	inPauseMenu := true
	View.Set ("nooffscreenonly")
	oldbackcolour := bgcolour
	Pic.Free (screenpic)
	screenpic := Pic.New (0, 0, maxx, maxy)
	Draw.FillBox (0, 0, maxx, maxy, bgcolour)     %a cls
	showPauseGUIs
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, headcolour)
	Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	Draw.Text (colourstringify (headcolour) + " head", 1, maxy - 90, font2, black)
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	Draw.Text (timestringify (timeOfDay), 100, maxy - 90, font2, black)
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, placingBlock.clr)
	Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	Draw.Text (placingBlock.name + " blocks", 238, maxy - 90, font2, black)
	loop
	    exit when GUI.ProcessEvent
	end loop

	%If the quit button has not been clicked
	if not quitthegame then
	    %Temporarily hide pause GUIs
	    hidePauseGUIs

	    %Reset game-continuing variable
	    View.Set ("offscreenonly")

	    %Loading screen
	    loading (bgcolour)

	    %Updates background colour
	    if oldbackcolour not= bgcolour then
		Draw.FillBox (0, 0, maxx, maxy, bgcolour)  %a cls
		showWorld ()
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
	sprintpossiblea := 0 %Reset opposite sprint counter
	if recentstartd then
	    recentstartd := false
	    if sprintpossibled = 0 then
		sprintpossibled := doubletapspeed
	    elsif sprintpossibled not= 0 and (onground or flying) then
		sprintpossibled := 0
		sprintd := true
	    end if
	end if
	if keys and onground or mustcrawl then %crawling
	    if flying then
		if not onrightwall then
		    pos.x += playerSpeed * 4 * deltaTime
		end if
	    else
		if not onrightwall then
		    pos.x += playerSpeed / 2 * deltaTime
		end if
	    end if
	elsif sprintd then %sprinting
	    if flying then
		if not onrightwall then
		    pos.x += playerSpeed * 8 * deltaTime
		end if
	    else
		if not onrightwall then
		    pos.x += playerSpeed * 2 * deltaTime
		end if
	    end if
	else %walking
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
    else
	recentstartd := true
	sprintd := false
    end if
    %Timer for double-tapping to sprint right
    if sprintpossibled > 0 then
	sprintpossibled -= deltaTime
	if sprintpossibled < 0 then
	    sprintpossibled := 0
	end if
    end if
end PressDKey

%If 'a' key is pressed
procedure PressAKey
    if keya and health > 0 then
	sprintpossibled := 0
	if recentstarta then
	    recentstarta := false
	    if sprintpossiblea = 0 then
		sprintpossiblea := doubletapspeed
	    elsif sprintpossiblea not= 0 and (onground or flying) then
		sprintpossiblea := 0
		sprinta := true
	    end if
	end if
	if keys and onground or mustcrawl then %crawling
	    if flying then
		if not onleftwall then
		    pos.x -= playerSpeed * 4 * deltaTime
		end if
	    else
		if not onleftwall then
		    pos.x -= playerSpeed / 2 * deltaTime
		end if
	    end if
	elsif sprinta then  %sprinting
	    if flying then
		if not onleftwall then
		    pos.x -= playerSpeed * 8 * deltaTime
		end if
	    else
		if not onleftwall then
		    pos.x -= playerSpeed * 2 * deltaTime
		end if
	    end if
	else %walking
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
	action := "walking"
	facing := "left"
    else
	recentstarta := true
	sprinta := false
    end if
    %Timer for double-tapping to sprint left
    if sprintpossiblea > 0 then
	sprintpossiblea -= deltaTime
	if sprintpossiblea < 0 then
	    sprintpossiblea := 0
	end if
    end if
end PressAKey

%If spacebar is pressed
procedure PressSpaceKey
    if keyspc and health > 0 then
	if not survival and recentstartspace then
	    recentstartspace := false
	    if flypossible = 0 then
		flypossible := doubletapspeed
	    elsif flypossible not= 0 then
		flypossible := 0
		flying := not flying
	    end if
	end if

	if (onground or flying) and not mustcrawl and not hitceiling then
	    if flying then
		pos.y += playerSpeed * 8 * deltaTime
	    else
		jumpcount := jumpheight
	    end if
	end if
    else
	recentstartspace := true
    end if
    %Timer for double-tapping to fly
    if flypossible > 0 then
	flypossible -= deltaTime
	if flypossible < 0 then
	    flypossible := 0
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
    if not mustcrawl and not flying then
	if jumpcount = jumpheight then
	    facing := ""
	end if
	if jumpcount > 0 then
	    action := "jumping"
	    if hitceiling then
		jumpcount := 0
	    else
		var gravScalar : real := 0.04
		if jumpcount > 0.1 and jumpcount < jumpheight then
		    gravScalar := jumpcount / lethalFallHeight + 0.02
		end if
		pos.y += gravAmount * gravScalar * deltaTime
		jumpcount -= gravAmount * gravScalar * deltaTime
	    end if
	elsif jumpcount < 0 then
	    jumpcount := 0
	end if

	if not onground and jumpcount = 0 then
	    action := "falling"
	end if
    end if
end CharJump

%If character is on the ground or hit the ceiling
procedure CharOnSurface
    %if this frame's blockrounded ground position is in a block, and last frame's isn't, then move to between those two positions
    %such that you are not inside a block. Easy to do - just round current position to last position's block.
    %Floor
    var fellIntoBlock : boolean := false
    var blockBelow : boolean := false
    %Ceiling
    var flewIntoBlock : boolean := false
    var blockAbove : boolean := false

    var checkCount : int := ceil (charwidth)
    if toBlock (rightSide ()) - toBlock (leftSide ()) > checkCount - 1 then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	%Floor
	if isBlockR (leftSide () + i, pos.y, blkGroup.solid, 1, true) and not isBlockR (leftSide () + i, oldPos.y, blkGroup.solid, 1, true) then
	    fellIntoBlock := true
	    exit when flewIntoBlock
	elsif isBlockR (leftSide () + i, pos.y - 1, blkGroup.solid, 1, true) then
	    blockBelow := true
	end if
	%Ceiling
	if isBlockR (leftSide () + i, topSide (), blkGroup.solid, 1, true) and not isBlockR (leftSide () + i, topSideOld (), blkGroup.solid, 1, true) then
	    flewIntoBlock := true
	    exit when fellIntoBlock
	elsif isBlockR (leftSide () + i, topSide () + 1, blkGroup.solid, 1, true) then
	    blockAbove := true
	end if
    end for

    %Floor
    if fellIntoBlock then
	onground := true
	pos.y := toBlock (oldPos.y)
    else
	if blockBelow and pos.y = toBlock (pos.y) then
	    onground := true
	else
	    onground := false
	end if
    end if

    %Ceiling
    if flewIntoBlock then
	hitceiling := true
	pos.y := toBlock (topSideOld ()) + 1 - charheight - toGameCdMeasure (1)
    else
	if blockAbove and topSide () = toBlock (topSide ()) + 1 - toGameCdMeasure (1) then
	    hitceiling := true
	else
	    hitceiling := false
	end if
    end if
end CharOnSurface

%If character is against a wall
procedure CharOnWall
    %Left
    onleftwall := false
    var blockBesideLeft : boolean := false
    %Right
    onrightwall := false
    var blockBesideRight : boolean := false

    var checkCount : int := ceil (charheight)
    if toBlock (topSide ()) - toBlock (pos.y) > checkCount - 1 then
	checkCount += 1
    end if
    for i : 0 .. checkCount - 1
	%Left
	if isBlockR (leftSide (), pos.y + i, blkGroup.solid, 1, true) and not isBlockR (leftSideOld (), pos.y + i, blkGroup.solid, 1, true) then
	    onleftwall := true
	    exit when onrightwall
	elsif isBlockR (leftSide () - 1, pos.y + i, blkGroup.solid, 1, true) then
	    blockBesideLeft := true
	end if
	%Right
	if isBlockR (rightSide (), pos.y + i, blkGroup.solid, 1, true) and not isBlockR (rightSideOld (), pos.y + i, blkGroup.solid, 1, true) then
	    onrightwall := true
	    exit when onleftwall
	elsif isBlockR (rightSide () + 1, pos.y + i, blkGroup.solid, 1, true) then
	    blockBesideRight := true
	end if
    end for

    %Left
    if onleftwall then
	pos.x := toBlock (leftSideOld ()) + charwidth / 2
    else
	if blockBesideLeft and leftSide () = toBlock (leftSide ()) then
	    onleftwall := true
	else
	    onleftwall := false
	end if
    end if
    %Right
    if onrightwall then
	pos.x := toBlock (rightSideOld ()) + 1 - charwidth / 2 - toGameCdMeasure (1)
    else
	if blockBesideRight and rightSide () = toBlock (rightSide ()) + 1 - toGameCdMeasure (1) then
	    onrightwall := true
	else
	    onrightwall := false
	end if
    end if
end CharOnWall

%If character must crawl
procedure CharMustCrawl
    if Pic.Height (stand) > blocksize then
	mustcrawl := false
	var headHeightLevel : real := topSide ()
	if isActionCurrent ("crawling") then
	    headHeightLevel += 1
	end if
	var checkCount : int := ceil (charwidth)
	if toBlock (rightSide ()) - toBlock (leftSide ()) > checkCount - 1 then
	    checkCount += 1
	end if
	%Draw.Box (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (headHeightLevel)),
	%    toScrnCdX (toBlock (leftSide () + (checkCount - 1)) + 1) - 1, toScrnCdY (toBlock (headHeightLevel + 1)) - 1, brightred)
	for i : 0 .. checkCount - 1
	    if isBlockR (leftSide () + i, headHeightLevel, blkGroup.solid, 1, true) then
		mustcrawl := true
		actionCurrent := "crawling"
		charheight := crouchheight
		exit
	    end if
	end for
    end if
end CharMustCrawl

procedure CharInBlock
    var checkCountx : int := ceil (charwidth)
    if toBlock (rightSide ()) - toBlock (leftSide ()) > checkCountx - 1 then
	checkCountx += 1
    end if
    var checkCounty : int := ceil (charheight)
    if toBlock (topSide ()) - toBlock (pos.y) > checkCounty - 1 then
	checkCounty += 1
    end if
    inground := false
    for i : 0 .. checkCountx - 1
	for i2 : 0 .. checkCounty - 1
	    if isBlockR (leftSide () + i, pos.y + i2, blkGroup.solid, 1, true) then
		onground := true
		onleftwall := false
		for i3 : 0 .. checkCounty - 1
		    if isBlockR (leftSide (), toBlock (pos.y) + i3, blkGroup.solid, 1, true) then
			onleftwall := true
			exit
		    end if
		end for
		onrightwall := false
		for i3 : 0 .. checkCounty - 1
		    if isBlockR (rightSide (), toBlock (pos.y) + i3, blkGroup.solid, 1, true) then
			onrightwall := true
			exit
		    end if
		end for
		inground := true
		if survival then
		    health -= 1
		    if health <= 0 then
			health := 0
		    end if
		end if
		exit
	    end if
	end for
    end for
end CharInBlock

procedure CharSnapDownFall
    %Function prototype:
    %if there is enough room below you to stand, then
    %   pos.y := highest possible that will allow a full standing pose
    if not onground and mustcrawl and not inground then     %Falling, but block above (on) head (crawling)
	var offendingY : int
	var canStand : boolean := true
	var checkCountx : int := ceil (charwidth)
	if toBlock (rightSide ()) - toBlock (leftSide ()) > checkCountx - 1 then
	    checkCountx += 1
	end if
	var checkCounty : int := ceil (standheight - crouchheight)     %Only checking above crouching player until full stand height
	if toBlock (pos.y + (standheight)) - toBlock (topSideCrouch ()) > checkCounty - 1 then
	    checkCounty += 1
	end if
	%put checkCounty
	%Draw.Box (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (topSideCrouch ())),
	%    toScrnCdX (toBlock (leftSide () + (checkCountx - 1)) + 1) - 1, toScrnCdY (toBlock (topSideCrouch () + (checkCounty - 1)) + 1) - 1, brightred)
	for i : 0 .. checkCountx - 1
	    for i2 : 0 .. checkCounty - 1
		if isBlockR (leftSide () + i, topSideCrouch () + i2, blkGroup.solid, 1, true) then
		    offendingY := toBlock (topSideCrouch () + i2)
		    canStand := false
		    exit
		end if
	    end for
	end for
	if not canStand then
	    canStand := true
	    var desiredBottom : real := offendingY - standheight
	    checkCounty := ceil (pos.y - desiredBottom)     %Only checking from where player currently is down to desired position
	    for i : 0 .. checkCountx - 1
		for i2 : 0 .. checkCounty - 1
		    if isBlockR (leftSide () + i, toBlock (desiredBottom) + i2, blkGroup.solid, 1, true) then
			canStand := false
			exit
		    end if
		end for
	    end for
	    if canStand then
		pos.y := desiredBottom
		scrollSlow := true
	    end if
	end if
	if canStand then
	    mustcrawl := false
	    actionCurrent := "falling"
	    charheight := standheight
	end if
    end if
end CharSnapDownFall

procedure WorldCollisions
    CharOnSurface

    CharOnWall

    CharMustCrawl

    CharInBlock

    CharSnapDownFall
end WorldCollisions

%Gravity
procedure Gravity
    if not onground and jumpcount = 0 and not flying then
	var gravScalar : real := 1
	if gravcount = 0 then     %The "if = 0" is starting fall amount - still not sure what to make of this
	    gravScalar := 0.4
	elsif gravcount < lethalFallHeight then
	    gravScalar := gravcount / lethalFallHeight + 0.01
	end if
	pos.y -= gravAmount * gravScalar * deltaTime
	gravcount += gravAmount * gravScalar * deltaTime
    end if

    %On solid ground reset gravity and calculate fall damage
    if onground and gravcount not= 0 then
	if survival then
	    if staticfalldamage then
		if gravcount >= lethalFallHeight then
		    health -= round (((gravcount - (lethalFallHeight - 1)) / 15) * 1000)
		end if
	    else
		if gravcount >= lethalFallHeight then
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
	    if toGameCdX (xm) >= pos.x then
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
	    if toGameCdX (xm) >= pos.x then
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
    if (action = "falling left" or action = "falling right") and not keya and not keyd and not onground then
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
		if toGameCdX (xm) >= pos.x then
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
		if toGameCdX (xm) >= pos.x then
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
	Draw.FillOval (toScrnCdX (pos.x) - 4, toScrnCdY (pos.y) + 4, 3, 3, headcolour)
    elsif action = "dying right" then
	Draw.FillOval (toScrnCdX (pos.x) + 4, toScrnCdY (pos.y) + 4, 3, 3, headcolour)
    elsif action = "crawling left" or action = "crawlingstop left" then
	Draw.FillOval (toScrnCdX (pos.x) - 4, toScrnCdY (pos.y) + 8, 3, 3, headcolour)
    elsif action = "crawling right" or action = "crawlingstop right" or action = "crawlingstop" then
	Draw.FillOval (toScrnCdX (pos.x) + 4, toScrnCdY (pos.y) + 8, 3, 3, headcolour)
    else
	Draw.FillOval (toScrnCdX (pos.x), toScrnCdY (pos.y) + 21, 3, 3, headcolour)
    end if

    %Draw character
    /*
     var charxcdreal : real := ((pos.x - charwidth / 2) - offsetleftright) * blocksize
     var charxcd : int := ceil (((pos.x - charwidth / 2) - offsetleftright) * blocksize)

     if timer > 500 then
     timer := 0
     tempMin := charxcdreal
     tempMax := charxcdreal
     end if
     timer += 1

     if charxcdreal < tempMin then
     tempMin := charxcdreal
     end if
     if charxcdreal > tempMax then
     tempMax := charxcdreal
     end if

     locate (1, 1)
     put charxcdreal
     put tempMin, " ", tempMax
     put charxcd*/
     
     locate (1,1)
     put action
    Pic.Draw (character, toScrnCdX (leftSide ()), toScrnCdY (pos.y), picMerge)
end CharDraw

procedure TrainCompute
    if not isBlockR (trainx, trainy - 0.01, blkGroup.solid, 1, true) then
	trainy -= 0.01
    end if
    if not isBlockR (trainx - 0.01, trainy, blkGroup.solid, 1, true) and trainLeft then
	trainx -= 0.01
    end if
    if not isBlockR (trainx + 1.01, trainy, blkGroup.solid, 1, true) and not trainLeft then
	trainx += 0.01
    end if
    if isBlockR (trainx - 0.01, trainy, blkGroup.solid, 1, true) or isBlockR (trainx + 1.01, trainy, blkGroup.solid, 1, true) then
	trainy += 0.08
    end if
    if trainx <= -208 then
	trainLeft := false
    elsif trainx >= 21 then
	trainLeft := true
    end if
end TrainCompute

%Save background behind aim guides and draw them
procedure AimGuideBacksaveAndDraw
    if health > 0 then
	%Get blocks at block placing box and block breaking crosshairs
	if toGameCdXR (rcursorbb.x) not= toGameCdXR (rcursorpb.x) or toGameCdYR (rcursorbb.y) not= toGameCdYR (rcursorpb.y) then
	    %Save background behind crosshairs
	    backpiccross := Pic.New (rcursorbb.x, rcursorbb.y, rcursorbb.x + blocksize - 1, rcursorbb.y + blocksize - 1)

	    %Save background behind box
	    backpicbox := Pic.New (rcursorpb.x, rcursorpb.y, rcursorpb.x + blocksize - 1, rcursorpb.y + blocksize - 1)

	    %Draw crosshairs for breaking blocks
	    if isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 1, true) and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).block).clr = black
		    or isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 0, true) and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).bg).clr = black
		    or bgcolour = black then
		Pic.Draw (crosshairsbb2, rcursorbb.x, rcursorbb.y, picMerge)
	    else
		Pic.Draw (crosshairsbb, rcursorbb.x, rcursorbb.y, picMerge)
	    end if

	    %Draw box for placing blocks
	    if isBlock (toGameCdXR (rcursorpb.x), toGameCdYR (rcursorpb.y), blkGroup.any, 1, true) and blockType (block (toGameCdXR (rcursorpb.x)) (toGameCdYR (rcursorpb.y)).block).clr = black
		    or isBlock (toGameCdXR (rcursorpb.x), toGameCdYR (rcursorpb.y), blkGroup.any, 0, true) and blockType (block (toGameCdXR (rcursorpb.x)) (toGameCdYR (rcursorpb.y)).bg).clr = black
		    or bgcolour = black then
		Pic.Draw (crosshairspb2, rcursorpb.x, rcursorpb.y, picMerge)
	    else
		Pic.Draw (crosshairspb, rcursorpb.x, rcursorpb.y, picMerge)
	    end if
	else
	    %Save background behind crosshairs and box
	    backpiccross := Pic.New (rcursorbb.x, rcursorbb.y, rcursorbb.x + blocksize - 1, rcursorbb.y + blocksize - 1)

	    %Draw crosshairs for breaking blocks and box for placing blocks
	    if isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 1, true) and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).block).clr = black
		    or isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 0, true) and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).bg).clr = black
		    or bgcolour = black then
		Pic.Draw (crosshairsbb2, rcursorbb.x, rcursorbb.y, picMerge)
		Pic.Draw (crosshairspb2, rcursorpb.x, rcursorpb.y, picMerge)
	    else
		Pic.Draw (crosshairsbb, rcursorbb.x, rcursorbb.y, picMerge)
		Pic.Draw (crosshairspb, rcursorpb.x, rcursorpb.y, picMerge)
	    end if
	end if
    end if
end AimGuideBacksaveAndDraw

%Draw the health bar and save its background
procedure DrawHealthBar
    if survival then

	Pic.Free (healthbarback)
	healthbarback := Pic.New (0, 19, maxx, 41)     %Pic.New (maxx div 8 - 1, 19, (maxx div 4 * 3) + maxx div 8 + 1, 41)

	if health not= 0 then
	    /*if health not= healthold then
	     %draw healthbar full texture over all bottom of screen
	     Pic.Draw (healthbarfrst, 0, 20, picCopy)
	     %take image of desired section and save as healthbar
	     Pic.Free (healthbar)
	     healthbar := Pic.New (maxx div 8, 20, maxx div 8 + round ((maxx div 4 * 3 / 100) * (health / 10)), 40)
	     %restore background from healthbarback
	     Pic.Draw (healthbarback, 0, 19, picCopy)
	     healthold := health
	     end if
	     %Draw health bar portion in desired position
	     Pic.Draw (healthbar, maxx div 8, 20, picMerge)*/
	    PicDrawTranslucentBox (maxx div 8, 20, maxx div 8 + round ((maxx div 4 * 3 / 100) * (health / 10)), 40, brightgreen, 0.5)
	    Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, 10)
	else
	    Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, brightred)
	end if
    end if
end DrawHealthBar

procedure IfDeadGameOver
    if health <= 0 then
	health := 0
	Draw.Text ("Game Over", midx - 150, midy, font1, red)
    end if
end IfDeadGameOver

%Erase the health bar by redrawing its background
procedure EraseHealthBar
    if survival then
	Pic.Draw (healthbarback, 0, 19, picCopy)
    end if
end EraseHealthBar

%Erase guide graphics
procedure EraseAimGuide
    if health > 0 then
	if toGameCdXR (rcursorbb.x) not= toGameCdXR (rcursorpb.x) or toGameCdYR (rcursorbb.y) not= toGameCdYR (rcursorpb.y) then
	    %Draw old unaltered block over crosshairs for breaking blocks
	    Pic.Draw (backpiccross, rcursorbb.x, rcursorbb.y, picCopy)
	    Pic.Free (backpiccross)

	    %Draw old unaltered block over box for placing blocks
	    Pic.Draw (backpicbox, rcursorpb.x, rcursorpb.y, picCopy)
	    Pic.Free (backpicbox)
	else
	    %Draw old unaltered block over crosshairs for breaking blocks and box for placing blocks
	    Pic.Draw (backpiccross, rcursorbb.x, rcursorbb.y, picCopy)
	    Pic.Free (backpiccross)
	end if
    end if
end EraseAimGuide

%End of main loop procedures

procedure resetVariables
    sprintpossibled := 0
    sprintpossiblea := 0
    flypossible := 0
    gravcount := 0
    jumpcount := 0
    frametimer := 0
    wlk := 1
    crl := 1
    crosshairsbb2 := 0
    crosshairsbb := 0
    crosshairspb2 := 0
    crosshairspb := 0
    mclickr := 0
    mclickl := 0
    offsetupdown := 0
    offsetleftright := 0
    healthold := 0
    blockplacespeed := 130
    blockbreakspeed := 130
    oldbackcolour := white
    infinatePlacing := false
    gmfrstmthrgh := false
    onground := false
    onleftwall := false
    onrightwall := false
    hitceiling := false
    sprintd := false
    sprinta := false
    recentstartd := false
    recentstarta := false
    mustcrawl := false
    recentclick := false
    loaded := false
    quitthegame := false
    keyspc := false
    keya := false
    keys := false
    keyd := false
    keyp := false
    keyalt := false
    preview := false
    resetdefaulthead := false
    flying := false
    menuReturn := false
    charwidth := toGameCdMeasure (Pic.Width (character) - Pic.Width (character) mod 2)
    charheight := toGameCdMeasure (Pic.Height (character))
    pos.x := 0
    pos.y := 0
    health := 1000
    action := "standing"
    facing := ""
    oldfacing := ""
    loadfile := ""
    headcolour := 983
    ponwlk := 1
    poncrl := 1
    loading (white)
    View.Update
    for i : mstScrnHsGnLft .. mstScrnHsGnRght
	for i2 : mstScrnHsGnDwn .. mstScrnHsGnUp
	    setBlock (i, i2, ord (blk.void), false)
	    setBlock (i, i2, ord (blk.void), true)
	end for
    end for
    mstScrnHsGnLft := 0
    mstScrnHsGnRght := 0
    mstScrnHsGnUp := 0
    mstScrnHsGnDwn := 0
end resetVariables

procedure DebugDraw
    locate (1, 1)
    put pos.x, " ", pos.y

    %Drawing debug character inhabited boxes and misc
    Draw.FillOval (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (pos.y)), 4, 4, yellow)
    Draw.FillOval (toScrnCdX (toBlock (rightSide ())), toScrnCdY (toBlock (pos.y)), 4, 4, brightgreen)
    Draw.FillOval (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (topSide ())), 4, 4, brightblue)
    Draw.FillOval (toScrnCdX (toBlock (rightSide ())), toScrnCdY (toBlock (topSide ())), 4, 4, brightred)
    Draw.Box (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (pos.y)),
	toScrnCdX (toBlock (leftSide ()) + 1), toScrnCdY (toBlock (pos.y) + 1), yellow)
    Draw.Box (toScrnCdX (toBlock (rightSide ())), toScrnCdY (toBlock (pos.y)),
	toScrnCdX (toBlock (rightSide ()) + 1), toScrnCdY (toBlock (pos.y) + 1), brightgreen)
    Draw.Box (toScrnCdX (toBlock (leftSide ())), toScrnCdY (toBlock (topSide ())),
	toScrnCdX (toBlock (leftSide ()) + 1), toScrnCdY (toBlock (topSide ()) + 1), brightblue)
    Draw.Box (toScrnCdX (toBlock (rightSide ())), toScrnCdY (toBlock (topSide ())),
	toScrnCdX (toBlock (rightSide ()) + 1), toScrnCdY (toBlock (topSide ()) + 1), brightred)
end DebugDraw


%Entire program loop
loop
    %Main menu loop
    loop
	colorback (white)
	if gmfrstmthrgh then
	    %Find all saved files' names
	    var savenames : int
	    var fileName : string
	    savenames := Dir.Open ("Saves\\Preferences\\")
	    assert savenames > 0
	    loop
		fileName := Dir.Get (savenames)
		exit when fileName = ""
		if fileName not= "." and fileName not= ".." then
		    fileName := fileName (1 .. (length (fileName) - 4))
		    var continue : boolean := false
		    if length (fileName) > 40 then
			cls
			put "ERROR: File name too long! (max 40 characters)\nFile name: ", fileName
			put "File being ignored."
			continue := true
			delay (3000)
		    end if
		    if not continue then
			isaves += 1
			menuitemsaves (isaves) := fileName
			menuitemdelete (isaves - 1) := fileName
		    end if
		end if
	    end loop
	    Dir.Close (savenames)
	end if

	%Clear all blocks %This happens in resetvariables, right, so do we actually need it here?
	for x : mstScrnHsGnLft .. mstScrnHsGnRght
	    for y : mstScrnHsGnDwn .. mstScrnHsGnUp
		block (x) (y).block := blockID ("void")
		block (x) (y).bg := blockID ("void")
	    end for
	end for
	cls

	%Disables buffer drawing
	View.Set ("nooffscreenonly")

	%Run the GUIs to be used in main and pause menus
	if gmfrstmthrgh then
	    createguis
	end if
	showMainMenuGUIs

	ShowColourPreveiwDefault

	%Wait until user clicks "start" or "quit" button
	loop
	    exit when GUI.ProcessEvent
	end loop
	if quitthegame then
	    exit
	end if

	%Get preview checkbox state
	if GUI.GetCheckBox (cbprev) then
	    preview := true
	else
	    preview := false
	end if

	%Get iscreative checkbox state
	survival := not GUI.GetCheckBox (cbcreative)
	if GUI.GetCheckBox (cbcreative) then
	    infinatePlacing := true
	    blockplacespeed := 0
	    blockbreakspeed := 0
	end if

	%Set head default indicator
	if headcolour = 983 then
	    resetdefaulthead := true
	end if

	hideMainMenuGUIs

	cls

	%Allows for smooth animation
	View.Set ("offscreenonly")

	%Second loading screen
	loading (white)

	GetPreferences

	AssignStartingVariables

	%Update background colour
	Draw.FillBox (0, 0, maxx, maxy, blockType (blockID ("air")).clr)     %a cls

	GenerateWorld

	WorldPreview

	if not preview then
	    exit
	end if
    end loop

    if quitthegame then
	exit
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

	KeyAndParallelInput

	AimGuideMovement

	PlayerRightClick

	PlayerLeftClick

	PressPKey
	if quitthegame then
	    exit
	elsif menuReturn then
	    menuReturn := false
	    exit
	end if

	%Character standing by default
	actionCurrent := action     %Save current action (continuing from last frame) for detection purposes
	action := "standing"

	Gravity

	PressDKey

	PressAKey

	PressSpaceKey

	PressSKey

	CharJump

	WorldCollisions

	ScreenSlide

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
	charwidth := toGameCdMeasure (Pic.Width (character) - Pic.Width (character) mod 2)
	charheight := toGameCdMeasure (Pic.Height (character))

	%Save background behind character
	Pic.Free (backpic)
	backpic := Pic.New (toScrnCdX (leftSide ()) - charudpxrange, toScrnCdY (pos.y) - charudpxrange,
	    toScrnCdX (rightSide ()) + charudpxrange, toScrnCdY (topSide ()) + charudpxrange)

	TrainCompute

	Pic.Free (trainbackpic)
	trainbackpic := Pic.New (toScrnCdX (trainx) - charudpxrange, toScrnCdY (trainy) - charudpxrange,
	    toScrnCdX (trainx + 1) + charudpxrange, toScrnCdY (trainy + 1) + charudpxrange)

	SetHealth

	%Draw the train
	%DrawBlock (trainx, trainy, 104)

	CharDraw

	AimGuideBacksaveAndDraw

	DrawHealthBar

	IfDeadGameOver

	%DebugDraw
	%locate (1, 1)
	%put deltaTime

	%Show new screen
	View.Update

	EraseHealthBar

	EraseAimGuide

	%Draw old unaltered background over character
	Pic.Draw (backpic, toScrnCdX (pos.x - charwidth / 2) - charudpxrange, toScrnCdY (pos.y) - charudpxrange, picCopy)
	Pic.Draw (trainbackpic, toScrnCdX (trainx) - charudpxrange, toScrnCdY (trainy) - charudpxrange, picCopy)

	%Setting oldPos
	oldPos.x := pos.x
	oldPos.y := pos.y

	%Movement timer
	frametimer += playerSpeed * 140 * deltaTime
    end loop
    if quitthegame then
	exit
    end if
    resetVariables
end loop

View.Set ("nooffscreenonly")
colourback (white)
cls

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
