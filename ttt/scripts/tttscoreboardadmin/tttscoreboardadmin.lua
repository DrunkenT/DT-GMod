
--[[-----------------------------------------------------------------------//
* 
* Created by bamq. (http://steamcommunity.com/id/bamq)
* Garry's Mod Trouble in Terrorist Town - Scoreboard Administration for The
* Drunken T's TTT
* 1 October 2016 | Updated 22 February 2017
* 
* Adds more features to the scordboard using "TTTScoreboardMenu" hook.
* Designed for The Drunken T's TTT server.
* http://steamcommunity.com/groups/thedrunkent
* Features:
* - Uses Derma menus to provide a menu upon right-clicking on a player on the
* scoreboard.
* - By default there's a few commands that all players can access. Staff can
* access a wider variety of commands that aid in the quick execution of
* common administrative commands.
* Handles staff name colors on the scoreboard using
* TTT_ScoreboardColorForPlayer hook.
* 
//-----------------------------------------------------------------------]]--

hook.Add( "TTTScoreboardMenu", "DT_TTTScoreboardMenu", function( menu )
--	local menu = DermaMenu()
	local ply = menu.Player

	local function bs()
		-- instead of typing this a thousand times, make it a function with a really short name.
		surface.PlaySound( "buttons/button9.wav" )
	end

	bs()

	-- Commands for all players.
	menu:AddOption( "Open Steam Profile", function()
		bs()
		RunConsoleCommand( "ulx", "profile", ply:Nick() )
	end ):SetIcon( "icon16/world.png" )

	menu:AddOption( "Copy Steam ID", function()
		bs()
		SetClipboardText( ply:SteamID() )
	end ):SetIcon( "icon16/script_edit.png" )

	-- Only admins have the copy IP command.
	if LocalPlayer():IsAdmin() then
		menu:AddOption( "Copy IP Address", function()
			bs()
			RunConsoleCommand( "ulx", "ip", ply:Nick() )
		end ):SetIcon( "icon16/computer_edit.png" )
	end

	-- Commands for moderators and admins.
	if LocalPlayer():IsAdmin() or LocalPlayer():IsUserGroup( "moderator" ) then

		menu:AddSpacer()

		menu:AddOption( "Send Message...", function()
			bs()
			if ply == LocalPlayer() then
				chat.AddText( Color( 255, 50, 50 ), "Can't send a message to yourself!" )
				return
			end
			Derma_StringRequest( "Send Message - Message", "Message to send to " .. ply:Nick() .. ":", "", function( message )
				RunConsoleCommand( "ulx", "psay", ply:Nick(), message )
			end,
			function()
			end )
		end ):SetIcon( "icon16/comment.png" )

		menu:AddSpacer()

		menu:AddOption( "Set AutoSlay(s)", function()
			bs()
			Derma_StringRequest( "Set AutoSlay(s) - Number of rounds", "Set number of rounds:", "1", function( rounds )
				Derma_StringRequest( "Set AutoSlay(s) - Reason", "Set reason:", "", function( reason )
					RunConsoleCommand( "ulx", "aslay", ply:Nick(), tonumber( rounds ), reason )
				end,
				function()
				end ) end,
			function()
			end )
		end ):SetIcon( "icon16/font.png" )

		menu:AddOption( "Remove AutoSlay(s)", function()
			bs()
			RunConsoleCommand( "ulx", "aslay", ply:Nick(), 0 )
		end ):SetIcon( "icon16/font_delete.png" )

		menu:AddOption( "Slay", function()
			bs()
			RunConsoleCommand( "ulx", "slay", ply:Nick() )
		end ):SetIcon( "icon16/cross.png" )

		local freeze, freezeico = menu:AddSubMenu( "Freeze Options" )
		freezeico:SetIcon( "icon16/control_stop_blue.png" )

		freeze:AddOption( "Freeze", function()
			bs()
			RunConsoleCommand( "ulx", "freeze", ply:Nick() )
		end ):SetIcon( "icon16/control_pause_blue.png" )

		freeze:AddOption( "Unfreeze", function()
			bs()
			RunConsoleCommand( "ulx", "unfreeze", ply:Nick() )
		end ):SetIcon( "icon16/control_play_blue.png" )

		menu:AddSpacer()

		menu:AddOption( "Kick", function()
			bs()
			Derma_StringRequest( "Kick - Reason", "Set reason:", "", function( reason )
				RunConsoleCommand( "ulx", "kick", ply:Nick(), reason )
			end,
			function()
			end )
		end ):SetIcon( "icon16/door_out.png" )

		menu:AddOption( "Ban", function()
			bs()
			RunConsoleCommand( "xgui", "xban", ply:Nick() )
		end ):SetIcon( "icon16/cancel.png" )

		menu:AddSpacer()

		local mute, muteico = menu:AddSubMenu( "Mute Options" )
		muteico:SetIcon( "icon16/textfield.png" )

		mute:AddOption( "Mute", function()
			bs()
			RunConsoleCommand( "ulx", "mute", ply:Nick() )
		end ):SetIcon( "icon16/textfield_delete.png" )

		mute:AddOption( "Unmute", function()
			bs()
			RunConsoleCommand( "ulx", "unmute", ply:Nick() )
		end ):SetIcon( "icon16/textfield_add.png" )
		-- Only admins have gimp
		if LocalPlayer():IsAdmin() then
			mute:AddOption( "Gimp", function()
				bs()
				RunConsoleCommand( "ulx", "gimp", ply:Nick() )
			end ):SetIcon( "icon16/textfield_rename.png" )
			mute:AddOption( "Ungimp", function()
				bs()
				RunConsoleCommand( "ulx", "ungimp", ply:Nick() )
			end ):SetIcon( "icon16/textfield.png" )
		end

		local gag, gagico = menu:AddSubMenu( "Gag Options" )
		gagico:SetIcon( "icon16/sound.png" )

		gag:AddOption( "Gag", function()
			bs()
			RunConsoleCommand( "ulx", "gag", ply:Nick() )
		end ):SetIcon( "icon16/sound_delete.png" )

		gag:AddOption( "Ungag", function()
			bs()
			RunConsoleCommand( "ulx", "ungag", ply:Nick() )
		end ):SetIcon( "icon16/sound_add.png" )
	end

	-- Commands only for superadmins
	if LocalPlayer():IsSuperAdmin() then

		menu:AddSpacer()

		menu:AddOption( "Respawn", function()
			bs()
			RunConsoleCommand( "ulx", "respawn", ply:Nick() )
		end ):SetIcon( "icon16/arrow_rotate_anticlockwise.png" )

		menu:AddOption( "Respawn (Silent)", function()
			bs()
			RunConsoleCommand( "ulx", "srespawn", ply:Nick() )
		end ):SetIcon( "icon16/arrow_rotate_anticlockwise.png" )

		menu:AddOption( "Grant GodMode", function()
			bs()
			RunConsoleCommand( "ulx", "god", ply:Nick() )
		end ):SetIcon( "icon16/shield_add.png" )

		menu:AddOption( "Revoke GodMode", function()
			bs()
			RunConsoleCommand( "ulx", "ungod", ply:Nick() )
		end ):SetIcon( "icon16/shield_delete.png" )

		menu:AddOption( "Toggle Noclip", function()
			bs()
			RunConsoleCommand( "ulx", "noclip", ply:Nick() )
		end ):SetIcon( "icon16/wand.png" )

		local force, forceico = menu:AddSubMenu( "Force Role" )
		forceico:SetIcon( "icon16/user_go.png" )

		force:AddOption( "Innocent", function()
			bs()
			RunConsoleCommand( "ulx", "force", ply:Nick(), "innocent" )
		end ):SetIcon( "icon16/user_green.png" )

		force:AddOption( "Traitor", function()
			bs()
			RunConsoleCommand( "ulx", "force", ply:Nick(), "traitor" )
		end ):SetIcon( "icon16/user_red.png" )

		force:AddOption( "Detective", function()
			bs()
			RunConsoleCommand( "ulx", "force", ply:Nick(), "detective" )
		end ):SetIcon( "icon16/user.png" )

		local forcesilent, forcesilentico = menu:AddSubMenu( "Force Role (Silent)" )
		forcesilentico:SetIcon( "icon16/user_go.png" )

		forcesilent:AddOption( "Innocent", function()
			bs()
			RunConsoleCommand( "ulx", "sforce", ply:Nick(), "innocent" )
		end ):SetIcon( "icon16/user_green.png" )

		forcesilent:AddOption( "Traitor", function()
			bs()
			RunConsoleCommand( "ulx", "sforce", ply:Nick(), "traitor" )
		end ):SetIcon( "icon16/user_red.png" )

		forcesilent:AddOption( "Detective", function()
			bs()
			RunConsoleCommand( "ulx", "sforce", ply:Nick(), "detective" )
		end ):SetIcon( "icon16/user.png" )

		menu:AddOption( "Give Credits", function()
			bs()
			Derma_StringRequest( "Give Credits - Amount", "Amount of credits to give:", "", function( amount )
				RunConsoleCommand( "ulx", "credits", ply:Nick(), tonumber( amount ) )
			end,
			function()
			end )
		end ):SetIcon( "icon16/coins_add.png" )

	end

end )

-- TTT Scoreboard player name colors
-- moved away from sb_row.lua to use the intended hook instead.

local colorgroups = {
	"superadmin",
	"admin",
	"moderator",
	"tempmod"
}

hook.Add( "TTTScoreboardColorForPlayer", "DT_TTTScoreboardColorForPlayer", function( ply )

	if GetGlobalBool( "ttt_highlight_admins", true ) then
		local group = ply:GetUserGroup()
		if table.HasValue( colorgroups, group ) then
			return DT_RankColors[ group ]
		else
			return Color( 255, 255, 255 )
		end
	else
		return Color( 255, 255, 255 )
	end

end )

-- Created by bamq.
