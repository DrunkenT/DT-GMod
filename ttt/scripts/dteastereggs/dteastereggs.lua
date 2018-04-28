
--[[-----------------------------------------------------------------------//
* 
* Created by bamq. (http://steamcommunity.com/id/bamq)
* Garry's Mod Trouble in Terrorist Town - Easter Eggs for The Drunken T's TTT
* 22 February 2017
* 
* Easter eggs system for GMod TTT designed for The Drunken T's TTT server.
* http://steamcommunity.com/groups/thedrunkent
* Features:
* - Typing specific phrases in chat will trigger the matching easter egg
* to be discovered. PointShop points will be rewarded if enabled.
* - Player data is stored on the server. Each player has a unique text
* file which is named as their Steam Community ID (SteamID64).
* - Using the !myeggs command, a player may request their list of discovered
* easter eggs. The data is sent from the server and displayed on the screen.
* 
//-----------------------------------------------------------------------]]--

DT_Eggs = DT_Eggs or {} -- don't touch this
DT_Eggs.Config = DT_Eggs.Config or {} -- or this

-- ////// CONFIG ////// --

-- DT_Eggs.Config.UsePointShop - Should we award PointShop points for discovering easter eggs?
-- Requires PointShop to be installed.
DT_Eggs.Config.UsePointShop					= true

-- DT_Eggs.Config.PointsForEgg - How many PointShop points should be rewarded for finding an easter egg?
-- For this to do anything, DT_Eggs.UsePointShop must be set to true.
DT_Eggs.Config.PointsForEgg					= 500

-- DT_Eggs.Config.TTTDisableDuringRounds - Disables the ability to discover easter eggs while the round is active
-- and the player is alive and not spectating. If the player is dead or spectating, he/she can still
-- discover easter eggs while the round is active.
DT_Eggs.Config.TTTDisableDuringRounds		= true

-- Add easter eggs to this list.
if SERVER then
	DT_EggsList = {
		"!tellbreen",
		"!dankpotatoes",
		"!heythatsprettygood",
		"!takethechance",
		"!dankmemes",
		"!bamq",
		"!holygoalie10",
		"!drunkentraitors",
		"!kosqwiqk",
		"!herecomedatboi",
		"!spacestation",
		"!dunkey",
		"!cancer",
		"!detective",
		"!traitor",
		"!innocent",
		"!seeder4admin",
		"!badmin",
		"!terrortown",
		"!swag",
		"!scumbagkyro",
		"!abuse",
		"!kappa",
		"!sgscrub",
		"!pcmasterrace",
		"!bushdid911",
		"!tneconni",
		"!minecraft",
		"!mememaster10",
		"!360noscope",
		"!cactusgun",
		"!farmersonly",
		"!hitbox",
		"!bestbuy",
		"!wasd",
		"!oshitwaddup",
		"!drunkent",
		"!stormthefront",
		"!potatofarm",
		"!donate"
	}
end

-- ////// END OF CONFIG ////// --

if SERVER then

	util.AddNetworkString( "DT_Eggs_DiscoverEggMessage" ) -- for discovered egg messasges.
	util.AddNetworkString( "DT_Eggs_NormalMessage" ) -- for regular messages.
	util.AddNetworkString( "DT_Eggs_PlayerRequestedList" ) -- for when player requests their list of found eggs.

	local PLAYER = FindMetaTable( "Player" )

	-- Make sure the proper directories exist in the data folder on the server.
	if not file.IsDir( "drunkent", "DATA" ) then
		file.CreateDir( "drunkent" )
	end
	if not file.IsDir( "drunkent/dt_eastereggs_playerdata", "DATA" ) then
		file.CreateDir( "drunkent/dt_eastereggs_playerdata" )
	end

	-- Creates a player's data file on the server if it doesn't already exist.
	function DT_Eggs.InitializePlayerFile( ply )
		if not file.Exists( "drunkent/dt_eastereggs_playerdata/" .. ply:SteamID64() .. ".txt", "DATA" ) then
			file.Write( "drunkent/dt_eastereggs_playerdata/" .. ply:SteamID64() .. ".txt", util.TableToJSON( {} ) )
		end
	end

	-- Handles converting the table to a JSON string and writing the player's data to the file.
	function DT_Eggs.WriteTableToPlayerFile( ply, tbl )
		file.Write( "drunkent/dt_eastereggs_playerdata/" .. ply:SteamID64() .. ".txt", util.TableToJSON( tbl ) )
	end

	-- Returns the player's data file converted from a JSON string to a Lua table.
	function PLAYER:DT_Eggs_ReadPlayerFileTable()
		DT_Eggs.InitializePlayerFile( self )
		return util.JSONToTable( file.Read( "drunkent/dt_eastereggs_playerdata/" .. self:SteamID64() .. ".txt", "DATA" ) )
	end

	-- Sends a list of the player's discovered easter eggs to the player.
	function DT_Eggs.SendRequestedEggListToPlayer( ply )
		local playerEggs = ply:DT_Eggs_ReadPlayerFileTable()
		timer.Simple( 0.5, function()
			net.Start( "DT_Eggs_PlayerRequestedList" )
			net.WriteTable( playerEggs )
			net.Send( ply )
		end )
	end

	-- Sends a chat message to the player when they discover an easter egg.
	function DT_Eggs.PlayerMessageFoundEgg( ply, egg )
		timer.Simple( 0.5, function()
			net.Start( "DT_Eggs_DiscoverEggMessage" )
			net.WriteString( egg )
			net.Send( ply )
		end )
	end

	-- Sends a chat message to the player that just contains normal text.
	function DT_Eggs.PlayerMessageNormal( ply, message )
		timer.Simple( 0.5, function()
			net.Start( "DT_Eggs_NormalMessage" )
			net.WriteString( message )
			net.Send( ply )
		end )
	end

	-- Checks if the player has discovered a particular easter egg.
	function PLAYER:DT_Eggs_HasDiscoveredEasterEgg( egg )
		return table.HasValue( self:DT_Eggs_ReadPlayerFileTable(), egg )
	end

	-- Called on the player when they discover an easter egg. Checks if they already have discovered it,
	-- and tells the player and writes the updated table to the player data file if they have not.
	function PLAYER:DT_Eggs_DiscoverEasterEgg( egg )
		if self:DT_Eggs_HasDiscoveredEasterEgg( egg ) then
			DT_Eggs.PlayerMessageNormal( self, "You have already found this easter egg!" )
			return
		end

		local playerEggs = self:DT_Eggs_ReadPlayerFileTable()
		table.insert( playerEggs, egg )
		DT_Eggs.WriteTableToPlayerFile( self, playerEggs )

		DT_Eggs.PlayerMessageFoundEgg( self, egg )
		MsgN( "[Easter Eggs]: LOG (" .. os.date( "%H:%M - %m/%d/%Y", os.time() ) .. ") " .. self:Nick() .. " [" .. self:SteamID() .. "] has discovered easter egg " .. egg .. "." )

		if DT_Eggs.Config.UsePointShop then
			self:PS_GivePoints( DT_Eggs.Config.PointsForEgg )
		end
	end

	-- Removes an easter egg from the player's list of discovered easter eggs.
	function PLAYER:DT_Eggs_UndiscoverEasterEgg( egg )
		local playerEggs = self:DT_Eggs_ReadPlayerFileTable()
		if self:DT_Eggs_HasDiscoveredEasterEgg( egg ) then
			table.RemoveByValue( playerEggs, egg )
		end
		DT_Eggs.WriteTableToPlayerFile( self, playerEggs )
	end

	-- Remind everyone that they cannot discover easter eggs in an active round if TTTDisableDuringRounds is true.
	hook.Add( "TTTBeginRound", "DT_Eggs_ActiveRoundReminder_TTTBeginRound", function()
		if not DT_Eggs.Config.TTTDisableDuringRounds then return end
		for _, ply in pairs( player.GetAll() ) do
			DT_Eggs.PlayerMessageNormal( ply, "Reminder: discovery is disabled during rounds unless you are dead or spectating!" )
		end
	end )

	-- Chat hook for finding if the player has entered an easter egg.
	hook.Add( "PlayerSay", "DT_Eggs_ChatDiscoverEgg_PlayerSay", function( ply, text, isTeam )
		if not IsValid( ply ) then return end -- Silly console, easter eggs are for players.

		if DT_Eggs.Config.TTTDisableDuringRounds and ( GetRoundState() == ROUND_ACTIVE ) and ply:Alive() and not ply:IsSpec() then return end

		local cmd = string.lower( text )

		-- table.HasValue is slow, might be a better way to do this.
		if table.HasValue( DT_EggsList, cmd ) then
			ply:DT_Eggs_DiscoverEasterEgg( cmd )
		end
	end )

	hook.Add( "PlayerSay", "DT_Eggs_ChatRequestDiscoveredList_PlayerSay", function( ply, text, isTeam )
		if not IsValid( ply ) then return end
		text = string.lower( text )
		if text == "!myeggs" then
			DT_Eggs.SendRequestedEggListToPlayer( ply )
		end
	end )

end

if CLIENT then

	local function EggsMenu( eggs )

		local EggsFrame = vgui.Create( "DFrame" )
		EggsFrame:SetSize( 250, 175 )
		EggsFrame:SetTitle( "Easter Eggs List" )
		EggsFrame:Center()
		EggsFrame:SetSizable( true )
		EggsFrame:ShowCloseButton( true )
		EggsFrame:MakePopup()
		function EggsFrame:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 150, 255, 150 ) )
		end

		local EggsPanel = vgui.Create( "DPanel", EggsFrame )
		EggsPanel:Dock( FILL )

		local EggsListView = vgui.Create( "DListView", EggsPanel )
		EggsListView:AddColumn( "Easter Eggs" )
		for _, egg in ipairs( eggs ) do
			EggsListView:AddLine( egg )
		end
		EggsListView:Dock( FILL )

	end

	net.Receive( "DT_Eggs_NormalMessage", function()
		local message = net.ReadString()

		chat.AddText( Color( 50, 200, 255 ), "[Easter Eggs]: ", Color( 255, 255, 255 ), message )
	end )

	net.Receive( "DT_Eggs_DiscoverEggMessage", function()
		local egg = net.ReadString()

		local MSG = {}
		table.insert( MSG, Color( 50, 200, 255 ) )
		table.insert( MSG, "[Easter Eggs]: " )
		table.insert( MSG, Color( 255, 255, 0 ) )
		table.insert( MSG, "Congratulations! You have found easter egg " )
		table.insert( MSG, Color( 255, 255, 255 ) )
		table.insert( MSG, "\"" .. egg .. "\"" )
		table.insert( MSG, Color( 255, 255, 0 ) )
		table.insert( MSG, "!\n" )
		if DT_Eggs.Config.UsePointShop then
			table.insert( MSG, Color( 255, 255, 0 ) )
			table.insert( MSG, "You've earned " )
			table.insert( MSG, Color( 255, 255, 255 ) )
			table.insert( MSG, tostring( DT_Eggs.Config.PointsForEgg ) .. " " )
			table.insert( MSG, Color( 255, 255, 0 ) )
			table.insert( MSG, PS.Config.PointsName .. "!\n" )
		end

		surface.PlaySound( "UI/buttonclick.wav" )
		chat.AddText( unpack( MSG ) )
	end )

	net.Receive( "DT_Eggs_PlayerRequestedList", function()
		local eggs = net.ReadTable()
		EggsMenu( eggs )
	end )

end

-- Created by bamq.
