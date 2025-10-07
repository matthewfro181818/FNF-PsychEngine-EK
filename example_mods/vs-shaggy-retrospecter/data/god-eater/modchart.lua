-- Psych Engine 1.0.4 port of your modchart
-- Save as: data/<song-name>/<song-name>-modchart.lua (or mods/scripts/ if you prefer)

--------------------------
-- CONFIG / STATE
--------------------------
local cameraTHROBBING = true
local defaultZoom = 0.8
local camZoomProxy = { zoom = 0.8 }

local desiredSpeed = 60
local speedRampSteps = 32
local sh_r = desiredSpeed

local setWinXY = false
local winX, winY = 0, 0
local shakePower = 0

-- strum bases for per-frame offsets
local oppLen, plrLen = 4, 4
local baseOpp = {}
local basePlr = {}

-- modchart phases (step gated)
local modchartPhase = 0
local modchartPhases = {
    {step=256,  phase=1},
    {step=384,  phase=0},
    {step=416,  phase=1},
    {step=1184, phase=0},
    {step=1472, phase=1.5},
    {step=2240, phase=1},
    {step=2496, phase=2},
    {step=2784, phase=2.5},
    {step=3640, phase=2},
    {step=3840, phase=3},
    {step=4608, phase=2.5},
    {step=4736, phase=4},
    {step=4880, phase=4.5},
}

--------------------------
-- HELPERS
--------------------------
local function numLerp(a,b,c) return a + (b-a) * c end

local function cacheStrumBases()
    oppLen = getProperty('opponentStrums.length') or 4
    plrLen = getProperty('playerStrums.length') or 4

    baseOpp = {}
    basePlr = {}
    for i=0, oppLen-1 do
        baseOpp[i] = {
            x = getPropertyFromGroup('opponentStrums', i, 'x'),
            y = getPropertyFromGroup('opponentStrums', i, 'y')
        }
    end
    for i=0, plrLen-1 do
        basePlr[i] = {
            x = getPropertyFromGroup('playerStrums', i, 'x'),
            y = getPropertyFromGroup('playerStrums', i, 'y')
        }
    end
end

local function setStrumXY(groupName, idx, x, y)
    setPropertyFromGroup(groupName, idx, 'x', x)
    setPropertyFromGroup(groupName, idx, 'y', y)
end

local function tweenHUDandGameZoom(target, time, ease)
    doTweenZoom('camGameZoom', 'camGame', target, time, ease or 'inOutQuad')
    doTweenZoom('camHUDZoom',  'camHUD',  1.0 + (target - defaultZoom), time, ease or 'inOutQuad')
end

local function fadeOpponentStrums(toAlpha, time, ease)
    ease = ease or 'quadInOut'
    local off = 0 -- opponent strums are first in strumLineNotes
    for i=0, oppLen-1 do
        noteTweenAlpha('oppFade'..i, off + i, toAlpha, time, ease)
    end
end

local function fadePlayerStrums(toAlpha, time, ease)
    ease = ease or 'quadInOut'
    local off = oppLen -- player strums follow opponents
    for i=0, plrLen-1 do
        noteTweenAlpha('plrFade'..i, off + i, toAlpha, time, ease)
    end
end

local function changeDad(char)
    -- Safe character change in Psych
    triggerEvent('Change Character','dad', char)
end

--------------------------
-- LIFECYCLE
--------------------------
function onCreate()
    defaultZoom = getProperty('defaultCamZoom') or 0.8
    camZoomProxy.zoom = defaultZoom

    -- Preload all Shaggy variants you swap to
    addCharacterToList('ui_shaggy',      1)
    addCharacterToList('shaggypowerup',  1)
    addCharacterToList('shaggy',         1)

    -- Black fade overlay
    makeLuaSprite('blackfade', 'BlackFade', -800, -2000)
    setObjectCamera('blackfade', 'other')
    setProperty('blackfade.alpha', 0)
    scaleObject('blackfade', 8, 8)
    addLuaSprite('blackfade', true)
end

function onCreatePost()
    cacheStrumBases()
end

--------------------------
-- BEAT / STEP
--------------------------
function onBeatHit()
    if cameraTHROBBING then
        setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.025)
        setProperty('camHUD.zoom',  getProperty('camHUD.zoom')  + 0.025)
    end
end

