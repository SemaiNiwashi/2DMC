%Description: A program that is a block-based game in which the player moves around
%(optionally by way of the peripheral device I have constructed), and interacts with its surroundings with the mouse.
%Your Name: Kyle Blumreisinger
%File Name: 2DMC.t
%Date: Feb. 11, 2013

import GUI %Make using GUI features possible

%Program settings
View.Set ("position:top;right,graphics:640;400") %Smallest advisable:450,330
buttonchoose ("multibutton")
setscreen ("noecho")
%Framerate goal: deltatime of 6-7 on still, 17-20 on screen scrolling

%Colors for the preview are all wrong.
%Dropdowns go off-screen. See "CreateTextBoxChoiceCustom.t"
%Text for "_________ saved" and other "put"s move based on user's set font size. Only use Draw.Text.
%Make player's update box form-fit to the player by placing it at the *old* location (unless I've already done that)
%Make screen scrolling faster by moving the background picture and just updating the blocks at the edge of the screen
%Fix player holding click to place blocks while crawling backwards makes spacing of 1, but then when screen is scrolling, it makes spacing of 2.
/*
 -Background makes block not infinite IF it is a wall-type tile!
 -Dirt, stone, any physics block that generates underground, and liquids CANNOT be used as wall tiles.
 -Dirt and stone can still be used as background though, for decorative purposes.
 -Liquids and physics blocks can never go on the background layer.
 -While on the go-around layer, you cannot place blocks or walls (breaking through a wall is allowed - think breaking into your house if you are stuck out for some reason)
 X-No background blocks underground
 X-Only naturally occuring terrain blocks can be infinite (dirt, stone, sand, water (not ores?))
 X-ORRRR! Background blocks only have a go-around effect (or can only be placed(X)) if [there is no solid block on them] || [there is an air block on the foreground within 2 squares of them]!
 -Trees on whole regular blocks, no "nat wood" - this way, can climb them and jump from treetop to treetop
 -Wood: Can be climbed like a ladder if just a pole (new animation for this?)
 -Hotbar 1,2,3 are three tools: foreground, background, and terrain(terrain tool is just foreground tool, but removes any background blocks behind it)
 -Tools other than foreground have to be unlocked/acquired/crafted
 -Rest of hotbar is blocks
 */
%In gen version 4, add whether or not the playing is flying to the preferences file
%Add physics to sand and water!
%Make leaves act like ladders/water - free movement when touching them > 50%
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
const MAX_ENTITIES : int := 99
const boolUnInit := 16#FF
const intUnInit := 16#80000000
const thisGenVersion : int := 3
const timeSpeed : real := 0.00001
const charudpxrange := 30
var bareBonesPreview : boolean := true
const parallelinput : boolean := false
const keepmapblocksize : boolean := true
const pxscrollclearance : int := 70
const savDir : string := "ByanSaves\\"
const imgDir : string := "Images\\"
const imgType : string := ".bmp"
var trainx : real := 10
var trainy : real := 3
var trainLeft : boolean := true
var trainbackpic : int := Pic.New (0, 0, 2, 2)

%Type declarations for blocks
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

