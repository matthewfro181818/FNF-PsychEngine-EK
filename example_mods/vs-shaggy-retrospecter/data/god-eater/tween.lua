-- tween.lua (Psych Engine 1.0.4 compatible)
-- Simplified from tween 2.1.1 by kikito, adjusted for runtime usage in Psych Lua

local tween = {}

----------------------------------------------------------
-- basic easing
----------------------------------------------------------
local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

local function linear(t,b,c,d) return c*t/d + b end
local function inQuad(t,b,c,d) return c*pow(t/d,2)+b end
local function outQuad(t,b,c,d) t=t/d; return -c*t*(t-2)+b end
local function inOutQuad(t,b,c,d)
    t=t/d*2
    if t<1 then return c/2*t*t+b end
    return -c/2*((t-1)*(t-3)-1)+b
end

tween.easing = {
    linear=linear,
    inQuad=inQuad, outQuad=outQuad, inOutQuad=inOutQuad
}

----------------------------------------------------------
-- helpers
----------------------------------------------------------
local function copyTables(dest,src)
    for k,v in pairs(src) do
        if type(v)=='table' then
            dest[k]=copyTables({},v)
        else dest[k]=v end
    end
    return dest
end

local function performEasing(subject,target,initial,clock,duration,ease)
    for k,v in pairs(target) do
        if type(v)=='table' then
            performEasing(subject[k],v,initial[k],clock,duration,ease)
        else
            subject[k]=ease(clock,initial[k],v-initial[k],duration)
        end
    end
end

----------------------------------------------------------
-- Tween object
----------------------------------------------------------
local Tween = {}
Tween.__index = Tween

function Tween:set(clock)
    if not self.initial then self.initial=copyTables({},self.subject) end
    self.clock=clock
    if self.clock<=0 then
        self.clock=0; copyTables(self.subject,self.initial)
    elseif self.clock>=self.duration then
        self.clock=self.duration; copyTables(self.subject,self.target)
    else
        performEasing(self.subject,self.target,self.initial,self.clock,self.duration,self.easing)
    end
    return self.clock>=self.duration
end

function Tween:update(dt)
    return self:set(self.clock+dt)
end

----------------------------------------------------------
-- new tween
----------------------------------------------------------
function tween.new(duration,subject,target,ease)
    ease=ease or tween.easing.linear
    return setmetatable({
        duration=duration,
        subject=subject,
        target=target,
        easing=ease,
        clock=0
    },Tween)
end

return tween
