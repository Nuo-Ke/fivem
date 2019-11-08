--------------------------------
------ RP Revive by 諾恪(天恪鎮) --------
--------------------------------

local reviveWait = 300 -- 死亡後多長時間可以上使用(秒)
local isDead = false
local timerCount = reviveWait

AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer() 
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)	
end)


function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)

end

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
	isDead = false
	timerCount = reviveWait
	NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
end

function ShowInfoRevive(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(true, true)
end

Citizen.CreateThread(function()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	local respawnCount = 0
	local spawnPoints = {}
	local playerIndex = NetworkGetPlayerIndex(-1) or 0
	math.randomseed(playerIndex)

    while true do
    Citizen.Wait(0)
		ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
			isDead = true
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
			ShowInfoRevive('5分鐘後,使用指令/doc復活.')
          
			
			RegisterCommand("doc", function(source, args)
				if GetLastInputMethod(0) then
					if timerCount <= 0 then
				
					ESX.TriggerServerCallback('jh:jiance', function(flag)
						if flag then
						TriggerServerEvent('jh:vahicle')
						 TriggerEvent('esx_ambulancejob:revive', source)
						 timerCount = reviveWait
						end
				
					end)
					
					else
						TriggerEvent('chat:addMessage', { args = {'^*等待 ' .. timerCount .. '後使用/doc指令復活.'}})
					end	
				
				
				end
				
			end, false)
			
			
			
			
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isDead then
			timerCount = timerCount - 1
        end
        Citizen.Wait(1000)          
    end
end)





AddEventHandler('esx_ambulancejob:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}

		ESX.SetPlayerData('lastPosition', formattedCoords)

		TriggerServerEvent('esx:updateLastPosition', formattedCoords)

		RespawnPed(playerPed, formattedCoords, 0.0)

		StopScreenEffect('DeathFailOut')
		DoScreenFadeIn(800)
	end)
end)
