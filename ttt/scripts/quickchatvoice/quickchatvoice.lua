
--[[-----------------------------------------------------------------------//
* 
* Created by bamq.
* Garry's Mod Trouble in Terrorist - Quickchat Voice Sounds
* 30 September 2016 | Updated 20 January 2017
* 
* Doing a TTT quickchat will cause the player's character to emit a
* line of dialogue appropriate for that quickchat.
* 
//-----------------------------------------------------------------------]]--

-- commands that don't have a target.
local DT_QV_NoTarg = {}
DT_QV_NoTarg[ "quick_yes" ]			= { "vo/npc/male01/yeah02.wav", "vo/npc/male01/yougotit02.wav", "vo/npc/male01/ok01.wav", "vo/npc/male01/ok02.wav" }
DT_QV_NoTarg[ "quick_help" ]		= { "vo/StreetWar/sniper/male01/c17_09_help02.wav", "vo/StreetWar/sniper/male01/c17_09_help01.wav", "vo/npc/male01/help01.wav", "vo/coast/bugbait/sandy_help.wav" }
DT_QV_NoTarg[ "quick_no" ]			= { "vo/npc/male01/no01.wav", "vo/npc/male01/no02.wav", "vo/npc/male01/ohno.wav" }
DT_QV_NoTarg[ "quick_check" ]		= { "vo/trainyard/wife_please.wav", "vo/Streetwar/sniper/male01/c17_09_help03.wav" }

-- commands that do have a target.
local DT_QV_Targ = {}
DT_QV_Targ[ "quick_imwith" ]		= { "vo/npc/Barney/ba_imwithyou.wav" }
DT_QV_Targ[ "quick_see" ]			= { "vo/npc/male01/hi01.wav", "vo/npc/male01/hi02.wav", "vo/npc/male01/overthere01.wav", "vo/npc/male01/overthere02.wav" }
DT_QV_Targ[ "quick_suspect" ]		= { "vo/npc/male01/watchwhat.wav", "vo/npc/male01/excuseme01.wav", "vo/npc/male01/goodgod.wav", "vo/npc/male01/headsup01.wav" }
DT_QV_Targ[ "quick_traitor" ]		= { "vo/Streetwar/sniper/ba_overhere.wav", "vo/Streetwar/rubble/ba_illbedamned.wav", "vo/Streetwar/rubble/ba_helpmeout.wav", "vo/ravenholm/wrongside_town.wav", "vo/coast/bugbait/sandy_youthere.wav", "vo/npc/Barney/ba_bringiton.wav" }
DT_QV_Targ[ "quick_inno" ]			= { "vo/k_lab2/ba_goodnews.wav", "vo/k_lab2/ba_goodnews_b.wav", "vo/k_lab2/kl_notallhopeless_b.wav", "vo/npc/Barney/ba_laugh01.wav" }

hook.Add( "TTTPlayerRadioCommand", "DT_QuickchatVoice_TTTPlayerRadioCommand", function( ply, cmd, target )

	if DT_QV_NoTarg[ cmd ] ~= nil then
		ply:EmitSound( DT_QV_NoTarg[ cmd ][ math.random( 1, #DT_QV_NoTarg[ cmd ] ) ] )
	elseif DT_QV_Targ[ cmd ] ~= nil then
		if target == "quick_nobody" then
			return
		else
			ply:EmitSound( DT_QV_Targ[ cmd ][ math.random( 1, #DT_QV_Targ[ cmd ] ) ] )
		end
	end

end )

-- Created by bamq.
