/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */

#include "ShipMoveMath.h"
#include "Map/ReadMap.h"
#include "Sim/Objects/SolidObject.h"
#include "System/mmgr.h"

CR_BIND_DERIVED(CShipMoveMath, CMoveMath, );

/*
Calculate speed-multiplier for given height and slope data.
*/
float CShipMoveMath::SpeedMod(const MoveDef& moveDef, float height, float slope) const
{
	if (-height < moveDef.depth)
		return 0.0f;

	return 1.0f;
}

float CShipMoveMath::SpeedMod(const MoveDef& moveDef, float height, float slope, float moveSlope) const
{
	if (-height < moveDef.depth && moveSlope > 0.0f)
		return 0.0f;

	return 1.0f;
}
