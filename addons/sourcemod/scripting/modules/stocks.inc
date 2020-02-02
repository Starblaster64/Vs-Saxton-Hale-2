stock int GetHealingTarget(const int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if( !IsValidEntity(medigun) )
		return -1;
	
	if( HasEntProp(medigun, Prop_Send, "m_bHealing") ) {
		if( GetEntProp(medigun, Prop_Send, "m_bHealing") )
			return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
	}
	return -1;
}
stock int GetActiveWep(const int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return( IsValidEntity(weapon) ) ? weapon : -1;
}
stock float GetMediCharge(const int medigun)
{
	return( IsValidEntity(medigun) ) ? GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") : -1.0;
}
stock void SetMediCharge(const int medigun, const float val)
{
	if( IsValidEntity(medigun) )
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock bool IsNearSpencer(const int client)
{
	int healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	int medics;
	if( healers > 0 ) {
		for( int i=MaxClients; i; --i ) {
			if( IsValidClient(i) && GetHealingTarget(i) == client )
				medics++;
		}
	}
	return (healers > medics);
}

stock bool IsHealedByMedic(const int client)
{
	int numhealers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	for( int i=0; i<numhealers; i++ )
		if( 0 < GetHealerByIndex(client, i) <= MaxClients )
			return true;
	return false;
}

public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return (entity != data);
}
public bool TraceRayIgnoreEnts(int entity, int mask, any data)
{
	return entity==0;
}
stock void ForceTeamWin(const int team)
{
	int entity = FindEntityByClassname(-1, "team_control_point_master");
	if (entity <= 0) {
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int GetItemIndex(const int item)
{
	return( IsValidEntity(item) ) ? GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex") : -1;
}
stock int GetItemQuality(const int item)
{
	return( IsValidEntity(item) ) ? GetEntProp(item, Prop_Send, "m_iEntityQuality") : -1;
}
stock int GetIndexOfWeaponSlot(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return GetItemIndex(weapon);
}
stock bool IsInRange(const int entity, const int target, const float dist, bool trace = false)
{
	float entitypos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", entitypos);
	float targetpos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetpos);
	if( GetVectorDistance(entitypos, targetpos) <= dist ) {
		if( !trace )
			return true;
		else {
			TR_TraceRayFilter(entitypos, targetpos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, entity);
			if( TR_GetFraction() > 0.98 )
				return true;
		}
	}
	return false;
}
stock int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(particle)) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, RemoveEnt, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
}
stock void SetWeaponInvis(const int client, const int alpha)
{
	int transparent = alpha;
	for( int i; i<5; i++ ) {
		int entity = GetPlayerWeaponSlot(client, i); 
		if( IsValidEntity(entity) ) {
			if (transparent > 255)
				transparent = 255;
			if (transparent < 0)
				transparent = 0;
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 150, 150, 150, transparent); 
		}
	}
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int ShootRocket(const int client, bool bCrit = false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false)
{
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	
	if( !IsValidEntity(iProjectile) )
		return 0;
	
	float vVelocity[3];
	GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);
	
	if( !arc )
		NormalizeVector(vVelocity, vVelocity);
	else vVelocity[2] -= 0.025;
	
	ScaleVector(vVelocity, flSpeed);
	SetEntPropEnt(iProjectile,	Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,		Prop_Send, "m_bCritical", (bCrit ? 1 : 0));
	SetEntProp(iProjectile,		Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,		Prop_Send, "m_nSkin", (iTeam-2));
	
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
	
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	if( arc )
		SetEntityMoveType(iProjectile, MOVETYPE_FLYGRAVITY);
	if( model[0] != '\0' )
		SetEntityModel(iProjectile, model);
	return iProjectile;
}

stock void SetClientOverlay(const int client, const char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}

