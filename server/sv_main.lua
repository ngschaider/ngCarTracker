local ESX = nil;
TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj;
end);


Citizen.CreateThread(function()
	while not ESX do
		Citizen.Wait(100);
	end
	
	ESX.RegisterUsableItem(Config.CarTrackerItem, CarTrackerItemUsed);
	ESX.RegisterUsableItem(Config.ScannerItem, ScannerItemUsed);
	ESX.RegisterUsableItem(Config.RemoteItem, RemoteItemUsed);
	ESX.RegisterUsableItem(Config.RemoverItem, RemoverItemUsed);
end);


function CarTrackerItemUsed(playerId)
	TriggerClientEvent("ngCarTracker:CarTrackerItemUsed", playerId);
end

function ScannerItemUsed(playerId)
	TriggerClientEvent("ngCarTracker:ScannerItemUsed", playerId);
end

function RemoteItemUsed(playerId)
	TriggerClientEvent("ngCarTracker:RemoteItemUsed", playerId);
end

function RemoverItemUsed(playerId)
	TriggerClientEvent("ngCarTracker:RemoverItemUsed", playerId);
end

ESX.RegisterServerCallback("ngCarTacker:GetTrackedVehiclePositions", function(playerId, cb)
	local xPlayer = ESX.GetPlayerFromId(playerId);

	local results = MySQL.Sync.fetchAll("SELECT plate FROM ng_car_tracker WHERE attached_by=@attached_by", {
		["@attached_by"] = xPlayer.identifier
	});
	
	if results and #results > 0 then
		local positions = {};
		for _,result in pairs(results) do
			local vehicle = GetVehicleByPlate(result.plate);
			if vehicle then
				local vehiclePosition = GetEntityCoords(vehicle);
				table.insert(positions, vehiclePosition);
			end
		end
		cb(positions);
	else
		cb({});
	end
end);


ESX.RegisterServerCallback("ngCarTracker:GetIsTrackerInstalled", function(playerId, cb, netId)
	local vehicle = NetworkGetEntityFromNetworkId(netId);
	local plate = trim(GetVehicleNumberPlateText(vehicle));
	
	local results = MySQL.Sync.fetchAll("SELECT id FROM ng_car_tracker WHERE plate=@plate", {
		["@plate"] = plate,
	});
	
	local scanResult = results and #results > 0;
	cb(scanResult);
end);

RegisterNetEvent("ngCarTracker:InstallCarTracker", function(netId)
	local playerId = source;

	local vehicle = NetworkGetEntityFromNetworkId(netId);
	local xPlayer = ESX.GetPlayerFromId(playerId);
	xPlayer.removeInventoryItem(Config.CarTrackerItem, 1);
	
	local plate = trim(GetVehicleNumberPlateText(vehicle));
	
	MySQL.Sync.execute("INSERT INTO ng_car_tracker (plate, attached_by) VALUES (@plate, @attached_by)", {
		["@plate"] = plate,
		["@attached_by"] = xPlayer.identifier
	});
end);


RegisterNetEvent("ngCarTracker:RemoveCarTracker", function(netId)
	local playerId = source;

	local vehicle = NetworkGetEntityFromNetworkId(netId);
	local xPlayer = ESX.GetPlayerFromId(playerId);
	xPlayer.removeInventoryItem(Config.RemoverItem, 1);
	
	local plate = trim(GetVehicleNumberPlateText(vehicle));
	
	MySQL.Sync.execute("DELETE FROM ng_car_tracker WHERE plate=@plate", {
		["@plate"] = plate
	});
end);