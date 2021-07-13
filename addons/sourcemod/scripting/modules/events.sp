public Action ReSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int roundstate = g_vsh2.m_hGamemode.iRoundState;
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || roundstate==StateDisabled )
		return Plugin_Continue;

	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	if( player && IsClientInGame(player.index) ) {
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0");

		if( player.bIsBoss && (StateDisabled < roundstate < StateEnding) ) {
			if( GetClientTeam(player.index) != VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Boss);

			player.ConvertToBoss();    /// in base.sp
			if( player.iHealth <= 0 )
				player.iHealth = player.iMaxHealth;
		}

		if( !player.bIsBoss && (StateDisabled < roundstate < StateEnding) && !player.bIsMinion) {
			if( GetClientTeam(player.index) == VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Red);
			SetPawnTimer(PrepPlayers, 0.2, player);
		}
	}
	return Plugin_Continue;
}

public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState==StateDisabled )
		return Plugin_Continue;

	BaseBoss player = BaseBoss( event.GetInt("userid"), true );
	if( player && IsClientInGame(player.index) ) {
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0");

		if( player.bIsBoss && (StateDisabled < g_vsh2.m_hGamemode.iRoundState < StateEnding) ) {
			if( GetClientTeam(player.index) != VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Boss);
			player.ConvertToBoss();		/// in base.sp
		}
	}
	return Plugin_Continue;
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	/// Bug patch: first round kill immediately ends the round.
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState==StateDisabled )
		return Plugin_Continue;

	BaseBoss victim = BaseBoss( event.GetInt("userid"), true );
	BaseBoss fighter = BaseBoss( event.GetInt("attacker"), true );
	ManageBossKillPlayer(fighter, victim, event);

	/// Patch: Don't want multibosses playing last-player sound clips when a BOSS dies...
	if( !victim.bIsBoss && !victim.bIsMinion )
		SetPawnTimer(CheckAlivePlayers, 0.2);

	int death_flags = event.GetInt("death_flags");
	if( (g_vsh2.m_hGamemode.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue)
		&& !victim.bIsBoss
		&& !victim.bIsMinion
		&& victim.iLives
		&& g_vsh2.m_hGamemode.iRoundState==StateRunning
		&& !(death_flags & TF_DEATHFLAG_DEADRINGER) )
	{
		SetPawnTimer(_RespawnPlayer, g_vsh2.m_hCvars.MedievalRespawnTime.FloatValue, victim.userid);
		victim.iLives--;
	}

	if( victim.GetTFClass() == TFClass_Engineer && !(death_flags & TF_DEATHFLAG_DEADRINGER) ) {
		if( g_vsh2.m_hCvars.EngieBuildings.IntValue > 0 ) {
			switch( g_vsh2.m_hCvars.EngieBuildings.IntValue ) {
				case 1: {
					int sentry = FindSentry(victim.index);
					if( sentry != -1 ) {
						SetVariantInt(GetEntProp(sentry, Prop_Send, "m_iMaxHealth")+8);
						AcceptEntityInput(sentry, "RemoveHealth");
					}
				}
				case 2: {
					for( int ent=MaxClients+1; ent<2048; ++ent ) {
						if( !IsValidEntity(ent) || !HasEntProp(ent, Prop_Send, "m_hBuilder") )
							continue;
						else if( GetBuilder(ent) != victim.index )
							continue;

						SetVariantInt(GetEntProp(ent, Prop_Send, "m_iMaxHealth")+8);
						AcceptEntityInput(ent, "RemoveHealth");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;

	BaseBoss victim = BaseBoss( event.GetInt("userid"), true );
	/*
	if( victim.bIsBoss ) {
		int damage = event.GetInt("damageamount");
		victim.iHealth -= damage;
	}
	*/

	/// make sure the attacker is valid so we can set him/her as BaseBoss instance
	int attacker = GetClientOfUserId( event.GetInt("attacker") );
	if( victim.index == attacker || attacker <= 0 )
		return Plugin_Continue;

	BaseBoss boss = BaseBoss( event.GetInt("attacker"), true );
	ManageHurtPlayer(boss, victim, event);
	return Plugin_Continue;
}

public Action DelaySpawn(BaseBoss boss)
{
	/// check if they preset something and if its not the same boss
	if( boss.iPresetType > -1 && boss.iBossType != boss.iPresetType ) {
		boss.flCharge = 0.0; /// bugfix: HHHjr sets this to negative value, reset to 0
		boss.iBossType = boss.iPresetType;
		ManageOnBossSelected(boss);
		boss.ConvertToBoss();
		boss.iPresetType = -1; /// they got what they wanted now reset this var
	}
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
#if defined _steamtools_included
		Steam_SetGameDescription("Team Fortress");
#endif
		return Plugin_Continue;
	}
	StopBackGroundMusic();
	g_vsh2.m_hGamemode.bMedieval = (FindEntityByClassname(-1, "tf_logic_medieval") != -1 || FindConVar("tf_medieval").BoolValue);
	VSHGameMode.CheckArena(g_vsh2.m_hCvars.PointType.BoolValue);
	g_vsh2.m_hGamemode.bPointReady = false;
	g_vsh2.m_hGamemode.iTimeLeft = 0;
	g_vsh2.m_hGamemode.iCaptures = 0;
	g_vsh2.m_hGamemode.iPrevSpecial = g_vsh2.m_hGamemode.iSpecial;
	g_vsh2.m_hGamemode.GetBossType();    /// in gamemode.sp
	
	int playing;
	for( int iplay=MaxClients; iplay; --iplay ) {
		if( !IsValidClient(iplay) || !IsClientInGame(iplay) )
			continue;

		ManageResetVariables(BaseBoss(iplay));    /// in handler.sp
		if( GetClientTeam(iplay) > VSH2Team_Spectator )
			++playing;
	}
	if( GetClientCount() <= 1 || playing < 2 ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Need more Players to Commence");
		g_vsh2.m_hGamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(60.0);
		//SetPawnTimer(EnableCap, 71.0, g_vsh2.m_hGamemode.bDoors);
		return Plugin_Continue;
	} else if( g_vsh2.m_hGamemode.iRoundCount <= 0 && !g_vsh2.m_hCvars.FirstRound.BoolValue ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Normal Round while Everybody is Loading");
		g_vsh2.m_hGamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(60.0);
		FindConVar("mp_teams_unbalance_limit").IntValue = 1;
		FindConVar("mp_forceautoteam").IntValue = 1;
		//SetPawnTimer(EnableCap, 71.0, g_vsh2.m_hGamemode.bDoors);
		return Plugin_Continue;
	}
	
	FindConVar("mp_teams_unbalance_limit").IntValue = 0;
	FindConVar("mp_forceautoteam").IntValue = 0;
	
	BaseBoss boss = VSHGameMode.FindNextBoss();
	if( boss.index <= 0 ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Boss client index was Invalid. Need more Players to Commence");
		g_vsh2.m_hGamemode.iRoundState = StateDisabled;
		SetControlPoint(true);
		return Plugin_Continue;
	} else if( g_vsh2.m_hGamemode.hNextBoss ) {
		boss = g_vsh2.m_hGamemode.hNextBoss;
		g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
	}
	
	/// Got our boss, let's prep him/her.
	boss.iBossType = g_vsh2.m_hGamemode.iSpecial;
	
	/// Setting this here so we can intercept Boss type and other info
	ManageOnBossSelected(boss);
	boss.ConvertToBoss();
	g_vsh2.m_hGamemode.iSpecial = -1;
	
	float snddelay = 3.5; /// this is the default value for delay on the boss intro line
	if( g_vsh2.m_hCvars.PreRoundSetBoss.BoolValue ) {
		/// If player has used /setboss before round started, swap their boss to their new selection
		SetPawnTimer(DelaySpawn, 8.5, boss);

		/// add 7 seconds to delay the sound until round has started
		snddelay += 7.0;
	}
	
	if( GetClientTeam(boss.index) != VSH2Team_Boss )
		boss.ForceTeamChange(VSH2Team_Boss);
	
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || GetClientTeam(i) <= VSH2Team_Spectator )
			continue;
		
		player = BaseBoss(i);
		if( player.bIsBoss )
			continue;
		
		/// Forceteamchange does respawn.
		if( GetClientTeam(i) == VSH2Team_Boss )
			player.ForceTeamChange(VSH2Team_Red);
	}
	
	/// We got players and a valid boss, set the gamestate to Starting
	g_vsh2.m_hGamemode.iRoundState = StateStarting;
	//SetPawnTimer(RoundStartPost, 9.1);    /// in handler.sp
	SetPawnTimer(ManagePlayBossIntro, snddelay, boss);    /// in handler.sp
	
	int ent = -1;
	while( (ent = FindEntityByClassname(ent, "func_regenerate")) != -1 )
		AcceptEntityInput(ent, "Disable");
	
	ent = -1;
	while( (ent = FindEntityByClassname(ent, "func_respawnroomvisualizer")) != -1 )
		AcceptEntityInput(ent, "Disable");
	
	ent = -1;
	while( (ent = FindEntityByClassname(ent, "obj_dispenser")) != -1 ) {
		SetVariantInt(VSH2Team_Red);
		AcceptEntityInput(ent, "SetTeam");
		AcceptEntityInput(ent, "skin");
		SetEntProp(ent, Prop_Send, "m_nSkin", 0);
	}
	
	ent = -1;
	while( (ent = FindEntityByClassname(ent, "mapobj_cart_dispenser")) != -1 ) {
		SetVariantInt(VSH2Team_Red);
		AcceptEntityInput(ent, "SetTeam");
		AcceptEntityInput(ent, "skin");
	}
	VSHGameMode.SearchForItemPacks();
	g_vsh2.m_hGamemode.iHealthChecks = 0;
	return Plugin_Continue;
}

public Action ObjectDeflected(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	BaseBoss airblaster = BaseBoss( event.GetInt("userid"), true );
	BaseBoss airblasted = BaseBoss( event.GetInt("ownerid"), true );
	
	/// number lower or higher than 0 is considered "true", learned that in C programming lol
	int weaponid = event.GetInt("weaponid");
	if( weaponid )
		return Plugin_Continue;
	
	ManagePlayerAirblast(airblaster, airblasted, event);
	return Plugin_Continue;
}

public Action ObjectDestroyed(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	BaseBoss boss = BaseBoss(event.GetInt("attacker"), true);
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");
	ManageBuildingDestroyed(boss, building, objecttype, event);
	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;
	
	BaseBoss victim = BaseBoss( event.GetInt("userid"), true );
	int attacker = event.GetInt("attackerid");
	ManageBossJarated(victim, attacker);
	return Plugin_Continue;
}

public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_vsh2.m_hGamemode.iRoundCount++;
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState == StateDisabled )
		return Plugin_Continue;
	
	g_vsh2.m_hGamemode.iRoundState = StateEnding;
	g_vsh2.m_hGamemode.flMusicTime = 0.0;
	BaseBoss boss;
	int i;
	for( i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;
#if defined _tf2attributes_included
		if( g_vsh2.m_hGamemode.bTF2Attribs )
			TF2Attrib_RemoveByDefIndex(i, 26);
#endif
	}
	StopBackGroundMusic();         /// in handler.sp
	ShowPlayerScores();            /// In vsh2.sp
	SetPawnTimer(CalcScores, 3.0); /// In vsh2.sp

	ArrayList bosses = new ArrayList();
	for( i=MaxClients; i; --i ) {    /// Loop again for bosses only
		if( !IsValidClient(i) )
			continue;

		boss = BaseBoss(i);
		if( !boss.bIsBoss )
			continue;

		if( !IsPlayerAlive(i) ) {
			if( GetClientTeam(i) != VSH2Team_Boss )
				boss.ForceTeamChange(VSH2Team_Boss);
		}
		else bosses.Push(boss); /// Only living bosses are counted
	}
	ManageRoundEndBossInfo(bosses, (event.GetInt("team") == VSH2Team_Boss));
	/*
	int teamroundtimer = FindEntityByClassname(-1, "team_round_timer");
	if( teamroundtimer && IsValidEntity(teamroundtimer) )
		AcceptEntityInput(teamroundtimer, "Kill");
	*/
	return Plugin_Continue;
}

