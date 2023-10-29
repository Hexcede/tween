--!strict
local Promise = require(script.Parent.Parent.Promise)
local Trove = require(script.Parent.Parent.Trove)

local TweenGroup = {}
TweenGroup.__index = TweenGroup

function TweenGroup.from(tweens)
	local self = setmetatable({}, TweenGroup)

	local trove = Trove.new()

	self._tweens = tweens
	self._tweenPromises = {}

	self._trove = trove

	return self
end

function TweenGroup:Play()
	local promise = self._promise

	-- If the tween has not yet been started
	if not promise then
		local tweens: { any } = self._tweens

		-- Create a subtrove for this current interaction
		local trove = self._trove:Extend()

		local tweenPromises = {}
		local promises = table.create(#tweens)

		-- Play each tween and collect all of the resulting promises
		--  Additionally, map each tween to its promise within a tween promises table,
		--- so that individaul tween statuses can be queried.
		for _, tween in tweens do
			local tweenPromise = trove:AddPromise(tween:Play())
			tweenPromises[tween] = tweenPromise
			table.insert(promises, tweenPromise)
		end

		-- Assign tween promises
		self._tweenPromises = tweenPromises

		-- When cleaning up, clear the grouped promise and reset the tween promises table
		trove:Add(function()
			self._promise = nil
			self._tweenPromises = {}
		end)

		-- Finally after the tween promises have completed, clean the subtrove
		promise = Promise.all(promises):finallyCall(trove.Clean, trove)

		self._promise = promise
	else
		-- The tween has been started, retrieve the tween promises
		local tweenPromises: { [any]: any } = self._tweenPromises

		for tween, tweenPromise in tweenPromises do
			-- Resume or restart each in progress tween
			if tweenPromise:getStatus() == Promise.Status.Started then
				tween:Play()
			end
		end
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