function onStepHit()
    -- Determine current phase up to this step
    local prev = 0
    for i=1, #modchartPhases do
        local entry = modchartPhases[i]
        if curStep >= entry.step then prev = entry.phase else break end
    end
    modchartPhase = prev

    if curStep >= 3840 and not setWinXY then
        -- Snapshot window position from Haxe
        runHaxeCode([[
            if (Application.current != null && Application.current.window != null) {
                var w = Application.current.window;
                game.modchartVars.set('winX', w.x);
                game.modchartVars.set('winY', w.y);
            }
        ]])
        winX = getProperty('modchartVars.winX') or 0
        winY = getProperty('modchartVars.winY') or 0
        setWinXY = true
    end

    if curStep == 1184 then
        cameraTHROBBING = false
    elseif curStep == 1472 or curStep == 2496 then
        cameraTHROBBING = true
    end

    if curStep == 2240 then
        -- Dramatic cut
        doTweenAlpha('fadeInBlack','blackfade',1,2,'quadInOut')
        doTweenAlpha('bfOut','boyfriend',0,2,'quadInOut')
        doTweenAlpha('gfOut','gf',0,2,'quadInOut')
        changeDad('shaggypowerup')

        fadeOpponentStrums(0, 2, 'inOutQuad')
        tweenHUDandGameZoom(1.1, 2, 'inOutQuad')

        characterPlayAnim('dad','YOUREFUCKED',true)
        setProperty('dad.specialAnim', true)
        setProperty('dad.skipDance', true)
        cameraTHROBBING = false

    elseif curStep == 2330 then
        -- Back in
        setProperty('dad.skipDance', false)
        doTweenAlpha('fadeOutBlack','blackfade',0,0.5,'quadInOut')
        doTweenAlpha('bfIn','boyfriend',1,0.5,'quadInOut')
        doTweenAlpha('gfIn','gf',1,0.5,'quadInOut')

        tweenHUDandGameZoom(defaultZoom, 1, 'inOutQuad')
        fadeOpponentStrums(1, 0.5, 'inOutQuad')
        changeDad('ui_shaggy')

    elseif curStep == 3552 then
        cameraTHROBBING = false
        doTweenAlpha('fadeInBlack2','blackfade',1,0.5,'quadInOut')
        doTweenAlpha('bfOut2','boyfriend',0,0.5,'quadInOut')
        doTweenAlpha('gfOut2','gf',0,0.5,'quadInOut')
        tweenHUDandGameZoom(1.1, 2, 'inOutQuad')

        fadePlayerStrums(0, 0.5, 'inOutQuad')
        fadeOpponentStrums(0, 0.5, 'inOutQuad')

    elseif curStep == 3632 then
        doTweenAlpha('fadeOutBlack2','blackfade',0,0.5,'quadInOut')
        doTweenAlpha('bfIn2','boyfriend',1,0.5,'quadInOut')
        doTweenAlpha('gfIn2','gf',1,0.5,'quadInOut')
        tweenHUDandGameZoom(defaultZoom, 1, 'inOutQuad')

        fadePlayerStrums(1, 0.5, 'inOutQuad')
        fadeOpponentStrums(1, 0.5, 'inOutQuad')
        cameraTHROBBING = true
    end

    -- Desired scroll-rate ramps (preserved from your logic)
    if      curStep>=128  and curStep<256  then desiredSpeed=120
    elseif  curStep>=256  and curStep<1344 then desiredSpeed=600
    elseif  curStep>=1344 and curStep<1440 then desiredSpeed=600
    elseif  curStep>=1440 and curStep<1472 then desiredSpeed=60
    elseif  curStep>=1472 and curStep<2224 then desiredSpeed=600
    elseif  curStep>=2224 and curStep<2496 then desiredSpeed=60
    elseif  curStep>=2496 and curStep<3840 then desiredSpeed=800
    elseif  curStep>=3840 and curStep<4608 then desiredSpeed=1900
    elseif  curStep>=4608                  then desiredSpeed=60
    end

    if curStep == 240 then
        tweenHUDandGameZoom(1.1, 0.2, 'inOutQuad')
    elseif curStep>=256 and curStep<1000 then
        tweenHUDandGameZoom(defaultZoom, 0.5, 'inOutQuad')
    end
end

