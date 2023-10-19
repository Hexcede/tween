--!strict
local TweenService = game:GetService("TweenService")

local Promise = require(script.Parent.Promise)
local Trove = require(script.Parent.Trove)

local Tween = {}
Tween.__index = Tween

function Tween.new(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any})
	local self = setmetatable({}, Tween)

	local trove = Trove.new()

	self._tween = trove:Add(TweenService:Create(instance, tweenInfo, properties))

	self._trove = trove

	return self
end

function Tween:Play()
	local promise = self._promise
	if not promise then
		local tween = self._tween
		local trove = self._trove:Extend()

		promise = trove:AddPromise(Promise.new(function(resolve, reject, onCancel)
			onCancel(function()
				tween:Cancel()
			end)

			trove:Add(tween.Completed:Once(resolve))
			tween:Play()
		end)):finally(function()
			trove:Clean()
			self._promise = nil
		end)

		self._promise = promise
	end
	return promise
end

function Tween:Pause()
	self._tween:Pause()
end

function Tween:Cancel()
	local promise = self._promise
	if promise then
		promise:cancel()
	else
		self._tween:Cancel()
	end
end

function Tween:Destroy()
	self._trove:Clean()
end

return Tween