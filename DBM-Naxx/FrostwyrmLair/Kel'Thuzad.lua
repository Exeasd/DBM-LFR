local mod	= DBM:NewMod("Kel'Thuzad", "DBM-Naxx", 5)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4911 $"):sub(12, -3))
mod:SetCreatureID(15990)
mod:SetModelID("creature/lich/lich.m2")
mod:SetMinCombatTime(60)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("yell", L.Yell)

mod:EnableModel()

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"UNIT_HEALTH",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_SUMMON"
)

local isHunter 				= select(2, UnitClass("player")) == "HUNTER"
local warnAddsSoon			= mod:NewAnnounce("warnAddsSoon", 1)
local warnPhase2			= mod:NewPhaseAnnounce(2, 3)
local warnBlastTargets		= mod:NewTargetAnnounce(27808, 2)
local warnFissure			= mod:NewSpellAnnounce(27810, 3)
local soundFissure			= mod:NewSound(27810)
local specwarnfissure		= mod:NewSpecialWarning("fissure")
local warnMana				= mod:NewTargetAnnounce(27819, 2)
local warnManaClose   		= mod:NewSpecialWarning("manaNear")
local warnChainsTargets		= mod:NewTargetAnnounce(28410, 2)
local warnMindControl 		= mod:NewSoonAnnounce(28410, 4)
local warnCorpse			= mod:NewSoonAnnounce(59216, 4)

local specwarnP2Soon		= mod:NewSpecialWarning("specwarnP2Soon")
local specWarnManaBomb		= mod:NewSpecialWarningMoveAway(27819, nil, nil, nil, 1, 2)
local yellManaBomb			= mod:NewShortYell(27819)


local blastTimer			= mod:NewBuffActiveTimer(4, 27808)
local timerPhase2			= mod:NewTimer(227, "TimerPhase2")
local mindControlCD 		= mod:NewNextTimer(90, 28410)
local frostBlastCD   		= mod:NewCDTimer(45, 27808)
local fissureCD  			= mod:NewCDTimer(14, 27810)

local timerPossibleMC		= mod:NewTimer(20, "MCImminent", 28410)
local timerCorpse			= mod:NewTimer(44, "IncCorpse")

mod:AddBoolOption("BlastAlarm", true)
mod:AddBoolOption("ShowRange", true)
mod:AddBoolOption("EqUneqWeaponsKT", mod:IsDps())
mod:AddBoolOption("EqUneqWeaponsKT2")

if mod.Options.EqUneqWeaponsKT and (mod:IsDifficulty("heroic25") or mod:IsDifficulty("normal25")) and not mod:IsEquipmentSetAvailable("pve") then
	for i = 1, select("#", GetFramesRegisteredForEvent("CHAT_MSG_RAID_WARNING")) do
		local frame = select(i, GetFramesRegisteredForEvent("CHAT_MSG_RAID_WARNING"))
		if frame.AddMessage then
			mod:Schedule(10, frame.AddMessage, frame, L.setMissing)
		end
	end
	mod:Schedule(10, RaidNotice_AddMessage, RaidWarningFrame, L.setMissing, ChatTypeInfo["RAID_WARNING"])
end

local MCTimer = 90
local FBTimer = 45
local warnedAdds = false

function mod:OnCombatStart(delay)
	if self.Options.ShowRange then
		self:ScheduleMethod(217-delay, "RangeToggle", true)
	end
	MCTimer = 90
	FBTimer = 45
	warnedAdds = false
	specwarnP2Soon:Schedule(217-delay)
	timerPhase2:Start()
	frostBlastCD:Start(267)
	warnPhase2:Schedule(227)
	self:ScheduleMethod(226, "StartPhase2")
	self:SetStage(1)
	if (mod:IsDifficulty("heroic25") or mod:IsDifficulty("normal25")) or self:IsNormal() then
		mindControlCD:Start(227 + 90 - delay)
		warnMindControl:Schedule(227 + 85 - delay)
		if self.Options.EqUneqWeaponsKT and self:IsDps() then
			self:ScheduleMethod(227 + 85, "UnWKT")
			self:ScheduleMethod(227.5 + 85, "UnWKT")
		end
	end
	self:Schedule(227, DBM.RangeCheck.Show, DBM.RangeCheck, 12)