public void OnExplosiveJump(Event event, const char[] name, bool dontBroadcast)
{
	BaseBoss(event.GetInt("userid"), true).bInJump = StrEqual(name, "rocket_jump", false) || StrEqual(name, "sticky_jump", false);
}

public Action ItemPickedUp(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Continue;

	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	char item[64]; event.GetString("item", item, sizeof(item));
	ManageBossPickUpItem(player, item);	/// In handler.sp
	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState == StateDisabled)
		return Plugin_Continue;

	BaseBoss medic = BaseBoss(event.GetInt("userid"), true);
	BaseBoss patient = BaseBoss(event.GetInt("targetid"), true);
	ManageUberDeploy(medic, patient);    /// In handler.sp
	return Plugin_Continue;
}

public Action ArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState == StateDisabled )
		return Plugin_Continue;

	BaseBoss boss;
	int i;    /// Count amount of bosses for health calculation!
	for( i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) <= VSH2Team_Spectator )
			continue;
		
		boss = BaseBoss(i);
		if( !boss.bIsBoss ) {
			SetEntityMoveType(i, MOVETYPE_WALK);
			
			/// For good measure!
			if( GetClientTeam(i) != VSH2Team_Red && GetClientTeam(i) > VSH2Team_Spectator )
				boss.ForceTeamChange(VSH2Team_Red);
			SetPawnTimer(PrepPlayers, 0.2, boss.userid);    /// in handler.sp
		}
	}
	g_vsh2.m_hGamemode.iTotalMaxHealth = 0;
	int bosscount = VSHGameMode.CountBosses(false);

	/// Loop again for bosses only
	ArrayList bosses = new ArrayList();
	for( i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;

		boss = BaseBoss(i);
		if( !boss.bIsBoss )
			continue;

		boss.iQueue = 0;
		bosses.Push(boss);
		if( !IsPlayerAlive(i) )
			TF2_RespawnPlayer(i);

		int red_players = GetLivingPlayers(VSH2Team_Red);
		/// Automatically divides health based on boss count but this can be changed if necessary

		int max_health = CalcBossHealth(760.8, red_players, 1.0, 1.0341, 2046.0) / (bosscount);    /// In stocks.sp
		if( max_health < 3000 && bosscount==1 )
			max_health = 3000;

		/// Putting in multiboss Handicap from complaints of fighting multiple bosses being too overpowered since teamwork itself is overpowered :)
		else if( max_health > 3000 && bosscount > 1 )
			max_health -= g_vsh2.m_hCvars.MultiBossHandicap.IntValue;

		Action act = Call_OnBossCalcHealth(boss, max_health, bosscount, red_players);
		if( act > Plugin_Changed )
			continue;

		boss.iMaxHealth = max_health;
		if( GetClientTeam(boss.index) != VSH2Team_Boss )
			boss.ForceTeamChange(VSH2Team_Boss);
		g_vsh2.m_hGamemode.iTotalMaxHealth += boss.iMaxHealth;
		boss.iHealth = boss.iMaxHealth;
	}
	RequestFrame(CheckAlivePlayers, 0);
	//SetPawnTimer(CheckAlivePlayers, 0.2);
	ManageMessageIntro(bosses);
	if( GetLivingPlayers(VSH2Team_Red) > 5 )
		SetControlPoint(false);
	g_vsh2.m_hGamemode.flHealthTime = GetGameTime() + g_vsh2.m_hCvars.HealthCheckInitialDelay.FloatValue;

	BaseBoss[] b = new BaseBoss[MaxClients];
	int boss_count = VSHGameMode.GetBosses(b, true);
	BaseBoss[] r = new BaseBoss[MaxClients];
	int red_count = VSHGameMode.GetFighters(r, true);
	Call_OnRoundStart(b, boss_count, r, red_count);

	return Plugin_Continue;
}