stock bool IsValidClient(const int client, bool replaycheck=true)
{
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) )
		return false;
	else if( GetEntProp(client, Prop_Send, "m_bIsCoaching") )
		return false;
	else if( replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)) )
		return false;
	else if( TF2_GetPlayerClass(client)==TFClass_Unknown )
		return false;
	return true;
}
stock int GetOwner(const int ent)
{
	return( IsValidEntity(ent) ) ? GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") : -1;
}
stock int GetBuilder(const int ent)
{
	return( IsValidEntity(ent) ) ? GetEntPropEnt(ent, Prop_Send, "m_hBuilder") : -1;
}
stock int GetGroundEntity(const int client)
{
	return( IsValidClient(client) ) ? GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") : -1;
}
stock int FindTeleOwner(const int client)
{
	int teleporter = GetGroundEntity(client);
	char classname[32];
	if (IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
	{
		int owner = GetBuilder(teleporter);
		if (IsValidClient(owner, false))
			return owner;
	}
	return -1;
}

/// Props to Chdata!
stock void TeleportToSpawn(const int client, int team = 0)
{
	int spawn = -1;
	ArrayList hArray = new ArrayList();
	while( (spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1 ) {
		/// skip disabled spawns.
		if( GetEntProp(spawn, Prop_Send, "m_bDisabled") )
			continue;
		else if (team <= 1)
			hArray.Push(spawn);
		else {
			int iSpawnTeam = GetEntProp(spawn, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == team)
				hArray.Push(spawn);
		}
	}
	
	spawn = hArray.Get(GetRandomInt(0, hArray.Length - 1));
	hArray.Close();
	
	/// Technically you'll never find a map without a spawn point. Not a good map at least.
	
	float vPos[3], vAng[3];
	GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(spawn, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(spawn, vPos, vAng, NULL_VECTOR);
}

stock void DoExplosion(const int owner, const int damage, const int radius, float pos[3])
{
	int explode = CreateEntityByName("env_explosion");
	if( !IsValidEntity(explode) )
		return;
	
	DispatchKeyValue(explode, "targetname", "exploder");
	DispatchKeyValue(explode, "spawnflags", "4");
	DispatchKeyValue(explode, "rendermode", "5");
	
	SetEntPropEnt(explode, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(explode, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(explode, Prop_Data, "m_iRadiusOverride", radius);
	
	int team = GetClientTeam(owner);
	SetVariantInt(team); AcceptEntityInput(explode, "TeamNum");
	SetVariantInt(team); AcceptEntityInput(explode, "SetTeam");
	
	TeleportEntity(explode, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(explode);
	ActivateEntity(explode);
	AcceptEntityInput(explode, "Explode");
	AcceptEntityInput(explode, "Kill");
}

stock float[] nSubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] - vec2[0];
	result[1] = vec1[1] - vec2[1];
	result[2] = vec1[2] - vec2[2];
	return result;
}
stock float[] nAddVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] + vec2[0];
	result[1] = vec1[1] + vec2[1];
	result[2] = vec1[2] + vec2[2];
	return result;
}
stock float[] nScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] nNegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock bool VectorCompare (const float v1[3], const float v2[3])
{
	for (int i=0; i<3; i++)
		if (v1[i] != v2[i])
			return false;
			
	return true;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients; i; --i) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout)
			return false;
	}
	return true;
}
stock int GetLivingPlayers(const int team)
{
	int AlivePlayers = 0;
	for (int i=MaxClients; i; --i) {
		if( IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team )
			++AlivePlayers;
	}
	return AlivePlayers;
}
stock void IncrementHeadCount(const int client, bool addhealth = true, int addheads = 1)
{
	/// Apply this condition to Demomen to give them their glowing eye effect.
	if( (TF2_GetPlayerClass(client) == TFClass_DemoMan) && !TF2_IsPlayerInCondition(client, TFCond_DemoBuff) )
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite);
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if( addhealth )
	{
		int health = GetClientHealth(client);
		//health += (decapitations >= 4 ? 10 : 15);
		
		/// TODO: Replace this with an overheal calculation (MaxHP * 1.5) OR add a maxhealth arg.
		if( health + (15 * addheads) <= 300 )
			health += 15 * addheads;
		else
			health = 300;
		SetEntProp(client, Prop_Data, "m_iHealth", health);
		SetEntProp(client, Prop_Send, "m_iHealth", health);
	}
	
	/// recalc their speed
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}
stock void SpawnSmallHealthPackAt(const int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	if( IsValidEntity(healthpack) ) {
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		
		/// for safety, though it normally doesn't respawn
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
	}
	return;
}

