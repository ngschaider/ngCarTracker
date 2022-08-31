local ESX = nil;
TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj;
end);

Citizen.CreateThread(function()
	while not HasAnimDictLoaded("mini@repair") do
		Citizen.Wait(100);
		RequestAnimDict("mini@repair");
		
	end
end);




local remoteActive = false;

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100);
		
	end
end);

Citizen.CreateThread(function()
	while true do		
		if remoteActive then
			ESX.TriggerServerCallback("ngCarTacker:GetTrackedVehiclePositions", function(positions)
				local ped = PlayerPedId();
				local playerPos = GetEntityCoords(ped);
				
				local radarPositions = {};
				for _,position in pairs(positions) do
					local distance = GetDistanceBetweenCoords(playerPos, position);
					local normalizedDistance = distance / Config.RadarDistance;					
					
					local dx = position.x - playerPos.x;
					local dy = position.y - playerPos.y;
					print("atan", math.atan(dy, dx) * 180 / math.pi);
					print("camRot", GetCamRotZ() * 180 / math.pi);
					local angle = 2 * math.pi - (math.atan(dy, dx) + GetCamRotZ());
					while angle > 2 * math.pi do
						angle = angle - 2 * math.pi;
					end
					print("angle", angle * 180 / math.pi);
					
					table.insert(radarPositions, {
						x = normalizedDistance * math.cos(angle),
						y = normalizedDistance * math.sin(angle),
					});
				end
				SendNuiMessage(json.encode({
					name = "SetTargets",
					args = {
						radarPositions
					}
				}));
			end);
		end
		
		Citizen.Wait(1000);
	end
end);

RegisterNetEvent("ngCarTracker:RemoteItemUsed", function()
	SendNuiMessage(json.encode({
		name = "Toggle"
	}));

	remoteActive = not remoteActive;
end);

RegisterNetEvent("ngCarTracker:RemoverItemUsed", function()
	Citizen.CreateThread(function()
		local vehicle = PlayMechanicAnimAndWait(Config.TimeToScan);
		
		if vehicle then
			local netId = NetworkGetNetworkIdFromEntity(vehicle);
			TriggerServerEvent("ngCarTracker:RemoveCarTracker", netId);
			ShowNotification(_U("cartracker_removed"));
		end
	end);
end);


RegisterNetEvent("ngCarTracker:ScannerItemUsed", function()
	Citizen.CreateThread(function()
		local vehicle = PlayMechanicAnimAndWait(Config.TimeToScan);
		
		if vehicle then
			local netId = NetworkGetNetworkIdFromEntity(vehicle);
			ESX.TriggerServerCallback("ngCarTracker:GetIsTrackerInstalled", function(isInstalled)
				if isInstalled then
					ShowNotification(_U("cartracker_is_installed"));
				else
					ShowNotification(_U("cartracker_is_not_installed"));
				end
			end, netId);
		end
	end);
end);

RegisterNetEvent("ngCarTracker:CarTrackerItemUsed", function()
	Citizen.CreateThread(function()
		local vehicle = PlayMechanicAnimAndWait(Config.TimeToInstall);
		
		if vehicle then
			local netId = NetworkGetNetworkIdFromEntity(vehicle);
			TriggerServerEvent("ngCarTracker:InstallCarTracker", netId);
			ShowNotification(_U("cartracker_installed"));
		end
	end);
end);

function PlayMechanicAnimAndWait(timeToWait)
	local ped = PlayerPedId();
	local vehicle = getClosestVehicleFromPedPos(ped, Config.MaxDistanceToVehicle);
	
	if vehicle then
		TaskPlayAnim(ped, "mini@repair", "fixing_a_ped", 8.0, 8.0, Config.TimeToInstall * 1000, 1, false, false, false);
		Citizen.Wait(Config.TimeToInstall * 1000);
		
		local vehiclePos = GetEntityCoords(vehicle);
		local playerPos = GetEntityCoords(ped);
		local distance = GetDistanceBetweenCoords(vehiclePos, playerPos);
		if distance < Config.MaxDistanceToVehicle then
			return vehicle;
		end
	end
end

