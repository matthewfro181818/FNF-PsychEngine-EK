local sh_r = 600
local bfControlY = 0
local endCheck = false
local trigger = 1
local shag_fly = true
local songStarted = false
----------------------------
local collected = false
local state0 = true
local vsp = -10
----------------------------
local dvsp = {-20, -20, -20}
local dhsp = {0, 0, 0}
local CdebId = 1
local Csx = {0,0,0}
local Csy = {0,0,0}
local Csc = {0,0,0}
local CtF = {0,0,0}
local CtD = {0,0,0}
local CpF = {0,0,0}
------Thanks to Bf Myt for this----------
local currentGhost = 0
local lastGhost = 0
local fps = 0

function debrisFly(sX, sY, debName, scroll, tFactor, tDelay, posFactor)
	Csx[CdebId] = sX
	Csy[CdebId] = sY
	Csc[CdebId] = scroll
	CtF[CdebId] = tFactor
	CtD[CdebId] = tDelay
	CpF[CdebId] = posFactor
	makeAnimatedLuaSprite('Cdebris'..CdebId, 'stages/god', Csx[CdebId], Csy[CdebId])
	addAnimationByPrefix('Cdebris'..CdebId, 'idk', 'deb_'..debName, 24, true)	
	setScrollFactor('Cdebris'..CdebId, Csc[CdebId], Csc[CdebId])
	scaleObject('Cdebris'..CdebId, Csc[CdebId] / 0.75, Csc[CdebId] / 0.75)
	addLuaSprite('Cdebris'..CdebId, false)
	CdebId = CdebId + 1
end

function onCreate()
	makeAnimatedLuaSprite('legs', 'characters/pshaggy', 0, 0)
	addAnimationByPrefix('legs', 'Instance', 'solo_legs', 24, false)
	addOffset('legs', 'Instance', 0, 0)
	setObjectOrder('legs', getObjectOrder('dadGroup'))
	addLuaSprite('legs', false)

	makeAnimatedLuaSprite('scooby', 'super-saiyan/scooby', -300, 290)
	addAnimationByPrefix('scooby', 'idle', 'scoob_idle', 24, true)
	setProperty('scooby.alpha', 0)
	setProperty('scooby.flipX', true)
	addLuaSprite('scooby', true)

	makeLuaSprite('door', 'doorframe', (getProperty('dad.x')), (getProperty('dad.y') + 400))
	scaleObject('door', 0, 0)
	setObjectOrder('door', getObjectOrder('dadGroup'))
	addLuaSprite('door', false)


	makeLuaSprite('frame', 'zephy/part/frame', 230, 600)
	addLuaSprite('frame', true)

	makeLuaSprite('mouse', 'zephy/part/picker', 0, 0)
	scaleObject('mouse', 1/0.65, 1/0.65)
	setProperty('mouse.alpha', 0)
	addLuaSprite('mouse', true)

	makeLuaSprite('fx', 'zephy/fx', 0, 0)
	setProperty('fx.alpha', 0)
	addLuaSprite('fx', true)

	makeLuaSprite('orb', 'zephy/partSmall', 0, 0)
	setProperty('orb.alpha', 0)
	addLuaSprite('orb', true)
end

local allowCountdown = true
function onCreatePost()
	if isStoryMode and not seenCutscene then
		state0 = false
		shag_fly = false
		allowCountdown = false
	else
		scaleObject('gf', 0.8, 0.8)
		setScrollFactor('gf', 0.8, 0.8)
	end
	if not isStoryMode or botplay or tonumber(getTextFromFile('Shaggy/savefiles/frame.txt', false)) > 0 then
		setProperty('mouse.visible', false)
		setProperty('frame.visible', false)
	end
end


function onStartCountdown()
	return onShaggyStart()
end

local cut = 0
function onShaggyStart()
	cut = cut + 1
	if not isStoryMode or cut == 1 and seenCutscene then
		--nothing
	elseif cut == 1 then
		setProperty('legs.alpha', 0)
		setProperty('bf_rock.alpha', 0)
		setProperty('gf_rock.alpha', 0)
		setProperty('frame.alpha', 0)
		playAnim('dad', 'back')
		setProperty('dad.x', 100)
		setProperty('dad.y', 100)
		setProperty('gf.x', 400)
		setProperty('gf.y', 130)
		setProperty('boyfriend.x', 770)
		setProperty('boyfriend.y', 450)
		setProperty('camFollow.x', getProperty('dad.x')+200)
		setProperty('camFollow.y', getProperty('dad.y')+300)
		runTimer('snap', 2)
		return Function_Stop;
	elseif cut == 2 then
		songStarted = true
	end
end

