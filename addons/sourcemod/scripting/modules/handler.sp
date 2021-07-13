/**
 * ALL NON-BOSS AND NON-MINION RELATED CODE IS AT THE BOTTOM. HAVE FUN CODING!
 */

#define MAXBOSS    (MaxDefaultVSH2Bosses + (g_modsys.m_hBossesRegistered.Length - 1))

#include "bosses.sp"

/**
	PLEASE REMEMBER THAT PLAYERS THAT DON'T HAVE THEIR BOSS ID'S SET ARE NOT ACTUAL BOSSES.
	THIS PLUGIN HAS BEEN SETUP SO THAT IF YOU BECOME A BOSS, YOU MUST HAVE A VALID BOSS ID.

	FOR MANAGEMENT FUNCTIONS, DO NOT HAVE THEM DISCRIMINATE WHO IS A BOSS OR NOT, SIMPLY CHECK 'iBossType' TO SEE IF IT REALLY WAS A BOSS PLAYER.
*/


public void ManageDownloads()
{
	Action act = Call_OnCallDownloads();    /// in forwards.sp
	if( act==Plugin_Stop )
		return;

	static char download_keys[][] = {
		"downloads.sounds",
		"downloads.models",
		"downloads.materials"
	};

	for( int i; i<sizeof(download_keys); i++ ) {
		ConfigMap download_map = g_vsh2.m_hCfg.GetSection(download_keys[i]);
		if( download_map != null ) {
			for( int n; n<download_map.Size; n++ ) {
				int value_size = download_map.GetIntKeySize(n);
				char[] filepath = new char[value_size];
				if( download_map.GetIntKey(n, filepath, value_size) ) {
					switch( i ) {
						case 0: PrepareSound(filepath);
						case 1: PrepareModel(filepath);
						case 2: PrepareMaterial(filepath);
					}
				}
			}
		}
	}

	char basic_sounds[][] = {
		"ui/item_store_add_to_cart.wav",
		"player/doubledonk.wav",
		"vo/announcer_am_capincite01.mp3",
		"vo/announcer_am_capincite03.mp3",
		"vo/announcer_am_capenabled02.mp3",
		"vo/announcer_ends_60sec.mp3",
		"vo/announcer_ends_30sec.mp3",
		"vo/announcer_ends_10sec.mp3",
		"vo/announcer_ends_1sec.mp3",
		"vo/announcer_ends_2sec.mp3",
		"vo/announcer_ends_3sec.mp3",
		"vo/announcer_ends_4sec.mp3",
		"vo/announcer_ends_5sec.mp3",
		"items/pumpkin_pickup.wav"
	};
	PrecacheSoundList(basic_sounds, sizeof(basic_sounds));
	//PrepareSound("saxton_hale/9000.wav");

	AddHaleToDownloads   ();
	AddVagToDownloads    ();
	AddCBSToDownloads    ();
	AddHHHToDownloads    ();
	AddBunnyToDownloads  ();
}

public void ManageMenu(Menu& menu, const int client)
{
	AddHaleToMenu(menu);
	AddVagToMenu(menu);
	AddCBSToMenu(menu);
	AddHHHToMenu(menu);
	AddBunnyToMenu(menu);
	Call_OnBossMenu(menu, BaseBoss(client));
}

public void ManageDisconnect(const int client)
{
	BaseBoss leaver = BaseBoss(client);
	if( leaver.index && leaver.bIsBoss ) {
		if( g_vsh2.m_hGamemode.iRoundState >= StateRunning ) {
			/// Arena mode flips out when no one is on the other team
			BaseBoss[] bosses = new BaseBoss[MaxClients];
			int numbosses = VSHGameMode.GetBosses(bosses, false);
			if( numbosses-1 > 0 ) { /// Exclude leaver, this is why CountBosses() can't be used
				for( int i=0; i<numbosses; i++ ) {
					if( bosses[i]==leaver || (IsClientValid(bosses[i].index) && IsPlayerAlive(bosses[i].index)) )
						continue;

					BaseBoss next = VSHGameMode.FindNextBoss();
					if( g_vsh2.m_hGamemode.hNextBoss ) {
						next = g_vsh2.m_hGamemode.hNextBoss;
						g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
					}
					if( IsValidClient(next.index) ) {
						next.bIsMinion = true;	/// Dumb hack, prevents spawn hook from forcing them back to red
						next.ForceTeamChange(VSH2Team_Boss);
					}

					if( g_vsh2.m_hGamemode.iRoundState == StateRunning )
						ForceTeamWin(VSH2Team_Red);
					break;
				}
			} else {	/// No bosses left
				BaseBoss next = VSHGameMode.FindNextBoss();
				if( g_vsh2.m_hGamemode.hNextBoss ) {
					next = g_vsh2.m_hGamemode.hNextBoss;
					g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
				}
				if( IsValidClient(next.index) ) {
					next.bIsMinion = true;
					next.ForceTeamChange(VSH2Team_Boss);
				}

				if( g_vsh2.m_hGamemode.iRoundState == StateRunning )
					ForceTeamWin(VSH2Team_Red);
			}
		} else if( g_vsh2.m_hGamemode.iRoundState == StateStarting ) {
			BaseBoss replace = VSHGameMode.FindNextBoss();
			if( g_vsh2.m_hGamemode.hNextBoss ) {
				replace = g_vsh2.m_hGamemode.hNextBoss;
				g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
			}
			if( IsValidClient(replace.index) ) {
				replace.MakeBossAndSwitch(replace.iPresetType == -1 ? leaver.iBossType : replace.iPresetType, true);
				CPrintToChat(replace.index, "{olive}[VSH 2]{green} Surprise! You're on NOW!");
			}
		}
		CPrintToChatAll("{olive}[VSH 2]{red} A Boss Just Disconnected!");
	} else {
		RequestFrame(CheckAlivePlayers, 0);
		if( client == VSHGameMode.FindNextBoss().index )
			SetPawnTimer(_SkipBossPanel, 1.0);

		if( leaver.userid == g_vsh2.m_hGamemode.hNextBoss.userid )
			g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
	}
}

public void ManageOnBossSelected(const BaseBoss base)
{
	SetPawnTimer(_SkipBossPanel, 4.0);
	Action act = Call_OnBossSelected(base);
	if( act > Plugin_Changed )
		return;

	ManageBossHelp(base);

	/// random multibosses code.
	int playing = GetLivingPlayers(VSH2Team_Red);
	int max_random_bosses = g_vsh2.m_hCvars.MaxRandomMultiBosses.IntValue;
	if( !g_vsh2.m_hCvars.AllowRandomMultiBosses.BoolValue || playing < 10 || GetRandomInt(0, 3) > 0 || VSHGameMode.CountBosses(false) >= max_random_bosses ) {
		return;
	}
	
	int extra_bosses = GetRandomInt(1, playing / 12);
	if( extra_bosses > max_random_bosses ) {
		extra_bosses = max_random_bosses;
	}
	for( int i; i<extra_bosses; i++ ) {
		BaseBoss partner = VSHGameMode.FindNextBoss();
		int preset_boss_type = partner.iPresetType;
		if( preset_boss_type == -1 )
			preset_boss_type = GetRandomInt(VSH2Boss_Hale, MAXBOSS);
		partner.MakeBossAndSwitch(preset_boss_type, false);
	}
}

public Action ManageOnTouchPlayer(const BaseBoss base, const BaseBoss victim)
{
	return Call_OnTouchPlayer(base, victim);
}

public Action ManageOnTouchBuilding(const BaseBoss base, const int building)
{
	return Call_OnTouchBuilding(base, EntIndexToEntRef(building));
}

public void ManageBossHelp(const BaseBoss base)
{
	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:     ToCHale(base).Help();
		case VSH2Boss_Vagineer: ToCVagineer(base).Help();
		case VSH2Boss_CBS:      ToCChristian(base).Help();
		case VSH2Boss_HHHjr:    ToCHHHJr(base).Help();
		case VSH2Boss_Bunny:    ToCBunny(base).Help();
	}
}

public void ManageBossThink(const BaseBoss base)
{
	/** Adding this so bosses can take minicrits if airborne */
	TF2_AddCondition(base.index, TFCond_GrapplingHookSafeFall, 0.2);

	Action act = Call_OnBossThink(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:		ToCHale(base).Think();
		case VSH2Boss_Vagineer:		ToCVagineer(base).Think();
		case VSH2Boss_CBS:		ToCChristian(base).Think();
		case VSH2Boss_HHHjr:		ToCHHHJr(base).Think();
		case VSH2Boss_Bunny:		ToCBunny(base).Think();
	}
	
	Call_OnBossThinkPost(base);
}

public void ManageBossModels(const BaseBoss base)
{
	Action act = Call_OnBossModelTimer(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:		ToCHale(base).SetModel();
		case VSH2Boss_Vagineer:		ToCVagineer(base).SetModel();
		case VSH2Boss_CBS:		ToCChristian(base).SetModel();
		case VSH2Boss_HHHjr:		ToCHHHJr(base).SetModel();
		case VSH2Boss_Bunny:		ToCBunny(base).SetModel();
	}
}

public void ManageBossDeath(const BaseBoss base)
{
	Action act = Call_OnBossDeath(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:		ToCHale(base).Death();
		case VSH2Boss_Vagineer:		ToCVagineer(base).Death();
		case VSH2Boss_CBS:		ToCChristian(base).Death();
		case VSH2Boss_HHHjr:		ToCHHHJr(base).Death();
		case VSH2Boss_Bunny:		ToCBunny(base).Death();
	}
	g_vsh2.m_hGamemode.iHealthBar.iState ^= 1;
}

public void ManageBossEquipment(const BaseBoss base)
{
	Action act = Call_OnBossEquipped(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:		ToCHale(base).Equip();
		case VSH2Boss_Vagineer:		ToCVagineer(base).Equip();
		case VSH2Boss_CBS:		ToCChristian(base).Equip();
		case VSH2Boss_HHHjr:		ToCHHHJr(base).Equip();
		case VSH2Boss_Bunny:		ToCBunny(base).Equip();
	}
	Call_OnBossEquippedPost(base);
}

