--Redeem codes from table
local RedeemCodesFunction = function()
	local localcodes = {"FixedEvent", "mbShutdown","ELFUPRISING", "UPD2", "4LEAFCLOVER", "HARDATWORK", "SaiyanPride","UPD1HALF","FORGOT40KLIKES", "THANKSFOR50KLIKES", "UPDATEONE", "BONIMARU", "MBFORDELAY", "15MVISITS", "100KBLUEAPP", "SORRYFORTHESHUTDOWN", "THANKSFORALLTHESUPPORT", "UPDATEHALF", "TOBITO",  "RELEASE", "THANKSFOR20KLIKES", "THANKSFOR5KLIKES", "SORRY4SHUTDOWN", "15KCCU", "TRAILER", "THANKSFOR20K", "ILUVAFS"}
	if not getgenv().skibidicodes or #getgenv().skibidicodes == 0 then getgenv().skibidicodes = localcodes end
	for _,v in pairs(getgenv().skibidicodes) do 
		local args = {
			"RedeemCode",
			v
		}
		local suc, fail = pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
		end)
		if suc then print("Successfully redeemed code: "..v) else print("Error while redeeming code: "..fail) end
	end
end
--Collect Daily reward
local CollectDailyFunction = function()
	local suc, failure = pcall(function()
		game:GetService("ReplicatedStorage"):WaitForChild("LobbyRemotes"):WaitForChild("DailyRewards"):FireServer()
	end)
	if suc then print("Success to collect daily") else print("Error to collect daily reward: "..failure) end
end
--Spin fortune wheel
local SpinWheelFunction = function()
	if getgenv().SpinWheel then
		local args = {
			true
		}
		local suc,failure = pcall(function()
			game:GetService("ReplicatedStorage"):WaitForChild("LobbyRemotes"):WaitForChild("SpinWheelFunction"):InvokeServer(unpack(args))
		end)
		if suc then print("Spinned wheel") else print("Error to spin wheel: "..failure) end
	end
end
--Buy goldshop rr
local BuyRRFunction = function()
	if getgenv().BuyRRS then
		for i=1,5 do
			local args = {
				"BuyShopItem",
				"GoldShop",
				7,
				1
			}
			local suc, er = pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("LobbyRemotes"):WaitForChild("ShopRemote"):FireServer(unpack(args))
			end)
			if suc then print("Bought RR from shop") else print("Error to buy RR: "..er) end
		end
	end
end
local main = function()
    if getgenv().BuyRRS then BuyRRFunction() end
	if getgenv().CollectDaily then CollectDailyFunction() end
	if getgenv().SpinWheel then SpinWheelFunction() end
	if getgenv().RedeemCodes then RedeemCodesFunction() end
end

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    task.wait(3)
    
    if game:GetService("Players").LocalPlayer then
		main()
    else
        game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait()
        task.wait(1)
        main()
    end
end)