%Block entry spot 1
type blk : enum (void, boarder, air, error, dirt, stone, sand, sandstone, mud, grass,
    leaves, wood, planks, platform, water, lava, fire, oil, rail, ladder, wire,
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
setBlockInfo (iter, "sandstone", true, false, 237, 203, 92)
setBlockInfo (iter, "mud", true, true, 255, 235, 182)
setBlockInfo (iter, "grass", true, false, 0, 128, 0)
setBlockInfo (iter, "leaves", false, false, 0, 255, 0)
setBlockInfo (iter, "wood", true, false, 65, 32, 0)
setBlockInfo (iter, "planks", true, false, 196, 156, 81)
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

%Type declarations pt 2
type vec2 :
    record
	x, y : real
    end record
type vec2i :
    record
	x, y : int
    end record

type layerId : enum (background, foreground, both)
type motion : enum (back)

%Global variable declarations
var blocksize : int := 16 %Must be > 15 %Edit: Oh really? Maybe now...
var loadingScreen1 : int := Pic.FileNew (imgDir + "loadingScreen" + imgType)
var font1 := Font.New ("sans serif:40:bold")
var font2 := Font.New ("sans serif:8:bold")
var loadingScreen : int := Pic.Scale (loadingScreen1, maxx - 20, maxy - 20)
var arrow : array char of boolean
var backpic : int := Pic.New (0, 0, 2, 2)
var screenpic : int := Pic.New (0, 0, 2, 2)
var deltaTime, xm, ym, cm, btnstrt, btncont, btnend, mainMenuButton, loadedsave, loadedsavepref, menuhead, menubg, menublk, menuload,
    saveButton, saveasguiheight, nameTextField, nameLabel, saveFile, menudelete, cbprev, cbcreative, genVersion, seed, popupWinID : int
var gametimeold, mstScrnHsGnLft, mstScrnHsGnRght, mstScrnHsGnUp, mstScrnHsGnDwn : int := 0
var loaded, quitthegame, preview, resetdefaulthead, resetdefaulttime, resetdefaultblock, menuReturn,
    inPauseMenu, scrollSlow, yesConfirm, recentclick, keyp : boolean := false
var gmfrstmthrgh : boolean := true
var offsetleftright, offsetupdown, slowScrollSpeed : real := 0
var timeOfDay, oldTimeColorVal, oldTime : real := -1
var isaves : int := 1
var bgcolour : int := white
var textfound : string
var loadfile, importedBlockList : string := ""
var item1 : array 1 .. 16 of int
var item2 : array 1 .. 13 of int
var item3 : array 1 .. numBlockTypes of int
var item4 : array 0 .. 99 of int
var item5 : array 1 .. 99 of int
var menuitemcolours : array 1 .. 16 of string (20) := init ("Default", "White", "Light Grey", "Dark Grey", "Black",
    "Brown", "Red", "Orange", "Yellow", "Green", "Dark Green", "Turquoise", "Blue", "Dark Blue", "Purple", "Pink")
var menuitemtime : array 1 .. 13 of string (10) := init ("Default", "12:00am", "2:00am", "4:00am", "6:00am", "8:00am", "10:00am", "12:00pm", "2:00pm", "4:00pm", "6:00pm", "8:00pm", "10:00pm")
var menuitemblock : array 1 .. numBlockTypes of string
for i : 1 .. numBlockTypes
    if i = 1 then
	menuitemblock (i) := "Default"
    elsif i > ord (blk.error) + 1 then
	menuitemblock (i) := blockType (i - 1).name
    else
	menuitemblock (i) := blockType (i - 2).name
    end if
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


%-------------Functions-----------------
function LERP (data1, data2 : int, u : real) : int
    result round (intreal (data1) * (1.0 - u) + intreal (data2) * u)
end LERP

%Range: x: -4999 to 5000, y: -2499 to 2500

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

function decodeX (coordcode : int) : int
    result coordcode - (floor (coordcode / 10000) * 10000) - 4999
end decodeX

function decodeY (coordcode : int) : int
    result floor (coordcode / 10000) - 2499
end decodeY

function isWholeNumber (input : real) : boolean
    result input = round (input)
end isWholeNumber

function smallestOf (in1, in2 : real) : real
    if in1 <= in2 then
	result in1
    else
	result in2
    end if
end smallestOf

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


%Declaration statement for the array of blocks: used to be way down there because
%it took a really long time But now, it's snappy fast as an int1 (-128 to 127)!
const XLIMIT : int := 5000 % = total of 5000 + 5000 + 1 = 10001 blocks
const YLIMIT : int := 2500 % = total of 2500 + 2500 + 1 = 5001 blocks
var block : array - XLIMIT .. XLIMIT of array - YLIMIT .. YLIMIT of blockVec


%Terrain generation rules
function terrainQuery (x, y : int, layer : int1) : int
    if genVersion < 4 then %Flat world terrain gen
	if layer not= ord (layerId.background) then %foreground, or both - only okay because background gen is always void!
	    if y < 0 then
		result ord (blk.dirt)
	    else
		result ord (blk.air)
	    end if
	else
	    result ord (blk.void)
	end if
    end if
    result ord (blk.air)
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
    if layer = ord (layerId.background) or layer = ord (layerId.both) and foundType <= ord (blk.air) then %If found invisible block (void, boarder, air) % wait is boarder invisible or not??
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
	result blockType (ord (blk.boarder))
    end if
    var returnBlock : blockStruct
    if background then
	returnBlock := blockType (block (cdx) (cdy).bg)
    else
	returnBlock := blockType (block (cdx) (cdy).block)
    end if
    if useTerrain and returnBlock.id = ord (blk.void) then
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

function getBlockLocColor (x, y : int, useTerrain : boolean) : int
    var foundTypeBlock : blockStruct := getBlock (x, y, false, useTerrain)
    if not isBlock (x, y, blkGroup.any, 1, useTerrain) then %slower than necessary?
	var foundTypeBg : blockStruct := getBlock (x, y, true, useTerrain)
	if foundTypeBg.id not= ord (blk.void) then
	    result foundTypeBg.clr
	end if
    end if
    result foundTypeBlock.clr
end getBlockLocColor

procedure DrawBlock (x, y : int, useTerrain : boolean)
    DrawBlockScrn (toScrnCdX (x), toScrnCdY (y), getBlockLocColor (x, y, useTerrain))
end DrawBlock

procedure DrawBlockClr (x, y : real, clr : int)
    DrawBlockScrn (toScrnCdX (x), toScrnCdY (y), clr)
end DrawBlockClr

procedure DrawBlockR (x, y : real, useTerrain : boolean)
    DrawBlock (toBlock (x), toBlock (y), useTerrain)
end DrawBlockR

%Classes
class entity
    import vec2, vec2i, blockStruct, blockType, blk, blocksize, imgDir, imgType,
	toGameCdMeasure, toScrnCdX, toScrnCdY, toGameCdX, toGameCdY, toGameCdXR, toGameCdYR, toBlock,
	isBlock, raycastLine, blkGroup, setBlock, DrawBlock, getBlock, isBlockR, Math, block,
	bgcolour, charudpxrange, PicDrawTranslucentBox
    export Initialize, Update, PreDraw, DrawEntity, DrawGUI, UnDraw

    procedure Initialize
    end Initialize

    procedure Update (deltaTime : int)
    end Update

    procedure PreDraw
    end PreDraw

    procedure DrawEntity
    end DrawEntity

    procedure DrawGUI
    end DrawGUI

    procedure UnDraw
    end UnDraw
end entity

class player
    inherit entity
    import xm, ym, cm, scrollSlow
    export headcolour, placingBlock, SetHeadColour, SetPlacingBlock, pos, health, survival,
	leftSide, rightSide, topSide, SetPosX, SetPosY, SetHealth, FinalVariableAssingment,
	KeyboardInput, HandleMouse, SetSurvival, HandleKeyboard, ResetVariables, DebugDraw,
	UpdateOldPos


    %Enums for readability
    type sprt : enum (walk, crawl, falljump, stand, jump, fall, dead, crosshairs)
    type cursor : enum (isbb, ispb)
    type cursorClr : enum (black, white)
    type backdir : enum (left, right)

    const jumpheight : real := 2.3
    const doubletapspeed : int := 300
    const staticfalldamage : boolean := true
    const lethalFallHeight : int := 5
    const gravAmount : real := 0.025

    var blockplacespeed : int := 130
    var blockbreakspeed : int := 130
    var reach : real := 5
    var playerSpeed : real := 5 / 1000

    var charbackpic : int := Pic.New (0, 0, 2, 2)
    var healthbarback : int := Pic.New (0, 0, 2, 2)
    var sprite : array 0 .. 7 of array 0 .. 3 of array 0 .. 2 of array 0 .. 1 of int
    var stand : int
    var crawlr : int
    var crosshairsbbpre : int % (action)(frame)(isbb=0)(colorblack=0)
    var crosshairsbbpre2 : int % (action)(frame)(isbb=0)(colorwhite=1)
    var crosshairspbpre : int % (action)(frame)(ispb=1)(colorblack=0)
    var crosshairspbpre2 : int % (action)(frame)(ispb=1)(colorwhite=1)
    var charwidth : real
    var charheight : real
    var pos, oldPos : vec2
    var rcursorbb, rcursorpb : vec2i
    var character, backpiccross, backpicbox : int
    var sprintpossibled, sprintpossiblea, flypossible, mclickr, mclickl, healthold, crosshairsbb2, crosshairsbb, crosshairspb2,
	crosshairspb, action, actionCurrent, frame, isClick, facing : int := 0
    var onground, inground, onleftwall, onrightwall, hitceiling, sprintd, sprinta, recentstartd, recentstarta, recentstartspace,
	mustcrawl, flying, moving, keyspc, keya, keys, keyd, keyalt : boolean := false
    var survival : boolean := true
    var jumpcount, gravcount, frametimer : real := 0
    var headcolour : int := -1
    var health : int := 1000
    var placingBlock : blockStruct := blockType (ord (blk.error))
    var oldfacing : string := ""

    var crouchheight : real % := toGameCdMeasure (Pic.Height (crawlr))
    var standheight : real % := toGameCdMeasure (Pic.Height (stand))

    forward procedure LoadSprites

    body procedure Initialize
	pos.x := 0
	pos.y := 0
	oldPos.x := pos.x
	oldPos.y := pos.y

	LoadSprites ()

	%Assignment of variables whose values are based on sprites
	stand := sprite (ord (sprt.stand)) (0) (0) (0)
	crawlr := sprite (ord (sprt.crawl)) (0) (2) (0)
	crosshairsbbpre := sprite (ord (sprt.crosshairs)) (0) (ord (cursor.isbb)) (ord (cursorClr.black)) % (action)(frame)(isbb=0)(colorblack=0)
	crosshairsbbpre2 := sprite (ord (sprt.crosshairs)) (0) (ord (cursor.isbb)) (ord (cursorClr.white)) % (action)(frame)(isbb=0)(colorwhite=1)
	crosshairspbpre := sprite (ord (sprt.crosshairs)) (0) (ord (cursor.ispb)) (ord (cursorClr.black)) % (action)(frame)(ispb=1)(colorblack=0)
	crosshairspbpre2 := sprite (ord (sprt.crosshairs)) (0) (ord (cursor.ispb)) (ord (cursorClr.white)) % (action)(frame)(ispb=1)(colorwhite=1)
	charwidth := Pic.Width (stand) / blocksize
	charheight := Pic.Height (stand) / blocksize
	crouchheight := toGameCdMeasure (Pic.Height (crawlr))
	standheight := toGameCdMeasure (Pic.Height (stand))
    end Initialize

    %Assign values to variables that are calculated using "blocksize"
    procedure FinalVariableAssingment
	crosshairsbb := Pic.Scale (crosshairsbbpre, blocksize, blocksize)
	crosshairsbb2 := Pic.Scale (crosshairsbbpre2, blocksize, blocksize)
	crosshairspb := Pic.Scale (crosshairspbpre, blocksize, blocksize)
	crosshairspb2 := Pic.Scale (crosshairspbpre2, blocksize, blocksize)
	Pic.SetTransparentColor (crosshairsbb2, 7)
	Pic.SetTransparentColor (crosshairspb2, 7)
    end FinalVariableAssingment

    body procedure LoadSprites
	%Legend:
	%walk, 1-4, l/r, ""/c
	%crawl, 1-4, l/r, ""/c
	%falljump, ""/c, (c's)l/r
	%stand, ""/c, (c's)l/r
	%jump, l/r, (""/c)/(r/l)
	%fall, l/r, (""/c)/(r/l)
	%dead, ""/l/r
	%crosshairs, bb/pb, ""/2
	%
	%Major: 1-4, ""/l/r, ""/c, bb/pb/ ""/2

	var spriteFileNames : array 0 .. 7 of string := init ("walk", "crawl", "falljump", "stand", "jump", "fall", "dead", "crosshairs")
	var spritelr : array 0 .. 2 of string := init ("", "l", "r")
	var spritec : array 0 .. 1 of string := init ("", "c")
	var spriteb : array 0 .. 1 of string := init ("bb", "pb")
	var sprite2 : array 0 .. 1 of string := init ("", "2")

	%var imgDir : string := "Images\\"
	%var imgType : string := ".bmp"
	%var nullPic : int := Pic.FileNew(imgDir + "dead" + imgType)
	for action : 0 .. 7
	    for frame : 0 .. 3
		for leftright : 0 .. 2
		    for isc : 0 .. 1
			for blockborp : 0 .. 1
			    for twoornah : 0 .. 1
				var filename : string := "null"
				if action <= 1 and leftright > 0 and blockborp = 0 and twoornah = 0 then %walk, crawl
				    filename := spriteFileNames (action) + intstr (frame + 1) + spritelr (leftright) + spritec (isc)
				    sprite (action) (frame) (leftright) (isc) := Pic.FileNew (imgDir + filename + imgType)
				elsif action >= 2 and action <= 3 and frame = 0 and leftright > 0 and blockborp = 0 and twoornah = 0 then %falljump, stand
				    if isc = 0 then
					if leftright = 1 then
					    filename := spriteFileNames (action) + spritec (isc)
					    sprite (action) (frame) (0) (isc) := Pic.FileNew (imgDir + filename + imgType)
					end if
				    else
					if action = 3 and frame = 0 and leftright not= 0 and isc = 1 then %standrc and lc .bmp do not exist! I've been using a frame from walk!
					    filename := spriteFileNames (ord (sprt.walk)) + "2" + spritelr (leftright) + spritec (isc)
					else
					    filename := spriteFileNames (action) + spritec (isc) + spritelr (leftright)
					end if
					sprite (action) (frame) (leftright) (isc) := Pic.FileNew (imgDir + filename + imgType)
				    end if
				elsif action >= 4 and action <= 5 and frame = 0 and leftright > 0 and twoornah = 0 then % jump, fall
				    if blockborp = 0 then
					if isc = 0 then
					    if leftright = 1 then
						filename := spriteFileNames (action) + spritelr (leftright) + spritelr (2)
					    else
						filename := spriteFileNames (action) + spritelr (leftright) + spritelr (1)
					    end if
					    sprite (action) (frame) (0) (leftright - 1) := Pic.FileNew (imgDir + filename + imgType)
					end if
				    else
					filename := spriteFileNames (action) + spritelr (leftright) + spritec (isc)
					sprite (action) (frame) (leftright) (isc) := Pic.FileNew (imgDir + filename + imgType)
				    end if
				elsif action = 6 and frame = 0 and isc = 0 and blockborp = 0 and twoornah = 0 then %dead
				    filename := spriteFileNames (action) + spritelr (leftright)
				    sprite (action) (frame) (leftright) (isc) := Pic.FileNew (imgDir + filename + imgType)
				elsif action = 7 and frame = 0 and leftright = 0 and isc = 0 then %crosshairs
				    filename := spriteFileNames (action) + spriteb (blockborp) + sprite2 (twoornah)
				    sprite (action) (frame) (blockborp) (twoornah) := Pic.FileNew (imgDir + filename + imgType)
				end if
				/*if filename = "null" and blockborp = 0 and twoornah = 0 then %Wouldn't work, too much changing the indicies going on up above.
				 sprite (action) (frame) (leftright) (isc) := nullPic
				 end if*/
			    end for
			end for
		    end for
		end for
	    end for
	end for
    end LoadSprites

    procedure SetHeadColour (clr : int)
	headcolour := clr
    end SetHeadColour

    procedure SetPlacingBlock (blockTypeIn : blockStruct)
	placingBlock := blockTypeIn
    end SetPlacingBlock

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

    procedure SetPosX (posXin : real)
	pos.x := posXin
    end SetPosX

    procedure SetPosY (posYin : real)
	pos.x := posYin
    end SetPosY

    procedure SetHealth (newHealth : int)
	health := newHealth
    end SetHealth

    procedure SetSurvival (newState : boolean)
	survival := newState
	if not survival then
	    blockplacespeed := 0
	    blockbreakspeed := 0
	end if
    end SetSurvival


    %Get input for keyboard and parallelport
    procedure KeyboardInput (arrow : array char of boolean)
	%Reset input variables
	keyspc := false
	keya := false
	keys := false
	keyd := false
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

	if arrow (KEY_ALT) then
	    keyalt := true
	end if

	for i : 0 .. 9
	    var c : char := intstr (i)
	    if arrow (c) then
		SetPlacingBlock (blockType (i))
	    end if
	end for
    end KeyboardInput

    %How the aim guide moves in accordance with the mouse
    procedure AimGuideMovement
	var handheight : real := pos.y + charheight / 3 * 2 %Height that the character's hands are
	if not survival then
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
		    if not survival or placingBlock.physics or againstValidBlock then
			setBlock (mouseGX, mouseGY, placingBlock.id, false)
			DrawBlock (mouseGX, mouseGY, true) %draws block you clicked, until a screen scroll/update
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


    procedure HandleMouse
	isClick := 0
	if cm not= 0 then
	    isClick := 1
	end if

	AimGuideMovement

	PlayerRightClick

	PlayerLeftClick
    end HandleMouse


    %If 'd' key is pressed
    procedure PressDKey (deltaTime : int)
	if keyd and health > 0 then
	    moving := true
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
	    action := ord (sprt.walk)
	    facing := 2 %"right"
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
    procedure PressAKey (deltaTime : int)
	if keya and health > 0 then
	    moving := true
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
	    elsif sprinta then %sprinting
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
	    action := ord (sprt.walk)
	    facing := 1 %"left"
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
    procedure PressSpaceKey (deltaTime : int)
	if keyspc and health > 0 then
	    if not survival and recentstartspace then
		recentstartspace := false
		if flypossible = 0 then
		    flypossible := doubletapspeed
		elsif flypossible not= 0 then
		    flypossible := 0
		    flying := not flying
		    gravcount := 0 %Reset downwards velocity
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
    procedure PressSKey (deltaTime : int)
	if keys and health > 0 then
	    if onground then
		action := ord (sprt.crawl)
	    elsif flying then
		pos.y -= playerSpeed * 8 * deltaTime
	    end if
	end if
    end PressSKey

    procedure HandleKeyboard (deltaTime : int)
	%Character standing by default
	actionCurrent := action     %Save current action (continuing from last frame) for detection purposes
	action := ord (sprt.stand)
	moving := false

	PressDKey (deltaTime)

	PressAKey (deltaTime)

	PressSpaceKey (deltaTime)

	PressSKey (deltaTime)

    end HandleKeyboard


    %Gravity
    procedure Gravity (deltaTime : int)
	if not onground and jumpcount = 0 and not flying then
	    var gravScalar : real := 1
	    if gravcount = 0 then %The "if = 0" is starting fall amount - still not sure what to make of this
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

    %Jumping
    procedure CharJump (deltaTime : int)
	if not mustcrawl and not flying then
	    if jumpcount = jumpheight then
		facing := 0
	    end if
	    if jumpcount > 0 then
		action := ord (sprt.jump)
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
		action := ord (sprt.fall)
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
	    if actionCurrent = ord (sprt.crawl) then %isActionCurrent ("crawling") then
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
		    actionCurrent := ord (sprt.crawl)
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
	if not onground and mustcrawl and not inground then %Falling, but block above (on) head (crawling)
	    var offendingY : int
	    var canStand : boolean := true
	    var checkCountx : int := ceil (charwidth)
	    if toBlock (rightSide ()) - toBlock (leftSide ()) > checkCountx - 1 then
		checkCountx += 1
	    end if
	    var checkCounty : int := ceil (standheight - crouchheight) %Only checking above crouching player until full stand height
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
		checkCounty := ceil (pos.y - desiredBottom) %Only checking from where player currently is down to desired position
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
		actionCurrent := ord (sprt.fall)
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

    %Crawling and walking animations
    procedure Animations
	%Character image used if forced crawling
	if mustcrawl then
	    action := ord (sprt.crawl)
	end if
	%Walking/Crawling animations
	if (frametimer >= 30 and action not= ord (sprt.crawl) and (sprinta or sprintd) or frametimer >= 50 and action not= ord (sprt.crawl))
		or (frametimer >= 80 and action = ord (sprt.crawl)) then
	    frametimer := 0
	    frame += 1
	    if frame > 5 then
		frame := 0
	    end if
	end if
    end Animations

    %Finalizing "action" and deciding what character image is being used
    procedure CharImage
	%Incorporate looking direction into action when not jumping or falling
	if health > 0 and action not= ord (sprt.jump) and action not= ord (sprt.fall) then
	    if cm not= 0 then
		if toGameCdX (xm) >= pos.x then
		    facing := 2 %"right"
		else
		    facing := 1 %"left"
		end if
	    end if
	end if

	if health = 0 then
	    action := ord (sprt.dead)
	end if

	%Directionless fall
	if action = ord (sprt.fall) and not keya and not keyd and not onground then
	    facing := 0
	end if

	var finalAction : int := action
	var finalFrame : int := frame
	if frame > 3 then
	    finalFrame := 6 - frame
	end if
	var finalLeftRight : int := facing
	var finalIsClick : int := isClick

	%Set falljump direction based on mouse location
	if (finalAction = ord (sprt.jump) or finalAction = ord (sprt.fall)) and facing = 0 then
	    finalAction := ord (sprt.falljump)
	    if isClick = 1 then
		if toGameCdX (xm) >= pos.x then
		    finalLeftRight := 2 %"right"
		else
		    finalLeftRight := 1 %"left"
		end if
	    end if
	end if

	%Fix value of frame(finalFrame) when there's no sprite for its current value
	if finalAction > ord (sprt.crawl) then
	    finalFrame := 0
	elsif finalAction <= ord (sprt.crawl) and not moving then
	    finalFrame := 1
	end if
	%locate (1, 1)
	%put delayFrameChange
	if finalAction <= ord (sprt.crawl) and moving and (onleftwall or onrightwall /*or delayFrameChange = 1*/) then
	    finalFrame := 2
	    %delayFrameChange += 1      %It used to bug out when I didn't have all this, but now it's fine? Whatever.
	    %else
	    %delayFrameChange := 0
	end if
	%Fix value of facing(finalLeftRight) when there's no sprite for its current value
	if finalLeftRight = 0 and (finalAction <= ord (sprt.crawl) %If no facing and: walk or crawl
		or (finalAction = ord (sprt.falljump) or finalAction = ord (sprt.stand)) and (isClick = 1)) then %or (falljump or stand) and clicking
	    finalLeftRight := 2
	elsif ((finalAction = ord (sprt.stand) or finalAction = ord (sprt.falljump)) and finalIsClick = 0) then
	    finalLeftRight := 0
	elsif (finalAction = ord (sprt.jump) or finalAction = ord (sprt.fall)) and finalIsClick = 1 then %jumplr and jumprl and stuff are saved under facing =0, click=left/right
	    %Incorporate looking direction into action when jumping or falling
	    if toGameCdX (xm) >= pos.x then
		if finalLeftRight = 1 then
		    finalIsClick := ord (backdir.left)
		    finalLeftRight := 0
		end if
	    else
		if finalLeftRight = 2 then
		    finalIsClick := ord (backdir.right)
		    finalLeftRight := 0
		end if
	    end if
	end if
	%Fix value of isClick(finalIsClick) when there's no sprite for its current value
	if finalIsClick not= 0 and finalAction = ord (sprt.dead) then
	    finalIsClick := 0
	end if

	character := sprite (finalAction) (finalFrame) (finalLeftRight) (finalIsClick)
    end CharImage

    procedure UpdateOldPos
	oldPos.x := pos.x
	oldPos.y := pos.y
    end UpdateOldPos

    body procedure Update (deltaTime : int)
	Gravity (deltaTime)

	CharJump (deltaTime)

	WorldCollisions

	Animations

	%Stop sprinting if crawling
	if action = ord (sprt.crawl) then
	    sprintd := false
	    sprinta := false
	end if

	CharImage

	%Get character dimensions
	charwidth := toGameCdMeasure (Pic.Width (character) - Pic.Width (character) mod 2)
	charheight := toGameCdMeasure (Pic.Height (character))

	if health < 0 then
	    health := 0
	end if

	%Setting oldPos
	UpdateOldPos

	if health < 0 then
	    health := 0
	end if

	%Movement timer
	frametimer += playerSpeed * 140 * deltaTime
    end Update

    %Save background behind aim guides
    procedure AimGuideBacksave
	if health > 0 then
	    %Get blocks at block placing box and block breaking crosshairs
	    if toGameCdXR (rcursorbb.x) not= toGameCdXR (rcursorpb.x) or toGameCdYR (rcursorbb.y) not= toGameCdYR (rcursorpb.y) then
		%Save background behind crosshairs
		backpiccross := Pic.New (rcursorbb.x, rcursorbb.y, rcursorbb.x + blocksize - 1, rcursorbb.y + blocksize - 1)

		%Save background behind box
		backpicbox := Pic.New (rcursorpb.x, rcursorpb.y, rcursorpb.x + blocksize - 1, rcursorpb.y + blocksize - 1)
	    else
		%Save background behind crosshairs and box
		backpiccross := Pic.New (rcursorbb.x, rcursorbb.y, rcursorbb.x + blocksize - 1, rcursorbb.y + blocksize - 1)
	    end if
	end if
    end AimGuideBacksave

    body procedure PreDraw
	%Save background behind character
	Pic.Free (charbackpic)
	charbackpic := Pic.New (toScrnCdX (leftSide ()) - charudpxrange, toScrnCdY (pos.y) - charudpxrange,
	    toScrnCdX (rightSide ()) + charudpxrange, toScrnCdY (topSide ()) + charudpxrange)

	%Save background behind aim guide
	AimGuideBacksave

	%Save background behind health bar
	if survival then
	    Pic.Free (healthbarback)
	    healthbarback := Pic.New (0, 19, maxx, 41) %Pic.New (maxx div 8 - 1, 19, (maxx div 4 * 3) + maxx div 8 + 1, 41)
	end if
    end PreDraw

    %Draw character image and head colour
    body procedure DrawEntity
	%Draw character's head colour
	var offsetx : int := 0
	var offsety : int := 21
	if action = ord (sprt.crawl) or action = ord (sprt.dead) then
	    offsetx := 4
	    offsety := 4
	    if facing = 1 then
		offsetx *= -1
	    end if
	    if action = ord (sprt.crawl) then
		offsety += 4
	    end if
	end if
	Draw.FillOval (toScrnCdX (pos.x) + offsetx, toScrnCdY (pos.y) + offsety, 3, 3, headcolour)

	%Draw character
	/*
	 //This commented stuff was for fixing that slight screen jitter, I think?
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

	Pic.Draw (character, toScrnCdX (leftSide ()), toScrnCdY (pos.y), picMerge)
    end DrawEntity

    %draw aim guides
    procedure DrawAimGuide
	if health > 0 then
	    %Get blocks at block placing box and block breaking crosshairs
	    if toGameCdXR (rcursorbb.x) not= toGameCdXR (rcursorpb.x) or toGameCdYR (rcursorbb.y) not= toGameCdYR (rcursorpb.y) then
		%Draw crosshairs for breaking blocks
		if isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 1, true)
			and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).block).clr = black
			or isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 0, true)
			and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).bg).clr = black
			or bgcolour = black then
		    Pic.Draw (crosshairsbb2, rcursorbb.x, rcursorbb.y, picMerge)
		else
		    Pic.Draw (crosshairsbb, rcursorbb.x, rcursorbb.y, picMerge)
		end if

		%Draw box for placing blocks
		if isBlock (toGameCdXR (rcursorpb.x), toGameCdYR (rcursorpb.y), blkGroup.any, 1, true)
			and blockType (block (toGameCdXR (rcursorpb.x)) (toGameCdYR (rcursorpb.y)).block).clr = black
			or isBlock (toGameCdXR (rcursorpb.x), toGameCdYR (rcursorpb.y), blkGroup.any, 0, true)
			and blockType (block (toGameCdXR (rcursorpb.x)) (toGameCdYR (rcursorpb.y)).bg).clr = black
			or bgcolour = black then
		    Pic.Draw (crosshairspb2, rcursorpb.x, rcursorpb.y, picMerge)
		else
		    Pic.Draw (crosshairspb, rcursorpb.x, rcursorpb.y, picMerge)
		end if
	    else
		%Draw crosshairs for breaking blocks and box for placing blocks
		if isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 1, true)
			and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).block).clr = black
			or isBlock (toGameCdXR (rcursorbb.x), toGameCdYR (rcursorbb.y), blkGroup.any, 0, true)
			and blockType (block (toGameCdXR (rcursorbb.x)) (toGameCdYR (rcursorbb.y)).bg).clr = black
			or bgcolour = black then
		    Pic.Draw (crosshairsbb2, rcursorbb.x, rcursorbb.y, picMerge)
		    Pic.Draw (crosshairspb2, rcursorpb.x, rcursorpb.y, picMerge)
		else
		    Pic.Draw (crosshairsbb, rcursorbb.x, rcursorbb.y, picMerge)
		    Pic.Draw (crosshairspb, rcursorpb.x, rcursorpb.y, picMerge)
		end if
	    end if
	end if
    end DrawAimGuide

    %Draw the health bar and save its background
    procedure DrawHealthBar
	if survival then
	    if health not= 0 then
		PicDrawTranslucentBox (maxx div 8, 20, maxx div 8 + round ((maxx div 4 * 3 / 100) * (health / 10)), 40, brightgreen, 0.5)
		Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, 10)
	    else
		Draw.Box (maxx div 8, 20, (maxx div 4 * 3) + maxx div 8, 40, brightred)
	    end if
	end if
    end DrawHealthBar

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

    body procedure DrawGUI
	DrawAimGuide
	DrawHealthBar
	%DebugDraw
    end DrawGUI

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

    %Erase the health bar by redrawing its background
    procedure EraseHealthBar
	if survival then
	    Pic.Draw (healthbarback, 0, 19, picCopy)
	end if
    end EraseHealthBar

    body procedure UnDraw
	EraseHealthBar

	EraseAimGuide

	%Draw old unaltered background over character
	Pic.Draw (charbackpic, toScrnCdX (pos.x - charwidth / 2) - charudpxrange, toScrnCdY (pos.y) - charudpxrange, picCopy)
    end UnDraw

    procedure ResetVariables
	sprintpossibled := 0
	sprintpossiblea := 0
	flypossible := 0
	gravcount := 0
	jumpcount := 0
	frametimer := 0
	frame := 0
	crosshairsbb2 := 0
	crosshairsbb := 0
	crosshairspb2 := 0
	crosshairspb := 0
	mclickr := 0
	mclickl := 0
	healthold := 0
	survival := false
	onground := false
	onleftwall := false
	onrightwall := false
	hitceiling := false
	sprintd := false
	sprinta := false
	recentstartd := false
	recentstarta := false
	mustcrawl := false
	charwidth := toGameCdMeasure (Pic.Width (character) - Pic.Width (character) mod 2)
	charheight := toGameCdMeasure (Pic.Height (character))
	pos.x := 0
	pos.y := 0
	health := 1000
	action := ord (sprt.stand)
	facing := 0
	oldfacing := ""
	/*%
	 if loaded then
	 headcolour := -1
	 placingBlock := blockType (ord (blk.error))
	 end if*/
	blockplacespeed := 130
	blockbreakspeed := 130
	flying := false
	keyspc := false
	keya := false
	keys := false
	keyd := false
	keyalt := false
    end ResetVariables
end player


var numEntities : int := 0
var entities : array 0 .. MAX_ENTITIES of pointer to entity

new player, entities (numEntities)
var player1 : pointer to player := entities (0)
player1 -> Initialize ()
numEntities += 1


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
	result - 1
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

function colourmenuify (clr : int) : int
    if clr = -1 then
	result 1
    elsif clr = white then
	result 2
    elsif clr = grey then
	result 3
    elsif clr = darkgrey then
	result 4
    elsif clr = black then
	result 5
    elsif clr = 114 then
	result 6
    elsif clr = brightred then
	result 7
    elsif clr = 42 then
	result 8
    elsif clr = yellow then
	result 9
    elsif clr = brightgreen then
	result 10
    elsif clr = green then
	result 11
    elsif clr = 52 then
	result 12
    elsif clr = brightblue then
	result 13
    elsif clr = blue then
	result 14
    elsif clr = 34 then
	result 15
    elsif clr = brightpurple then
	result 16
    end if
end colourmenuify

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
    var val : real := (12 - abs (nbr - 12)) / 12.0
    RGB.SetColor (blockType (ord (blk.air)).clr, 0, val, val / 2 + 0.5)
    result blockType (ord (blk.air)).clr
end timecolourify

function timemenu (nbr : int) : int
    if nbr = 1 then
	result - 1
    else
	result (nbr - 2) * 2
    end if
end timemenu

function blockmenu (nbr : int) : int
    if nbr = 1 then
	result ord (blk.error)
    elsif nbr > ord (blk.error) + 1 then
	result nbr - 1
    else
	result nbr - 2
    end if
end blockmenu

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
    bgcolour := white
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

%Show colour preview as default
procedure ShowColourPreview
    colourback (bgcolour) %Not needed once I've gotten rid of all the "put"s

    Draw.FillBox (0, maxy - 94, 94, maxy - 80, bgcolour)
    Draw.FillBox (24, maxy - 57, 75, maxy - 46, bgcolour)
    if player1 -> headcolour = -1 then
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, bgcolour)
	Draw.Text ("DEFAULT", 25, maxy - 55, font2, black)
	Draw.Text ("Default head", 1, maxy - 90, font2, black)
    else
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, player1 -> headcolour)
	Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	Draw.Text (menuitemcolours (colourmenuify (player1 -> headcolour)) + " head", 1, maxy - 90, font2, black)
    end if


    Draw.FillBox (99, maxy - 94, 232, maxy - 80, bgcolour)
    Draw.FillBox (137, maxy - 57, 188, maxy - 46, bgcolour)
    if timeOfDay = -1 then
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	Draw.Text ("DEFAULT", 138, maxy - 55, font2, black)
	Draw.Text ("Default time", 115, maxy - 90, font2, black)
    else
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, blockType (ord (blk.air)).clr)
	Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	Draw.Text ("Time: " + timestringify (timeOfDay), 115, maxy - 90, font2, black)
    end if

    Draw.FillBox (237, maxy - 94, 340, maxy - 80, bgcolour)
    Draw.FillBox (257, maxy - 57, 308, maxy - 46, bgcolour)
    if player1 -> placingBlock.id = ord (blk.error) then
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, bgcolour)
	Draw.Text ("DEFAULT", 258, maxy - 55, font2, black)
	Draw.Text ("Default blocks", 238, maxy - 90, font2, black)
    else
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, player1 -> placingBlock.clr)
	Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	Draw.Text (player1 -> placingBlock.name + " blocks", 238, maxy - 90, font2, black)
    end if
