local RunService = game:GetService("RunService")

return function()
	local Promise = require(script.Parent.Parent.Promise)
	local Tween = require(script.Parent)

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	describe("grouped tween", function()
		it("should be able to tween one instance", function()
			local instanceA = Instance.new("NumberValue")

			local tweenGroup = Tween.all({
				Tween.new(instanceA, tweenInfo, {
					Value = 1;
				})
			})

			tweenGroup:Play():expect()

			expect(instanceA.Value).to.be.equal(1)
		end)

		it("should be able to tween more than one instance", function()
			local instanceA = Instance.new("NumberValue")
			local instanceB = Instance.new("NumberValue")

			instanceB.Value = 1

			local tweenGroup = Tween.all({
				Tween.new(instanceA, tweenInfo, {
					Value = 1;
				});
				Tween.new(instanceB, tweenInfo, {
					Value = 0;
				});
			})

			tweenGroup:Play():expect()

			expect(instanceA.Value).to.be.equal(1)
			expect(instanceB.Value).to.be.equal(0)
		end)

		it("should be able to be cancelled", function()
			local instance = Instance.new("NumberValue")

			local tween = Tween.new(instance, tweenInfo, {
				Value = 1;
			})

			local tweenPromise = tween:Play()

			RunService.Heartbeat:Wait()
			Promise.delay(0.1)
				:andThen(function()
					tweenPromise:cancel()
				end)
				:expect()

			expect(instance.Value).never.to.be.equal(0)
			expect(instance.Value).never.to.be.equal(1)
		end)

		it("should be able to be paused", function()
			local instance = Instance.new("NumberValue")

			local tween = Tween.new(instance, tweenInfo, {
				Value = 1;
			})

			tween:Play()

			RunService.Heartbeat:Wait()
			Promise.delay(0.1)
				:andThen(function()
					tween:Pause()
				end)
				:expect()

			expect(instance.Value).never.to.equal(0)
		end)

		it("should be able to be resumed", function()
			local instance = Instance.new("NumberValue")

			local tween = Tween.new(instance, tweenInfo, {
				Value = 1;
			})

			tween:Play()

			Promise.delay(0.1)
				:andThen(function()
					tween:Pause()
				end)
				:expect()

			expect(instance.Value).never.to.equal(0)
			
			tween:Play():expect()

			expect(instance.Value).to.equal(1)
		end)
	end)
end