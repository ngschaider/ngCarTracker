function doesEntityExistAndIsNotNull(entity)
	if entity and DoesEntityExist(entity) then
		return true;
    else
		return false;
	end
end
 
function isVehicleDrivable(veh)
	local hash = GetEntityModel(veh);
    if IsVehicleDriveable(veh, false) and 
        (IsThisModelACar(hash) or
        IsThisModelABike(hash) or
        IsThisModelAQuadbike(hash) or
        IsThisModelAHeli(hash) or
        IsThisModelAPlane(hash) or
        IsThisModelABoat(hash) or
        IsThisModelABicycle(hash)) then
        return true;
	end
 
    return false;
end
 
function getClosestVehicleFromPedPos(ped, maxDistance)
    local vehicles = GetGamePool("CVehicle");
	
	local ret = nil;
	local smallestDistance = maxDistance;
 
    if vehicles then
		local playerPos = GetEntityCoords(PlayerPedId());
        for _,vehicle in pairs(vehicles) do
            if vehicle and DoesEntityExist(vehicle) then
				local vehiclePos = GetEntityCoords(vehicle);
				local distance = GetDistanceBetweenCoords(vehiclePos, playerPos);
				
				if distance <= smallestDistance and isVehicleDrivable(vehicle) then
					smallestDistance = distance;
					ret = vehicle;
				end
			end
        end
    end
 
    return ret;
end


function table_contains(t, item)
	for k,v in pairs(t) do
		if v == item then
			return true;
		end
	end
	
	return false;
end


TransformRotationY = function(x, y, z, rot)
	local value = math.sqrt(x * x + y * y);
	local angle = math.atan2(y, x);
	
	local newAngle = angle + rot;
	local newX = math.cos(newAngle) * value;
	local newY = math.sin(newAngle) * value;
	
	return {
		x = newX,
		y = newY,
		z = z,
	};
end;

RotationToDirection = function(rotation)
	local adjustedRotation = { 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	};
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	};
	return direction;
end;

RaycastGameplayCamera = function(distance)
	local cameraRotation = GetGameplayCamRot();
	local cameraCoord = GetGameplayCamCoord();
	local direction = RotationToDirection(cameraRotation);
	local destination = { 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	};
	local a, hit, endCoords, d, entityHit = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1));
	return hit, endCoords, entityHit;
end;

ShowNotification = function(message)
	BeginTextCommandThefeedPost("STRING");
	AddTextComponentSubstringPlayerName(message);
	EndTextCommandThefeedPostTicker(0, 1);
end;


function GetCamRotZ()
	local camRot = GetGameplayCamRot();
	local z = camRot.z / 180 * math.pi;
	if z < 0 then
		z = z + 2 * math.pi;
	end
	return 2 * math.pi - z;
end