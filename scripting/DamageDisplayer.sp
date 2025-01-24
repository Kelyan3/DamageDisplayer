#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>

#pragma newdecls required


/* BOOLEANS */
bool g_bDisplayEnemyName_Suffix[MAXPLAYERS + 1] = {false, ...};
bool g_bDisplayEnemyName[MAXPLAYERS + 1] = {false, ...};
bool g_bDisplayDamage_Suffix[MAXPLAYERS + 1] = {false, ...};
bool g_bDisplayDamage[MAXPLAYERS + 1] = {false, ...};
bool g_bDisplayEnemyHPRemaining_Suffix[MAXPLAYERS + 1] = {false, ...};
bool g_bDisplayEnemyHPRemaining[MAXPLAYERS + 1] = {false, ...};

/* COOKIES */
Handle g_hCookie_DisplayEnemyName_Suffix = INVALID_HANDLE;
Handle g_hCookie_DisplayEnemyName = INVALID_HANDLE;
Handle g_hCookie_DisplayDamage_Suffix = INVALID_HANDLE;
Handle g_hCookie_DisplayDamage = INVALID_HANDLE;
Handle g_hCookie_DisplayEnemyHPRemaining_Suffix = INVALID_HANDLE;
Handle g_hCookie_DisplayEnemyHPRemaining = INVALID_HANDLE;


