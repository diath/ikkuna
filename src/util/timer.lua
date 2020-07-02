local Timer = class('timer')

function Timer:initialize()
	self.time = love.timer.getTime()
end

function Timer:reset()
	self.time = love.timer.getTime()
end

function Timer:elapsed()
	return love.timer.getTime() - self.time
end

ikkuna.Timer = Timer