--------------------------
-- NOTE HITS / SHAKE
--------------------------
function opponentNoteHit(id, direction, noteType, isSustainNote)
    if curStep > 2464 then
        if shakePower > 0 then shakePower = shakePower + 1 else shakePower = 3 end
        characterPlayAnim('boyfriend','scared',true)
    end
    if (curStep>=2368 and curStep<=2464) or (curStep>=4736 and curStep<=4864) then
        setProperty('camGame.zoom', getProperty('camGame.zoom') + 0.05)
        setProperty('camHUD.zoom',  getProperty('camHUD.zoom')  + 0.05)
        shakePower = shakePower + 2
    end
    -- Allow dad to resume dance after hits
    setProperty('dad.specialAnim', false)
end

--------------------------
-- UPDATE LOOP
--------------------------
local function applyArrowMovement(groupName, baseTable, count, isPlayerSide)
    local currentBeat = (getSongPosition()/1000) * (getProperty('curBpm')/60)
    for i=0, count-1 do
        local bx, by = baseTable[i].x, baseTable[i].y
        local xOff, yOff = 0, 0
        local idx = i+1 -- 1-based for math patterns below

        if modchartPhase == 1 then
            xOff = 15 * math.sin(currentBeat)
            yOff = 20 * math.cos(currentBeat/2) + 10
        elseif modchartPhase == 1.5 then
            xOff = 20 * math.sin((currentBeat*3)+idx)
            yOff = 30 * math.cos(currentBeat)
        elseif modchartPhase == 2 then
            local k = idx + (isPlayerSide and oppLen or 0)
            xOff = 30*math.sin(currentBeat*2) + math.cos(currentBeat*k)*4
            yOff = 30*math.cos(currentBeat + k/4) + math.sin(currentBeat*k)*4
        elseif modchartPhase == 2.5 then
            local k = idx + (isPlayerSide and oppLen or 0)
            xOff = 30*math.sin((currentBeat*2) + k/2)
            yOff = 60*math.cos(currentBeat + k)
        elseif modchartPhase == 3 then
            xOff = 32*math.sin(currentBeat + idx)
            yOff = 25*math.cos((currentBeat + idx)*math.pi) + 10
        elseif modchartPhase == 4 then
            xOff = 0
            if (idx % 2 == 1) then yOff = -40 else yOff = 40 end
        elseif modchartPhase == 4.5 then
            -- ease back to base
            local cx = getPropertyFromGroup(groupName, i, 'x')
            local cy = getPropertyFromGroup(groupName, i, 'y')
            setStrumXY(groupName, i, numLerp(cx, bx, 0.03), numLerp(cy, by, 0.03))
            goto continue
        else
            xOff, yOff = 0, 0
        end

        -- Smooth towards target
        local cx = getPropertyFromGroup(groupName, i, 'x')
        local cy = getPropertyFromGroup(groupName, i, 'y')
        local tx, ty = bx + xOff, by + yOff
        setStrumXY(groupName, i, numLerp(cx, tx, 0.1), numLerp(cy, ty, 0.1))
        ::continue::
    end
end

function onUpdate(elapsed)
    -- decay window/camera shake
    if shakePower > 0 then shakePower = shakePower - 0.15 end
    if shakePower < 0 then shakePower = 0 end

    if curStep > 0 then
        setProperty('camHUD.angle',  math.random(-shakePower*100, shakePower*100)/100)
        setProperty('camGame.angle', math.random(-shakePower*100, shakePower*100)/100)
    end

    if curStep > 3840 and setWinXY then
        local mult = (curStep >= 4736) and 0.5 or 3
        local dx = math.random(-shakePower*100, shakePower*100)/100 * mult
        local dy = math.random(-shakePower*100, shakePower*100)/100 * mult
        runHaxeCode([[
            if (Application.current != null && Application.current.window != null) {
                var w = Application.current.window;
                w.x = ]]..math.floor(winX)..[[ + ]]..math.floor(dx)..[[;
                w.y = ]]..math.floor(winY)..[[ + ]]..math.floor(dy)..[[;
            }
        ]])
    end

    -- smooth scroll-rate signal (kept local; if you drive something with it, read sh_r)
    sh_r = sh_r + (desiredSpeed - sh_r)/speedRampSteps

    -- live strum movement
    applyArrowMovement('playerStrums',   basePlr, plrLen, true)
    applyArrowMovement('opponentStrums', baseOpp, oppLen, false)
end
