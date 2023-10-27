--!strict
local Promise = require(script.Parent.Parent.Promise)
local Trove = require(script.Parent.Parent.Trove)

local TweenGroup = {}
TweenGroup.__index = TweenGroup

function TweenGroup.from(tweens)
	local self = setmetatable({}, TweenGroup)

	local trove = Trove.new()

	self._tweens = tweens

	self._trove = trove

	return self
end

function TweenGroup:Play()
	local promise = self._promise
	if not promise then
		local tweens: {any} = self._tweens
		local trove = self._trove:Extend()

		local promises = table.create(#tweens)
		for _, tween in tweens do
			table.insert(promises, trove:AddPromise(tween:Play()))
		end

		promise = Promise.all(promises):finally(function()
			trove:Clean()
			self._promise = nil
		end)

		self._promise = promise
	end
	return promise
end

function TweenGroup:Pause()
	for _, tween in self._tweens do
		tween:Pause()
	end
end

function TweenGroup:Cancel()
	local promise = self._promise
	if promise then
		promise:cancel()
	else
		for _, tween in self._tweens do
			tween:Cancel()
		end
	end
end

function TweenGroup:Destroy()
	self._trove:Clean()
end

return TweenGroup