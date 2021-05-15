local Rect = ikkuna.class('Rect')

function Rect:initialize(args)
	local args = args or {}

	local all = args.all or 0
	local top = args.top or all
	local bottom = args.bottom or all
	local left = args.left or all
	local right = args.right or all

	self.top = math.min(top, bottom)
	self.bottom = math.max(top, bottom)
	self.left = math.min(left, right)
	self.right = math.max(left, right)
end

function Rect:width()
	return self.right - self.left
end

function Rect:height()
	return self.bottom - self.top
end

ikkuna.Rect = Rect