end

function mod:UnWKT()
	if (self.Options.EqUneqWeaponsKT or self.Options.EqUneqWeaponsKT2) and self:IsEquipmentSetAvailable("pve") then
		if isHunter then
			PickupInventoryItem(18)
			PutItemInBackpack()
			DBM:Debug("Ranged unequipped",2)
		end
		PickupInventoryItem(16)
		PutItemInBackpack()
		PickupInventoryItem(17)
		PutItemInBackpack()
		DBM:Debug("MH and OH unequipped",2)
	end
end

function mod:EqWKT()
	if (self.Options.EqUneqWeaponsKT or self.Options.EqUneqWeaponsKT2) and self:IsEquipmentSetAvailable("pve") then
		DBM:Debug("trying to equip pve",1)
		UseEquipmentSet("pve")
		CancelUnitBuff("player", (GetSpellInfo(25780))) -- Righteous Fury
	end
end

function mod:OnCombatEnd()
	if self.Options.ShowRange then
		self:RangeToggle(false)
	end
end

function mod:StartPhase2()
	self:SetStage(2)
end

local frostBlastTargets = {}
local chainsTargets = {}

--function mod:SPELL_SUMMON(args)
--	if args:IsSpellID(27810) and self:AntiSpam(2, 1) then
--		warnFissure:Show()
--		fissureCD:Start()
--		if UnitName("player") == args.destName then
--			specwarnfissure:Show()
--			soundFissure:Play("Interface\\AddOns\\DBM-Core\\sounds\\beware.ogg")
--		end
--	end
--end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 27808 then -- Frost Blast
		table.insert(frostBlastTargets, args.destName)
		self:UnscheduleMethod("AnnounceBlastTargets")
		self:ScheduleMethod(0.5, "AnnounceBlastTargets")
		if self.Options.BlastAlarm then
			PlaySoundFile("Interface\\Addons\\DBM-Core\\sounds\\alarm1.wav")
		end
		blastTimer:Start()
		frostBlastCD:Start(FBTimer)
	elseif args:IsSpellID(27819) then -- Detonate Mana
		warnMana:Show(args.destName)
		self:SetIcon(args.destName, 8, 5.5)
		if self:GetDetonateRange(args.destName) <= 12 then
			if args:IsPlayer() then
				specWarnManaBomb:Show()
				specWarnManaBomb:Play("scatter")
				yellManaBomb:Yell()
			else
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
				warnManaClose:Show()
			end
		end
	elseif args:IsSpellID(28410) then -- Chains of Kel'Thuzad
		table.insert(chainsTargets, args.destName)
		mindControlCD:Start(MCTimer)
		warnMindControl:Schedule(MCTimer - 5)
		self:UnscheduleMethod("AnnounceChainsTargets")
		if #chainsTargets >= 3 then
			self:AnnounceChainsTargets()
		else
			self:ScheduleMethod(1.0, "AnnounceChainsTargets")
		end
		if self.Options.EqUneqWeaponsKT and self:IsDps() then
			self:ScheduleMethod(MCTimer - 2, "UnWKT")
			self:ScheduleMethod(MCTimer - 1.5, "UnWKT")
		end
	end
end

function mod:has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function mod:AnnounceChainsTargets()
	warnChainsTargets:Show(table.concat(chainsTargets, "< >"))
	if (not self:has_value(chainsTargets,UnitName("player")) and self.Options.EqUneqWeaponsKT and self:IsDps()) then
		DBM:Debug("Equipping scheduled",2)
        self:ScheduleMethod(1.0, "EqWKT")
		self:ScheduleMethod(2.0, "EqWKT")
		self:ScheduleMethod(3.6, "EqWKT")
		self:ScheduleMethod(5.0, "EqWKT")
		self:ScheduleMethod(6.0, "EqWKT")
        self:ScheduleMethod(8.0, "EqWKT")
		self:ScheduleMethod(10.0,"EqWKT")
		self:ScheduleMethod(12.0,"EqWKT")
	end
	table.wipe(chainsTargets)
