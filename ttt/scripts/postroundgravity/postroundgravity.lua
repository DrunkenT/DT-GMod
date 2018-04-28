

--[[ =======================================================================================

	Post-round anti-gravity for TTT.
	
	Created by bamq for The Drunken T's Trouble in Terrorist Town server.
	http://drunkent.com/
	
]]-- =======================================================================================




if SERVER then

	-- precache the net string to send to clients.
	util.AddNetworkString( "DT_NewGravity" )
	util.AddNetworkString( "DT_DefGravity" )
	CreateConVar( "ttt_postroundgravity_scale", 0.5, FCVAR_ARCHIVE, "Gravity scale during post-round phase." )
	
	dt_isgrav = false -- Global serverside value for use in other scripts. true = gravity is currently active, false = gravity is not currently active.

	function DT_EndRoundGravity( r )
		
	
		if r == WIN_TRAITOR or r == WIN_INNOCENT then -- won't activate unless a team actually won, not if the time just runs out.

			dt_newgrav = GetConVar( "ttt_postroundgravity_scale" ):GetFloat() -- new gravity scale to set to.
			dt_defgrav = 1 -- remember the default gravity scale to set back to.
			
			local time = GetConVar( "ttt_posttime_seconds" ):GetInt() - 5 -- get the post-round time, minus 5 seconds.
			
			for k, a in pairs( player.GetAll() ) do
				if IsValid( a ) then
					a:SetGravity( dt_newgrav ) -- set gravity scale for each player.
				end
			end
			
				net.Start( "DT_NewGravity" )
				net.WriteFloat( dt_newgrav ) -- send gravity value.
				net.Broadcast() -- tell all players that the gravity was set.
				
			MsgN( "Round has ended, setting post-round gravity to " .. math.Round( dt_newgrav, 2 ) .. "." ) -- print to server console.
			
			dt_isgrav = true
			
			timer.Simple( time, function() -- after (post-round time minus 5 seconds):
				for k, b in pairs( player.GetAll() ) do
					if IsValid( b ) then
						b:SetGravity( dt_defgrav ) -- reset gravity scale for each player.
					end
				end
				
					net.Start( "DT_DefGravity" )
					net.WriteFloat( dt_defgrav ) -- send gravity value
					net.Broadcast() -- tell all players that the gravity was reset back to default.
					
				MsgN( "Resetting gravity back to default. (" .. math.Round( dt_defgrav, 2 ) .. ")" ) -- print to server console.
				
				dt_isgrav = false
			end )

		end
		
	end
	hook.Add( "TTTEndRound", "DT_EndRoundGravity", DT_EndRoundGravity )
	
end

if CLIENT then

	dt_svgravx = GetConVar( "sv_gravity" ):GetInt()

	-- clients will receive the message from server.

	net.Receive( "DT_NewGravity", function()
		local g = math.Round( net.ReadFloat(), 2 ) -- read gravity value
		local grx = math.Round( dt_svgravx * g, 2 )
		-- print message to chat. Gravity changed to new value.
		chat.AddText( Color( 255, 255, 255 ), "The round ended! Setting gravity scale to ", Color( 255, 0, 0 ), tostring( g ) .. " (" .. tostring( grx ) .. ")", Color( 255, 255, 255 ), "!" )
	end )
	
	net.Receive( "DT_DefGravity", function()
		local d = math.Round( net.ReadFloat(), 2 ) -- read gravity value
		local drx = math.Round( dt_svgravx * d, 2 )
		-- print message to chat. Gravity reset to default value.
		chat.AddText( Color( 255, 255, 255 ), "Setting gravity scale back to default of ", Color( 25, 225, 255 ), tostring( d ) .. " (" .. tostring( drx ) .. ")", Color( 255, 255, 255 ), "!" )
	end )

end

