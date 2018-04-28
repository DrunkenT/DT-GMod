
--[[

	Modified version of the regular chat tags script.
	
	This is a little cleaner and has some added functionality
	
]]--

AddCSLuaFile()
print( "DT Chat Tags script loaded successfully." )

-- Global rank colors, can be used by other addons.
DT_RankColors = {
	superadmin				= Color( 255, 255, 0 ),
	admin					= Color( 255, 100, 0 ),
	moderator				= Color( 0, 200, 255 ),
	tempmod					= Color( 0, 100, 155 ),
	trusted					= Color( 50, 200, 0 ),
	donorbasic				= Color( 116, 27, 71 ),
	donoradvanced			= Color( 166, 28, 0 ),
	donorpremium			= Color( 241, 194, 50 ),
	donorelite				= Color( 106, 168, 79 ),
	donorlegendary			= Color( 153, 0, 255 ),
	donorlegacy				= Color( 227, 208, 0 ),
	user					= Color( 255, 255, 255 )
}

DT_DonatorColors = {
	basic					= Color( 116, 27, 71 ),
	advanced				= Color( 166, 28, 0 ),
	vip						= Color( 0, 28, 166 ),
	premium					= Color( 241, 194, 50 ),
	elite					= Color( 106, 168, 79 ),
	legendary				= Color( 153, 0, 255 ),
	legacy					= Color( 227, 208, 0 )
}

local Colors = {
	white					= Color( 255, 255, 255 ),
	black					= Color( 0, 0, 0 ),
	gray					= Color( 125, 125, 125 ),
	lightgray				= Color( 200, 200, 200 ),
	red						= Color( 255, 0, 0 ),
	green					= Color( 0, 255, 0 ),
	blue					= Color( 0, 0, 255 ),
	lightgreen				= Color( 75, 255, 75 ),
	lightblue				= Color( 0, 175, 255 ),
	lightred				= Color( 255, 75, 75 ),
	purple					= Color( 200, 50, 255 ),
	orange					= Color( 255, 150, 0 ),
	pink					= Color( 255, 50, 150 ),
	yellow					= Color( 255, 255, 0 ),
	darkblue				= Color( 5, 49, 125 ),
	gold					= Color( 227, 189, 0 )
}

local AllowedUserChatColors = {
	"white",
	"red",
	"green",
	"blue",
	"lightgreen",
	"lightblue",
	"lightred",
	"purple",
	"orange",
	"pink",
	"yellow"
}
--------------

local Tags = {}
Tags[1] = { "Owner", "superadmin", DT_RankColors.superadmin }
Tags[2] = { "Admin", "admin", DT_RankColors.admin }
Tags[3] = { "Moderator", "moderator", DT_RankColors.moderator }
Tags[4] = { "Temp Mod", "tempmod", DT_RankColors.tempmod }
Tags[5] = { "Trusted", "trusted", DT_RankColors.trusted }
Tags[6] = { "Guest", "user", DT_RankColors.user }
Tags[7] = { "Donor", "basic", DT_DonatorColors.basic }
Tags[8] = { "Advanced Donor", "advanced", DT_DonatorColors.advanced }
Tags[9] = { "VIP Donor", "vip", DT_DonatorColors.vip }
Tags[10] = { "Premium Donor", "premium", DT_DonatorColors.premium }
Tags[11] = { "Elite Donor", "elite", DT_DonatorColors.elite }
Tags[12] = { "Legendary Donor", "legendary", DT_DonatorColors.legendary }
Tags[13] = { "Legacy Donor", "legacy", DT_DonatorColors.legacy }

local CustomTags = {}

if SERVER then

	local function ConfirmChatColor( ply )
		local pdata = ply:GetPData( "dt_chatcolor" )
		if pdata ~= nil then
			ply:SetNWString( "dt_chatcolor", pdata )
		end
	end

	hook.Add( "PlayerSay", "DT_SetChatColor_PlayerSay", function( ply, text, teamonly )
		text = string.lower( text )
		if string.sub( text, 1, 15 ) == "!setmychatcolor" then
			if not ply:DT_IsPremiumDonorOrHigher() and not ply:IsSuperAdmin() then
				ply:ChatPrint( "You cannot use this! You must be Premium Donor or higher!" )
				return false
			end
			local str = string.Explode( " ", text )
			local color = str[ 2 ]
			if color ~= nil then
				if table.HasValue( AllowedUserChatColors, color ) then
					ply:SetPData( "dt_chatcolor", color )
					ply:ChatPrint( "Chat color set to " .. string.upper( color ) .. "!" )
					ConfirmChatColor( ply )
				elseif color == "help" then
					timer.Simple( 1, function()
						ply:ChatPrint( "Chat color help!" )
						ply:ChatPrint( "----" )
						ply:ChatPrint( "To set your chat color, type !setmychatcolor <color>" )
						ply:ChatPrint( "The valid chat colors are: " )
						for _, col in ipairs( AllowedUserChatColors ) do
							ply:ChatPrint( col )
						end
						ply:ChatPrint( "---" )
						ply:ChatPrint( "Scroll up in chat to see the help!" )
					end )
				else
					ply:ChatPrint( "INVALID COLOR! Type !setmychatcolor help for help!" )
				end
			else
				ply:ChatPrint( "Type !setmychatcolor help for help!" )
			end
			return false
		end
	end )

	hook.Add( "PlayerInitialSpawn", "DT_SetChatColor_PlayerInitialSpawn", function( ply )
		ConfirmChatColor( ply )
	end )

end

hook.Add( "OnPlayerChat", "DT_ChatTags_OnPlayerChat", function( ply, text, isTeam, isDead )

	local CHAT = {}

	local ghost
	if IsValid( ply ) then
		ghost = ply:IsGhost()
	else
		ghost = false
	end

	if ghost then
		table.insert( CHAT, Colors.gray )
		table.insert( CHAT, "[SpecDM] " )
	end

	if isDead then
		table.insert( CHAT, Colors.red )
		table.insert( CHAT, "[DEAD] " )
	end

	if IsValid( ply ) then

		for _, tag in pairs( Tags ) do
			if ply:DT_IsDonatorRank( tag[2] ) then

				table.insert( CHAT, tag[3] )
				table.insert( CHAT, "{" .. tag[1] .. "} | ")

			end
			if ply:IsUserGroup( tag[ 2 ] ) then
				table.insert( CHAT, tag[ 3 ] )
				table.insert( CHAT, "-( " .. tag[ 1 ] .. " )- | " )
			end

		end

		for _, ctag in pairs( CustomTags ) do
			if ply:SteamID() == ctag[2] then
				table.insert( CHAT, ctag[3] )
				table.insert( CHAT, ctag[1] .. " | " )

				break
			end
		end

		if ply:IsDetective() and ply:Alive() and not ghost then

			table.insert( CHAT, Color( 25, 200, 255 ) )

		elseif ghost then

			table.insert( CHAT, Colors.lightgray )

		else

			table.insert( CHAT, team.GetColor( ply:Team() ) )

		end

		table.insert( CHAT, ply:Nick() )

		table.insert( CHAT, Colors.white )
		table.insert( CHAT, ": " )

		local chatcolor = Colors[ ply:GetNWString( "dt_chatcolor" ) ]
		if chatcolor ~= nil then

			table.insert( CHAT, chatcolor )

		else

			table.insert( CHAT, Colors.white )

		end

		table.insert( CHAT, text )

	else

		table.insert( CHAT, Colors.red )
		table.insert( CHAT, "(CONSOLE): " .. text )

	end

	chat.PlaySound()
	chat.AddText( unpack( CHAT ) )

	return true

end )
