

if SERVER then

	print( "TTT M9K Weapons v0.01 - by bamq." )
	
end




// ADD WEAPON SOUNDS



//MP40
sound.Add({
	name = 			"mp40.single",
	channel = 		CHAN_USER_BASE+10,
	volume = 		1.0,
	sound = 			"weapons/mp40/mp5-1.wav"
})

sound.Add({
	name = 			"Weapon_mp40m9k.Clipout",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/mp40/magout.mp3"
})

sound.Add({
	name = 			"Weapon_mp40m9k.Clipin",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/mp40/magin.mp3"
})

sound.Add({
	name = 			"Weapon_mp40m9k.Slideback",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = 			"weapons/mp40/boltback.mp3"
})

//P229R
sound.Add({
	name = 			"Sauer1_P228.Single",
	channel =		CHAN_USER_BASE+10,
	volume =		1,
	sound =			"weapons/sig_p228/p228-1.wav"
})

sound.Add({
	name = 			"Sauer1_P228.Magout",
	channel =		CHAN_ITEM,
	volume =		1,
	sound =			"weapons/sig_p228/magout.mp3" 
})

sound.Add({
	name = 			"Sauer1_P228.Magin",
	channel =		CHAN_ITEM,
	volume =		1,
	sound =			"weapons/sig_p228/magin.mp3" 
})

sound.Add({
	name = 			"Sauer1_P228.MagShove",
	channel =		CHAN_ITEM,
	volume =		1,
	sound =			"weapons/sig_p228/magshove.mp3" 
})

sound.Add({
	name = 			"Sauer1_P228.Sliderelease",
	channel =		CHAN_ITEM,
	volume =		1,
	sound =			"weapons/sig_p228/sliderelease.mp3"
})

sound.Add({
	name = 			"Sauer1_P228.Cloth",
	channel =		CHAN_ITEM,
	volume =		.5,
	sound =			"weapons/sig_p228/cloth.mp3"
})

sound.Add({
	name = 			"Sauer1_P228.Shift",
	channel =		CHAN_ITEM,
	volume =		1,
	sound =			"weapons/sig_p228/shift.mp3"
})