end ShowColourPreview

%If the user selects an option in the "Head Colour" menu
procedure HeadSelected
    for i : 1 .. 16
	if item1 (i) = GUI.GetEventWidgetID then
	    player1 -> SetHeadColour (numbercolourify (i))
	    ShowColourPreview
	end if
    end for
end HeadSelected

%If the user selects an option in the "Background Colour" menu
procedure TimeSelected
    for i : 1 .. 13
	if item2 (i) = GUI.GetEventWidgetID then
	    timeOfDay := timemenu (i)
	    if inPauseMenu then
		bgcolour := timecolourify (timeOfDay)
		Draw.FillBox (0, 0, maxx, maxy - 20, bgcolour) %a cls
		GUI.Refresh
	    else
		var tmp : int := timecolourify (timeOfDay)
	    end if
	    ShowColourPreview
	end if
    end for
end TimeSelected

%If the user selects an option in the "Block Colour" menu
procedure BlocksSelected
    for i : 1 .. numBlockTypes
	if item3 (i) = GUI.GetEventWidgetID then
	    player1 -> SetPlacingBlock (blockType (blockmenu (i)))
	    ShowColourPreview
	end if
    end for
end BlocksSelected

procedure GUIConfirm
    yesConfirm := true
    GUI.Quit
end GUIConfirm