/** whatever stuff needs initializing should be done here */
public void ManageBossTransition(const BaseBoss base)
{
#if defined _tf2attributes_included
	if( g_vsh2.m_hGamemode.bTF2Attribs )
		TF2Attrib_RemoveAll(base.index);
#endif
	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:
			TF2_SetPlayerClass(base.index, TFClass_Soldier, _, false);
		case VSH2Boss_Vagineer:
			TF2_SetPlayerClass(base.index, TFClass_Engineer, _, false);
		case VSH2Boss_CBS:
			TF2_SetPlayerClass(base.index, TFClass_Sniper, _, false);
		case VSH2Boss_HHHjr, VSH2Boss_Bunny:
			TF2_SetPlayerClass(base.index, TFClass_DemoMan, _, false);
	}
	ManageBossModels(base);
	/// Patch: Aug 18, 2018 - patching bad first person animations on custom boss models.
	Call_OnBossInitialized(base);
	ManageBossEquipment(base);
}

public void ManageMinionTransition(const BaseBoss base)
{
	if( !base.bIsMinion )
		return;

	base.ForceTeamChange(VSH2Team_Boss); /// Force our guy to the dark side lmao
	base.RemoveAllItems(false);

	BaseBoss master = BaseBoss(base.iOwnerBoss, true);
	Call_OnMinionInitialized(base, master);
}

public void ManagePlayBossIntro(const BaseBoss base)
{
	Action act = Call_OnBossPlayIntro(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:	ToCHale(base).PlaySpawnClip();
		case VSH2Boss_Vagineer:	ToCVagineer(base).PlaySpawnClip();
		case VSH2Boss_CBS:	ToCChristian(base).PlaySpawnClip();
		case VSH2Boss_HHHjr:	ToCHHHJr(base).PlaySpawnClip();
		case VSH2Boss_Bunny:	ToCBunny(base).PlaySpawnClip();
	}
}