end

function mod:AnnounceBlastTargets()
	warnBlastTargets:Show(table.concat(frostBlastTargets, "< >"))
	for i = #frostBlastTargets, 1, -1 do
		self:SetIcon(frostBlastTargets[i], 8 - i, 4.5)
		frostBlastTargets[i] = nil
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(27810) then
		warnFissure:Show()
		fissureCD:Start()
		if UnitName("player") == args.destName then
			specwarnfissure:Show()
			soundFissure:Play("Interface\\AddOns\\DBM-Core\\sounds\\beware.ogg")
		end
	elseif args:IsSpellID(27808) then
		frostBlastCD:Start(FBTimer)
	elseif args:IsSpellID(28410) then
		mindControlCD:Start(MCTimer)
		DBM:Debug("MC on "..args.destName,2)
		if mod.Options.EqUneqWeaponsKT2 and args.destName == UnitName("player") then
			mod:UnWKT()
			mod:UnWKT()
			DBM:Debug("Unequipping",2)
		end
	elseif args:IsSpellID(36721) and self:AntiSpam(30,1) then
		warnCorpse:Schedule(40)
		timerCorpse:Start()
	end
end

function mod:UNIT_HEALTH(uId)
	if not warnedAdds and self:GetUnitCreatureId(uId) == 15990 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.48 then
		warnedAdds = true
		warnAddsSoon:Show()
	end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(28410) then
		if (args.destName == UnitName("player") or args:IsPlayer()) and (self.Options.EqUneqWeaponsKT or self.Options.EqUneqWeaponsKT2) and self:IsDps() then
			DBM:Debug("Equipping scheduled",2)
	        self:ScheduleMethod(0.1, "EqWKT")
			self:ScheduleMethod(1.7, "EqWKT")
			self:ScheduleMethod(3.7, "EqWKT")
	        self:ScheduleMethod(7.0, "EqWKT")
			self:ScheduleMethod(9.0, "EqWKT")
			self:ScheduleMethod(11.0,"EqWKT")
		end
	end
end

function mod:RangeToggle(show)
	if show then
		DBM.RangeCheck:Show(12)
	else
		DBM.RangeCheck:Hide()
	end
end

function mod:GetDetonateRange(playerName)
	local uId
	for i= 1, GetNumRaidMembers()  do
		uId = "raid"..i
		if UnitName(uId) == playerName then
			return DBM.RangeCheck:GetDistance(uId, GetPlayerMapPosition("player"))
		end
	end
	return 100 --dummy number
end



function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellMC1 or msg:find(L.YellMC1) or msg == L.YellMC2 or msg:find(L.YellMC2)) then
		if mod.Options.EqUneqWeaponsKT and self:IsDps() then
			mod:UnWKT()
			mod:UnWKT()
			self:ScheduleMethod(MCTimer - 1, "UnWKT")
		end
		mindControlCD:Start()
	elseif (msg == L.YellP3 or msg:find(L.YellP3)) and (mod:IsDifficulty("heroic25") or mod:IsDifficulty("normal25")) then
		self:SetStage(3)
		mindControlCD:Stop()
		frostBlastCD:Stop()
		warnCorpse:Schedule(40)
		timerCorpse:Start()
	elseif	(msg == L.YellP4 or msg:find(L.YellP4)) and (mod:IsDifficulty("heroic25") or mod:IsDifficulty("normal25")) then
		self:SetStage(4)
		timerCorpse:Stop()
		warnCorpse:Cancel()
		MCTimer = 45
		FBTimer = 22
		warnMindControl:Schedule(MCTimer - 5)
		mindControlCD:Start(MCTimer)
		frostBlastCD:Start(FBTimer)
		if self.Options.EqUneqWeaponsKT and self:IsDps() then
			self:ScheduleMethod(MCTimer - 2, "UnWKT")
			self:ScheduleMethod(MCTimer - 1.5, "UnWKT")
		end
	end
end