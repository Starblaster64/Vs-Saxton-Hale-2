public Action ReSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss player = BaseBoss( event.GetInt("userid"), true );
	if( player && IsClientInGame(player.index) ) {
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0"); //SetClientOverlay(client, "0");
		
		if( player.bIsBoss && gamemode.iRoundState < StateEnding && gamemode.iRoundState != StateDisabled )
		{
			if( GetClientTeam(player.index) != VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Boss);
			player.ConvertToBoss();		/// in base.sp
			if( player.iHealth <= 0 )
				player.iHealth = player.iMaxHealth;
		}
		
		if( !player.bIsBoss && StateDisabled < gamemode.iRoundState < StateEnding && !player.bIsMinion) {
			if( GetClientTeam(player.index) == VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Red);
			SetPawnTimer( PrepPlayers, 0.2, player );
		}
	}
	return Plugin_Continue;
}
public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss player = BaseBoss( event.GetInt("userid"), true );
	if( player && IsClientInGame(player.index) ) {
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0"); //SetClientOverlay(client, "0");

		if( player.bIsBoss && gamemode.iRoundState < StateEnding && gamemode.iRoundState != StateDisabled )
		{
			if( GetClientTeam(player.index) != VSH2Team_Boss )
				player.ForceTeamChange(VSH2Team_Boss);
			player.ConvertToBoss();		/// in base.sp
		}
	}
	return Plugin_Continue;
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue || gamemode.iRoundState == StateDisabled )	/// Bug patch: first round kill immediately ends the round.
		return Plugin_Continue;

	BaseBoss victim = BaseBoss( event.GetInt("userid"), true );
	BaseBoss fighter = BaseBoss( event.GetInt("attacker"), true );

	//if( fighter.bIsBoss && !player.bIsBoss )	/// If Boss is killer and victim is not a Boss
	ManageBossKillPlayer(fighter, victim, event);

	//if( fighter.bIsBoss && victim.bIsBoss )	/// clash of the titans - when both killer and victim are Bosses


	if( !victim.bIsBoss && !victim.bIsMinion )	/// Patch: Don't want multibosses playing last-player sound clips when a BOSS dies...
		SetPawnTimer(CheckAlivePlayers, 0.2);
	
	if( (gamemode.bMedieval || cvarVSH2[ForceLives].BoolValue)
		&& !victim.bIsBoss
		&& !victim.bIsMinion
		&& victim.iLives
		&& gamemode.iRoundState == StateRunning
		&& !(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
		SetPawnTimer(_RespawnPlayer, cvarVSH2[MedievalRespawnTime].FloatValue, victim.userid);
		victim.iLives--;
	}
	
	if( (TF2_GetPlayerClass(victim.index) == TFClass_Engineer) && !(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
		if( cvarVSH2[EngieBuildings].IntValue ) {
			switch( cvarVSH2[EngieBuildings].IntValue ) {
				case 1: {
					int sentry = FindSentry(victim.index);
					if( sentry != -1 ) {
						SetVariantInt(GetEntProp(sentry, Prop_Send, "m_iMaxHealth")+8);
						AcceptEntityInput(sentry, "RemoveHealth");
					}
				}
				case 2: {
					for( int ent=MaxClients+1; ent<2048; ++ent ) {
						if( !IsValidEdict(ent) ) 
							continue;
						else if( !HasEntProp(ent, Prop_Send, "m_hBuilder") )
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
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss victim = BaseBoss( event.GetInt("userid"), true );
	int attacker = GetClientOfUserId( event.GetInt("attacker") );
	//int damage = event.GetInt("damageamount");

	/// make sure the attacker is valid so we can set him/her as BaseBoss instance
	if( victim.index == attacker || attacker <= 0 )
		return Plugin_Continue;

	BaseBoss boss = BaseBoss( event.GetInt("attacker"), true );
	ManageHurtPlayer(boss, victim, event);
	//if( player.bIsBoss )
	//	player.iHealth -= damage;
	return Plugin_Continue;
}
public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue ) {
#if defined _steamtools_included
		Steam_SetGameDescription("Team Fortress");
#endif
		return Plugin_Continue;
	}
	/*if( gamemode.hMusic != null ) {
		KillTimer(gamemode.hMusic);
		gamemode.hMusic = null;
	}*/
	StopBackGroundMusic();
	gamemode.bMedieval = (FindEntityByClassname(-1, "tf_logic_medieval") != -1 || FindConVar("tf_medieval").BoolValue);
	gamemode.CheckArena(cvarVSH2[PointType].BoolValue);
	gamemode.bPointReady = false;
	gamemode.iTimeLeft = 0;
	gamemode.iCaptures = 0;
	gamemode.GetBossType();    /// in gamemode.sp

	int playing;
	for( int iplay=MaxClients; iplay; --iplay ) {
		if( !IsClientInGame(iplay) )
			continue;
		
		ManageResetVariables(BaseBoss(iplay));    /// in handler.sp
		if( GetClientTeam(iplay) > VSH2Team_Spectator )
			++playing;
	}
	if( GetClientCount() <= 1 || playing < 2 ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Need more Players to Commence");
		gamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(60.0);
		SetPawnTimer(EnableCap, 71.0, gamemode.bDoors);
		return Plugin_Continue;
	}
	else if( gamemode.iRoundCount <= 0 && !cvarVSH2[FirstRound].BoolValue ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Normal Round while Everybody is Loading");
		gamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(60.0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 1);
		SetConVarInt(FindConVar("mp_forceautoteam"), 1);
		SetPawnTimer(EnableCap, 71.0, gamemode.bDoors);
		return Plugin_Continue;
	}
	
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
	SetConVarInt(FindConVar("mp_forceautoteam"), 0);
	
	BaseBoss boss = gamemode.FindNextBoss();
	if( boss.index <= 0 ) {
		CPrintToChatAll("{olive}[VSH 2]{default} Boss client index was Invalid. Need more Players to Commence");
		gamemode.iRoundState = StateDisabled;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	else if( gamemode.hNextBoss ) {
		boss = gamemode.hNextBoss;
		gamemode.hNextBoss = view_as< BaseBoss >(0);
	}

	/// Got our boss, let's prep him/her.
	boss.bSetOnSpawn = true;
	boss.iBossType = gamemode.iSpecial;
	
	/// Setting this here so we can intercept Boss type and other info
	ManageOnBossSelected(boss);
	boss.ConvertToBoss();
	gamemode.iSpecial = -1;
	
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
	gamemode.iRoundState = StateStarting;
	//SetPawnTimer(RoundStartPost, 9.1);	 /// in handler.sp
	SetPawnTimer(ManagePlayBossIntro, 3.5, boss);    /// in handler.sp
	
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
	gamemode.SearchForItemPacks();
	gamemode.iHealthChecks = 0;
	return Plugin_Continue;
}
public Action ObjectDeflected(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss airblaster = BaseBoss( event.GetInt("userid"), true );
	BaseBoss airblasted = BaseBoss( event.GetInt("ownerid"), true );
	int weaponid = GetEventInt(event, "weaponid");
	if( weaponid )   /// number lower or higher than 0 is considered "true", learned that in C programming lol
		return Plugin_Continue;

	ManagePlayerAirblast(airblaster, airblasted, event);
	return Plugin_Continue;
}

public Action ObjectDestroyed(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss boss = BaseBoss(event.GetInt("attacker"), true);
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");

	ManageBuildingDestroyed(boss, building, objecttype, event);
	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;

	BaseBoss jarateer = BaseBoss(event.GetInt("thrower_entindex"), true);
	BaseBoss jarateed = BaseBoss(event.GetInt("victim_entindex"), true);
	ManagePlayerJarated(jarateer, jarateed);

	return Plugin_Continue;
}
public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	gamemode.iRoundCount++;
	
	if( !bEnabled.BoolValue || gamemode.iRoundState == StateDisabled )
		return Plugin_Continue;

	gamemode.iRoundState = StateEnding;
	gamemode.flMusicTime = 0.0;
	BaseBoss boss;
	int i;
	for( i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;
#if defined _tf2attributes_included
		if( gamemode.bTF2Attribs )
			TF2Attrib_RemoveByDefIndex(i, 26);
#endif
		//PrintToConsole(i, "resetting boss hp.");
	}
	StopBackGroundMusic();	/// in handler.sp
	
	ShowPlayerScores();	/// In vsh2.sp
	SetPawnTimer(CalcScores, 3.0);	/// In vsh2.sp
	
	ArrayList bosses = new ArrayList();
	for( i=MaxClients; i; --i ) {	/// Loop again for bosses only
		if( !IsValidClient(i) )
			continue;

		boss = BaseBoss(i);
		if( !boss.bIsBoss )
			continue;

		if( !IsPlayerAlive(i) ) {
			if( GetClientTeam(i) != VSH2Team_Boss/*gamemode.iHaleTeam*/ )
				boss.ForceTeamChange(VSH2Team_Boss);
		}
		else bosses.Push(boss); //bosses[index++] = boss;	/// Only living bosses are counted
	}
	ManageRoundEndBossInfo(bosses, (event.GetInt("team") == VSH2Team_Boss));
	/*
	int teamroundtimer = FindEntityByClassname(-1, "team_round_timer");
	if( teamroundtimer && IsValidEntity(teamroundtimer) )
		AcceptEntityInput(teamroundtimer, "Kill");
	*/
	return Plugin_Continue;
}
public void OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	BaseBoss(event.GetInt("userid"), true).bInJump = StrEqual(name, "rocket_jump", false);
}
public Action ItemPickedUp(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue || gamemode.iRoundState != StateRunning )
		return Plugin_Continue;
	
	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	char item[64]; event.GetString("item", item, sizeof(item));
	ManageBossPickUpItem(player, item);	/// In handler.sp
	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue || gamemode.iRoundState == StateDisabled)
		return Plugin_Continue;
	
	BaseBoss medic = BaseBoss(event.GetInt("userid"), true);
	BaseBoss patient = BaseBoss(event.GetInt("targetid"), true);
	ManageUberDeploy(medic, patient);	/// In handler.sp
	return Plugin_Continue;
}
public Action ArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue || gamemode.iRoundState == StateDisabled )
		return Plugin_Continue;
	
	BaseBoss boss;
	int i;	/// Count amount of bosses for health calculation!
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
	gamemode.iTotalMaxHealth = 0;
	int bosscount = gamemode.CountBosses(false);
	
	/// Loop again for bosses only
	ArrayList bosses = new ArrayList();
	for( i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;

		boss = BaseBoss(i);
		if( !boss.bIsBoss )
			continue;

		bosses.Push(boss);
		if( !IsPlayerAlive(i) )
			TF2_RespawnPlayer(i);
		
		/// Automatically divides health based on boss count but this can be changed if necessary
		boss.iMaxHealth = CalcBossHealth(760.8, gamemode.iPlaying, 1.0, 1.0341, 2046.0) / (bosscount);	/// In stocks.sp
		if( boss.iMaxHealth < 3000 && bosscount == 1 )
			boss.iMaxHealth = 3000;
		
		/// Putting in multiboss Handicap from complaints of fighting multiple bosses being too overpowered since teamwork itself is overpowered :).
		else if( boss.iMaxHealth > 3000 && bosscount > 1 )
			boss.iMaxHealth -= cvarVSH2[MultiBossHandicap].IntValue;
#if defined _tf2attributes_included
		int maxhp = GetEntProp(boss.index, Prop_Data, "m_iMaxHealth");
		if( gamemode.bTF2Attribs ) {
			TF2Attrib_RemoveAll(boss.index);
			TF2Attrib_SetByDefIndex( boss.index, 26, float(boss.iMaxHealth-maxhp) );
		}
#endif
		if( GetClientTeam(boss.index) != VSH2Team_Boss )
			boss.ForceTeamChange(VSH2Team_Boss);
		gamemode.iTotalMaxHealth += boss.iMaxHealth;
		boss.iHealth = boss.iMaxHealth;
	}
	SetPawnTimer(CheckAlivePlayers, 0.2);
	ManageMessageIntro(bosses);
	if( gamemode.iPlaying > 5 )
		SetControlPoint(false);
	gamemode.flHealthTime = GetGameTime() + cvarVSH2[HealthCheckInitialDelay].FloatValue;
	return Plugin_Continue;
}

public Action PointCapture(Event event, const char[] name, bool dontBroadcast)
{
	if( !bEnabled.BoolValue || gamemode.iRoundState != StateRunning || !cvarVSH2[MultiCapture].BoolValue )
		return Plugin_Continue;
	
	// int iCap = GetEventInt(event, "cp"); /// Doesn't seem to give the correct origin vectors
	
	int iCapTeam = event.GetInt("team");
	gamemode.iCaptures++;
	
	if( gamemode.iCaptures >= cvarVSH2[MultiCapAmount].IntValue ||
		(GetLivingPlayers(VSH2Team_Red) == 1 && iCapTeam == VSH2Team_Red) )
	{
		ForceTeamWin(iCapTeam);
		return Plugin_Continue;
	}
	_SetCapOwner(VSH2Team_Neutral, gamemode.bDoors); /// in stocks.inc
	
	char sCappers[MAXPLAYERS+1];
	event.GetString("cappers", sCappers, MAXPLAYERS);
	ManageOnBossCap(sCappers, iCapTeam);
	return Plugin_Continue;
}
