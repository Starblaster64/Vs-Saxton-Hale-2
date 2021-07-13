void InitializeForwards()
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		g_hForwards[i][OnCallDownloads] = new PrivateForward( ET_Event );
		g_hForwards[i][OnBossSelected] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnTouchPlayer] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnTouchBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossThink] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossModelTimer] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossDeath] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossEquipped] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossInitialized] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnMinionInitialized] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossPlayIntro] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossTakeDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnPlayerKilled] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnPlayerAirblasted] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnTraceAttack] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossMedicCall] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossTaunt] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossKillBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossJarated] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnMessageIntro] = new PrivateForward( ET_Event, Param_Cell, Param_String );
		g_hForwards[i][OnBossPickUpItem] = new PrivateForward( ET_Event, Param_Cell, Param_String );
		g_hForwards[i][OnVariablesReset] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnUberDeployed] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnUberLoop] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnMusic] = new PrivateForward( ET_Event, Param_String, Param_FloatByRef, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnRoundEndInfo] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
		g_hForwards[i][OnLastPlayer] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossHealthCheck] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
		g_hForwards[i][OnControlPointCapped] = new PrivateForward( ET_Event, Param_String, Param_Cell, Param_Array, Param_Cell );
		g_hForwards[i][OnPrepRedTeam] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnRedPlayerThink] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnPlayerHurt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossMenu] = new PrivateForward( ET_Ignore, Param_CellByRef, Param_Cell );
		g_hForwards[i][OnScoreTally] = new PrivateForward( ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef );
		g_hForwards[i][OnItemOverride] = new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_Cell, Param_CellByRef );

		/// OnBossDealDamage Specific Forwards.
		g_hForwards[i][OnBossDealDamage_OnStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitDefBuff] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitCritMmmph] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitMedic] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitDeadRinger] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitCloakedSpy] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitShield] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );

		/// OnBossTakeDamage Specific Forwards
		g_hForwards[i][OnBossTakeDamage_OnStabbed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnTelefragged] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnSwordTaunt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHeavyShotgun] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnSniped] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnThirdDegreed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitSword] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitFanOWar] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitCandyCane] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnMarketGardened] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnPowerJack] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnKatana] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnAmbassadorHeadshot] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnDiamondbackManmelterCrit] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHolidayPunch] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );

		g_hForwards[i][OnBossSuperJump] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossDoRageStun] = new PrivateForward( ET_Event, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnBossWeighDown] = new PrivateForward( ET_Event, Param_Cell );

		g_hForwards[i][OnRPSTaunt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossAirShotProj] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossGiveRage] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnBossCalcHealth] = new PrivateForward( ET_Single, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell );

		g_hForwards[i][OnBossTakeDamage_OnTriggerHurt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnMantreadsStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossThinkPost] = new PrivateForward( ET_Hook, Param_Cell );
		g_hForwards[i][OnBossEquippedPost] = new PrivateForward( ET_Hook, Param_Cell );
		g_hForwards[i][OnPlayerTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );

		g_hForwards[i][OnSoundHook] = new PrivateForward( ET_Event, Param_Cell, Param_String, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef );
		g_hForwards[i][OnRoundStart] = new PrivateForward( ET_Ignore, Param_Array, Param_Cell, Param_Array, Param_Cell );
		g_hForwards[i][OnHelpMenu] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
		g_hForwards[i][OnHelpMenuSelect] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnDrawGameTimer] = new PrivateForward( ET_Hook, Param_CellByRef );
		g_hForwards[i][OnPlayerClimb] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_FloatByRef, Param_CellByRef );
		g_hForwards[i][OnBossConditionChange] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnBannerDeployed] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell );
		g_hForwards[i][OnBannerEffect] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnUberLoopEnd] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef );
	}
}

Action Call_OnCallDownloads()
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnCallDownloads]);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossSelected(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossSelected]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnTouchPlayer(const BaseBoss boss, const BaseBoss otherguy)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTouchPlayer]);
		Call_PushCell(boss);
		Call_PushCell(otherguy);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTouchBuilding]);
		Call_PushCell(player);
		Call_PushCell(buildRef);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossThink(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossThink]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossModelTimer(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossModelTimer]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossDeath(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDeath]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossEquipped(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossEquipped]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossInitialized(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossInitialized]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnMinionInitialized(const BaseBoss player, const BaseBoss master)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMinionInitialized]);
		Call_PushCell(player);
		Call_PushCell(master);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossPlayIntro(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossPlayIntro]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerKilled(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerKilled]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerAirblasted]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerHurt(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerHurt]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTraceAttack]);
		Call_PushCell(player);
		Call_PushCell(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(ammotype);
		Call_PushCell(hitbox);
		Call_PushCell(hitgroup);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossMedicCall(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossMedicCall]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTaunt(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTaunt]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossKillBuilding]);
		Call_PushCell(player);
		Call_PushCell(building);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossJarated(const BaseBoss victim, const int attacker)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossJarated]);
		Call_PushCell(attacker);
		Call_PushCell(victim);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnMessageIntro(const BaseBoss player, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMessageIntro]);
		Call_PushCell(player);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossPickUpItem]);
		Call_PushCell(player);
		Call_PushString(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnVariablesReset(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnVariablesReset]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnUberDeployed(const BaseBoss medic, const BaseBoss target)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnUberDeployed]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnUberLoop(const BaseBoss medic, const BaseBoss target)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnUberLoop]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const BaseBoss player, float& vol)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMusic]);
		Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_PushCell(player);
		Call_PushFloatRef(vol);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRoundEndInfo]);
		Call_PushCell(player);
		Call_PushCell(bosswin);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnLastPlayer(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnLastPlayer]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossHealthCheck(const BaseBoss player, const bool isBoss, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossHealthCheck]);
		Call_PushCell(player);
		Call_PushCell(isBoss);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team, BaseBoss[] bcappers, const int capper_count)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnControlPointCapped]);
		Call_PushString(cappers);
		Call_PushCell(team);
		Call_PushArrayEx(bcappers, capper_count, SM_PARAM_COPYBACK);
		Call_PushCell(capper_count);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPrepRedTeam(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPrepRedTeam]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnRedPlayerThink(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRedPlayerThink]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