function onBeatHit()
	if curBeat < 32 then
		sh_r = 60
	elseif (curBeat >= 50*4 and curBeat <= 58*4) or curBeat >= 140 * 4 then
		sh_r = 60
	else
		sh_r = 600
	end
end


function onUpdate(elapsed)
	if isStoryMode and not seenCutscene then
		if getProperty('dad.animation.curAnim.name') == "snap" and getProperty('dad.animation.curAnim.finished') == true then
			playAnim('dad', 'snapped')
			cameraShake('game', 0.05, 0.2)
			playSound('god-eater/snap', 1)
			playSound('god-eater/undSnap', 1)
			runTimer('mansion_shake', 2)
		end
		for i = 1, 3 do
			dhsp[i] = CpF[i]
			dvsp[i] = dvsp[i] + 0.15

			setProperty('Cdebris'..i..'.x', getProperty('Cdebris'..i..'.x') + dhsp[i])
			setProperty('Cdebris'..i..'.y', getProperty('Cdebris'..i..'.y') + dvsp[i])
			setProperty('Cdebris'..i..'.angle', getProperty('Cdebris'..i..'.angle') - (dhsp[i] / 2))
		end
	end
	if not endCheck and allowCountdown then
		fps = fps + elapsed
		if fps >= 1/10 then
			if getProperty('legs.alpha') > 0 then
				createGhost('legs','FFFFF', getProperty('legs.animation.curAnim.name'), getProperty('dad.imageFile'))
			end
			createGhost('dad', 'FFFFF', getProperty('dad.animation.curAnim.name'), getProperty('dad.imageFile'))
			fps = 0
		end
		if getPropertyFromClass('flixel.FlxG', 'keys.pressed.DOWN') and bfControlY < 2290 then
			bfControlY = bfControlY + 1

		elseif getPropertyFromClass('flixel.FlxG', 'keys.pressed.UP') and bfControlY > 0 then
			bfControlY = bfControlY - 1

		end
		rotRateGf = curStep / 9.5 / 4
		gf_tox = 100 + math.sin(rotRateGf) * 200
		gf_toy = -2000 - math.sin(rotRateGf) * 80
		setProperty('gf.x', (getProperty('gf.x') + (gf_tox - getProperty('gf.x')) / 20))
		setProperty('gf.y', (getProperty('gf.y') + (gf_toy - getProperty('gf.y')) / 20))

		rotRate = curStep * 0.25
		bf_toy = -2000 + math.sin(rotRate) * 20 + bfControlY
		setProperty('boyfriend.y', (getProperty('boyfriend.y') + (bf_toy - getProperty('boyfriend.y')) / 20))

		rotRateShag = curStep / 9.25
		sh_toy = -2450 + -math.sin(rotRateShag * 2) * sh_r * 0.45
		sh_tox = -330 - math.cos(rotRateShag) * sh_r
		if shag_fly and curStep > 0 then
			setProperty('dad.x', getProperty('dad.x') + ((sh_tox - getProperty('dad.x')) / 12))
			setProperty('dad.y', getProperty('dad.y') + ((sh_toy - getProperty('dad.y')) / 12))
		elseif shag_fly and curStep <= 0 then
			setProperty('dad.x', getProperty('dad.x') + (((sh_tox+800) - getProperty('dad.x')) / 12))
			setProperty('dad.y', getProperty('dad.y') + ((sh_toy - getProperty('dad.y')) / 12))
		end

		if getProperty('dad.animation.curAnim.name') == "idle" then
			setProperty('dad.angle', math.sin(rotRateShag) * sh_r * 0.07 / 4)
			setProperty('legs.alpha', 1)
			setProperty('legs.angle', math.sin(rotRateShag) * sh_r * 0.07)
			setProperty('legs.x', (getProperty('dad.x') + -25 + math.cos((getProperty('legs.angle') + 90) * (math.pi/180)) * 150))
			setProperty('legs.y', (getProperty('dad.y') + 290 + math.sin((getProperty('legs.angle') + 90) * (math.pi/180)) * 150))
			setProperty('legs.x', getProperty('legs.x') - getProperty('legs.angle')*3.6)
			if getProperty('legs.angle') > 0 then
				setProperty('legs.y', getProperty('legs.y') + -getProperty('legs.angle')-getProperty('dad.angle')*2)
			elseif getProperty('legs.angle') < 0 then
				setProperty('legs.y', getProperty('legs.y') + getProperty('legs.angle')-getProperty('dad.angle')*2)
			end
		else
			setProperty('legs.alpha', 0)
			setProperty('dad.angle', 0)
		end
		
		if state0 then
			setProperty('frame.alpha', 1)
			setProperty('frame.y', getProperty('frame.y') + vsp)
			setProperty('frame.angle', getProperty('frame.angle') + 10)
			vsp = vsp + 0.3
			if vsp > 10 then
				setProperty('frame.angle', 0)
				setProperty('frame.x', 330)
				setProperty('frame.y', 660)
				state0 = false
			end
		end
	end
	if (not mustHitSection and not endCheck) and ((shag_fly and songStarted) or not isStoryMode) or (seenCutscene) or endCheck then
		cameraSetTarget('dad')
		setProperty('mouse.alpha', 0)
	elseif (not shag_fly and allowCountdown) or mustHitSection then
		cameraSetTarget('boyfriend')
		if bfControlY > 2000 and not collected then
			setProperty('mouse.alpha', 1)
		else
			setProperty('mouse.alpha', 0)
		end
	end
	if getProperty('dad.animation.curAnim.name') == "smile" and getProperty('dad.animation.curAnim.finished') == true and trigger == 1 then
		if bfControlY >= 400 then
			triggerEvent('startDialogue', 'dial1B', '');
		else
			doTweenX('camGY', 'camFollowPos', getMidpointX('dad'), 1, 'elasticInOut')
			doTweenY('camGF', 'camFollowPos', getMidpointY('dad'), 1, 'elasticInOut')
			triggerEvent('startDialogue', 'dial1A', '');
		end
		trigger = 2
	end


	setProperty('mouse.x',getMouseX('camGame')+ getProperty('camGame.scroll.x'));
	setProperty('mouse.y',getMouseY('camGame')+ getProperty('camGame.scroll.y'));

	if getProperty('frame.visible') == true and not collected and mouseClicked('left') and (getProperty('mouse.y') < getProperty('frame.y') + 200) and (getProperty('mouse.y') > getProperty('frame.y')) and (getProperty('mouse.x') < getProperty('frame.x') + 200) and (getProperty('mouse.x') > getProperty('frame.x')) then
		collected = true
		setProperty('orb.x', getMidpointX('frame')-50)
		setProperty('orb.y', getMidpointY('frame')-50)

		setProperty('fx.x', getProperty('orb.x')-50)
		setProperty('fx.y', getProperty('orb.y')-50)
		cancelTween('frame_fall')
		cancelTween('frame_speen')
		playSound('zephyrus/maskColl')
		setProperty('fx.alpha', 1)
		setProperty('orb.alpha', 1)
		setProperty('frame.alpha', 0)
		doTweenX('fx_growX', 'fx.scale', 1.3, 1, 'linear')
		doTweenY('fx_growY', 'fx.scale', 1.3, 1, 'linear')
		doTweenAlpha('bye_fx', 'fx', 0, 1, 'linear')
		doTweenX('orb_flyX', 'orb', getMidpointX('boyfriend'), 2, 'cubeIn')
		doTweenY('orb_flyY', 'orb', getMidpointY('boyfriend'), 2, 'sineInOut')
		saveFile('Shaggy/savefiles/frame.txt', "1", false)
	end
