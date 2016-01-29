#include <sourcemod>

#define PLUGIN_VERSION "0.1"

ConVar sm_botcon_enable        = null;
ConVar sm_botcon_quota_empty   = null;
ConVar sm_botcon_quota_players = null;
ConVar srcds_bot_quota         = null;

public Plugin myinfo =
{
	name        = "Bot Connection Handler",
	author      = "spacepope",
	description = "Handle bot presence on empty servers ",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/hypercephalickitten/sourcemod-plugins"
};

public void OnPluginStart()
{
	CreateConVar(
		"sm_botcon_version",
		PLUGIN_VERSION,
		"Bot Connection Handler plugin version",
		FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY);

	sm_botcon_enable = CreateConVar(
	                   	"sm_botcon_enable",
	                   	"1",
	                   	"Enable/Disable the plugin",
	                   	_,
	                    	true, 0.0,
	                    	true, 1.0);

	sm_botcon_quota_players = CreateConVar(
	                          	"sm_botcon_quota_players",
	                          	"3",
	                          	"Bot quota when players are connected",
	                          	_,
	                          	true, 0.0,
	                           	true, 16.0);

	sm_botcon_quota_empty = CreateConVar(
	                        	"sm_botcon_quota_empty",
	                        	"0",
	                        	"Bot quota when server is empty",
	                        	_,
	                        	true, 0.0,
	                        	true, 16.0);
	
	AutoExecConfig(true, "botcon");

	srcds_bot_quota = FindConVar("bot_quota");
	if (srcds_bot_quota == null)
		SetFailState("Mod does not support bot_quota");

	HookConVarChange(sm_botcon_enable, OnConVarChange);
	HookConVarChange(sm_botcon_quota_players, OnConVarChange);
	HookConVarChange(sm_botcon_quota_empty, OnConVarChange);
}

public void OnConVarChange(ConVar sm_convar, char[] oldValue, char[] newValue)
{
	if (!GetConVarBool(sm_botcon_enable))
		return;

	if (sm_convar == sm_botcon_enable) {
		int players = GetRealClientCount();

		if (players == 0 && StringToInt(newValue) == 1)
			SetConVarInt(srcds_bot_quota,
				GetConVarInt(sm_botcon_quota_empty));
		else
			SetConVarInt(srcds_bot_quota,
				GetConVarInt(sm_botcon_quota_players));
	
	} else if (sm_convar == sm_botcon_quota_players) {
		int players = GetRealClientCount();
		
		if (players > 0) 
			SetConVarInt(srcds_bot_quota, StringToInt(newValue));
	} else {
		SetConVarInt(srcds_bot_quota, StringToInt(newValue));
	}
}

public void OnClientAuthorized(int client)
{
	if (GetConVarBool(sm_botcon_enable))
		SetBotQuota(client, GetConVarInt(sm_botcon_quota_players));
}

public void OnClientDisconnect(int client)
{
	if (GetConVarBool(sm_botcon_enable))
		SetBotQuota(client, GetConVarInt(sm_botcon_quota_empty));
}

public void SetBotQuota(int client, int new_bot_quota)
{
	if (!IsClientConnected(client) || IsFakeClient(client))
		return;

	int players = GetRealClientCount();

	if (players == 1)
		SetConVarInt(srcds_bot_quota, new_bot_quota);
}

public int GetRealClientCount()
{
	int total = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i))
			continue;
		if (IsFakeClient(i))
			continue;
		if (IsClientSourceTV(i))
			continue;

		total++;
	}
	return total;
}