//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Plugin myinfo =
{
	name			= "Damage Displayer",
	description		= "Allows clients to display damage they've dealt, the victim's health and their remaining HP.",
	author			= "Kelyan3",
	version			= "1.0.0",
	url				= "https://steamcommunity.com/id/BeholdTheBahamutSlayer",
};

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void OnPluginStart()
{
	RegConsoleCmd("sm_dd", Command_DamageDisplayer, "Displays the Damage Displayer's settings menu.");
	RegConsoleCmd("sm_damagedisplayer", Command_DamageDisplayer, "Displays the Damage Displayer's settings menu.");

	g_hCookie_DisplayDamage = RegClientCookie("dd_display_damage", "Does the client wants to display the damage he dealt?", CookieAccess_Protected);
	g_hCookie_DisplayEnemyName = RegClientCookie("dd_display_enemyname", "Does the client wants to display the victim's name?", CookieAccess_Protected);
	g_hCookie_DisplayEnemyHPRemaining = RegClientCookie("dd_display_enemyhpleft", "Does the client wants to display the victim's remaining HP?", CookieAccess_Protected);

	g_hCookie_DisplayDamage_Suffix = RegClientCookie("dd_display_damage_suffix", "Does the client wants to display the suffix \"Damage: \" with the damage he dealt?", CookieAccess_Protected);
	g_hCookie_DisplayEnemyName_Suffix = RegClientCookie("dd_display_enemyname_suffix", "Does the client wants to display the suffix \"Name: \" with the victim's name?", CookieAccess_Protected);
	g_hCookie_DisplayEnemyHPRemaining_Suffix = RegClientCookie("dd_display_enemyhpleft_suffix", "Does the client wants to display the suffix \"HP Remaining: \" with the victim's remaining HP?", CookieAccess_Protected);

	HookEvent("player_hurt", EventHook_PlayerHurt, EventHookMode_Post);

	SetCookieMenuItem(MenuHandler_CookieMenu_DamageDisplayer, INVALID_HANDLE, "Damage Displayer");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void OnClientCookiesCached(int client)
{
	char sCookieBuffer[2];

	GetClientCookie(client, g_hCookie_DisplayEnemyName_Suffix, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayEnemyName_Suffix[client] = true;
	else
		g_bDisplayEnemyName_Suffix[client] = false;

	GetClientCookie(client, g_hCookie_DisplayEnemyName, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayEnemyName[client] = true;
	else
		g_bDisplayEnemyName[client] = false;

	GetClientCookie(client, g_hCookie_DisplayDamage_Suffix, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayDamage_Suffix[client] = true;
	else
		g_bDisplayDamage_Suffix[client] = false;

	GetClientCookie(client, g_hCookie_DisplayDamage, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayDamage[client] = true;
	else
		g_bDisplayDamage[client] = false;

	GetClientCookie(client, g_hCookie_DisplayEnemyHPRemaining_Suffix, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayEnemyHPRemaining_Suffix[client] = true;
	else
		g_bDisplayEnemyHPRemaining_Suffix[client] = false;

	GetClientCookie(client, g_hCookie_DisplayEnemyHPRemaining, sCookieBuffer, sizeof(sCookieBuffer));
	if (sCookieBuffer[0] != '\0')
		g_bDisplayEnemyHPRemaining[client] = true;
	else
		g_bDisplayEnemyHPRemaining[client] = false;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void MenuHandler_CookieMenu_DamageDisplayer(int client, CookieMenuAction hAction, any aInfo, char[] sBuffer, int iMaxLength)
{
	switch (hAction)
	{
		case CookieMenuAction_DisplayOption:
			Format(sBuffer, iMaxLength, "Damage Displayer", client);

		case CookieMenuAction_SelectOption:
			DisplayDamageDisplayerMenu(client);
	}
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void DisplayDamageDisplayerMenu(int client)
{
	Menu SettingsMenu = new Menu(MenuHandler_Menu_DisplayDamageSettings);
	SettingsMenu.SetTitle("Damage Displayer Settings", client);

	char sBuffer[128];

	Format(sBuffer, sizeof(sBuffer), "Enemy Name (SUFFIX): %s", g_bDisplayEnemyName_Suffix[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("0", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Enemy Name: %s", g_bDisplayEnemyName[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("1", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Damage Dealt (SUFFIX): %s", g_bDisplayDamage_Suffix[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("2", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Damage Dealt: %s", g_bDisplayDamage[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("3", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Enemy HP Remaining (SUFFIX): %s", g_bDisplayEnemyHPRemaining_Suffix[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("4", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Enemy HP Remaining: %s", g_bDisplayEnemyHPRemaining[client] ? "Enabled" : "Disabled");
	SettingsMenu.AddItem("5", sBuffer);

	SettingsMenu.ExitBackButton = true;
	SettingsMenu.Display(client, MENU_TIME_FOREVER);
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayEnemyName_Suffix(int client)
{
	g_bDisplayEnemyName_Suffix[client] = !g_bDisplayEnemyName_Suffix[client];
	SetClientCookie(client, g_hCookie_DisplayEnemyName_Suffix, g_bDisplayEnemyName_Suffix[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayEnemyName(int client)
{
	g_bDisplayEnemyName[client] = !g_bDisplayEnemyName[client];
	SetClientCookie(client, g_hCookie_DisplayEnemyName, g_bDisplayEnemyName[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayDamage_Suffix(int client)
{
	g_bDisplayDamage_Suffix[client] = !g_bDisplayDamage_Suffix[client];
	SetClientCookie(client, g_hCookie_DisplayDamage_Suffix, g_bDisplayDamage_Suffix[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayDamage(int client)
{
	g_bDisplayDamage[client] = !g_bDisplayDamage[client];
	SetClientCookie(client, g_hCookie_DisplayDamage, g_bDisplayDamage[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayEnemyHPRemaining_Suffix(int client)
{
	g_bDisplayEnemyHPRemaining_Suffix[client] = !g_bDisplayEnemyHPRemaining_Suffix[client];
	SetClientCookie(client, g_hCookie_DisplayEnemyHPRemaining_Suffix, g_bDisplayEnemyHPRemaining_Suffix[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void ToggleDisplayEnemyHPRemaining(int client)
{
	g_bDisplayEnemyHPRemaining[client] = !g_bDisplayEnemyHPRemaining[client];
	SetClientCookie(client, g_hCookie_DisplayEnemyHPRemaining, g_bDisplayEnemyHPRemaining[client] ? "1" : "");
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public int MenuHandler_Menu_DisplayDamageSettings(Menu SettingsMenu, MenuAction hAction, int iParam1, int iParam2)
{
	switch (hAction)
	{
		case MenuAction_Select:
		{
			switch (iParam2)
			{
				case 0: ToggleDisplayEnemyName_Suffix(iParam1);
				case 1: ToggleDisplayEnemyName(iParam1);
				case 2: ToggleDisplayDamage_Suffix(iParam1);
				case 3: ToggleDisplayDamage(iParam1);
				case 4: ToggleDisplayEnemyHPRemaining_Suffix(iParam1);
				case 5: ToggleDisplayEnemyHPRemaining(iParam1);
			}

			DisplayDamageDisplayerMenu(iParam1);
		}

		case MenuAction_Cancel:
			ShowCookieMenu(iParam1);

		case MenuAction_End:
			delete SettingsMenu;
	}

	return 0;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Action Command_DamageDisplayer(int client, int argc)
{
	if (!client)
	{
		ReplyToCommand(client, "[SM] Cannot use command from server console.");
		return Plugin_Handled;
	}

	DisplayDamageDisplayerMenu(client);

	return Plugin_Handled;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void EventHook_PlayerHurt(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iVictim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	int iDamage = GetEventInt(hEvent, "dmg_health");

	if (iAttacker == 0 || IsFakeClient(iAttacker) || !IsClientInGame(iAttacker))
		return;

	/* We're not taking into account self-inflicted damage. */
	if (iVictim == iAttacker)
		return;

	char sEnemyNameText[64];
	char sVictimName[MAX_NAME_LENGTH];
	GetClientName(iVictim, sVictimName, sizeof(sVictimName));
	Format(sEnemyNameText, sizeof(sEnemyNameText), "%s%s",
		g_bDisplayEnemyName[iAttacker] ? (g_bDisplayEnemyName_Suffix[iAttacker] ? "Name: " : "") : "",
		g_bDisplayEnemyName[iAttacker] ? sVictimName : "");

	char sDamageText[64];
	char sAttackerDamage[32];
	IntToString(iDamage, sAttackerDamage, sizeof(sAttackerDamage));
	Format(sDamageText, sizeof(sDamageText), "%s%s",
		g_bDisplayDamage[iAttacker] ? (g_bDisplayDamage_Suffix[iAttacker] ? "Damage: " : "") : "",
		g_bDisplayDamage[iAttacker] ? sAttackerDamage : "");

	char sVictimHealth[32];
	int iVictimHealth = GetClientHealth(iVictim);
	if (iVictimHealth > 0)
		Format(sVictimHealth, sizeof(sVictimHealth), "%d HP", iVictimHealth);
	else
		Format(sVictimHealth, sizeof(sVictimHealth), "(Dead)");

	char sHPRemainingText[64];
	Format(sHPRemainingText, sizeof(sHPRemainingText), "%s%s",
		g_bDisplayEnemyHPRemaining[iAttacker] ? (g_bDisplayEnemyHPRemaining_Suffix[iAttacker] ? "HP Remaining: " : "") : "",
		g_bDisplayEnemyHPRemaining[iAttacker] ? sVictimHealth : "");

	char sFinalText[256];
	Format(sFinalText, sizeof(sFinalText), "%s\n%s\n%s", sEnemyNameText, sDamageText, sHPRemainingText);

	PrintCenterText(iAttacker, sFinalText);
}