function GUIChoose (messageIn, btn1, btn2 : string) : boolean
    yesConfirm := false
    var popupWinID : int := Window.Open ("position:center;center,graphics:200;100,popup")
    colorback (grey)
    cls
    var font : int := Font.New ("serif:13")
    var message : string := messageIn
    %Quotify message
    var inQuotes : boolean := false
    for i : 1 .. length (message)
	if message (i) = "\"" then
	    inQuotes := not inQuotes
	end if
	if inQuotes and message (i) = " " then
	    message := message (1 .. i - 1) + "_" + message (i + 1 .. length (message))
	end if
    end for

    var message1 : string := ""
    var message2 : string := ""
    var message3 : string := ""
    if Font.Width (message, font) < maxx then
	message2 := message
    else
	var middleSpace : int := 1
	for i : 1 .. length (message)
	    if message (i) = " " then
		if abs (i - length (message) div 2) < abs (middleSpace - length (message) div 2) then
		    middleSpace := i
		end if
	    end if
	end for
	message1 := message (1 .. middleSpace - 1)
	message2 := message (middleSpace + 1 .. length (message))
	if Font.Width (message1, font) >= maxx or Font.Width (message2, font) >= maxx then
	    var thirdSpace1 : int := 1
	    var thirdSpace2 : int := 1
	    for i : 1 .. length (message)
		if message (i) = " " then
		    if abs (i - length (message) div 3) < abs (thirdSpace1 - length (message) div 3) then
			thirdSpace1 := i
		    elsif abs (i - length (message) div 3 * 2) < abs (thirdSpace2 - length (message) div 3 * 2) then
			thirdSpace2 := i
		    end if
		end if
	    end for
	    message1 := message (1 .. thirdSpace1 - 1)
	    message2 := message (thirdSpace1 + 1 .. thirdSpace2 - 1)
	    message3 := message (thirdSpace2 + 1 .. length (message))
	end if
    end if

    %UnQuotify message
    for i : 1 .. length (message1)
	if message1 (i) = "_" then
	    message1 := message1 (1 .. i - 1) + " " + message1 (i + 1 .. length (message1))
	end if
    end for
    for i : 1 .. length (message2)
	if message2 (i) = "_" then
	    message2 := message2 (1 .. i - 1) + " " + message2 (i + 1 .. length (message2))
	end if
    end for
    for i : 1 .. length (message3)
	if message3 (i) = "_" then
	    message3 := message3 (1 .. i - 1) + " " + message3 (i + 1 .. length (message3))
	end if
    end for
    Draw.Text (message1, 10, maxy - 15, font, black)
    Draw.Text (message2, 10, maxy - 35, font, black)
    Draw.Text (message3, 10, maxy - 55, font, black)
    %Font.Free(font)
    GUI.SetDisplayWhenCreated (true)
    var deleteBtn : int := GUI.CreateButton (20, 10, 0, "Delete", GUIConfirm)
    var quitBtn : int := GUI.CreateButton (110, 10, 0, "Cancel", GUI.Quit)

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.CloseWindow (popupWinID)
    GUI.ResetQuit
    result yesConfirm