/// Credit to Mecha the Slag
public void SickleClimbWalls(const int client, const int weapon, const float upwardvel, const float health, const bool attackdelay)
{
	if( !IsValidClient(client) || (GetClientHealth(client) <= health) )
		return;
	
	char classname[64];
	float vecClientEyePos[3];
	float vecClientEyeAng[3];
	
	/// Get the position of the player's eyes
	GetClientEyePosition(client, vecClientEyePos);
	
	/// Get the angle the player is looking
	GetClientEyeAngles(client, vecClientEyeAng);
	
	/// Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	
	if( !TR_DidHit(null) )
		return;
	
	int TRIndex = TR_GetEntityIndex(null);
	GetEdictClassname(TRIndex, classname, sizeof(classname));
	if (!StrEqual(classname, "worldspawn"))
		return;
	
	float fNormal[3];
	TR_GetPlaneNormal(null, fNormal);
	GetVectorAngles(fNormal, fNormal);
	
	if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0)
		return;
	if (fNormal[0] <= -30.0)
		return;
	
	float pos[3];
	TR_GetEndPosition(pos);
	float distance = GetVectorDistance(vecClientEyePos, pos);
	
	if (distance >= 100.0)
		return;
	
	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	fVelocity[2] = upwardvel;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
	
	//if (!IsBoss[client])
	//	ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");
	
	if (attackdelay)
		RequestFrame(NoAttacking, EntIndexToEntRef(weapon));
}
public void NoAttacking(const any ref)
{
	int wepref = ref;
	int weapon = EntRefToEntIndex(wepref);
	SetNextAttack(weapon, 1.56);
}
stock void SetNextAttack(const int weapon, float duration = 0.0)
{
	if (weapon <= MaxClients || !IsValidEntity(weapon))
		return;
	float next = GetGameTime()+duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}
stock void ResetPlayer(const int client)
{
	TF2_RegeneratePlayer(client);
	SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );
	SetEntProp( client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth") );
}


/**
 * Wrapper function for easily setting up non-repeating timers
 *
 * @param func			Function pointer to call desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */

/**
If you need to use this and your function uses 3 parameters, modify it if necessary.
BUG/GLITCH: For some strange reason, SetPawnTimer doesn't work when u attempt to callback stock functions, interesting...
*/
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}


stock void ForceClientTeamChange(const int client, const int iTeam)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}

stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}