end


local steps = 0
function onEndSong()
	setProperty('inCutscene', true)
	return onGodEnd()
end

function onGodEnd()
	steps = steps + 1
	if not isStoryMode then
		--nothing
	elseif steps == 1 then
		doTweenAlpha('byeHUD', 'camHUD', 0, 1, 'linear')
		runTimer('dial1', 0.5)

		return Function_Stop;
	elseif steps == 2 then
		runTimer('normal', 1)
		return Function_Stop;
	elseif steps == 3 then
		runTimer('door', 0.8)
		return Function_Stop;
	elseif steps == 4 then
		doTweenAlpha('byebye', 'dad', 0, 2, 'linear')
		doTweenAlpha('byebye2', 'scooby', 0, 2, 'linear')
		return Function_Stop;
	end
end

function onTimerCompleted(tag)
	if tag == "snap" then
		playAnim('dad', 'snap')
	end
	if tag == "mansion_shake" then
		cameraShake('game', 0.07, 2)
		runTimer('bf_fly', 2)
	end
	if tag == "bf_fly" then
		allowCountdown = true
		state0 = true
		setProperty('camFollow.x', getProperty('boyfriend.x'))
		setProperty('camFollow.y', getProperty('boyfriend.y'))
		playSound('god-eater/rockFly', 1)
		debrisFly(-300, -120, 'ceil', 1, 1, -4, -40)
		debrisFly(0, -120, 'ceil', 1, 1, -4, -5)
		debrisFly(200, -120, 'ceil', 1, 1, -4, 40)
		setProperty('bf_rock.alpha', 1)
		setProperty('gf_rock.alpha', 1)
		doTweenX('gf_shrink', 'gf.scale', 0.8, 1, 'linear')
		doTweenY('gf_shrink2', 'gf.scale', 0.8, 1, 'linear')
		setScrollFactor('gf', 0.8, 0.8)
		runTimer('shaggy_up', 3)
	end
	if tag == "shaggy_up" then
		playAnim('dad', 'idle')
		playSound('god-eater/shagFly', 1, 'startC')
		shag_fly = true
	end
	if tag == "dial1" then
		playAnim('dad', 'smile')
	end
	if tag == "normal" then
		endCheck = true
		setProperty('defaultCamZoom',0.8)
		setProperty('frame.alpha', 0)
		setProperty('gf_rock.alpha', 0)
		setProperty('bf_rock.alpha', 0)
		scaleObject('gf', 1, 1)
		setScrollFactor('gf', 0.95, 0.95)
		playAnim('dad', 'stand')
		setProperty('dad.x', 100)
		setProperty('dad.y', 100)
		setProperty('scooby.alpha', 1)
		setProperty('gf.x', 400)
		setProperty('gf.y', 130)
		setProperty('boyfriend.x', 770)
		setProperty('boyfriend.y', 450)
		setProperty('camFollowPos.x', getProperty('dad.x') + 300)
		setProperty('camFollowPos.y', getProperty('dad.y') + 300)
		setProperty('camFollow.x', getProperty('dad.x') + 300)
		setProperty('camFollow.y', getProperty('dad.y') + 300)
		playSound('burst', 1, 'music1')
	end
	if tag == "dial2" then
		triggerEvent('startDialogue', 'dial2', '');
		playSound('god-eater/happy', 1, 'loop1')
	end
	if tag == "door" then
		playSound('exit', 1)
		doTweenX('doorAppX', 'door.scale', 1, 0.7, 'linear')
		doTweenY('doorAppY', 'door.scale', 1, 0.7, 'linear')
	end
	if tag == "dial3" then
		triggerEvent('startDialogue', 'dial3', '');
	end