end GUIChoose

%If the user selects an option in the "Delete" menu
procedure DeleteSelected
    var idelete : int
    for i : 1 .. isaves - 1
	if item5 (i) = GUI.GetEventWidgetID then
	    idelete := i
	end if
    end for

    %Could also use GUI.Choose here, but it doesn't exist?
    %"Are you sure?" prompt
    if GUIChoose ("Are you sure you want to delete world \"" + menuitemdelete (idelete) + "\"?", "Delete", "Cancel") then
	if menuitemdelete (idelete) = loadfile and loaded then
	    loadfile := ""
	    loaded := false
	end if
	File.Delete (savDir + menuitemdelete (idelete) + ".txt")
	File.Delete (savDir + "Preferences\\" + menuitemdelete (idelete) + ".txt")

	GUI.Disable (item5 (idelete))
	GUI.Disable (item4 (idelete + 1))
	colourback (bgcolour)
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
	    colourback (bgcolour)
	    locate (12, 1)
	    if i = 1 then
		GUI.SetCheckBox (cbcreative, false)
		loaded := false
		put "World: New                       "
		loadfile := ""
	    else
		var isSurvival : boolean := true
		%check preferences file to find survival variable
		open : loadedsavepref, (savDir + "Preferences\\" + loadfile + ".txt"), get, put, seek, mod
		seek : loadedsavepref, 0
		var instring : string
		get : loadedsavepref, instring
		if strrealok (instring) then
		    genVersion := 0
		else
		    genVersion := strint (instring (9 .. *))
		end if
		var numSlotsIgnore : int
		if genVersion = 0 then
		    numSlotsIgnore := 15
		else
		    numSlotsIgnore := 9
		end if

		for i2 : 1 .. numSlotsIgnore
		    get : loadedsavepref, instring
		end for
		get : loadedsavepref, isSurvival
		close : loadedsavepref

		GUI.SetCheckBox (cbcreative, not isSurvival)
		loaded := true
		player1 -> SetHeadColour (-1)
		timeOfDay := -1
		player1 -> SetPlacingBlock (blockType (ord (blk.error)))
		ShowColourPreview
		put "World: ", loadfile + "                      "
	    end if
	end if
    end for
