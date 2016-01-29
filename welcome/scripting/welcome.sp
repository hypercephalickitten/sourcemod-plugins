#include <sourcemod>

#define PLUGIN_VERSION "0.2"

Handle g_adtArray               = null;
Handle g_tWelcome[MAXPLAYERS+1] = null;
ConVar sm_welcome_timer         = null;
ConVar srcds_hostname           = null;
char   g_cHostname[128];

public Plugin myinfo =
{
	name        = "Simple Welcome Message",
	author      = "spacepope",
	description = "Display a simple welcome message",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/hypercephalickitten/sourcemod-plugins"
};

public void OnPluginStart()
{
	CreateConVar(
		"sm_welcome_version",
		PLUGIN_VERSION,
		"Simple Welcome Message plugin version",
		FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY);

	sm_welcome_timer = CreateConVar(
	                   	"sm_welcome_timer",
	                   	"10",
	                   	"Time in seconds before message is displayed",
	                   	_,
	                   	true, 0.0,
	                    	true, 120.0);

	AutoExecConfig(true, "welcome");

	srcds_hostname = FindConVar("hostname");

	char cPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, cPath, sizeof(cPath), "configs/welcome.txt");
	
	File hFile = OpenFile(cPath, "r");
	if (hFile == null)
		SetFailState("Unable to read file %s", cPath);

	g_adtArray = CreateArray(128);
	char cLine[128];
	while (!IsEndOfFile(hFile)) {
		ReadFileLine(hFile, cLine, sizeof(cLine));
	        TrimString(cLine);
		PushArrayString(g_adtArray, cLine);
	}

	hFile.Close();
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsClientConnected(client))
		return;
	g_tWelcome[client] = CreateTimer(GetConVarFloat(sm_welcome_timer),
	                     	WelcomePlayer, client);
}

public void OnClientDisconnect(int client)
{
	if (!IsClientConnected(client))
		return;

	if (g_tWelcome[client] != null)	{
		KillTimer(g_tWelcome[client]);
		g_tWelcome[client] = null;
	}
}

public Action WelcomePlayer(Handle Timer, int client)
{
	char cClientName[MAX_NAME_LENGTH];
	GetClientName(client, cClientName, sizeof(cClientName));
	GetConVarString(srcds_hostname, g_cHostname, sizeof(g_cHostname));

	PrintToChat(client, "Hello %s! Welcome to %s.", cClientName,
		g_cHostname);

	char cLine[128];
	for (int i = 0; i < GetArraySize(g_adtArray) - 1; i++) {
		GetArrayString(g_adtArray, i, cLine, sizeof(cLine));
		PrintToChat(client, "%s", cLine);
	}

	g_tWelcome[client] = null;
}