end

function onTweenCompleted(tag)
	if tag == "doorAppY" then
		runTimer('dial3', 0.6)
	end
	if tag == "byebye2" then
		playSound('exit', 1)
		doTweenX('sus1', 'door.scale', 0, 0.7, 'linear')
		doTweenY('sus2', 'door.scale', 0, 0.7, 'linear')
	end
	if tag == "orb_flyY" then
		doTweenX('orb_shrinkX', 'orb.scale', 0, 3, 'linear')
		doTweenY('orb_shrinkY', 'orb.scale', 0, 3, 'linear')
	end
	if tag == "sus2" then
		endSong()
	end
	if string.find(tag,'dad') ~= nil and string.find(tag,'Bye') then
        for ghosts = currentGhost,lastGhost do
            local spriteName = 'dadGhost'..ghosts
            if tag == spriteName..'Bye' then
                removeLuaSprite(spriteName,true)
                currentGhost = currentGhost + 1
            end
        end
    end
end

function onSoundFinished(tag)
	if tag == "startC" then
		startCountdown()
	end
	if tag == "music1" then
		runTimer('dial2', 1)
	end
	if tag == "loop1" then
		playSound('god-eater/happy', 1, 'loop1')
	end
	if tag == "orb_flyY" then
		doTweenX('orb_shrinkX', 'orb.scale', 0, 3, 'linear')
		doTweenY('orb_shrinkY', 'orb.scale', 0, 3, 'linear')
	end
end

function createGhost(character, color, anim, location)
    local spriteName = character..'Ghost'..lastGhost
    makeAnimatedLuaSprite(spriteName, location, getProperty(character..'.x'), getProperty(character..'.y'))
    scaleObject(spriteName, getProperty(character..'.scale.x'), getProperty(character..'.scale.y'))
    setProperty(spriteName..'.color',getColorFromHex(color))
    setProperty(spriteName..'.alpha', getProperty(character..'.alpha') - 0.4)
    doTweenAlpha(spriteName..'Bye',spriteName, 0, 0.5, 'linear')
    setObjectOrder(spriteName,getObjectOrder('dadGroup')-2)
    addGhostAnim(character,anim)
    addLuaSprite(spriteName,false)
    setProperty(spriteName..'.flipX', getProperty(character..'.flipX'))
    setProperty(spriteName..'.angle', getProperty(character..'.angle'))
    objectPlayAnimation(character..'Ghost'..lastGhost,anim,true)
    lastGhost = lastGhost + 1
end

function addGhostAnim(character, name)
	local spriteAnim = character..'Ghost'..lastGhost
	addAnimationByPrefix(spriteAnim, name, getProperty(character..'.animation.frameName'), getProperty(character..'.animation.curAnim.frameRate'), getProperty(character..'.animation.curAnim.looped'))
	setProperty(spriteAnim..'.offset.x', getProperty(character..'.offset.x'))
	setProperty(spriteAnim..'.offset.y', getProperty(character..'.offset.y'))
end