end LoadSelected

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

	open : loadedsavepref, (savDir + "Preferences\\" + textfound + ".txt"), get, put, seek

	put : loadedsavepref, "Gen_Ver_", thisGenVersion
	put : loadedsavepref, player1 -> pos.x
	put : loadedsavepref, player1 -> pos.y
	put : loadedsavepref, player1 -> headcolour
	put : loadedsavepref, timeOfDay
	put : loadedsavepref, player1 -> placingBlock.id
	put : loadedsavepref, blocksize
	put : loadedsavepref, offsetupdown
	put : loadedsavepref, offsetleftright
	put : loadedsavepref, player1 -> health
	put : loadedsavepref, player1 -> survival
	put : loadedsavepref, exportBlockString
	close : loadedsavepref

	open : saveFile, (savDir + textfound + ".txt"), get, put, seek
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
    for i : 1 .. 13
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
    GUI.Enable (item1 (1))
    GUI.Enable (item2 (1))
    GUI.Enable (item3 (1))
    GUI.ResetQuit
    GUI.Refresh
end showMainMenuGUIs

procedure hideMainMenuGUIs
    GUI.Disable (menuload)
    GUI.Disable (menudelete)
    GUI.Disable (item1 (1))
    GUI.Disable (item2 (1))
    GUI.Disable (item3 (1))
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
    GUI.SetText (nameTextField, loadfile)
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
	if isBlock (x, y, blkGroup.any, ord (layerId.both), true) then % or isBlock (x, y, blkGroup.any, true, true) then %Edit: uhhh...?
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

%Draw block on screen
procedure showBlock (xin, yin : int1)
    var x : int := xin
    var y : int := yin
    for i : 0 .. 4
	DrawBlock (x, y, true)
	if i = 0 then
	    y := yin + 1
	elsif i = 1 then
	    y := yin - 1
	elsif i = 2 then
	    y := yin
	    x := xin + 1
	elsif i = 3 then
	    x := xin - 1
	end if
    end for
end showBlock

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

    Draw.FillBox (0, 0, maxx, maxy, blockType (ord (blk.air)).clr) %a cls
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

procedure CenterCamera
    offsetleftright := player1 -> pos.x - toGameCdMeasure (maxx div 2)
    offsetupdown := player1 -> pos.y - toGameCdMeasure (pxscrollclearance) %maxy div 2) - charheight
    UpdateMostTravelled
end CenterCamera

procedure ClampOffsetToScreen
    if toScrnCdX (player1 -> leftSide ()) < pxscrollclearance then
	offsetleftright -= toGameCdMeasure (pxscrollclearance - toScrnCdX (player1 -> leftSide ()))
    elsif toScrnCdX (player1 -> rightSide ()) > maxx - pxscrollclearance then
	offsetleftright += toGameCdMeasure (toScrnCdX (player1 -> rightSide ()) - (maxx - pxscrollclearance))
    end if
    put toScrnCdY (player1 -> pos.y) < pxscrollclearance, ", ", toScrnCdY (player1 -> topSide ()) > maxy - pxscrollclearance
    if toScrnCdY (player1 -> pos.y) < pxscrollclearance then
	offsetupdown -= toGameCdMeasure (pxscrollclearance - toScrnCdY (player1 -> pos.y))
    elsif toScrnCdY (player1 -> topSide ()) > maxy - pxscrollclearance then
	offsetupdown += toGameCdMeasure (toScrnCdY (player1 -> topSide ()) - (maxy - pxscrollclearance))
    end if
    UpdateMostTravelled
end ClampOffsetToScreen


function checkFileReadability (filePathIn : string, testTooLongString : boolean) : int
    var fileSize, attr, ftype : int
    File.Status (filePathIn, fileSize, attr, ftype)
    if fileSize = -1 then
	put "Error: file \"", filePathIn, "\" not found."
	result - 1
    end if
    var emptyCharsOnEnd : int := 0
    var lastValidCharStart : int := 1
    var instring : string
    var file : int
    open : file, (filePathIn), read, seek, mod
    loop
	var pos : int
	tell : file, pos
	var oldPos : int := pos
	read : file, instring
	tell : file, pos
	if length (instring) < pos - oldPos then
	    put "Something is very wrong with this text file. Are you sure it's not an image file or something? (\"", filePathIn, "\")"
	    result - 1
	end if
	var numNewChars : int := pos - oldPos
	var exitEarly : boolean := false

	var emptyCharsOnEndNew : int := 0
	for decreasing i : numNewChars .. 1
	    if ord (instring (i)) = 10 or ord (instring (i)) = 13 then
		emptyCharsOnEndNew += 1
	    else
		emptyCharsOnEnd := emptyCharsOnEndNew
		exitEarly := true
		exit
	    end if
	end for
	if not exitEarly then
	    emptyCharsOnEnd += emptyCharsOnEndNew
	end if
	if testTooLongString then
	    for i : 1 .. numNewChars
		if ord (instring (i)) = 10 or ord (instring (i)) = 13 then
		    if lastValidCharStart not= -1 then
			if ((oldPos + i) - lastValidCharStart) > 255 then
			    put "too many characters in one line! (starting at byte ", lastValidCharStart, " until byte ", oldPos + i, " of file \"", filePathIn, "\")"
			    result - 1
			end if
			lastValidCharStart := -1
		    end if
		else
		    if lastValidCharStart = -1 then
			lastValidCharStart := oldPos + i
		    end if
		end if
	    end for
	end if
	exit when eof (file)
    end loop
    if lastValidCharStart not= -1 then
	if (fileSize - lastValidCharStart + 1) > 255 then
	    put "too many characters in one line! (starting at byte ", lastValidCharStart, " until byte ", fileSize, " of file \"", filePathIn, "\")"
	    result - 1
	end if
	lastValidCharStart := -1
    end if
    close : file
    if emptyCharsOnEnd > 2 then
	put "ignoring last ", emptyCharsOnEnd, " characters"
	result fileSize - emptyCharsOnEnd
    else
	put "ignoring nothing"
	result fileSize
    end if