stock void SetArenaCapEnableTime(const float time)
{
	int ent = -1;
	char strTime[32]; FloatToString(time, strTime, sizeof(strTime));
	if( (ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1 )
		DispatchKeyValue(ent, "CapEnableDelay", strTime);
}

stock void SetClientGlow(const int client, const float time1, float clampfl = 0.0, float &glowtimer)
{
	if (IsValidClient(client)) {
		glowtimer += time1;
		if (clampfl > 0.0)
			glowtimer = clampfl;
		if (glowtimer <= 0.0) {
			glowtimer = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}

stock void SetControlPoint(const bool enable)
{
	int CPm = -1;
	while( (CPm = FindEntityByClassname(CPm, "team_control_point")) != -1 ) {
		if( CPm > MaxClients && IsValidEntity(CPm) ) {
			AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}

public void EnableCap(const bool open_doors)
{
	SetControlPoint(true);
	if( open_doors ) {
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "func_door")) != -1) {
			AcceptEntityInput(ent, "Open");
			AcceptEntityInput(ent, "Unlock");
		}
	}
}

stock bool CanFitHere(float origin[3], const float mins[3], const float maxs[3])
{
	for( int i=0; i<60; ++i ) {
		TR_TraceHull(origin, origin, mins, maxs, MASK_PLAYERSOLID);
		if( TR_GetFraction() > 0.98 )
			return true;
		else origin[2] += 1.0;
	}
	return false;
}

stock void SpawnRandomAmmo()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int maxlim = g_vsh2.m_hCvars[AmmoKitLimitMax].IntValue;
	int minlim = g_vsh2.m_hCvars[AmmoKitLimitMin].IntValue;
	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( minlim )
			if( spawned >= minlim )
				if( GetRandomInt(0, 3) )
					continue;
		//if( maxlim )
		if( spawned >= maxlim )
			break;
		/// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int ammo = CreateEntityByName("item_ammopack_small");
		TeleportEntity(ammo, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(ammo);
		SetEntProp(ammo, Prop_Send, "m_iTeamNum", g_vsh2.m_hCvars[Enabled].BoolValue ? VSH2Team_Red : VSH2Team_Neutral, 4);
		++spawned;
	}
}
stock void SpawnRandomHealth()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int maxlim = g_vsh2.m_hCvars[HealthKitLimitMax].IntValue;
	int minlim = g_vsh2.m_hCvars[HealthKitLimitMin].IntValue;
	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( minlim )
			if( spawned >= minlim )
				if( GetRandomInt(0, 3) )
					continue;
		//if( maxlim )
		if( spawned >= maxlim )
			break;
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int healthkit = CreateEntityByName("item_healthkit_small");
		TeleportEntity(healthkit, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(healthkit);
		SetEntProp(healthkit, Prop_Send, "m_iTeamNum", g_vsh2.m_hCvars[Enabled].BoolValue ? VSH2Team_Red : VSH2Team_Neutral, 4);
		++spawned;
	}
}
stock int GetTeamPlayerCount(const int team)
{
	int count = 0;
	for (int i=MaxClients; i; --i)
		if (IsValidClient(i) && GetClientTeam(i) == team)
			count++;
	return count;
}
stock int GetClientCloakIndex(const int client)
{
	if (!IsValidClient(client))
		return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep))
		return -1;
	char classname[32];
	GetEntityClassname(wep, classname, sizeof(classname));
	if( !strncmp(classname, "tf_wea", 6, false) )
		return GetItemIndex(wep);
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
stock bool RemoveDemoShield(int iClient) /// Taken from VSH1
{
	int iEnt = MaxClients + 1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable_demoshield")) != -1)
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && !GetEntProp(iEnt, Prop_Send, "m_bDisguiseWearable"))
		{
			TF2_RemoveWearable(iClient, iEnt);
			return true; /// Returns true if Shield was removed...
		}
	}
	return false; /// ...and returns False if one wasn't found.
}

stock bool RemoveRazorBack(int iClient)
{
	int iEnt = MaxClients + 1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable_razorback")) != -1)
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && !GetEntProp(iEnt, Prop_Send, "m_bDisguiseWearable"))
		{
			TF2_RemoveWearable(iClient, iEnt);
			return true; /// Returns true if Shield was removed...
		}
	}
	return false; /// ...and returns False if one wasn't found.
}

stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i=0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return -1;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i])
						return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname(edict, "tf_wearable_razorback")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearableRazorback"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++) {
					if (idx == indices[i]) {
						return edict;
					}
				}
			}
		}
	}
	return -1;
}
stock int FindSentry(const int client)
{
	return TF2_GetObjectOfType(client, TFObject_Sentry);
}
stock bool TF2_IsPlayerCritBuffed(const int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(34))
			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(35))
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			);
}
stock void OverNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}
public void _NoHonorBound(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client) && IsPlayerAlive(client)) {
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[32];
		if( IsValidEntity(active) )
			GetEdictClassname(active, classname, sizeof(classname));
		if( index == 357 && active == weapon && !strcmp(classname, "tf_weapon_katana", false) )
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
}
stock int GetMaxAmmo(const int client, const int slot)
{
	if (!IsValidClient(client))
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		switch( slot ) {
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool IsWeaponSlotActive(const int client, const int slot)
{
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}
public void _StopTickle(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
		TF2_RemoveCondition(client, TFCond_Taunting);
}
stock bool MapHasMusic(bool forceRecalc = false)	/// Does this even work?
{
	static bool hasMusic;
	static bool found = false;
	if (forceRecalc) {
		found = false;
		hasMusic = false;
	}
	if (!found) {
		int i = -1;
		char name[64];
		while( (i = FindEntityByClassname(i, "info_target")) != -1 ) {
			GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
			if( !strcmp(name, "hale_no_music", false) )
				hasMusic = true;
		}
		found = true;
	}
	return hasMusic;
}
stock bool IsValidAdmin(const int client, const char[] flags)
{
	if (!IsClientInGame(client))
		return false;
	int ibFlags = ReadFlagString(flags);
	if (!StrEqual(flags, "")) {
		if( (GetUserFlagBits(client) & ibFlags) == ibFlags )
			return true;
	}
	if( GetUserFlagBits(client) & ADMFLAG_ROOT )
		return true;
	return false;
}
stock int AttachProjectileModel(const int entity, const char[] strModel, char[] strAnim = "")
{
	if (!IsValidEntity(entity))
		return -1;
	int model = CreateEntityByName("prop_dynamic");
	if (IsValidEntity(model)) {
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if (strAnim[0] != '\0') {
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	}
	else LogError("(AttachProjectileModel): Could not create prop_dynamic");
	return -1;
}
stock bool GetRandomBool()
{
	return( !GetRandomInt(0, 1) ? false : true );
}
stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock void SetClip(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
}
stock int GetAmmo(const int client, const int slot)
{
	if (!IsValidClient(client))
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(client, iAmmoTable+iOffset);
	}
	return 0;
}
stock int GetClip(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}

stock void SkipBossPanelNotify(const int client/*, bool newchoice = true*/)
{
	if (!g_vsh2.m_hCvars[Enabled].BoolValue || !IsValidClient(client) || IsFakeClient(client) || IsVoteInProgress())
		return;
	
	Panel panel = new Panel();
	char strNotify[64];
	
	panel.SetTitle("[VSH2] You're The Next Boss!");
	Format(strNotify, sizeof(strNotify), "You are going to be a Boss soon! Type /halenext to check/reset your queue points.\nAlternatively, use !resetq.\nDon't forget to use !setboss to set your boss.");
	
	panel.DrawItem(strNotify);
	panel.Send(client, SkipHalePanelH, 30); /// in commands.sp
	delete panel;
}
stock void _SetCapOwner(const int iCapTeam, const bool open_doors, float flEnableTime = 30.0)
{
	int i = -1;
	int cap_master = FindEntityByClassname(-1, "team_control_point_master");
	while( (i = FindEntityByClassname(i, "team_control_point")) != -1 ) {
		/// Adapted from Arena:Respawn
		if (IsValidEntity(i)) {
			SetVariantInt(iCapTeam);
			
			/// Must have team_control_point_master as the activator, less it will just ignore the Input
			AcceptEntityInput(i, "SetOwner", -1, cap_master);
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			SetPawnTimer(EnableCap, flEnableTime, open_doors);
		}
	}
}
stock bool StrStarts(const char[] szStr, const char[] szSubStr, bool bCaseSensitive = true)
{
	return !StrContains(szStr, szSubStr, bCaseSensitive);
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i=0; i<length; ++i) {
		int holder = name[i];
		/// Invalid name, names may only contains numbers, underscores, and normal letters.
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_'))
			return false;
	}
	/// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
/// Thx Pelipoika
stock int GetHealerByIndex(const int client, const int index)
{
	int m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;
	Address m_Shared = GetEntityAddress(client) + view_as< Address >(m_aHealers);
	Address aHealers = view_as< Address >(LoadFromAddress(m_Shared, NumberType_Int32));
	return (LoadFromAddress(aHealers + view_as< Address >(index * 0x24), NumberType_Int32) & 0xFFF);
}

stock float GetConditionDuration(const int client, const TFCond cond)
{
	if (!TF2_IsPlayerInCondition(client, cond))
		return 0.0;
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = view_as< float >(LoadFromAddress(aCondDuration, NumberType_Int32));
	return flDuration;
}

stock void SetConditionDuration(const int client, const TFCond cond, const float duration)
{
	if (!TF2_IsPlayerInCondition(client, cond))
		return;
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	StoreToAddress(aCondDuration, view_as< int >(duration), NumberType_Int32);
}

enum {
	TF_AMMO_DUMMY = 0,    /// Dummy index to make the CAmmoDef indices correct for the other ammo types.
	TF_AMMO_PRIMARY,
	TF_AMMO_SECONDARY,
	TF_AMMO_METAL,
	TF_AMMO_GRENADES1,
	TF_AMMO_GRENADES2,
	TF_AMMO_COUNT
};
stock void SetAmmoPackData(int pack, int type, int val)
{
	int offset = ((type * 4) + (FindDataMapInfo(pack, "m_vOriginalSpawnAngles") + 20));

	SetEntData(pack, offset, val, _, true);
}
stock void PrepareSoundDir(bool valve = false, char[] dir = "sound")
{
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	int len;
	l.GetNext(buffer, sizeof(buffer));
	
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;
		
		if (type == FileType_Directory) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareSoundDir(valve, buffer);
		} else if (type == FileType_File) {
			if ((len = strlen(buffer)) < 5)			/// .mp3, .wav, etc
				continue;
			
			if (StrContains(buffer[len-4], ".mp3") == -1 && StrContains(buffer[len-4], ".wav") == -1 && StrContains(buffer[len-4], ".ogg") == -1)		/// Don't think TF2 supports .ogg but w/e
				continue;
			
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
			
			if (!IsSoundPrecached(buffer[6]))	/// Offsets 'sound/'
				PrecacheSound(buffer[6]);
		}
	}
	delete l;
}
stock void PrepareModelDir(bool valve = false, char[] dir = "models")
{
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));
	
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;
		
		if (type == FileType_Directory) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareModelDir(valve, buffer);
		} else if (type == FileType_File) {
			if (strlen(buffer) < 5)
				continue;
			
			if (StrContains(buffer, ".dx80.vtx") == -1 && StrContains(buffer, ".dx90.vtx") == -1 && StrContains(buffer, ".mdl") == -1
			 && StrContains(buffer, ".phy") == -1 && StrContains(buffer, ".sw.vtx") == -1 && StrContains(buffer, ".vvd") == -1)
				continue;
			
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
			if (StrContains(buffer, ".mdl", false) != -1 && !IsModelPrecached(buffer))
				PrecacheModel(buffer);
		}
	}
	delete l;
}
stock void PrepareMaterialDir(bool valve = false, char[] dir = "materials")
{
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));
	
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if (buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false))
			continue;
		
		if (type == FileType_Directory) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareMaterialDir(valve, buffer);
		} else if (type == FileType_File) {
			if (strlen(buffer) < 5)
				continue;
			
			if (StrContains(buffer, ".vmt") == -1 && StrContains(buffer, ".vtf") == -1)
				continue;
			
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
		}
	}
	delete l;
}
stock char[] TF2_GetPlayerClassname(const int client, bool capitalize = false)
{
	char s[16];
	switch( TF2_GetPlayerClass(client) ) {
		case TFClass_Scout: s = "scout";
		case TFClass_Soldier: s = "soldier";
		case TFClass_Pyro: s = "pyro";
		case TFClass_DemoMan: s = "demoman";
		case TFClass_Medic: s = "medic";
		case TFClass_Heavy: s = "heavy";
		case TFClass_Pyro: s = "pyro";
		case TFClass_Spy: s = "spy";
		case TFClass_Engineer: s = "engineer";
	}
	
	if( capitalize )
		s[0] = CharToUpper(s[0]);
	return s;
}
stock int FindMatchingTeleporter(const int tele)
{
	if( !HasEntProp(tele, Prop_Send, "m_bMatchBuilding") )
		return;
	
	int offset = FindSendPropInfo("CObjectTeleporter", "m_bMatchBuilding")+4;
	return GetEntDataEnt2(tele, offset);
}
stock bool TF2_IsKillable(const int entity)
{
	bool bResult = true;
	if( 0 < entity <= MaxClients ) {
		if(TF2_IsPlayerInCondition(entity, TFCond_Ubercharged) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedHidden) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedCanteen)
		|| TF2_IsPlayerInCondition(entity, TFCond_Bonked)
		|| TF2_IsPlayerInCondition(entity, TFCond_PasstimeInterception))
		{
			bResult = false;
		}
	}
	if( GetEntProp(entity, Prop_Data, "m_takedamage") != 2 )
		bResult = false;
	
	return bResult;
}
stock int SetMetal(const int client, const int amount)
{
	int iMetalTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(client, iMetalTable + (4*3), 200, 4, true);
}
stock void SetActiveWep(const int client, const int wep)
{
	if( wep > MaxClients && IsValidEntity(wep) )
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
}
stock int GetRandomClient(bool balive=true, int team=0)
{
	int[] players = new int[MaxClients];
	int count;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;
		else if( balive && !IsPlayerAlive(i) )
			continue;
		else if( team && GetClientTeam(i) != team )
			continue;
		
		players[count++] = i;
	}
	return !count ? -1 : players[GetRandomInt(0, count-1)];
}
stock int GetThrower(const int ent)
{
	return IsValidEntity(ent) ? GetEntPropEnt(ent, Prop_Send, "m_hThrower") : -1;
}
/// CTFPlayer::GetObjectCount()
stock int TF2_GetObjectCount(int client)
{
	/// CUtlVector<CBaseObject*, CUtlMemory<CBaseObject*, int>>
	return GetEntData(client, FindSendPropInfo("CTFPlayer", "m_flMvMLastDamageTime") + 48 + 12);
}
/// CTFPlayer::GetObject(int)
stock int TF2_GetObject(int client, int objidx)
{
	/// 8568 linux
	/// 8560 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMvMLastDamageTime") + 48;
	Address m_aObjects = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(offset), NumberType_Int32));
	return LoadFromAddress(m_aObjects + view_as< Address >(4 * objidx), NumberType_Int32) & 0xFFF;
}
/// CTFPlayer::GetObjectOfType(int, int)
stock int TF2_GetObjectOfType(int client, TFObjectType objtype, TFObjectMode objmode = TFObjectMode_None, bool incdisposables = false)
{
	int numobjs = TF2_GetObjectCount(client);
	if (numobjs <= 0)
		return -1;

	int obj;
	int count;
	do
	{
		obj = TF2_GetObject(client, count);
		if (TF2_GetObjectType(obj) == objtype
		&& TF2_GetObjectMode(obj) == objmode
		&& !(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
		{
			return obj;
		}

	}	while ++count < numobjs;
	return -1;
}
/// CTFPlayer::GetNumObjects(int, int)
stock int TF2_GetNumObjects(int client, TFObjectMode objmode, TFObjectType objtype, bool incdisposables = false)
{
	int objects;
	int count;
	int objcount = TF2_GetObjectCount(client);
	int obj;
	if (objtype == view_as< TFObjectType >(-1))
	{
		while (count < objcount)
		{
			obj = TF2_GetObject(client, count);
			if (!(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
			{
				if (TF2_GetObjectMode(obj) == objmode)
					++objects;
			}
			++count;
		}
	}
	else
	{
		while (objcount > count)
		{
			obj = TF2_GetObject(client, count);
			if (!(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
			{
				if (TF2_GetObjectMode(obj) == objmode && TF2_GetObjectType(obj) == objtype)
					++objects;
			}
			++count;
		}
	}
	return objects;
}
