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

			local tweenPromise = tweenGroup:Play()

			Promise.delay(0.1)
				:andThen(function()
					tweenPromise:cancel()
				end)
				:expect()

			expect(instanceA.Value).never.to.be.equal(0)
			expect(instanceB.Value).never.to.be.equal(1)
		end)

		it("should be able to be paused", function()
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

			tweenGroup:Play()

			RunService.Heartbeat:Wait()
			Promise.delay(0.1)
				:andThen(function()
					tweenGroup:Pause()
				end)
				:expect()

			local valueA = instanceA.Value
			local valueB = instanceB.Value

			local valueA2 = 0
			local valueB2 = 0

			RunService.Heartbeat:Wait()
			Promise.delay(0.05)
				:andThen(function()
					valueA2 = instanceA.Value
					valueB2 = instanceB.Value
				end)
				:expect()

			expect(valueA).to.equal(valueA2)
			expect(valueB).to.equal(valueB2)

			expect(instanceA.Value).never.to.equal(0)
			expect(instanceB.Value).never.to.equal(1)
		end)

		it("should be able to be resumed", function()
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

			tweenGroup:Play()

			Promise.delay(0.1)
				:andThen(function()
					tweenGroup:Pause()
				end)
				:expect()

			local valueA = instanceA.Value
			local valueB = instanceB.Value

			expect(instanceA.Value).never.to.equal(1)
			expect(instanceB.Value).never.to.equal(0)

			local valueA2 = 0
			local valueB2 = 0

			Promise.delay(0.05)
				:andThen(function()
					valueA2 = instanceA.Value
					valueB2 = instanceB.Value
				end)

			tweenGroup:Play():expect()

			expect(valueA).never.to.equal(valueA2)
			expect(valueB).never.to.equal(valueB2)

			expect(instanceA.Value).to.equal(1)
			expect(instanceB.Value).to.equal(0)
		end)
	end)
end