end checkFileReadability

function checkFileEndChars (filePathIn : string) : int
    result checkFileReadability (filePathIn, false)
end checkFileEndChars

function eofl (fileIn, stopPoint : int) : boolean %End Of File Long
    var currentPos : int
    tell : fileIn, currentPos
    if eof (fileIn) or currentPos >= stopPoint then
	result true
    end if
    result false
end eofl

%Get preferences / load world preferences
procedure GetPreferences
    if loaded then
	var stopPoint : int := checkFileEndChars (savDir + "Preferences\\" + loadfile + ".txt")
	if stopPoint = -1 then
	    return
	end if
	open : loadedsavepref, (savDir + "Preferences\\" + loadfile + ".txt"), get, put, seek, mod
	seek : loadedsavepref, 0

	var instring : string
	get : loadedsavepref, instring
	if strrealok (instring) then
	    genVersion := 0
	else
	    genVersion := strint (instring (9 .. *))
	end if

	var nullreal : real
	var tempreal : real
	var tempInt : int
	if genVersion = 0 then
	    player1 -> SetPosX (strreal (instring))
	else
	    get : loadedsavepref, tempreal
	    player1 -> SetPosX (tempreal)
	end if
	get : loadedsavepref, tempreal
	player1 -> SetPosY (tempreal)
	if player1 -> headcolour = -1 then
	    get : loadedsavepref, tempInt
	    player1 -> SetHeadColour (tempInt)
	else
	    get : loadedsavepref, nullreal
	end if
	if timeOfDay = -1 then
	    get : loadedsavepref, timeOfDay
	    if genVersion < 3 then
		timeOfDay := 12
	    end if
	else
	    get : loadedsavepref, nullreal
	end if
	if player1 -> placingBlock.id = ord (blk.error) then
	    get : loadedsavepref, instring
	    tempInt := strint (instring)
	    if tempInt < 0 or tempInt >= numBlockTypes then
		tempInt := ord (blk.dirt)
	    end if
	    player1 -> SetPlacingBlock (blockType (tempInt))
	else
	    get : loadedsavepref, nullreal
	end if
	if genVersion <= 1 or player1 -> placingBlock.id = ord (blk.error) then
	    player1 -> SetPlacingBlock (blockType (ord (blk.dirt)))
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
	    get : loadedsavepref, tempreal
	    mstScrnHsGnUp := round (tempreal + toGameCdMeasure (maxy div 2))
	    get : loadedsavepref, tempreal
	    mstScrnHsGnDwn := round (tempreal - toGameCdMeasure (maxy div 2))
	    get : loadedsavepref, tempreal
	    mstScrnHsGnLft := round (tempreal - toGameCdMeasure (maxx div 2))
	    get : loadedsavepref, tempreal
	    mstScrnHsGnRght := round (tempreal + toGameCdMeasure (maxx div 2))
	    get : loadedsavepref, offsetupdown
	    offsetupdown /= -blocksize
	    get : loadedsavepref, offsetleftright
	    offsetleftright /= -blocksize
	    get : loadedsavepref, tempInt
	    player1 -> SetHealth (tempInt)
	    get : loadedsavepref, instring %survival - but I'm getting that elsewhere now
	else
	    get : loadedsavepref, offsetupdown
	    get : loadedsavepref, offsetleftright
	    get : loadedsavepref, tempInt
	    player1 -> SetHealth (tempInt)
	    get : loadedsavepref, instring %survival - but I'm getting that elsewhere now
	end if
	if player1 -> health = 0 then %As there is no respawn feature yet, just heal them up if they load in dead.
	    player1 -> SetHealth (1000)
	end if

	if not eof (loadedsavepref) then
	    get : loadedsavepref, importedBlockList : *
	    if importedBlockList not= "" and importedBlockList (1) not= "," then
		importedBlockList := ""
	    end if
	end if
	if importedBlockList = "" then
	    importedBlockList := ",void,boarder,air,dirt,stone,grass,leaves_nat,leaves,wood_nat,wood,platform,water,rail,ladder,wire,pressure_plate"
	end if
	%Convert incorrect ground levels to 0
	if groundLevel not= 0 then
	    player1 -> SetPosY (player1 -> pos.y - groundLevel)
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
			exit when eofl (loadedsavepref, stopPoint)
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

	    open : loadedsave, (savDir + loadfile + ".txt"), get, put, seek, mod
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
	if player1 -> headcolour = -1 then
	    player1 -> SetHeadColour (white)
	end if
	if timeOfDay = -1 then
	    timeOfDay := 12
	end if
	if player1 -> placingBlock.id = ord (blk.error) then
	    player1 -> SetPlacingBlock (blockType (ord (blk.dirt)))
	end if
	CenterCamera
    end if
    ClampOffsetToScreen
end GetPreferences

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

	open : loadedsave, (savDir + loadfile + ".txt"), get, put, seek, mod
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
		    if thisBlockID >= numItems then
			setBlock (xInd, yInd, ord (blk.error), false)
		    else
			setBlock (xInd, yInd, bestMatch (thisBlockID), false)
		    end if
		    if genVersion >= 3 then %Ver 3 and up (this gets the background block)
			get : loadedsave, thisBlockID
			if thisBlockID > numItems then
			    setBlock (xInd, yInd, ord (blk.error), true)
			else
			    setBlock (xInd, yInd, bestMatch (thisBlockID), true)
			end if
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
	    Draw.FillBox (0, 0, newWinMaxx, newWinMaxy, blockType (ord (blk.void)).clr) %a cls
	else
	    Draw.FillBox (0, 0, newWinMaxx, newWinMaxy, blockType (ord (blk.air)).clr) %a cls
	end if
	for cdx : mstScrnHsGnLft .. mstScrnHsGnRght
	    for cdy : mstScrnHsGnDwn .. mstScrnHsGnUp
		var drawCondition : boolean
		if bareBonesPreview then
		    drawCondition := not isBlock (cdx, cdy, ord (blk.void), ord (layerId.both), false)
		else
		    drawCondition := isBlock (cdx, cdy, blkGroup.any, ord (layerId.both), true)
		end if
		if drawCondition then
		    var x : int := cdx - mstScrnHsGnLft
		    var y : int := cdy - mstScrnHsGnDwn
		    /*if isBlock (x, y, blkGroup.any, ord(layerId.both), true) then
		     Draw.Dot (x, y, getBlockLocColor (x, y, not barebonesPreview))
		     end if*/
		    var foundType : int := block (cdx) (cdy).block
		    if not bareBonesPreview then
			if blockType (foundType).name = "void" then
			    foundType := terrainQuery (cdx, cdy, 1)
			    if blockType (foundType).name = "air" then
				foundType := block (cdx) (cdy).bg
				if blockType (foundType).name = "void" then
				    foundType := terrainQuery (cdx, cdy, 0)
				    if blockType (foundType).name = "void" then
					foundType := ord (blk.air)
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

	    Draw.FillBox (0, 0, maxx, maxy, blockType (ord (blk.void)).clr) %a cls
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
		exit
	    end if
	end loop
	Pic.Free (previewPic)

	offsetleftright := 0
	offsetupdown := 0

	%Reset menu option colour defaults
	if resetdefaulthead then
	    player1 -> SetHeadColour (-1)
	    resetdefaulthead := false
	end if
	if resetdefaulttime then
	    timeOfDay := -1
	    resetdefaulttime := false
	end if
	if resetdefaultblock then
	    player1 -> SetPlacingBlock (blockType (ord (blk.error)))
	    resetdefaultblock := false
	end if
    end if
