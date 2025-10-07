local debId = 1
local time = 0
local grav = 0.15
local vsp = -20
local hsp = 0
--Yes there's no other way stfu
local sx = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local sy = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local sc = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local tF = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local tD = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local pF = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}



function addDebris(sX, sY, debName, scroll, tFactor, tDelay, posFactor)
	sx[debId] = sX
	sy[debId] = sY
	sc[debId] = scroll
	tF[debId] = tFactor
	tD[debId] = tDelay
	pF[debId] = posFactor
	makeAnimatedLuaSprite('debris'..debId, 'stages/god', sx[debId], sy[debId])
	addAnimationByPrefix('debris'..debId, 'idk', 'deb_'..debName, 24, true)	
	setScrollFactor('debris'..debId, sc[debId], sc[debId])
	scaleObject('debris'..debId, sc[debId] / 0.75, sc[debId] / 0.75)
	addLuaSprite('debris'..debId, false)
	debId = debId + 1
end
	

function onCreate()
	makeAnimatedLuaSprite('sky', 'stages/god', -540, -650)
	scaleObject('sky', 0.8, 0.8)
	setScrollFactor('sky', 0.1, 0.1)
	addAnimationByPrefix('sky', 'sky_instance', 'sky', 24, true)
	addLuaSprite('sky', false)

	makeAnimatedLuaSprite('cloud1', 'stages/god', -800, -1220)
	setScrollFactor('cloud1', 0.3, 0.3)
	addAnimationByPrefix('cloud1', 'cloud_instance', 'cloud_smol', 24, true)
	addLuaSprite('cloud1', false)
	
	addDebris(300, -800, 'norm', 0.4, 1, 0, 1)
	addDebris(600, -300, 'tiny', 0.4, 1.5, 0, 1)
	addDebris(-150, -400, 'spike', 0.4, 1.1, 0, 1)
	addDebris(-750, -850, 'small', 0.4, 1.5, 0, 1)
	addDebris(-300, -1700, 'norm', 0.75, 1, 0, 1)
	addDebris(-1000, -1750, 'rect', 0.75, 2, 0, 1)
	addDebris(-600, -1100, 'tiny', 0.75, 1.5, 0, 1)
	addDebris(900, -1850, 'spike', 0.75, 1.2, 0, 1)
	addDebris(1500, -1300, 'small', 0.75, 1.5, 0, 1)
	addDebris(-600, -800, 'spike', 0.75, 1.3, 0, 1)
	addDebris(-1000, -900, 'small', 0.75, 1.7, 0, 1)

	makeAnimatedLuaSprite('cloud2', 'stages/god', -1500, -2900)
	setScrollFactor('cloud2', 0.9, 0.9)
	addAnimationByPrefix('cloud2', 'cloud2_instance', 'cloud_big', 24, true)
	addLuaSprite('cloud2', false)

	makeLuaSprite('mansion', 'stages/mansion', -950, -460)
	setScrollFactor('mansion', 0.95, 0.95)
	scaleObject('mansion', 1.5, 1.5)
	addLuaSprite('mansion', false)
	
	makeAnimatedLuaSprite('roof', 'stages/god', -950, -620)
	scaleObject('roof', 1.5, 1.5)
	addAnimationByPrefix('roof', 'roof_instance', 'broken_techo', 24, true)
	addLuaSprite('roof', false)

	makeAnimatedLuaSprite('gf_rock', 'stages/god', 0, 0)
	addAnimationByPrefix('gf_rock', 'gf_rock_instance', 'gf_rock', 24, true)
	setScrollFactor('gf_rock', 0.8, 0.8)
	addLuaSprite('gf_rock', false)
	
	makeAnimatedLuaSprite('bf_rock', 'stages/god', 0, 0)
	addAnimationByPrefix('bf_rock', 'rock_instance', 'rock', 24, true)
	addLuaSprite('bf_rock', false)
	
end

--function onCreatePost()
	--scaleObject('gf', 0.8, 0.8)
	--setScrollFactor('gf', 0.8, 0.8)
--end

function onUpdate()
	time = time + 1
	for i = 1, 16 do
		setProperty('debris'..i..'.y', sy[i] + math.sin((time + tD[i]) / 50 * tF[i]) * 50 * pF[i])
	end

	setProperty('bf_rock.x', getProperty('boyfriend.x')-200)
	setProperty('bf_rock.y', getProperty('boyfriend.y') + getProperty('boyfriend.height') - 200)

	setProperty('gf_rock.x', getProperty('gf.x') + 80)
	setProperty('gf_rock.y', getProperty('gf.y') + 530)
end