void Call_OnBossMenu(Menu& menu, const BaseBoss player)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossMenu]);
		Call_PushCellRef(menu);
		Call_PushCell(player);
		Call_Finish();
	}
}
Action Call_OnScoreTally(const BaseBoss player, int& points_earned, int& queue_earned)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnScoreTally]);
		Call_PushCell(player);
		Call_PushCellRef(points_earned);
		Call_PushCellRef(queue_earned);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnItemOverride(const BaseBoss player, const char[] classname, int itemdef, Handle& item)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnItemOverride]);
		Call_PushCell(player);
		Call_PushString(classname);
		Call_PushCell(itemdef);
		Call_PushCellRef(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnStomp]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitDefBuff(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitDefBuff]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitCritMmmph(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitCritMmmph]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitMedic(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitMedic]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitDeadRinger(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitDeadRinger]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitCloakedSpy(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitCloakedSpy]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitShield(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDealDamage_OnHitShield]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}


/// OnBossTakeDamage forwards.
Action Call_OnBossTakeDamage_OnStabbed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnStabbed]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnTelefragged(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnTelefragged]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnSwordTaunt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnSwordTaunt]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHeavyShotgun(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnHeavyShotgun]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnSniped(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnSniped]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnThirdDegreed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnThirdDegreed]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitSword(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnHitSword]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitFanOWar(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnHitFanOWar]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitCandyCane(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnHitCandyCane]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnMarketGardened(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnMarketGardened]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnPowerJack(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnPowerJack]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnKatana(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnKatana]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnAmbassadorHeadshot(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnAmbassadorHeadshot]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnDiamondbackManmelterCrit]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHolidayPunch(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnHolidayPunch]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossSuperJump(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossSuperJump]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossDoRageStun(const BaseBoss player, float& distance)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDoRageStun]);
		Call_PushCell(player);
		Call_PushFloatRef(distance);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossWeighDown(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossWeighDown]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnRPSTaunt(const BaseBoss loser, const BaseBoss winner)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRPSTaunt]);
		Call_PushCell(loser);
		Call_PushCell(winner);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossAirShotProj(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossAirShotProj]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeFallDamage]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossGiveRage(const BaseBoss player, const int damage, float& calcd_rage)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossGiveRage]);
		Call_PushCell(player);
		Call_PushCell(damage);
		Call_PushFloatRef(calcd_rage);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossCalcHealth(const BaseBoss player, int& max_health, const int boss_count, const int red_players)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossCalcHealth]);
		Call_PushCell(player);
		Call_PushCellRef(max_health);
		Call_PushCell(boss_count);
		Call_PushCell(red_players);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeDamage_OnTriggerHurt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnTriggerHurt]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeDamage_OnMantreadsStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTakeDamage_OnMantreadsStomp]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossThinkPost(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossThinkPost]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossEquippedPost(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossEquippedPost]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPlayerTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerTakeFallDamage]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnSoundHook(const BaseBoss player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnSoundHook]);
		Call_PushCell(player);
		Call_PushStringEx(sample, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushCellRef(channel);
		Call_PushFloatRef(volume);
		Call_PushCellRef(level);
		Call_PushCellRef(pitch);
		Call_PushCellRef(flags);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

void Call_OnRoundStart(BaseBoss[] bosses, const int boss_count, BaseBoss[] reds, const int red_count)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRoundStart]);
		Call_PushArrayEx(bosses, boss_count, SM_PARAM_COPYBACK);
		Call_PushCell(boss_count);

		Call_PushArrayEx(reds, red_count, SM_PARAM_COPYBACK);
		Call_PushCell(red_count);
		Call_Finish();
	}
}

void Call_OnHelpMenu(const BaseBoss player, Menu menu)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnHelpMenu]);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_Finish();
	}
}

void Call_OnHelpMenuSelect(const BaseBoss player, Menu menu, const int selection)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnHelpMenuSelect]);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_PushCell(selection);
		Call_Finish();
	}
}

Action Call_OnDrawGameTimer(int& time)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnDrawGameTimer]);
		Call_PushCellRef(time);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPlayerClimb(const BaseBoss player, const int weapon, float& upwardvel, float& health, bool& attackdelay)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerClimb]);
		Call_PushCell(player);
		Call_PushCell(weapon);
		Call_PushFloatRef(upwardvel);
		Call_PushFloatRef(health);
		Call_PushCellRef(attackdelay);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossConditionChange(const BaseBoss player, const TFCond cond, const bool removing)
{
	Action act[2];
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossConditionChange]);
		Call_PushCell(player);
		Call_PushCell(cond);
		Call_PushCell(removing);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

void Call_OnBannerDeployed(const BaseBoss owner, const int buff_type)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnBannerDeployed]);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}

void Call_OnBannerEffect(const BaseBoss player, const BaseBoss owner, const int buff_type)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnBannerEffect]);
		Call_PushCell(player);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}

void Call_OnUberLoopEnd(const BaseBoss medic, const BaseBoss target, float& reset_charge)
{
	for( int i; i<sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnUberLoopEnd]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_PushFloatRef(reset_charge);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}