end WorldPreview

%Beginning of main loop processes

%Get input for keyboard and parallelport
procedure KeyboardInput
    %Reset input variables
    keyp := false

    %Assign input variables for keyboard
    if arrow ('p') then
	keyp := true
    end if
    if arrow ('l') then
	for i : 0 .. 5
	    for i2 : 0 .. 5
		setBlock (player1 -> pos.x - 3 + i, player1 -> pos.y - 3 + i2, ord (blk.dirt), false)
	    end for
	end for
	showWorld ()
    end if
    if arrow ('k') then
	setBlock (player1 -> pos.x, player1 -> pos.y, ord (blk.air), false)
    end if
    if arrow ('o') then
	trainx := player1 -> pos.x
	trainy := player1 -> pos.y
    end if

end KeyboardInput

%Screen sliding
procedure ScreenSlide
    if (toScrnCdX (player1 -> leftSide ()) < pxscrollclearance or toScrnCdX (player1 -> rightSide ()) > maxx - pxscrollclearance
	    or toScrnCdY (player1 -> pos.y) < pxscrollclearance or toScrnCdY (player1 -> topSide ()) > maxy - pxscrollclearance) then
	if toScrnCdX (player1 -> leftSide ()) < pxscrollclearance then
	    screenscroll (- (toGameCdX (pxscrollclearance) - player1 -> leftSide ()), 0)
	elsif toScrnCdX (player1 -> rightSide ()) > maxx - pxscrollclearance then
	    screenscroll (player1 -> rightSide () - toGameCdX ((maxx - pxscrollclearance)), 0)
	end if
	if toScrnCdY (player1 -> pos.y) < pxscrollclearance then
	    screenscroll (0, - (toGameCdY (pxscrollclearance) - player1 -> pos.y))
	elsif toScrnCdY (player1 -> topSide ()) > maxy - pxscrollclearance then
	    screenscroll (0, player1 -> topSide () - toGameCdY (maxy - pxscrollclearance))
	end if
	if scrollSlow then
	    slowScrollSpeed *= 1.05
	end if
    else
	scrollSlow := false
	slowScrollSpeed := 0.02
    end if
end ScreenSlide

%If 'p' key is pressed
procedure PressPKey
    if keyp then
	for i : 0 .. 9 % I hate this, but otherwise, when you click where the "return to menu"
	    %or any other button will be, then pause, it will act as if you clicked the button.
	    var t : boolean := GUI.ProcessEvent %Gobbles up 10 last events to prevent processing
	end for
	inPauseMenu := true
	View.Set ("nooffscreenonly")
	oldTime := timeOfDay
	Pic.Free (screenpic)
	screenpic := Pic.New (0, 0, maxx, maxy)
	Draw.FillBox (0, 0, maxx, maxy, bgcolour)     %a cls
	showPauseGUIs
	Draw.FillBox (32, maxy - 67, 62, maxy - 37, player1 -> headcolour)
	Draw.Box (32, maxy - 67, 62, maxy - 37, black)
	Draw.Text (colourstringify (player1 -> headcolour) + " head", 1, maxy - 90, font2, black)
	Draw.FillBox (145, maxy - 67, 175, maxy - 37, bgcolour)
	Draw.Box (145, maxy - 67, 175, maxy - 37, black)
	Draw.Text (timestringify (timeOfDay), 100, maxy - 90, font2, black)
	Draw.FillBox (265, maxy - 67, 295, maxy - 37, player1 -> placingBlock.clr)
	Draw.Box (265, maxy - 67, 295, maxy - 37, black)
	Draw.Text (player1 -> placingBlock.name + " blocks", 238, maxy - 90, font2, black)
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
	    if oldTime not= timeOfDay then
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




procedure IfDeadGameOver
    if player1 -> health = 0 then
	Draw.Text ("Game Over", midx - 150, midy, font1, red)
    end if
end IfDeadGameOver



%End of main loop procedures

procedure resetVariables
    player1 -> ResetVariables

    /*%loadfile := ""
     if loaded then
     timeOfDay := -1
     end if
     loaded := false*/
    offsetupdown := 0
    offsetleftright := 0
    oldTime := -1
    gmfrstmthrgh := false
    recentclick := false
    quitthegame := false

    keyp := false
    preview := false
    resetdefaulthead := false
    resetdefaulttime := false
    resetdefaultblock := false
    menuReturn := false

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

%Entire program loop
loop
    %Main menu loop
    loop
	colorback (white)
	if gmfrstmthrgh then
	    %Find all saved files' names
	    var savenames : int
	    var fileName : string
	    savenames := Dir.Open (savDir + "Preferences\\")
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
		    if not continue then %as in, the C++ command, "continue", that skips the rest of the loop
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
		block (x) (y).block := ord (blk.void)
		block (x) (y).bg := ord (blk.void)
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

	ShowColourPreview
	locate (12, 1)
	if loadfile not= "" then
	    put "World: ", loadfile
	else
	    put "World: New"
	end if

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
	player1 -> SetSurvival (not GUI.GetCheckBox (cbcreative))


	%Set menu option default indicator
	if player1 -> headcolour = -1 then
	    resetdefaulthead := true
	end if
	if timeOfDay = -1 then
	    resetdefaulttime := true
	end if
	if player1 -> placingBlock.id = ord (blk.error) then
	    resetdefaultblock := true
	end if

	hideMainMenuGUIs

	cls

	%Allows for smooth animation
	View.Set ("offscreenonly")

	%Second loading screen
	loading (white)

	GetPreferences

	%Assign values to variables that are calculated using "blocksize"
	player1 -> FinalVariableAssingment

	%Update background colour
	Draw.FillBox (0, 0, maxx, maxy, blockType (ord (blk.air)).clr)    %a cls

	GenerateWorld

	WorldPreview

	if not preview then
	    exit
	end if
    end loop

    if quitthegame then
	exit
    end if

    %loaded := false

    %Show world
    View.Update

    %Setting oldPos
    player1 -> UpdateOldPos

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

	player1 -> KeyboardInput (arrow)

	player1 -> HandleMouse

	PressPKey
	if quitthegame then
	    exit
	elsif menuReturn then
	    menuReturn := false
	    exit
	end if

	%Passage of time
	var val : real := (12 - abs (timeOfDay - 12)) / 12.0
	bgcolour := timecolourify (timeOfDay)
	if abs (floor (val * 100) / 100 - floor (oldTimeColorVal * 100) / 100) > 0.001 then
	    oldTimeColorVal := val
	    Draw.FillBox (0, 0, maxx, maxy, blockType (ord (blk.air)).clr) %a cls
	    showWorld ()
	end if
	timeOfDay += timeSpeed * deltaTime
	if timeOfDay >= 24 then
	    timeOfDay := 0
	end if

	KeyboardInput

	player1 -> HandleKeyboard (deltaTime)

	for i : 0 .. numEntities - 1
	    entities (i) -> Update (deltaTime) %Separate because this must happen first for all entities
	end for

	for i : 0 .. numEntities - 1
	    player1 -> PreDraw %Separate because this must happen second for all entities
	end for

	for i : 0 .. numEntities - 1
	    player1 -> DrawEntity %Separate because this must happen next for all entities with UI elements
	end for

	for i : 0 .. numEntities - 1
	    player1 -> DrawGUI %Separate because this must happen last for all entities with UI elements
	end for

	%locate (1, 1)
	%put deltaTime

	%Show new screen
	View.Update

	for i : 0 .. numEntities - 1
	    player1 -> UnDraw
	end for

	IfDeadGameOver

	%Make physics blocks fall (temp until entities added(?))
	for xb : toGameCdXR (0) .. toGameCdXR (maxx)
	    for yb : toGameCdYR (0) .. toGameCdYR (maxy)
		if blockType (block (xb) (yb).block).physics then
		    %if block (xb) (yb).block = ord (blk.water) then
		    if isBlock (xb, yb - 1, ord (blk.air), ord (layerId.foreground), true) then
			block (xb) (yb - 1).block := block (xb) (yb).block
			block (xb) (yb).block := ord (blk.air)
			showBlock (xb, yb)
		    end if
		end if
	    end for
	end for

	ScreenSlide
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
