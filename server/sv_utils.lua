function GetVehicleByPlate(targetPlate)
	local vehicles = GetAllVehicles();
	for _,vehicle in pairs(vehicles) do
		local plate = trim(GetVehicleNumberPlateText(vehicle));
		if plate == targetPlate then
			return vehicle;
		end
	end
	
	return nil;
end