public Action PointCapture(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning || !g_vsh2.m_hCvars.MultiCapture.BoolValue )
		return Plugin_Continue;

	// int iCap = event.GetInt("cp"); /// Doesn't seem to give the correct origin vectors
	int iCapTeam = event.GetInt("team");
	g_vsh2.m_hGamemode.iCaptures++;

	if( g_vsh2.m_hGamemode.iCaptures >= g_vsh2.m_hCvars.MultiCapAmount.IntValue ||
		(GetLivingPlayers(VSH2Team_Red) == 1 && iCapTeam == VSH2Team_Red) )
	{
		ForceTeamWin(iCapTeam);
		return Plugin_Continue;
	}
	_SetCapOwner(VSH2Team_Neutral, g_vsh2.m_hGamemode.bDoors, g_vsh2.m_hCvars.CapReenableTime.FloatValue); /// in stocks.inc

	/// TODO: replace index string with BaseBoss array + size.
	char sCappers[MAXPLAYERS+1];

	event.GetString("cappers", sCappers, MAXPLAYERS);

	int capper_count = strlen(sCappers);
	BaseBoss[] cappers = new BaseBoss[capper_count];
	for( int i; i<capper_count; i++ ) {
		int client = sCappers[i];
		cappers[i] = BaseBoss(client);
	}
	ManageOnBossCap(sCappers, iCapTeam, cappers, capper_count);
	return Plugin_Continue;
}

public Action RPSTaunt(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Continue;

	BaseBoss winner = BaseBoss(event.GetInt("winner"));
	BaseBoss loser = BaseBoss(event.GetInt("loser"));
	if( !winner || !loser )
		return Plugin_Continue;

	return Call_OnRPSTaunt(loser, winner);
}

public Action DeployBuffBanner(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Continue;

	int buff_type = event.GetInt("buff_type");
	BaseBoss owner = BaseBoss(event.GetInt("buff_owner"), true);
	Call_OnBannerDeployed(owner, buff_type);
	return Plugin_Continue;
}

public Action OnPlayerBuff(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Continue;

	int buff_type = event.GetInt("buff_type");
	BaseBoss owner = BaseBoss(event.GetInt("buff_owner"), true);
	BaseBoss buffed_player = BaseBoss(event.GetInt("userid"), true);
	Call_OnBannerEffect(buffed_player, owner, buff_type);
	return Plugin_Continue;
}