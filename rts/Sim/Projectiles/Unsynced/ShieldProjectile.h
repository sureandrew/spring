/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */

#ifndef SHIELD_PROJECTILE_H
#define SHIELD_PROJECTILE_H

#include "Sim/Projectiles/Projectile.h"
#include "System/float3.h"

class CUnit;
class CPlasmaRepulser;
struct WeaponDef;

class CVertexArray;
struct AtlasedTexture;
class ShieldSegmentProjectile;


class ShieldProjectile: public CProjectile {
	CR_DECLARE(ShieldProjectile);
public:
	ShieldProjectile(const CPlasmaRepulser*);
	~ShieldProjectile();

	void Update();
	bool AllowDrawing();

	void PreDelete() {
		deleteMe = true;
		shield = NULL;
	}

	const CPlasmaRepulser* GetShield() const { return shield; }
	const AtlasedTexture* GetShieldTexture() const { return shieldTexture; }

private:
	const CPlasmaRepulser* shield;
	const AtlasedTexture* shieldTexture;

	unsigned int lastAllowDrawingUpdate;
	bool allowDrawing;

	// NOTE: these are also registered in ProjectileHandler
	std::list<ShieldSegmentProjectile*> shieldSegments;
};



class ShieldSegmentProjectile: public CProjectile {
	CR_DECLARE(ShieldSegmentProjectile);
public:
	ShieldSegmentProjectile(
		ShieldProjectile* shieldProjectile,
		const WeaponDef* shieldWeaponDef,
		const float3& shieldSegmentPos,
		const int xpart,
		const int ypart
	);
	~ShieldSegmentProjectile();

	void Draw();
	void Update();
	void PreDelete() {
		deleteMe = true;
		shieldProjectile = NULL;
	}

private:
	ShieldProjectile* shieldProjectile;

	float3 segmentPos;
	float3 segmentColor;

	float3 vertices[25];
	float3 texCoors[25];

	float segmentSize;
	float segmentAlpha;
	bool usePerlinTex;
};

#endif