public Action ManageOnBossTakeDamage(const BaseBoss victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	switch( victim.iBossType ) {
		case -1: {}
		default: {
			int bFallDamage = (damagetype & DMG_FALL);
			int client = victim.index;
			char trigger[32];
			if( attacker > MaxClients && GetEdictClassname(attacker, trigger, sizeof(trigger)) && !strcmp(trigger, "trigger_hurt", false) )
			{
				Action act = Call_OnBossTakeDamage_OnTriggerHurt(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
				if( act > Plugin_Changed )
					return Plugin_Continue;

				if( g_vsh2.m_hGamemode.bTeleToSpawn || damage >= victim.iHealth )
					victim.TeleToSpawn(VSH2Team_Boss);
				/// TODO: add cvar for trigger_hurt threshold
				else if( damage >= 200.0 ) {
					if( victim.iBossType==VSH2Boss_HHHjr )
						victim.flCharge = HALEHHH_TELEPORTCHARGE;
					else victim.bSuperCharge = true;
				}

				if( damage > 500.0 ) {
					if( act != Plugin_Changed )
						damage = 500.0;
					return Plugin_Changed;
				}
			} else if( attacker <= 0 && bFallDamage ) {
				if( Call_OnBossTakeFallDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage = (victim.iHealth > 100) ? 1.0 : 30.0;
				}
				return Plugin_Changed;
			}
			if( TF2_IsPlayerInCondition(client, TFCond_Jarated)) {
				ManageBossJarated(victim, attacker);
				TF2_RemoveCondition(client, TFCond_Jarated);
				///PrintCenterText(attacker, "You Jarated %s!", name);    ///Future WIP?
				///PrintCenterText(victim.index, "You Were Just Jarated!");	
			}
			if( attacker <= 0 || attacker > MaxClients )
				return Plugin_Continue;

			victim.iHits++;
			victim.flLastHit = GetGameTime();
			char classname[64], inflictor_name[32];
			if( IsValidEntity(inflictor) )
				GetEntityClassname(inflictor, inflictor_name, sizeof(inflictor_name));
			if( IsValidEntity(weapon) )
				GetEdictClassname(weapon, classname, sizeof(classname));

			/// Bosses shouldn't die from a single backstab
			int wepindex = GetItemIndex(weapon);
			if( damagecustom == TF_CUSTOM_BACKSTAB || (!strcmp(classname, "tf_weapon_knife", false) && damage > victim.iHealth) ) {
				float changedamage = ( (Pow(float(victim.iMaxHealth)*0.0014, 2.0) + 899.0) - (float(victim.iMaxHealth)*(float(victim.iStabbed)/100)) );
				if( victim.iStabbed < 4 )
					victim.iStabbed++;

				/// You can level "damage dealt" with backstabs
				damage = changedamage/3;
				damagetype |= DMG_CRIT;
				EmitSoundToAll("player/spy_shield_break.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				EmitSoundToAll("player/crit_received3.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);

				float curtime = GetGameTime();
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime+2.0);

				int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if( vm > MaxClients && IsValidEntity(vm) && TF2_GetPlayerClass(attacker) == TFClass_Spy ) {
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int anim = 15;
					switch( melee ) {
						case 727: anim = 41;
						case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
						case 638: anim = 31;
					}
					SetEntProp(vm, Prop_Send, "m_nSequence", anim);
				}
				char boss_name[MAX_BOSS_NAME_SIZE];
				victim.GetName(boss_name);
				PrintCenterText(attacker, "You Tickled %s!", boss_name);
				PrintCenterText(victim.index, "You Were Just Tickled!");
				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);

				/// Diamondback gains 2 crits on backstab
				if( pistol == 525 ) {
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
				}

				/// connivers kunai
				if( wepindex == 356 ) {
					int health = GetClientHealth(attacker)+180;
					if( health > 195 )
						health = 250;
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				}

				/// Big Earner gives full cloak on backstab
				else if( wepindex == 461 )
					SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);

				if( Call_OnBossTakeDamage_OnStabbed(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					switch( victim.iBossType ) {
						case VSH2Boss_Hale:      ToCHale(victim).Stabbed();
						case VSH2Boss_Vagineer:  ToCVagineer(victim).Stabbed();
						case VSH2Boss_HHHjr:     ToCHHHJr(victim).Stabbed();
						case VSH2Boss_Bunny:     ToCBunny(victim).Stabbed();
					}
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}

			if( damagecustom == TF_CUSTOM_BOOTS_STOMP ) {
				if( Call_OnBossTakeDamage_OnMantreadsStomp(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed )
					damage = 1024.0;
				return Plugin_Changed;
			}

			if( damagecustom == TF_CUSTOM_TELEFRAG ) {
				if( Call_OnBossTakeDamage_OnTelefragged(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage = victim.iHealth+0.2;
				}
				int teleowner = FindTeleOwner(attacker);
				if( teleowner != -1 && teleowner != attacker ) {
					BaseBoss builder = BaseBoss(teleowner);
					builder.iDamage += RoundFloat(damage) / 2;
				}
				return Plugin_Changed;
			}

			if( g_vsh2.m_hCvars.Anchoring.BoolValue ) {
				int iFlags = GetEntityFlags(victim.index);
#if defined _tf2attributes_included
				if( g_vsh2.m_hGamemode.bTF2Attribs ) {
					/// If Hale is ducking on the ground, it's harder to knock him back
					if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
						TF2Attrib_SetByDefIndex(victim.index, 252, 0.0);
					else TF2Attrib_RemoveByDefIndex(victim.index, 252);
				} else {
					/// Does not protect against sentries or FaN, but does against miniguns and rockets
					if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
						damagetype |= DMG_PREVENT_PHYSICS_FORCE;
				}
#else
				if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;
#endif
			}

			/// Gives 4 heads if successful sword killtaunt!
			/// TODO: add cvar for this?
			if( damagecustom == TF_CUSTOM_TAUNT_BARBARIAN_SWING ) {
				for( int x; x<4; x++ ) {
					IncrementHeadCount(attacker);
				}
				if( Call_OnBossTakeDamage_OnSwordTaunt(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
					return Plugin_Changed;
			}

			/// Heavy Shotguns heal for damage dealt
			if( StrContains(classname, "tf_weapon_shotgun", false) > -1 && TF2_GetPlayerClass(attacker) == TFClass_Heavy ) {
				return Call_OnBossTakeDamage_OnHeavyShotgun(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			} else if( StrContains(classname, "tf_weapon_sniperrifle", false) > -1 && g_vsh2.m_hGamemode.iRoundState != StateEnding ) {
				if( wepindex != 230 && wepindex != 526 && wepindex != 752 && wepindex != 30665 ) {
					float bossGlow = victim.flGlowtime;
					float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					float time = (bossGlow > 10 ? 1.0 : 2.0);
					time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4) * (chargelevel / 100);
					bossGlow += RoundToCeil(time);
					if( bossGlow > 30.0 )
						bossGlow = 30.0; /// TODO: Add cvar for this?
					victim.flGlowtime = bossGlow;
				}
				/// bazaar bargain I think
				if( wepindex == 402 && damagecustom == TF_CUSTOM_HEADSHOT )
					IncrementHeadCount(attacker, false);
				if( wepindex == 752 ) {
					float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					float add = 10 + (chargelevel / 10);
					if( TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)) )
						add /= 3.0;
					float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
					SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
				}

				if( wepindex == 230 )
					victim.flRAGE -= (damage * g_vsh2.m_hCvars.SydneySleeperRageRemove.FloatValue);

				if( !(damagetype & DMG_CRIT) ) {
					bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
					if( Call_OnBossTakeDamage_OnSniped(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
						damage *= (ministatus) ? 2.222222 : 3.0;
						return Plugin_Changed;
					}
					return Plugin_Changed;
				}
			}

			switch( wepindex ) {
				/// Third Degree
				case 593: {
					int medics;
					int numhealers = GetEntProp(attacker, Prop_Send, "m_nNumHealers");
					for( int i; i<numhealers; i++ ) {
						/// Dispensers > MaxClients
						if( 0 < GetHealerByIndex(attacker, i) <= MaxClients )
							medics++;
					}
					for( int i; i<numhealers; i++ ) {
						int healer;
						if( 0 < (healer = GetHealerByIndex(attacker, i)) <= MaxClients ) {
							int medigun = GetPlayerWeaponSlot(healer, TFWeaponSlot_Secondary);
							if( IsValidEntity(medigun) ) {
								char cls[32]; GetEdictClassname(medigun, cls, sizeof(cls));
								if( !strcmp(cls, "tf_weapon_medigun", false) ) {
									float gain = g_vsh2.m_hCvars.ThirdDegreeUberGain.FloatValue;
									float uber = GetMediCharge(medigun) + (gain / medics);
									float max = 1.0;
									if( GetEntProp(medigun, Prop_Send, "m_bChargeRelease") )
										max = g_vsh2.m_hCvars.UberDeployChargeAmnt.FloatValue;
									if( uber > max )
										uber = max;
									SetMediCharge(medigun, uber);
								}
							}
						}
					}
					if( Call_OnBossTakeDamage_OnThirdDegreed(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
				}
				/*
				case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098: {
					switch( wepindex ) {	/// cleaner to read than if wepindex == || wepindex == || etc.
						case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966: {	/// sniper rifles
							if( g_vsh2.m_hGamemode.iRoundState != StateEnding ) {
								float bossGlow = victim.flGlowtime;
								float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
								float time = (bossGlow > 10 ? 1.0 : 2.0);
								time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4)*(chargelevel/100);
								bossGlow += RoundToCeil(time);
								if( bossGlow > 30.0 )
									bossGlow = 30.0;
								victim.flGlowtime = bossGlow;
							}
						}
					}
					if( wepindex == 402 ) {	/// bazaar bargain I think
						if( damagecustom == TF_CUSTOM_HEADSHOT )
							IncrementHeadCount(attacker, false);
					}
					if( wepindex == 752 && g_vsh2.m_hGamemode.iRoundState != StateEnding ) {
						float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						float add = 10 + (chargelevel 0/ 10);
						if( TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)) )
							add /= 3;
						float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
						SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
					}
					if( !(damagetype & DMG_CRIT) ) {
						bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));

						damage *= (ministatus) ? 2.222222 : 3.0;
						if( wepindex==230 ) {
							victim.flRAGE -= (damage * 0.035);
						}
						return Plugin_Changed;
					}
					else if( wepindex==230 )
						victim.flRAGE -= (damage * 0.035);
				}
				*/
				/// Swords
				case 132, 266, 482, 1082: {
					if( Call_OnBossTakeDamage_OnHitSword(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
					IncrementHeadCount(attacker);
				}
				/// Fan O War
				case 355: {
					if( Call_OnBossTakeDamage_OnHitFanOWar(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
					victim.flRAGE -= g_vsh2.m_hCvars.FanoWarRage.FloatValue;
				}
				/**
				/// Jarate and its skin(s?)								
				case 58, 1083, 1105: {
					if( Call_OnBossJarated(jarateer, jarateed) == Plugin_Changed )
						return Plugin_Changed;
				}
				**/
				/// Candy Cane
				case 317: {
					if( Call_OnBossTakeDamage_OnHitCandyCane(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
					BaseBoss(attacker).SpawnSmallHealthPack(GetClientTeam(attacker));
				}
				/// Chdata's Market Gardener backstab
				case 416: {
					if( BaseBoss(attacker).bInJump ) {
						damage = ( Pow(float(victim.iMaxHealth), (0.74074)) - (victim.iMarketted/128*float(victim.iMaxHealth)) )/3.0;

						damage *= VSHGameMode.CountBosses(true);

						/// divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;
						if( victim.iMarketted < 5 )
							victim.iMarketted++;

						char name[MAX_BOSS_NAME_SIZE]; victim.GetName(name);
						PrintCenterText(attacker, "You Market Gardened %s!", name);
						PrintCenterText(victim.index, "You Were Just Market Gardened!");

						EmitSoundToAll("player/doubledonk.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);

						if( Call_OnBossTakeDamage_OnMarketGardened(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed )
							return Plugin_Changed;
						return Plugin_Changed;
					}
				}
				/// PowerJackass
				case 214: {
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health+25;
					if( health < max+50 ) {
						if( newhealth > max+50 )
							newhealth = max+50;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if( TF2_IsPlayerInCondition(attacker, TFCond_OnFire) )
						TF2_RemoveCondition(attacker, TFCond_OnFire);

					if( Call_OnBossTakeDamage_OnPowerJack(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
				}
				/// Katana
				case 357: {
					SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
					if( GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1 )
						SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health+35;
					if( health < max+25 ) {
						if( newhealth > max+25 )
							newhealth = max+25;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if( TF2_IsPlayerInCondition(attacker, TFCond_OnFire) )
						TF2_RemoveCondition(attacker, TFCond_OnFire);
					//int weap = GetPlayerWeaponSlot(victim.index, TFWeaponSlot_Melee);
					//int index = GetItemIndex(weap);
					//int active = GetEntPropEnt(victim.index, Prop_Send, "m_hActiveWeapon");
					if( Call_OnBossTakeDamage_OnKatana(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
					/*
					if( index == 357 && active == weap ) {
						damage = 195.0 / 3.0;
						return Plugin_Changed;
					}
					*/
				}
				/// Ambassador + Festive ver.
				case 61, 1006: {  /// Ambassador does 2.5x damage on headshot
					if( damagecustom == TF_CUSTOM_HEADSHOT ) {
						if( Call_OnBossTakeDamage_OnAmbassadorHeadshot(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed )
							damage *= 2.5;
						return Plugin_Changed;
					}
				}
				/*
				case 16, 203, 751, 1149: {  /// SMG does 2.5x damage on headshot
					if( damagecustom == TF_CUSTOM_HEADSHOT ) {
						damage = 27.0;
						return Plugin_Changed;
					}
				}
				*/
				/// Diamondback & Manmelter
				case 525, 595: {
					/// If a revenge crit was used, give a damage bonus
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if( iCrits ) {
						if( Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed )
							damage = 85.0;
						return Plugin_Changed;
					}
				}
				/// Tickle Hoovy Fists.
				case 656: {
					SetPawnTimer(_StopTickle, g_vsh2.m_hCvars.StopTickleTime.FloatValue, victim.userid);
					if( TF2_IsPlayerInCondition(attacker, TFCond_Dazed) )
						TF2_RemoveCondition(attacker, TFCond_Dazed);

					if( Call_OnBossTakeDamage_OnHolidayPunch(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed )
						return Plugin_Changed;
				}
			}

			/// Patch Nov 1, 2019: being in water fires air shot hook.
			int boss_flags = GetEntityFlags(victim.index);
			int grounded = boss_flags & FL_ONGROUND;
			int swimming = boss_flags & FL_INWATER;
			if( !grounded && !swimming && !StrContains(inflictor_name, "tf_projectile_", false) ) {
				float ray_angle[] = { 90.0, 0.0, 0.0 };
				TR_TraceRayFilter(damagePosition, ray_angle, MASK_PLAYERSOLID_BRUSHONLY, RayType_Infinite, TraceRayIgnoreEnts);
				if( TR_DidHit() ) {
					float end_pos[3]; TR_GetEndPosition(end_pos);
					if( GetVectorDistance(damagePosition, end_pos) >= g_vsh2.m_hCvars.AirShotDist.FloatValue )
						if( Call_OnBossAirShotProj(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) )
							return Plugin_Changed;
				}
			}

			/// everything else covered here.
			return Call_OnBossTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		}
	}
	return Plugin_Continue;
}

public Action ManageOnBossDealDamage(const BaseBoss victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BaseBoss fighter = BaseBoss(attacker);
	switch( fighter.iBossType ) {
		case -1: {}
		default: {
			victim.iHits++;
			victim.flLastHit = GetGameTime();

			int client = victim.index;
			if( damagecustom == TF_CUSTOM_BOOTS_STOMP ) {
				if( Call_OnBossDealDamage_OnStomp(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					float flFallVelocity = GetEntPropFloat(inflictor, Prop_Send, "m_flFallVelocity");
					/// TF2 Fall Damage formula, modified for VSH2
					damage = 10.0 * (GetRandomFloat(0.8, 1.2) * (5.0 * (flFallVelocity / 300.0)));
				}
				return Plugin_Changed;
			}
			if( TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed) ) {
				if( Call_OnBossDealDamage_OnHitDefBuff(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					ScaleVector(damageForce, 9.0);
					damage *= 0.3;
				}
				return Plugin_Changed;
			}
			/*
			if( TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph) ) {
				damage *= 9;
				/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
				TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
				return Plugin_Changed;
			}
			*/
			if( TF2_IsPlayerInCondition(client, TFCond_CritMmmph) ) {
				if( Call_OnBossDealDamage_OnHitCritMmmph(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage *= 0.25;
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}

			int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if( IsValidEntity(medigun)
				&& GetEdictClassname(medigun, mediclassname, sizeof(mediclassname))
				&& !strcmp(mediclassname, "tf_weapon_medigun", false)
				&& !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& weapon == GetPlayerWeaponSlot(attacker, 2)) {
				/**
					If medic has (nearly) full uber, use it as a single-hit shield to prevent medics from dying early.
					Entire team is pretty much screwed if all the medics just die.
				*/
				if( Call_OnBossDealDamage_OnHitMedic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					if( g_vsh2.m_hCvars.MedicUberShield.BoolValue && GetMediCharge(medigun) >= 0.90 ) {
						SetMediCharge(medigun, 0.1);
						ScaleVector(damageForce, 9.0);
						damage *= 0.1;
						/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
						//TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
						TF2_AddCondition(client, TFCond_SpeedBuffAlly, 5.0);
						return Plugin_Changed;
					}
				}
				return Plugin_Changed;
			}

			/// eggs probably do melee damage to spies, then? That's not ideal, but eh.
			if( TF2_GetPlayerClass(client) == TFClass_Spy ) {
				if( GetEntProp(client, Prop_Send, "m_bFeignDeathReady") || TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
					if( GetClientCloakIndex(client) == 59 ) {
						if( Call_OnBossDealDamage_OnHitDeadRinger(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							if( damagetype & DMG_CRIT )
								damagetype &= ~DMG_CRIT;
							if( damagetype & (DMG_CLUB|DMG_SLASH) )
								damage = g_vsh2.m_hCvars.DeadRingerDamage.FloatValue / FindConVar("tf_feign_death_damage_scale").FloatValue;
							return Plugin_Changed;
						}
						return Plugin_Changed;
					} else {
						if( Call_OnBossDealDamage_OnHitCloakedSpy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							if( damagetype & DMG_CRIT )
								damagetype &= ~DMG_CRIT;
							if( damagetype & (DMG_CLUB|DMG_SLASH) )
								damage = g_vsh2.m_hCvars.CloakDamage.FloatValue / FindConVar("tf_stealth_damage_reduction").FloatValue;
							return Plugin_Changed;
						}
						return Plugin_Changed;
					}
				}
			}

			int ent = GetDemoShield(client);
			if( ent != -1
				&& !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& (weapon == GetPlayerWeaponSlot(attacker, 2)
				|| damage >= GetClientHealth(client)+0.0) )	/// FIXME; crit damage is calculated after this and can kill regardless of shield!
			{
				if( Call_OnBossDealDamage_OnHitShield(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					TF2_RemoveWearable(client, ent);
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					return Plugin_Continue;
				}
				return Plugin_Changed;
			}
			ent = GetRazorBack(client);
			if( ent != -1
				&& !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& (weapon == GetPlayerWeaponSlot(attacker, 2)
				|| damage >= GetClientHealth(client)+0.0) )
			{
				if( Call_OnBossDealDamage_OnHitShield(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					TF2_RemoveWearable(client, ent);
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					return Plugin_Continue;
				}
				return Plugin_Changed;
			}
			return Call_OnBossDealDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		}
	}
	return Plugin_Continue;
}

#if defined _goomba_included_
public Action ManageOnGoombaStomp(int attacker, int client, float& damageMultiplier, float& damageAdd, float& JumpPower)
{
	BaseBoss boss = BaseBoss(client);
	/// Players Stomping the Boss
	if( boss.bIsBoss ) {
		switch( boss.iBossType ) {
			/// Ignore if not boss at all.
			case -1: {}
			/// Default behaviour for Goomba Stompoing the Boss
			default: {
				/// Prevent goomba stomp for mantreads/demo boots if being able to is disabled.
				if( IsValidEntity(FindPlayerBack(attacker, { 444, 405, 608 }, 3)) && !g_vsh2.m_hCvars.CanMantreadsGoomba.BoolValue )
					return Plugin_Handled;

				damageAdd = float(g_vsh2.m_hCvars.GoombaDamageAdd.IntValue);
				damageMultiplier = g_vsh2.m_hCvars.GoombaLifeMultiplier.FloatValue;
				JumpPower = g_vsh2.m_hCvars.GoombaReboundPower.FloatValue;

				//PrintToChatAll("%N Just Goomba stomped %N(The Boss)!", attacker, client);
				CPrintToChatAllEx(attacker, "{olive}>> {teamcolor}%N {default}just goomba stomped {unique}%N{default}!", attacker, client);
				return Plugin_Changed;
			}
		}
   		return Plugin_Continue;
	}

	boss = BaseBoss(attacker);
	/// The Boss(es) Stomping a player
	if( boss.bIsBoss ) {
		switch( boss.iBossType ) {
			/// Ignore if not boss at all.
			case -1: {}
			/// Default behaviour for the Boss Goomba Stomping other players.
			default: {
				/// Block the Boss from Goomba Stomping if disabled.
				if( !g_vsh2.m_hCvars.CanBossGoomba.BoolValue )
					return Plugin_Handled;
				/// If the demo had a shield to break
				if( RemoveDemoShield(client) || RemoveRazorBack(client) ) {
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					damageAdd = 0.0;
					damageMultiplier = 0.0;
					//JumpPower = 0.0;
					return Plugin_Changed;
				}
				//PrintToChatAll("%N(The Boss) just got stomped by %N!", client, attacker);
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}
#endif

public void ManageBossKillPlayer(const BaseBoss attacker, const BaseBoss victim, Event event)
{
	Action act = Call_OnPlayerKilled(attacker, victim, event);
	if( act > Plugin_Changed )
		return;

	//int dmgbits = event.GetInt("damagebits");
	int deathflags = event.GetInt("death_flags");

	/// If victim is a boss, kill him off
	if( victim.bIsBoss )
		RequestFrame(_BossDeath, victim.userid);
		//SetPawnTimer(_BossDeath, 0.1, victim.userid);

	if( attacker.bIsBoss ) {
		switch( attacker.iBossType ) {
			case -1: {}
			case VSH2Boss_Hale: {
				if( deathflags & TF_DEATHFLAG_DEADRINGER )
					event.SetString("weapon", "fists");
				else ToCHale(attacker).KilledPlayer(victim, event);
			}
			case VSH2Boss_Vagineer:	ToCVagineer(attacker).KilledPlayer(victim, event);
			case VSH2Boss_CBS:	ToCChristian(attacker).KilledPlayer(victim, event);
			case VSH2Boss_HHHjr:	ToCHHHJr(attacker).KilledPlayer(victim, event);
			case VSH2Boss_Bunny:	ToCBunny(attacker).KilledPlayer(victim, event);
		}
	}
}
public void ManageHurtPlayer(const BaseBoss attacker, const BaseBoss victim, Event event)
{
	Action act = Call_OnPlayerHurt(attacker, victim, event);
	if( act > Plugin_Changed )
		return;

	int damage = event.GetInt("damageamount");
	int custom = event.GetInt("custom");
	int weapon = event.GetInt("weaponid");
	switch( victim.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale, VSH2Boss_Vagineer, VSH2Boss_CBS, VSH2Boss_HHHjr, VSH2Boss_Bunny: {
			victim.GiveRage(damage);
		}
	}

	/// Minions shouldn't have their damage tracked.
	if( attacker.bIsMinion )
		return;


	/// Telefrags normally 1-shot the boss but let's cap damage at 9k
	if( custom == TF_CUSTOM_TELEFRAG )
		damage = (IsPlayerAlive(attacker.index) ? 9001 : 1);

	/// block off bosses from doing the rest of things but track their damage.
	attacker.iDamage += damage;
	if( attacker.bIsBoss )
		return;

	if( !GetEntProp(attacker.index, Prop_Send, "m_bShieldEquipped")
		&& GetPlayerWeaponSlot(attacker.index, TFWeaponSlot_Secondary) <= 0
		&& attacker.GetTFClass() == TFClass_DemoMan )
	{
		int iReqDmg = g_vsh2.m_hCvars.ShieldRegenDmgReq.IntValue;
		if( iReqDmg>0 ) {
			attacker.iShieldDmg += damage;
			if( attacker.iShieldDmg >= iReqDmg ) {
				/// TODO: figure out a better way to regenerate shield.
				/// save data so we can get our shield back.
				/// save health, heads, and weapon data.
				int client = attacker.index;
				int health = GetClientHealth(client);

				int heads;
				if( HasEntProp(client, Prop_Send, "m_iDecapitations") )
					heads = GetEntProp(client, Prop_Send, "m_iDecapitations");
				int primammo = GetAmmo(client, TFWeaponSlot_Primary);
				int primclip = GetClip(client, TFWeaponSlot_Primary);

				/// "respawn" player.
				TF2_RegeneratePlayer(client);

				/// reset old data
				SetEntityHealth(client, health);

				/// PATCH Sept 22, 2019: Demos that lost shield but changed loadouts during round retaining their heads...
				if( HasEntProp(client, Prop_Send, "m_iDecapitations") && heads > 0 ) {
					if( GetEntProp(client, Prop_Send, "m_bShieldEquipped") )
						SetEntProp(client, Prop_Send, "m_iDecapitations", heads);
					else SetEntProp(client, Prop_Send, "m_iDecapitations", 0);
				}
				SetAmmo(client, TFWeaponSlot_Primary, primammo);
				SetClip(client, TFWeaponSlot_Primary, primclip);
				attacker.iShieldDmg = 0;
			}
		}
	}

	/// Compatibility patch for Randomizer
	if( GetIndexOfWeaponSlot(attacker.index, TFWeaponSlot_Primary) == 1104 ) {
		if( weapon == TF_WEAPON_ROCKETLAUNCHER )
			attacker.iAirDamage += damage;
		int div = g_vsh2.m_hCvars.AirStrikeDamage.IntValue;
		SetEntProp(attacker.index, Prop_Send, "m_iDecapitations", attacker.iAirDamage/div);
	}

	/// Heavy Shotgun healing.
	else if( attacker.GetTFClass()==TFClass_Heavy && weapon==TF_WEAPON_SHOTGUN_HWG ) {
		int health = GetClientHealth(attacker.index);
		int maxhp = GetEntProp(attacker.index, Prop_Data, "m_iMaxHealth");
		int heavy_overheal = RoundFloat(FindConVar("tf_max_health_boost").FloatValue * maxhp);
		
		int health_from_dmg = (( health < maxhp ) ? (maxhp - health) : (heavy_overheal - health)) % damage;
		if( health_from_dmg==0 ) {
			health_from_dmg = damage >> view_as< int >(health > maxhp);
		}
		HealPlayer(attacker.index, health_from_dmg, true);
	}

	/// Medics now count as 3/5 of a backstab, similar to telefrag assists.
	int healers = GetEntProp(attacker.index, Prop_Send, "m_nNumHealers");
	int healercount;
	for( int i=0; i<healers; i++ ) {
		if( 0 < GetHealerByIndex(attacker.index, i) <= MaxClients ) {
			healercount++;
		}
	}

	BaseBoss medic;
	for( int r=0; r<healers; r++ ) {
		medic = BaseBoss(GetHealerByIndex(attacker.index, r));
		if( 0 < medic.index <= MaxClients ) {
			if( damage < 10 || medic.iUberTarget == attacker.userid )
				medic.iDamage += damage;
			else medic.iDamage += damage/(healercount+1);
		}
	}
}

public void ManagePlayerAirblast(const BaseBoss airblaster, const BaseBoss airblasted, Event event)
{
	Action act = Call_OnPlayerAirblasted(airblaster, airblasted, event);
	if( act > Plugin_Changed )
		return;

	switch( airblasted.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale, VSH2Boss_CBS, VSH2Boss_HHHjr, VSH2Boss_Bunny:
			airblasted.flRAGE += g_vsh2.m_hCvars.AirblastRage.FloatValue;
		case VSH2Boss_Vagineer: {
			if( TF2_IsPlayerInCondition(airblasted.index, TFCond_Ubercharged) ) {
				float dur = GetConditionDuration(airblasted.index, TFCond_Ubercharged);
				float max_dur = g_vsh2.m_hCvars.VagineerUberTime.FloatValue;
				float increase = g_vsh2.m_hCvars.VagineerUberAirBlast.FloatValue;
				SetConditionDuration(airblasted.index, TFCond_Ubercharged, dur + increase < max_dur ? dur + increase : max_dur);
			}
			else airblasted.flRAGE += g_vsh2.m_hCvars.AirblastRage.FloatValue;
		}
	}
}

public Action ManageTraceHit(const BaseBoss victim, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	return Call_OnTraceAttack(victim, attacker, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsPlayerAlive(client) )
		return Plugin_Continue;

	BaseBoss base = BaseBoss(client);
	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Bunny: {
			if( GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetActiveWep(client) ) {
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
		case VSH2Boss_HHHjr: {
			if( base.flCharge >= 47.0 && (buttons & IN_ATTACK) ) {
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	BaseBoss player = BaseBoss(client);
	if( !player.bIsBoss )
		return;

	bool remove;
	switch( condition ) {
		case TFCond_Disguised, TFCond_MarkedForDeath:		///Jarate cond will be removed in some seperate logic
			remove = true;
	}

	if( Call_OnBossConditionChange(player, condition, remove) <= Plugin_Changed && remove )		{
		TF2_RemoveCondition(client, condition);
	}
}

public void ManageBossMedicCall(const BaseBoss base)
{
	Action act = Call_OnBossMedicCall(base);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale, VSH2Boss_Vagineer, VSH2Boss_CBS, VSH2Boss_HHHjr, VSH2Boss_Bunny: {
			if( base.flRAGE < 100.0 )
				return;
			DoTaunt(base.index, "", 0);
			base.flRAGE = 0.0;
		}
	}
}
public void ManageBossTaunt(const BaseBoss base)
{
	Action act = Call_OnBossTaunt(base);
	if( act > Plugin_Changed )
		return;
	
	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:     ToCHale(base).RageAbility();
		case VSH2Boss_Vagineer: ToCVagineer(base).RageAbility();
		case VSH2Boss_CBS:      ToCChristian(base).RageAbility();
		case VSH2Boss_HHHjr:    ToCHHHJr(base).RageAbility();
		case VSH2Boss_Bunny:    ToCBunny(base).RageAbility();
	}
}
public void ManageBuildingDestroyed(const BaseBoss base, const int building, const int objecttype, Event event)
{
	Action act = Call_OnBossKillBuilding(base, building, event);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale: {
			event.SetString("weapon", "fists");
			ToCHale(base).KillToy();
		}
	}
}

public void ManageBossJarated(const BaseBoss victim, const int attacker)			///Reworked code, Working 12/07/2021
{
	Action act = Call_OnBossJarated(victim, attacker);
	if( act > Plugin_Changed )
		return;

	switch( victim.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale, VSH2Boss_Vagineer, VSH2Boss_CBS, VSH2Boss_HHHjr, VSH2Boss_Bunny:
			victim.flRAGE -= g_vsh2.m_hCvars.JarateRage.FloatValue;
			
	}
}

public Action HookSound(int clients[64], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsValidClient(entity) )
		return Plugin_Continue;

	BaseBoss base = BaseBoss(entity);
	Action act = Call_OnSoundHook(base, sample, channel, volume, level, pitch, flags);
	if( act != Plugin_Continue )
		return act;

	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale: {
			if( !strncmp(sample, "vo", 2, false) )
				return Plugin_Handled;
		}
		case VSH2Boss_Vagineer: {
			if( StrContains(sample, "vo/engineer_laughlong01", false) != -1 ) {
				strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
				return Plugin_Changed;
			}
			if( !strncmp(sample, "vo", 2, false) ) {
				if( StrContains(sample, "positivevocalization01", false) != -1 )	/// For backstab sound
					return Plugin_Continue;
				if( StrContains(sample, "engineer_moveup", false) != -1 )
					Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				else if( StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6 )
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.mp3");
				else strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.mp3");
				return Plugin_Changed;
			}
			else return Plugin_Continue;
		}
		case VSH2Boss_HHHjr: {
			if( !strncmp(sample, "vo", 2, false) ) {
				if( GetRandomInt(0, 30) <= 10 ) {
					Format(sample, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if( StrContains(sample, "halloween_boss") == -1 )
					return Plugin_Handled;
			}
		}
		case VSH2Boss_Bunny: {
			if( StrContains(sample, "gibberish", false) == -1
				&& StrContains(sample, "burp", false) == -1
				&& !GetRandomInt(0, 2) ) /// Do sound things
			{
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;

	BaseBoss base = BaseBoss(client);
	if( base.bIsBoss ) {
		switch( base.iBossType ) {
			case -1: {}
			case VSH2Boss_HHHjr: {
				if( base.iClimbs < g_vsh2.m_hCvars.HHHMaxClimbs.IntValue && base.ClimbWall(weapon, g_vsh2.m_hCvars.HHHClimbVelocity.FloatValue, 0.0, false) ) {
					base.flWeighDown = 0.0;
				}
			}
		}
		
		/// Fuck random crits
		if( TF2_IsPlayerCritBuffed(base.index) )
			return Plugin_Continue;
		result = false;
		return Plugin_Changed;
	} else if( !base.bIsMinion ) {
		if( TF2_GetPlayerClass(client)==TFClass_Sniper
				&& IsWeaponSlotActive(client, TFWeaponSlot_Melee)
				&& g_vsh2.m_hCvars.AllowSniperClimbing.BoolValue ) {
			base.ClimbWall(weapon, g_vsh2.m_hCvars.SniperClimbVelocity.FloatValue, g_vsh2.m_hCvars.SniperClimbDmg.FloatValue, true);
		}
	}
	return Plugin_Continue;
}

public void ManageMessageIntro(ArrayList bosses)
{
	if( g_vsh2.m_hGamemode.bDoors ) {
		int ent = -1;
		while( (ent = FindEntityByClassname(ent, "func_door")) != -1 ) {
			AcceptEntityInput(ent, "Open");
			AcceptEntityInput(ent, "Unlock");
		}
	}

	char intro_msg[MAXMESSAGE];
	SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
	int i;
	int len = bosses.Length;
	for( i=0; i<len; ++i ) {
		BaseBoss base = bosses.Get(i);
		if( base == view_as< BaseBoss >(0) )
			continue;

		char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
		base.GetName(name);

		/// TODO: add something that can prefix and suffix the intro message possibly?
		Format(boss_msg, sizeof boss_msg, "%N has become %s with %i Health", base.index, name, base.iHealth);
		Action act = Call_OnMessageIntro(base, boss_msg);
		if( act > Plugin_Changed )
			continue;

		StrCat(intro_msg, MAXMESSAGE, boss_msg);
		StrCat(intro_msg, MAXMESSAGE, "\n");
	}
	for( i=MaxClients; i; --i ) {
		if( IsClientInGame(i) )
			ShowHudText(i, -1, "%s", intro_msg);
	}
	g_vsh2.m_hGamemode.iRoundState = StateRunning;
	delete bosses;
}

public void ManageBossPickUpItem(const BaseBoss base, const char item[64])
{
	/// block Persian Persuader
	//if( GetIndexOfWeaponSlot(base.index, TFWeaponSlot_Melee) == 404 )
	//	return;

	Action act = Call_OnBossPickUpItem(base, item);
	if( act > Plugin_Changed )
		return;

	switch( base.iBossType ) {
		case -1: {}
	}
}

public void ManageResetVariables(const BaseBoss base)
{
	Action act = Call_OnVariablesReset(base);
	if( act > Plugin_Changed )
		return;

	base.iBossType = -1;
	base.iStabbed = 0;
	base.iMarketted = 0;
	base.flRAGE = 0.0;
	base.bIsMinion = false;
	base.iDamage = 0;
	base.iAirDamage = 0;
	base.iUberTarget = 0;
	base.flCharge = 0.0;
	base.flGlowtime = 0.0;
	base.bUsedUltimate = false;
	base.iOwnerBoss = 0;
	base.iSongPick = -1;
	SetEntityRenderColor(base.index, 255, 255, 255, 255);
	base.flLastShot = 0.0;
	base.flLastHit = 0.0;
	base.iState = -1;
	base.iHits = 0;
	base.iLives = ((g_vsh2.m_hGamemode.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue) ? g_vsh2.m_hCvars.MedievalLives.IntValue : 0);
	//base.iHealth = 0;
	base.iMaxHealth = 0;
	base.iShieldDmg = 0;
	base.iClimbs = 0;
	base.bSuperCharge = false;
	base.bInJump = false; /// PATCH: rocket jumping at end of round then respawning keeps this on true with perma-crit market gardener.
}
public void ManageEntityCreated(const int entity, const char[] classname)
{
	if( StrContains(classname, "rune") != -1 ) {
		CreateTimer( 0.1, RemoveEnt, EntIndexToEntRef(entity) );
	} else if( !g_vsh2.m_hCvars.DroppedWeapons.BoolValue && StrEqual(classname, "tf_dropped_weapon") ) {
		/// Remove dropped weapons to avoid bad things
		AcceptEntityInput(entity, "kill");
		return;
	} else if( !strcmp(classname, "tf_projectile_cleaver", false) ) {
		SDKHook(entity, SDKHook_SpawnPost, OnCleaverSpawned);
	} else if( g_vsh2.m_hGamemode.iRoundState == StateRunning ) {
		if( !strcmp(classname, "tf_projectile_pipe", false) )
			SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
		else if( !strcmp(classname, "item_healthkit_medium", false) || !strcmp(classname, "item_healthkit_small", false) ) {
			int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
			if( team != VSH2Team_Red )
				SetEntProp(entity, Prop_Send, "m_iTeamNum", VSH2Team_Red, 4);
		}
	}
}
public void OnEggBombSpawned(int entity)
{
	int owner = GetOwner(entity);
	BaseBoss boss = BaseBoss(owner);
	if( IsClientValid(owner) && boss.bIsBoss && boss.iBossType == VSH2Boss_Bunny )
		CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}
public void OnCleaverSpawned(int entity)
{
	int client = GetThrower(entity);
	if( IsClientValid(client) && TF2_GetPlayerClass(client)==TFClass_Spy ) {
		char kunai_model[] = "models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl";
		PrecacheModel(kunai_model, true);
		SetEntityModel(entity, kunai_model);
		SetEntityGravity(entity, 10.0);
	}
}

public void ManageUberDeploy(const BaseBoss medic, const BaseBoss patient)
{
	int medigun = GetPlayerWeaponSlot(medic.index, TFWeaponSlot_Secondary);
	if( IsValidEntity(medigun) ) {
		char strMedigun[32]; GetEdictClassname(medigun, strMedigun, sizeof(strMedigun));
		if( !strcmp(strMedigun, "tf_weapon_medigun", false) ) {
			Action act = Call_OnUberDeployed(medic, patient);
			if( act > Plugin_Changed )
				return;

			SetMediCharge(medigun, g_vsh2.m_hCvars.UberDeployChargeAmnt.FloatValue);
			TF2_AddCondition(medic.index, TFCond_CritOnWin, 0.5, medic.index);
			if( IsClientValid(patient.index) && IsPlayerAlive(patient.index) ) {
				TF2_AddCondition(patient.index, TFCond_CritOnWin, 0.5, medic.index);
				medic.iUberTarget = patient.userid;
			}
			else medic.iUberTarget = 0;
			CreateTimer(0.1, Timer_UberLoop, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void ManageMusic(char song[PLATFORM_MAX_PATH], float& time, float& vol)
{
	/// UNFORTUNATELY, we have to get a random boss so we can set our music, tragic I know...
	/// Remember that you can get a random boss filtered by type as well!
	BaseBoss currBoss = VSHGameMode.GetRandomBoss(true);
	Action act = Call_OnMusic(song, time, currBoss, vol);
	if( act > Plugin_Changed )
		return;

	if( currBoss && song[0]=='\0' ) {
		switch( currBoss.iBossType ) {
			case -1: {song = "\0"; time = -1.0;}
			case VSH2Boss_CBS: {
				strcopy(song, sizeof(song), CBSTheme);
				time = 140.0;
			}
			case VSH2Boss_HHHjr: {
				strcopy(song, sizeof(song), HHHTheme);
				time = 90.0;
			}
			case VSH2Boss_Bunny, VSH2Boss_Hale, VSH2Boss_Vagineer: {
				song = "\0";
				time = -1.0;
			}
		}
	}
}
public void StopBackGroundMusic()
{
	if( g_vsh2.m_strCurrSong[0] != 0 ) {
		for( int i=MaxClients; i; --i ) {
			if( !IsClientValid(i) )
				continue;
			BaseBoss(i).StopMusic();
		}
	}
}

public void ManageRoundEndBossInfo(ArrayList bosses, bool bossWon)
{
	char round_end_msg[MAXMESSAGE];
	int i=0;
	BaseBoss base;
	int len = bosses.Length;
	for( i=0; i<len; ++i ) {
		base = bosses.Get(i);
		if( base == view_as< BaseBoss >(0) )
			continue;

		char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
		base.GetName(name);

		Format(boss_msg, sizeof boss_msg, "%s (%N) had %i (of %i) health left.", name, base.index, base.iHealth, base.iMaxHealth);

		Action act = Call_OnRoundEndInfo(base, bossWon, boss_msg);
		if( act > Plugin_Changed )
			continue;

		StrCat(round_end_msg, MAXMESSAGE, boss_msg);
		StrCat(round_end_msg, MAXMESSAGE, "\n");

		if( bossWon ) {
			switch( base.iBossType ) {
				case -1: {}
				case VSH2Boss_Vagineer:	ToCVagineer(base).PlayWinSound();
				case VSH2Boss_Bunny:	ToCBunny(base).PlayWinSound();
				case VSH2Boss_Hale:	ToCHale(base).PlayWinSound();
			}
		}
		base.iDifficulty = 0;
	}
	if( round_end_msg[0] != '\0' ) {
		CPrintToChatAll("{olive}[VSH 2] End of Round{default} %s", round_end_msg);
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for( i=MaxClients; i; --i ) {
			if( IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE) )
				ShowHudText(i, -1, "%s", round_end_msg);
		}
	}
	delete bosses;
}
public void ManageLastPlayer()
{
	BaseBoss currBoss = VSHGameMode.GetRandomBoss(true);
	Action act = Call_OnLastPlayer(currBoss);
	if( act > Plugin_Changed )
		return;

	switch( currBoss.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale:      ToCHale(currBoss).LastPlayerSoundClip();
		case VSH2Boss_Vagineer:  ToCVagineer(currBoss).LastPlayerSoundClip();
		case VSH2Boss_CBS:       ToCChristian(currBoss).LastPlayerSoundClip();
		case VSH2Boss_Bunny:     ToCBunny(currBoss).LastPlayerSoundClip();
	}
}

public void ManageBossCheckHealth(const BaseBoss base)
{
	static int LastBossTotalHealth;
	float currtime = GetGameTime();

	/// If a boss reveals their own health, only show that one boss' health.
	if( base.bIsBoss && IsPlayerAlive(base.index) ) {
		char health_check[MAXMESSAGE];
		Action act = Call_OnBossHealthCheck(base, true, health_check);
		if( act > Plugin_Changed )
			return;

		char name[MAX_BOSS_NAME_SIZE];
		base.GetName(name);
		PrintCenterTextAll("%s showed his current HP: %i of %i", name, base.iHealth, base.iMaxHealth);
		LastBossTotalHealth = base.iHealth;
		return;
	}
	/// If a non-boss is checking health, reveal all Boss' hp
	else if( currtime >= g_vsh2.m_hGamemode.flHealthTime ) {
		g_vsh2.m_hGamemode.iHealthChecks++;
		int totalHealth;
		char health_check[MAXMESSAGE];
		for( int i=MaxClients; i; --i ) {
			/// exclude dead bosses for health check
			if( !IsValidClient(i) || !IsPlayerAlive(i) )
				continue;

			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;

			char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
			boss.GetName(name);
			Format(boss_msg, sizeof boss_msg, "%s's current health is: %i of %i", name, boss.iHealth, boss.iMaxHealth);

			Action act = Call_OnBossHealthCheck(boss, false, boss_msg);
			if( act > Plugin_Changed )
				continue;

			StrCat(health_check, MAXMESSAGE, boss_msg);
			StrCat(health_check, MAXMESSAGE, "\n");
			totalHealth += boss.iHealth;
		}
		PrintCenterTextAll(health_check);
		CPrintToChatAll("{olive}[VSH 2] {axis}Boss Health Check{default} %s", health_check);
		LastBossTotalHealth = totalHealth;
		g_vsh2.m_hGamemode.flHealthTime = currtime + ((g_vsh2.m_hGamemode.iHealthChecks < 3) ? 10.0 : 60.0);
	} else {
		CPrintToChat(base.index, "{olive}[VSH 2]{default} You cannot see the Boss HP now (wait %i seconds). Last known total boss health was %i.", RoundFloat(g_vsh2.m_hGamemode.flHealthTime-currtime), LastBossTotalHealth);
	}
}

public void CheckAlivePlayers(const any nil)
{
	if( g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return;

	int living = GetLivingPlayers(VSH2Team_Red);
	if( !living ) {
		ForceTeamWin(VSH2Team_Boss);
	} else if( living == 1 && VSHGameMode.CountBosses(true) > 0 && g_vsh2.m_hGamemode.iTimeLeft <= 0 ) {
		ManageLastPlayer(); /// in handler.sp
		g_vsh2.m_hGamemode.iTimeLeft = g_vsh2.m_hCvars.LastPlayerTime.IntValue;

		/// maybe some day...
		/*
		int round_timer = -1;
		round_timer = FindEntityByClassname(RoundTimer, "team_round_timer");
		if( round_timer <= 0 )
			round_timer = CreateEntityByName("team_round_timer");

		if( round_timer > MaxClients && IsValidEntity(round_timer) ) {
			SetVariantInt(g_vsh2.m_hCvars.LastPlayerTime.IntValue);
			//DispatchKeyValue(round_timer, "targetname", TIMER_NAME);
			//DispatchKeyValue(round_timer, "setup_length", setupLength);
			//DispatchKeyValue(round_timer, "setup_length", "30");
			DispatchKeyValue(round_timer, "reset_time", "1");
			DispatchKeyValue(round_timer, "auto_countdown", "1");
			char time[5];
			IntToString(g_vsh2.m_hCvars.LastPlayerTime.IntValue, time, sizeof(time));
			DispatchKeyValue(round_timer, "timer_length", time);
			DispatchSpawn(round_timer);
		}
		*/
		CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	int enable_alive = g_vsh2.m_hCvars.AliveToEnable.IntValue;
	if( !g_vsh2.m_hCvars.PointType.BoolValue && living <= enable_alive && !g_vsh2.m_hGamemode.bPointReady ) {
		PrintHintTextToAll("%i players are left; control point enabled!", living);
		if( living==enable_alive ) {
			EmitSoundToAll("vo/announcer_am_capenabled02.mp3");
		} else if( living < enable_alive ) {
			char cap_incite_snd[][] = {
				"vo/announcer_am_capincite01.mp3",
				"vo/announcer_am_capincite03.mp3"
			};
			EmitSoundToAll(cap_incite_snd[GetRandomInt(0, 1)]);
		}
		SetControlPoint(true);
		g_vsh2.m_hGamemode.bPointReady = true;
	}
}

public void ManageOnBossCap(char sCappers[MAXPLAYERS+1], const int capping_team, BaseBoss[] cappers, const int capper_count)
{
	Call_OnControlPointCapped(sCappers, capping_team, cappers, capper_count);
}

/// TODO: fix this up so it appears more often.
public void _SkipBossPanel()
{
	BaseBoss[] upnext = new BaseBoss[MaxClients];
	VSHGameMode.GetQueue(upnext);
	for( int j; j<3; j++ ) {
		if( !upnext[j] )
			continue;

		/// If up next to become a boss.
		if( !j ) {
			SkipBossPanelNotify(upnext[j].index);
		} else if( !IsFakeClient(upnext[j].index) ) {
			CPrintToChat(upnext[j].index, "{olive}[VSH 2]{default} You are going to be a Boss soon! Type {olive}/halenext{default} to check/reset your queue points & !setboss to set your boss.");
		}
	}
}

public void PrepPlayers(const BaseBoss player)
{
	int client = player.index;
	if( g_vsh2.m_hGamemode.iRoundState == StateEnding || !IsValidClient(client) || !IsPlayerAlive(client) || player.bIsBoss )
		return;
	
#if defined _tf2attributes_included
	if( g_vsh2.m_hGamemode.bTF2Attribs )
		TF2Attrib_RemoveAll(client);
#endif
	
	Action act = Call_OnPrepRedTeam(player);
	if( act > Plugin_Changed )
		return;
	
	/// Added fix by Chdata to correct team colors
	int player_team = GetClientTeam(client);
	if( player_team > VSH2Team_Spectator && player_team != VSH2Team_Red ) {
		player.ForceTeamChange(VSH2Team_Red);
		TF2_RegeneratePlayer(client);
	}
	TF2_RegeneratePlayer(client);
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	if( !GetRandomInt(0, 1) )
		player.HelpPanelClass();
	
#if defined _tf2attributes_included
	/// Fixes mantreads to have jump height again
	if( g_vsh2.m_hGamemode.bTF2Attribs ) {
		/// Patch: Equipping mantreads then equipping gunboats allows you to keep the push force increase.
		TF2Attrib_RemoveByDefIndex(client, 58);
		if( IsValidEntity(FindPlayerBack(client, { 444 }, 1)) ) {
			/// "self dmg push force increased"
			TF2Attrib_SetByDefIndex(client, 58, 1.8);
		}
	}
#endif
	static ConfigMap replacer, entry_sect;
	replacer = g_vsh2.m_hCfg.GetSection("weapon overrides.replace");
	if( replacer != null ) {
		int entries = replacer.Size;
		for( int i; i<entries; i++ ) {
			entry_sect = replacer.GetIntSection(i);
			if( entry_sect != null ) {
				int classes_len = entry_sect.GetSize("classes");
				char[] classes = new char[classes_len];
				entry_sect.Get("classes", classes, classes_len);

				/// First we check if a class requirement is set.
				if( classes[0] != '0' ) {
					char class_strs[10][10];
					int class_count = ExplodeString(classes, ", ", class_strs, 10, 10);
					bool correct_class;
					TFClassType tfclass = TF2_GetPlayerClass(client);
					for( int n; n<class_count; n++ ) {
						TFClassType class_type = view_as< TFClassType >(StringToInt(class_strs[n]));
						if( tfclass==class_type ) {
							correct_class = true;
							break;
						}
					}
					if( !correct_class )
						continue;
				}
				
				int indices_len = entry_sect.GetSize("indices");
				char[] indices = new char[indices_len];
				entry_sect.Get("indices", indices, indices_len);
				char index_strs[20][10];
				int index_count = ExplodeString(indices, ", ", index_strs, 20, 10);
				int[] indexes = new int[index_count];
				for( int n; n<index_count; n++ ) {
					indexes[n] = StringToInt(index_strs[n]);
				}
				/// O(n^2)...
				for( int slot=TFWeaponSlot_Primary; slot<=TFWeaponSlot_Item2; slot++ ) {
					int weapon = GetPlayerWeaponSlot(client, slot);
					int index = GetItemIndex(weapon);
					for( int n; n<index_count; n++ ) {
						if( index==indexes[n] ) {
							int classname_len = entry_sect.GetSize("classname");
							char[] wep_classname = new char[classname_len];
							entry_sect.Get("classname", wep_classname, classname_len);
							int desired_index, desired_level, desired_quality, desired_ammo;
							entry_sect.GetInt("index", desired_index);
							entry_sect.GetInt("level", desired_level);
							entry_sect.GetInt("quality", desired_quality);
							
							int attribs_len = entry_sect.GetSize("attribs");
							char[] attribs = new char[attribs_len];
							entry_sect.Get("attribs", attribs, attribs_len);
							entry_sect.GetInt("ammo", desired_ammo);
							
							TF2_RemoveWeaponSlot(client, slot);
							if( desired_index == -1 ) {
								desired_index = index;
							}
							weapon = player.SpawnWeapon(wep_classname, desired_index, desired_level, desired_quality, attribs);
							if( desired_ammo>0 ) {
								SetWeaponAmmo(weapon, desired_ammo);
							}
						}
					}
				}
			}
		}
	}
	
	TFClassType tfclass = TF2_GetPlayerClass(client);
	switch( tfclass ) {
		case TFClass_Medic: {
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			/// 200; 1 for area of effect healing, 178; 0.75 Faster switch-to, 14; 0.0 perm overheal, 11; 1.25 Higher overheal
			float start_uber = g_vsh2.m_hCvars.StartUberChargeAmnt.FloatValue;
			if( GetMediCharge(weapon) != start_uber )
				SetMediCharge(weapon, start_uber);
		}
	}
#if defined _tf2attributes_included
	if( g_vsh2.m_hGamemode.bTF2Attribs && g_vsh2.m_hCvars.HealthRegenForPlayers.BoolValue ) {
		int max_health = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		TF2Attrib_SetByDefIndex(client, 57, max_health / 50.0 + g_vsh2.m_hCvars.HealthRegenAmount.FloatValue);
	}
#endif
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue )
		return Plugin_Continue;

	TF2Item hItemOverride = null;
	TF2Item hItemCast = view_as< TF2Item >(hItem);

	static char override_keys[][] = {
		"weapon overrides.preserve",
		"weapon overrides.override"
	};

	for( int i; i<sizeof(override_keys); i++ ) {
		ConfigMap override_map = g_vsh2.m_hCfg.GetSection(override_keys[i]);
		if( override_map != null ) {
			char itemdef_path[15]; IntToString(iItemDefinitionIndex, itemdef_path, sizeof itemdef_path);
			int attribs_len = override_map.GetSize(itemdef_path);
			if( attribs_len > 0 ) {
				char[] attribs = new char[attribs_len];
				override_map.Get(itemdef_path, attribs, attribs_len);
				hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, i==1);
			}
		}
	}

	if( hItemOverride==null && iItemDefinitionIndex==415 ) {
		if( TF2_GetPlayerClass(client)==TFClass_Soldier )
			hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "135 ; 0.7 ; 179; 1.0; 2; 1.1");
		else hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "179 ; 1.0; 2 ; 1.1");
	}

	if( hItemOverride != null ) {
		Action act = Call_OnItemOverride(BaseBoss(client), classname, iItemDefinitionIndex, view_as< Handle >(hItemOverride));
		if( act > Plugin_Changed )
			return Plugin_Continue;

		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}

	/// TODO: Make this section moddable from ConfigMap.
	TFClassType iClass = TF2_GetPlayerClass(client);
	if( !strncmp(classname, "tf_weapon_rocketlauncher", 24, false) || !strncmp(classname, "tf_weapon_particle_cannon", 25, false) ) {
		switch( iItemDefinitionIndex ) {
			/// Direct Hit
			case 127: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114 ; 1.0; 179 ; 1.0");

			/// Liberty Launcher.
			case 414: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114 ; 1.0; 99 ; 1.25");

			/// Air Strike.
			case 1104: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "76; 1.25; 114; 1.0");
			//case 730: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "394; 0.2; 241; 1.3; 3; 0.75; 411; 5; 6; 0.1; 642; 1; 413; 1", true);
			default: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114; 1.0");
		}
	}
	if( !strncmp(classname, "tf_weapon_grenadelauncher", 25, false) /*|| !strncmp(classname, "tf_weapon_cannon", 16, false)*/ ) {
		switch( iItemDefinitionIndex ) {
			/// loch n load
			case 308: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114; 1.0; 208; 1.0");
			default: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114; 1.0; 128; 1; 135; 0.5");
		}
	}
	if( !strncmp(classname, "tf_weapon_sword", 15, false) ) {
		hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "178; 0.8");
	}
	if( !StrContains(classname, "tf_weapon_shotgun", false) || !strncmp(classname, "tf_weapon_sentry_revenge", 24, false) ) {
		switch( iClass ) {
			case TFClass_Soldier:
				hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "135; 0.6; 114; 1.0");
			default: hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "114; 1.0");
		}
		//hItemOverride = TF2Item_PrepareItemHandle(hItem, _, _, "114; 1.0");
	}

	switch( iClass ) {
		case TFClass_Sniper: {
			if( StrEqual(classname, "tf_weapon_club", false) || StrEqual(classname, "saxxy", false) ) {
				switch( iItemDefinitionIndex ) {
					/// Shahanshah
					case 401: {
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "236 ; 1 ; 224 ; 1.66 ; 225 ; 0.5");
					}
					default: {
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "236 ; 1"); /// Block healing while in use.
					}
				}
			}
		}
		case TFClass_Medic: {
			/// Medic mediguns
			if( !StrContains(classname, "tf_weapon_medigun", false) ) {
				if( g_vsh2.m_hCvars.PermOverheal.BoolValue ) {
					/// Kritzkrieg
					if( iItemDefinitionIndex==35 )
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "14; 0.0; 10 ; 2.26 ; 178 ; 0.75 ; 18 ; 0");
					/// Other Mediguns
					else hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "14; 0.0; 10 ; 1.81 ; 178 ; 0.75 ; 18 ; 0", true);
				} else {
					if( iItemDefinitionIndex==35 )
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "10 ; 2.26 ; 178 ; 0.75 ; 18 ; 0");
					else hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, "10 ; 1.81 ; 178 ; 0.75 ; 18 ; 0", true);
				}
			}
		}
	}
	if( hItemOverride != null ) {
		Action act = Call_OnItemOverride(BaseBoss(client), classname, iItemDefinitionIndex, view_as< Handle >(hItemOverride));
		if( act > Plugin_Changed )
			return Plugin_Continue;
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	return Call_OnItemOverride(BaseBoss(client), classname, iItemDefinitionIndex, hItem);
}

public void ManageFighterThink(const BaseBoss fighter)
{
	if( GetClientTeam(fighter.index) != VSH2Team_Red ) {
		return;
	}

	Action act = Call_OnRedPlayerThink(fighter);
	if( act > Plugin_Changed ) {
		return;
	}

	char HUDText[300];
	int i = fighter.index;
	int buttons = GetClientButtons(i);

	/// HUD code
	Format(HUDText, sizeof(HUDText), "Damage: %d", fighter.iDamage);
	if( !IsPlayerAlive(i) ) {
		int obstarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
		if( IsValidClient(obstarget) && GetClientTeam(obstarget) != VSH2Team_Boss && obstarget != i ) {
			BaseBoss observ = BaseBoss(obstarget);
			Format(HUDText, sizeof(HUDText), "%s - %N's Damage: %d", HUDText, obstarget, observ.iDamage);
		}
	} else if( g_vsh2.m_hGamemode.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue ) {
		Format(HUDText, sizeof(HUDText), "%s | Lives: %d", HUDText, fighter.iLives);
	}

	/// killstreak support code.
	if( HasEntProp(i, Prop_Send, "m_iKillStreak") ) {
		int killstreaker = fighter.iDamage / 1000;
		if( killstreaker && GetEntProp(i, Prop_Send, "m_iKillStreak") >= 0 ) {
			SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
		}
	}

	char wepclassname[64];
	TFClassType tfclass = TF2_GetPlayerClass(i);
	int weapon = GetActiveWep(i);
	if( weapon <= MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)) ) {
		strcopy(wepclassname, sizeof(wepclassname), "");
	}
	bool validwep = !strncmp(wepclassname, "tf_wea", 6, false);

	switch( tfclass ) {
		/// Chdata's Deadringer Notifier
		case TFClass_Spy: {
			if( GetClientCloakIndex(i)==59 ) {
				int drstatus = TF2_IsPlayerInCondition(i, TFCond_Cloaked) ? 2 : GetEntProp(i, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
				char status_str[32];
				switch( drstatus ) {
					case 1: {
						Format(status_str, sizeof(status_str), "Status: Feign-Death Ready");
					}
					case 2: {
						Format(status_str, sizeof(status_str), "Status: Dead-Ringered");
					}
					default: {
						Format(status_str, sizeof(status_str), "Status: Inactive");
					}
				}
				Format(HUDText, sizeof(HUDText), "%s\n%s", HUDText, status_str);
			}
			int spy_secondary = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if( spy_secondary > MaxClients && IsValidEntity(spy_secondary) ) {
				Format(HUDText, sizeof(HUDText), "%s | Kunai: %s", HUDText, GetWeaponAmmo(spy_secondary) ? "Ready" : "None");
			}
		}
		case TFClass_Medic: {
			int medigun = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if( medigun > MaxClients && IsValidEntity(medigun) ) {
				GetEdictClassname(medigun, mediclassname, sizeof(mediclassname));
				if( !strcmp(mediclassname, "tf_weapon_medigun", false) ) {
					float charge_level = GetMediCharge(medigun);
					int charge = RoundToFloor(charge_level * 100);
					Format(HUDText, sizeof(HUDText), "%s\nUbercharge: %i%%", HUDText, charge);
					
					/// Fixes Ubercharges ending prematurely on Medics.
					if( GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && charge_level > 0.0 && GetActiveWep(i)==medigun ) {
						TF2_AddCondition(i, TFCond_Ubercharged, 1.0);
					}
				}
			}
		}
		case TFClass_Soldier: {
			if( GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary)==1104 ) {
				Format(HUDText, sizeof(HUDText), "%s\nAir Strike Damage: %i", HUDText, fighter.iAirDamage);
			}
		}
		case TFClass_DemoMan: {
			int shield = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if( shield <= 0 ) {
				if( GetEntProp(i, Prop_Send, "m_bShieldEquipped") ) {
					Format(HUDText, sizeof(HUDText), "%s\nShield: Active", HUDText);
				} else {
					Format(HUDText, sizeof(HUDText), "%s\nShield: Gone", HUDText);
				}
			}
		}
	}

	if( !(buttons & IN_SCORE) ) {
		SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
		ShowSyncHudText(i, g_vsh2.m_hHUDs[PlayerHUD], HUDText);
	}

	if( !TF2_IsPlayerInCondition(i, TFCond_Cloaked) ) {
		switch( GetLivingPlayers(VSH2Team_Red) ) {
			case 1: {
				TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
				TF2_AddCondition(i, TFCond_Buffed,    0.2);
				int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
				if( tfclass==TFClass_Engineer && weapon==primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false) ) {
					SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
				}
				return;
			}
			case 2: {
				TF2_AddCondition(i, TFCond_Buffed, 0.2);
			}
		}
	}

	/// Crit conditional code.
	if( TF2_IsPlayerInCondition(i, TFCond_CritCola) && (tfclass==TFClass_Scout || tfclass==TFClass_Heavy) ) {
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
		return;
	}

	int crit_flags = 0;
	enum {
		CRITFLAG_MINI  = 1 << 0, /// minicrits.
		CRITFLAG_FULL  = 1 << 1, /// full crits.
		CRITFLAG_STACK = 1 << 2, /// stack crits.
	};

	int healers = GetEntProp(i, Prop_Send, "m_nNumHealers");
	for( int u; u<healers; u++ ) {
		if( 0 < GetHealerByIndex(i, u) <= MaxClients ) {
			crit_flags |= CRITFLAG_STACK;
			break;
		}
	}

	if( validwep ) {
		switch( GetSlotFromWeapon(i, weapon) ) {
			case TFWeaponSlot_Melee: {
				/// slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
				crit_flags |= view_as< int >(!!strcmp(wepclassname, "tf_weapon_knife", false)) << 1;
			}
			case TFWeaponSlot_Primary: {
				bool is_wep_class = (StrStarts(wepclassname, "tf_weapon_compound_bow") || /// Sniper bows
					StrStarts(wepclassname, "tf_weapon_crossbow") || /// Medic crossbows
					StrEqual(wepclassname,  "tf_weapon_shotgun_building_rescue") || /// Engineer Rescue Ranger
					StrEqual(wepclassname,  "tf_weapon_drg_pomson"));
				crit_flags |= view_as< int >(is_wep_class) << 1;
			}
			case TFWeaponSlot_Secondary: {
				if( StrStarts(wepclassname, "tf_weapon_pistol") || /// Engineer/Scout pistols
					StrStarts(wepclassname, "tf_weapon_handgun_scout_secondary") || /// Scout pistols
					StrStarts(wepclassname, "tf_weapon_flaregun") || /// Flare guns
					StrStarts(wepclassname, "tf_weapon_smg") ) /// Sniper SMGs minus Cleaner's Carbine
				{
					int PrimaryIndex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
					/// No crits if using Phlogistinator or Cozy Camper
					if( (tfclass==TFClass_Pyro && PrimaryIndex == 594) || (IsValidEntity(FindPlayerBack(i, { 642 }, 1))) ) {
						crit_flags &= ~CRITFLAG_FULL;
					} else {
						crit_flags |= CRITFLAG_FULL;
					}
					
					if( tfclass==TFClass_Scout ) {
						crit_flags = CRITFLAG_MINI;
					}
				}

				/// Jarate/Milk + Flying Guillotine
				crit_flags |= view_as< int >((StrStarts(wepclassname, "tf_weapon_jar") || StrEqual(wepclassname, "tf_weapon_cleaver"))) << 1;
			}
		}
	}

	/// Specific weapon crit list
	switch( GetItemIndex(weapon) ) {
		/// Holiday Punch, Short Circuit
		case 656, 528: {
			crit_flags = CRITFLAG_MINI;
		}
		/// Market Gardener
		case 416: {
			crit_flags = 0;
		}
	}
	
	/// Demo Man shield crits code.
	if( tfclass == TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)) && GetSlotFromWeapon(i, weapon) != TFWeaponSlot_Melee ) {
		if( g_vsh2.m_hCvars.DemoShieldCrits.IntValue >= 1 ) {
			float flShieldMeter = GetEntPropFloat(i, Prop_Send, "m_flChargeMeter");
			crit_flags = CRITFLAG_FULL;
			if( g_vsh2.m_hCvars.DemoShieldCrits.IntValue == 1 || (g_vsh2.m_hCvars.DemoShieldCrits.IntValue == 3 && flShieldMeter < 100.0) ) {
				crit_flags = CRITFLAG_MINI;
			}

			if( g_vsh2.m_hCvars.DemoShieldCrits.IntValue == 3 && (flShieldMeter < 35.0 || !GetEntProp(i, Prop_Send, "m_bShieldEquipped")) ) {
				crit_flags = 0;
			}
		}
	}
	
	if( crit_flags & CRITFLAG_FULL ) {
		if( crit_flags & CRITFLAG_STACK )
			TF2_AddCondition(i, TFCond_Buffed, 0.2);
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
	}
	if( crit_flags & CRITFLAG_MINI ) {
		TF2_AddCondition(i, TFCond_Buffed, 0.2);
	}

	switch( tfclass ) {
		case TFClass_Spy: {
			/// If Spies are cloaked or disguised, make sure they're not showing crit FX.
			if( validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) ) {
				if( !TF2_IsPlayerCritBuffed(i)
					&& !TF2_IsPlayerInCondition(i, TFCond_Buffed)
					&& !TF2_IsPlayerInCondition(i, TFCond_Cloaked)
					&& !TF2_IsPlayerInCondition(i, TFCond_Disguised)
					&& !GetEntProp(i, Prop_Send, "m_bFeignDeathReady") )
				{
					TF2_AddCondition(i, TFCond_CritCola, 0.2);
				}
			}
		}

		case TFClass_Engineer: {
			/// Frontier Justice revenge-crits code.
			if( weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false) ) {
				int sentry = FindSentry(i);
				if( IsValidEntity(sentry) ) {
					/// Trying to target minions as well
					int enemy = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
					if( enemy > 0 && GetClientTeam(enemy) == VSH2Team_Boss ) {
						SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
						TF2_AddCondition(i, TFCond_Kritzkrieged, 0.2);
					} else {
						if( HasEntProp(i, Prop_Send, "m_iRevengeCrits") ) {
							SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
						} else if( TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing) ) {
							TF2_RemoveCondition(i, TFCond_Kritzkrieged);
						}
					}
				}
			}
		}
	}
}

/// too many temp funcs just to call as a timer. No wonder sourcepawn needs lambda funcs...
public void _RespawnPlayer(const int userid)
{
	if( g_vsh2.m_hGamemode.iRoundState == StateRunning ) {
		TF2_RespawnPlayer(GetClientOfUserId(userid));
	}
}
