----------------------------------
------------COPYRIGHT-------------
-- Editing the code as a refrence is allowed. 
-- if u wanna publish your edited code, don't forget to give a refrence in addon descriptions.

-- DONT republish the same addon 
----------------------------------

if SERVER then
	AddCSLuaFile()
end

if LocalPlayer then

	-- Add Typefaces for HUD
	surface.CreateFont( "Numbers", {
		font = "TEST",
		extended = true,
		size = 89,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "Trebuchet", {
		font = "Trebuchet MS",
		extended = true,
		size = 24,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "WPIcons", {
		font = "LFHUD_GMODICONS",
		extended = false,
		size = 150,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "OrbitMed", {
		font = "Orbitron-Medium",
		extended = false,
		size = 22,
		weight = 0,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )


	-- Add HUD Colors
	local BGColor = Color(10,10,10,229)
	local AccentColor = Color(0,225,225,255)
	local DisabledColor = Color(128,128,128,225)
	local Warning = Color(255,156,0,255)
	local EmptyMag = Color(255,0,0,255)
	local DamageColor = Color(200,10,10,225)
	local ArmorRecharge = Color(88,174,255,225)
	local ArmorDecrease = Color(225,10,10,225)
	local HealingColor = Color(88,255,205,225)

	
	-- Define some variables to fit the HUD better in screen space
	local ScreenVars = {
		['x']=1/64,
		['y']=1/64*ScrW()/ScrH()
	}

	-- Heal/Lose Animation Variables
	local HealthColor = Color(AccentColor.r,AccentColor.g,AccentColor.b,AccentColor.a)

	local ArmorColor = Color(AccentColor.r,AccentColor.g,AccentColor.b,AccentColor.a)

	local FadeSpeed = 300

	local OldHealth = 100

	local OldArmor = 0

	-- Hide default gmod HUD
	local HiddenElements = {
		['CHudHealth']=true,
		['CHudBattery']=true,
		['CHudAmmo']=true,
		['CHudSecondaryAmmo']=true
	}

	-- Define Some information for drawing HP & Armor Icons
	local HealthIconInfo = {
		['text'] = nil,
		['font'] = nil,
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_CENTER,
		['color'] = AccentColor
	}

	local ArmorIconInfo = {
		['text'] = nil,
		['font'] = nil,
		['pos'] = {0,0},
		['xalign'] = TEXT_ALIGN_LEFT,
		['yalign'] = TEXT_ALIGN_CENTER,
		['color'] = AccentColor
	}
	
	


	local function ShouldDraw()
		local myplayer = LocalPlayer()
		if !IsValid(myplayer) then 
			return 
		end
		if !myplayer:Alive() then 
			return false 
		end
		return ( GetConVarNumber("cl_drawhud",1) == 1 ) and true or false
	end

	local function HideHUD( el )
		if HiddenElements[el] then 
			return false
		end
	end


	local function DrawTheHUD()

		local myplayer = LocalPlayer()

		local HealthIconTable = {
			['text'] = "A",
			['font'] = "Numbers",
			['pos'] = {3,3},
			['xalign'] = TEXT_ALIGN_LEFT,
			['yalign'] = TEXT_ALIGN_CENTER,
			['color'] = HealthColor
		}



		if !ShouldDraw() then 
			return 
		end
		
		local w,h = ScrW(), ScrH()
		
		local xx, yy
		
		local iconx,icony
		
		local textx,texty = 19,16
		
		function CyberpunkUIShape( leftx, downy, fillcolor, linecolor, wid, hei, bendsize, offset, identifier )
			local shapebg = {
				{ x = leftx+bendsize, y = downy-hei }, -- top left
				{ x = leftx , y = downy }, -- down left
				{ x = leftx+wid, y = downy }, -- down right
				{ x = leftx+wid+bendsize, y = downy-hei } -- top right
			}
			
			local function DrawIt()
 
				surface.SetDrawColor(fillcolor)
				surface.DrawPoly( shapebg )
			 
				
				surface.SetDrawColor(linecolor)
				surface.DrawLine(leftx+bendsize+offset, downy-hei+offset, leftx+wid+bendsize-offset-2, downy-hei+offset) -- top
				surface.DrawLine(leftx+offset+1, downy-offset-1, leftx+wid-offset, downy-offset-1) -- down
				surface.DrawLine(leftx+bendsize+offset, downy-hei+offset, leftx+offset+1, downy-offset) -- left
				surface.DrawLine(leftx+wid+bendsize-offset-2, downy-hei+offset, leftx+wid-offset-1, downy-offset)
			end
			hook.Add("HUDPaint", identifier , DrawIt)
		end

		xx=w*ScreenVars.x
		yy=h-h*(ScreenVars.y)
		
		--draw.RoundedBox(0,0,yy,w,1,color_white)
		
		--Health	

		yy=yy+5
		
		surface.SetDrawColor(BGColor)
		
		HealthIconInfo.pos = {xx+1,yy+9}
		
		HealthIconInfo.text =  ""
		
		HealthIconInfo.font =  "Numbers"
		
		HealthIconInfo.xalign = TEXT_ALIGN_LEFT
		HealthIconInfo.yalign = TEXT_ALIGN_CENTER
		

		if myplayer:Health()<1 then
			HealthIconInfo.color = DisabledColor
			HealthIconTable.color = DisabledColor
		else
			HealthIconInfo.color = AccentColor
			HealthIconTable.color = AccentColor
		end

		local healthpercentforbar = math.Clamp( myplayer:Health() / math.max( myplayer:GetMaxHealth(), 1 ), 0, 1)*165

		HealthIconTable.pos = {xx+5,yy-45}

		HealthIconTable.color = HealthColor
		HealthIconInfo.color = HealthColor
		draw.Text( HealthIconTable )
		
		HealthIconInfo.pos[1] = HealthIconInfo.pos[1]+125
		
		HealthIconInfo.pos[2] = HealthIconInfo.pos[2]-55
		
		HealthIconInfo.xalign = TEXT_ALIGN_CENTER
		HealthIconInfo.yalign = TEXT_ALIGN_CENTER
		
		HealthIconInfo.text =  tostring(math.ceil(myplayer:Health()))
		
		HealthIconInfo.text = string.sub(HealthIconInfo.text,1,math.min(string.len(HealthIconInfo.text),3))
		
		HealthIconInfo.font =  "Numbers"
		
		iconx,icony = draw.Text( HealthIconInfo )

		local healthpercent = math.Clamp( myplayer:Health() / math.max( myplayer:GetMaxHealth(), 1 ), 0, 1)
		
		if HealthColor.r>AccentColor.r then
			HealthColor.r = math.Clamp(math.max(HealthColor.r-FrameTime()*FadeSpeed,AccentColor.r),0,255)
		elseif HealthColor.r<AccentColor.r then
			HealthColor.r = math.Clamp(math.min(HealthColor.r+FrameTime()*FadeSpeed,AccentColor.r),0,255)
		end
		
		if HealthColor.g>AccentColor.g then
			HealthColor.g = math.Clamp(math.max(HealthColor.g-FrameTime()*FadeSpeed,AccentColor.g),0,255)
		elseif HealthColor.g<AccentColor.g then
			HealthColor.g = math.Clamp(math.min(HealthColor.g+FrameTime()*FadeSpeed,AccentColor.g),0,255)
		end
		
		if HealthColor.b>AccentColor.b then
			HealthColor.b = math.Clamp(math.max(HealthColor.b-FrameTime()*FadeSpeed,AccentColor.b),0,255)
		elseif HealthColor.b<AccentColor.b then
			HealthColor.b = math.Clamp(math.min(HealthColor.b+FrameTime()*FadeSpeed,AccentColor.b),0,255)
		end
		
		if HealthColor.a>AccentColor.a then
			HealthColor.a = math.Clamp(math.max(HealthColor.a-FrameTime()*FadeSpeed,AccentColor.a),0,255)
		elseif HealthColor.a<AccentColor.a then
			HealthColor.a = math.Clamp(math.min(HealthColor.a+FrameTime()*FadeSpeed,AccentColor.a),0,255)
		end
		
		if myplayer:Health()<OldHealth then
			for k,v in pairs(DamageColor) do
				HealthColor[k]=v
			end
		elseif myplayer:Health()>OldHealth then
			for k,v in pairs(HealingColor) do
				HealthColor[k]=v
			end	
		end
		
		OldHealth = myplayer:Health()
		
		surface.SetDrawColor(HealthColor)
		
		surface.DrawRect( xx+14, yy-12, 180*healthpercent,4 )
		CyberpunkUIShape(xx, yy, BGColor, HealthColor, 204, 80, 16, 2, "health")


		---\/------------------------------\/--
		---     Armor
		---\/------------------------------\/--
		
		yy = yy
		
		-- DrawBlurRect( xx, yy, w/7, 25, 2, 2 )
		
		-- surface.SetDrawColor(BGColor)
		-- surface.DrawRect( xx, yy, w/7,24 ,25 )

		if myplayer:Armor()!=0 then
			
			local ArmorGlobalColor

			if myplayer:Armor()!=0 then
				-- print("YES")

				ArmorGlobalColor = ArmorColor
			elseif myplayer:Armor()==0 then
				-- print("NO")
				
				ArmorGlobalColor = DisabledColor
			end
		
			ArmorIconInfo.color = ArmorGlobalColor
		
			ArmorIconInfo.pos = {xx+210,yy-39}
		
			ArmorIconInfo.text = 'B'
		
			ArmorIconInfo.font =  "Numbers"
		
			ArmorIconInfo.xalign = TEXT_ALIGN_LEFT
			ArmorIconInfo.yalign = TEXT_ALIGN_CENTER
		
			if myplayer:Armor()==0 then
				ArmorColor = DisabledColor
				ArmorIconInfo.color = DisabledColor
				ArmorIconInfo.color = DisabledColor
			else
				ArmorIconInfo.color = AccentColor
				ArmorIconInfo.color = AccentColor
			end
		
			ArmorIconInfo.color = ArmorGlobalColor
			draw.Text( ArmorIconInfo )
		
			ArmorIconInfo.pos[1] = ArmorIconInfo.pos[1]+125
		
			ArmorIconInfo.pos[2] = ArmorIconInfo.pos[2]-7
		
			ArmorIconInfo.xalign = TEXT_ALIGN_CENTER
			ArmorIconInfo.yalign = TEXT_ALIGN_CENTER
		
			ArmorIconInfo.text =  tostring(math.ceil(myplayer:Armor()))
		
			ArmorIconInfo.text = string.sub(ArmorIconInfo.text,1,math.min(string.len(ArmorIconInfo.text),3))
			
			ArmorIconInfo.font =  "Numbers"
		
			iconx,icony = draw.Text( ArmorIconInfo )

			local armorpercent = math.Clamp( myplayer:Armor() / 100, 0, 1)
		
		
			if ArmorColor.r>AccentColor.r then
				ArmorColor.r = math.Clamp(math.max(ArmorColor.r-FrameTime()*FadeSpeed,AccentColor.r),0,255)
			elseif ArmorColor.r<AccentColor.r then
				ArmorColor.r = math.Clamp(math.min(ArmorColor.r+FrameTime()*FadeSpeed,AccentColor.r),0,255)
			end
		
			if ArmorColor.g>AccentColor.g then
				ArmorColor.g = math.Clamp(math.max(ArmorColor.g-FrameTime()*FadeSpeed,AccentColor.g),0,255)
			elseif ArmorColor.g<AccentColor.g then
				ArmorColor.g = math.Clamp(math.min(ArmorColor.g+FrameTime()*FadeSpeed,AccentColor.g),0,255)
			end
		
			if ArmorColor.b>AccentColor.b then
				ArmorColor.b = math.Clamp(math.max(ArmorColor.b-FrameTime()*FadeSpeed,AccentColor.b),0,255)
			elseif ArmorColor.b<AccentColor.b then
				ArmorColor.b = math.Clamp(math.min(ArmorColor.b+FrameTime()*FadeSpeed,AccentColor.b),0,255)
			end
		
			if ArmorColor.a>AccentColor.a then
				ArmorColor.a = math.Clamp(math.max(ArmorColor.a-FrameTime()*FadeSpeed,AccentColor.a),0,255)
			elseif ArmorColor.a<AccentColor.a then
				ArmorColor.a = math.Clamp(math.min(ArmorColor.a+FrameTime()*FadeSpeed,AccentColor.a),0,255)
			end
		
			if myplayer:Armor()<OldArmor then
				for k,v in pairs(ArmorDecrease) do
				ArmorColor[k]=v
			end
			elseif myplayer:Armor()>OldArmor then
				for k,v in pairs(ArmorRecharge) do
					ArmorColor[k]=v
				end	
			end
		
			OldArmor = myplayer:Armor()
		
			surface.SetDrawColor(ArmorColor)

			surface.DrawRect(xx+223, yy-12, 180*armorpercent,4 )
			CyberpunkUIShape(xx+209, yy, BGColor, ArmorGlobalColor, 204, 80, 16, 2, "armor")
		
		else
			hook.Remove("HUDPaint", "armor")
		end


		---\/------------------------------\/--
		---     Weapon & Ammo
		---\/------------------------------\/--

		xx = xx+1147

		local AmmoGlobalColor = Color(255,255,255,255)
		local ShapeLeftX = xx
		local ShapeWidth

		local wp = myplayer:GetActiveWeapon()
		local wpid = wp:GetClass()
		local wpname = wp:GetPrintName() 
		local wpdisp
		local wpcode

		local a2code

		if wpid=="weapon_smg1" then wpcode = "a"   wpdisp = "SMG"
		elseif wpid=="weapon_shotgun" then wpcode = "b"  wpdisp = "Shotgun"
		elseif wpid=="weapon_crowbar" then wpcode = "c"  wpdisp = "Crowbar"
		elseif wpid=="weapon_pistol"  then wpcode = "d"  wpdisp = "9mm Pistol"
		elseif wpid=="weapon_357"     then wpcode = "e"  wpdisp = ".357 Magnum"
		elseif wpid=="weapon_crossbow" then wpcode = "g"  wpdisp = "Crossbow"
		elseif wpid=="weapon_rpg"     then wpcode = "i"  wpdisp = "RPG Launcher"
		elseif wpid=="weapon_ar2"     then wpcode = "l"  wpdisp = "Pulse-Rifle"
		elseif wpid=="weapon_bugbait" then wpcode = "j"  wpdisp = "Bug Bait"
		elseif wpid=="weapon_physcannon" then wpcode = "m"   wpdisp = "Gravity Gun"
		elseif wpid=="weapon_physgun" then wpcode = "m"   wpdisp = "Physic Gun"
		elseif wpid=="weapon_stunstick" then wpcode = "n"   wpdisp = "Stunstick"
		elseif wpid=="weapon_frag"    then wpcode = "k"  wpdisp = "Frag Grenade"
		elseif wpid=="weapon_slam"	  then wpcode = "0"  wpdisp = "S.L.A.M"
		elseif wpid=="weapon_medkit"  then wpcode = "+"
		elseif string.find(wpid,"csgo_bayonet")!=nil then wpcode = "0"  wpdisp = "Bayonet Knife"
		elseif string.find(wpid,"csgo_bowie")!=nil then wpcode = "0"  wpdisp = "Bowie Knife"
		elseif string.find(wpid,"csgo_butterfly")!=nil then wpcode = "0"  wpdisp = "Butterfly Knife"
		elseif string.find(wpid,"csgo_default_t_golden")!=nil then wpcode = "0"  wpdisp = "Default T Knife"
		elseif string.find(wpid,"csgo_default_golden")!=nil then wpcode = "0"  wpdisp = "Default CT Knife"
		elseif string.find(wpid,"csgo_falchion")!=nil then wpcode = "0"  wpdisp = "Falchion Knife"
		elseif string.find(wpid,"csgo_flip")!=nil then wpcode = "0"  wpdisp = "Flip Knife"
		elseif string.find(wpid,"csgo_gut")!=nil then wpcode = "0"  wpdisp = "Gut Knife"
		elseif string.find(wpid,"csgo_huntsman")!=nil then wpcode = "0"  wpdisp = "Huntsman Knife"
		elseif string.find(wpid,"csgo_karambit")!=nil then wpcode = "0"  wpdisp = "Karambit Knife"
		elseif string.find(wpid,"csgo_m9")!=nil then wpcode = "0"  wpdisp = "M9 Bayonet Knife"
		elseif string.find(wpid,"csgo_daggers")!=nil then wpcode = "0"  wpdisp = "Shadow Daggers"
		else
			wpcode="0"
			wpdisp=wpname
		end

		local WeaponNameInfo = {
			['text'] = wpdisp,
			['font'] = "OrbitMed",
			['pos'] = {0,0},
			['xalign'] = TEXT_ALIGN_RIGHT,
			['yalign'] = TEXT_ALIGN_CENTER,
			['color'] = AmmoGlobalColor
		}
		local WeaponIconInfo = {
			['text'] = wpcode,
			['font'] = "WPIcons",
			['pos'] = {0,0},
			['xalign'] = TEXT_ALIGN_RIGHT,
			['yalign'] = TEXT_ALIGN_CENTER,
			['color'] = AmmoGlobalColor
		}
		local AmmoInfo = {
			['text'] = nil,
			['font'] = "Numbers",
			['pos'] = {0,0},
			['xalign'] = TEXT_ALIGN_RIGHT,
			['yalign'] = TEXT_ALIGN_CENTER,
			['color'] = AmmoGlobalColor
		}


		if wpcode=="0" then
			WeaponNameInfo.pos = {xx+305,yy-67}
			AmmoInfo.pos = {xx+320,yy-34}
		else
			WeaponNameInfo.pos = {xx+215,yy-67}
			AmmoInfo.pos = {xx+220,yy-34}
		end


		local ammo1 = wp:Clip1()
		local ammo1type = wp:GetPrimaryAmmoType()
		local ammo1invt = myplayer:GetAmmoCount(ammo1type)
		local ammo1percentage = ammo1 * 100 / wp:GetMaxClip1()

		local ammo2type = wp:GetSecondaryAmmoType()
		local ammo2invt = myplayer:GetAmmoCount(ammo2type)

		ShapeWidth = 460
		ShapeLeftX = ShapeLeftX -60

		local ammoleng = string.len(ammo1) + string.len(ammo1invt) + 1
		local ammoaddi = ammoleng - 5
		local ammolengaddi = 55 * ammoaddi


		if ammo1type!=-1 then
			
			if ammoleng>= 6 then
				ShapeWidth = ShapeWidth + ammolengaddi
				ShapeLeftX = ShapeLeftX - ammolengaddi
				if wpcode == "0" then
					ShapeWidth = ShapeWidth - 85
					ShapeLeftX = ShapeLeftX + 85
				end
			end
			if ammo1percentage >= 25 then
				AmmoGlobalColor = AccentColor

			elseif ammo1percentage < 25 then
				AmmoGlobalColor = Warning

				if ammo1percentage == 0 then
					AmmoGlobalColor = EmptyMag
				end

			end
		else 
			ShapeWidth = 460
			ShapeLeftX = xx
			AmmoGlobalColor = AccentColor
			ShapeWidth = 400
		end
		

		WeaponNameInfo.color = AmmoGlobalColor

		if wpid=="weapon_357" then WeaponIconInfo.pos = {xx+380,yy-45}
		else WeaponIconInfo.pos = {xx+380,yy-40}
		end

		WeaponIconInfo.color = AmmoGlobalColor
		
		draw.Text(WeaponNameInfo)
		draw.Text(WeaponIconInfo)
		
		

		if ammo1type != -1 then
			
			AmmoInfo.color = AmmoGlobalColor
			if ammo1 == -1 then
				AmmoInfo.text = ammo1invt
				AmmoInfo.xalign = TEXT_ALIGN_RIGHT
				draw.Text(AmmoInfo)
			else
				AmmoInfo.text = ammo1.." ⁄ "..ammo1invt
				AmmoInfo.xalign = TEXT_ALIGN_RIGHT
				draw.Text(AmmoInfo)
			end
		end

		-- print(ammo1type)
		-- print(ammo2type)

		
		---- SECOND AMMO ------------------
		WeaponNameInfo.pos = {xx+380,yy-150}
		AmmoInfo.pos = {xx+370,yy-117}
		if ammo2type!=-1 then
			if ammo2invt != 0 and ammo2type!=11 then
				if ammo2invt > 99 then 
					AmmoInfo.text = "99+"
				else 
					AmmoInfo.text = ammo2invt
				end

				if ammo2type == 9 then WeaponNameInfo.text = "SMG Grenade"
				elseif ammo2type == 2 then WeaponNameInfo.text = "AR2 Orb"
				else
					WeaponNameInfo.text = "[UNKNOWN]"
				end

				draw.Text(WeaponNameInfo)
				draw.Text(AmmoInfo)
				CyberpunkUIShape(xx-17+200, yy-85, BGColor, AmmoGlobalColor, 200, 80, 16, 2, "clip2")
			else
				hook.Remove("HUDPaint", "clip2")
			end
		else
			hook.Remove("HUDPaint", "clip2")
		end

		CyberpunkUIShape(ShapeLeftX, yy, BGColor, AmmoGlobalColor, ShapeWidth, 80, -16, 2, "weapon")
		
		render.SetScissorRect( 0, 0, 0, 0, false )
		
	end
	
	hook.Add( 'HUDPaint', 'zDrawHUD', DrawTheHUD )
	hook.Add( 'HUDShouldDraw', 'HideHUD', HideHUD )

end



