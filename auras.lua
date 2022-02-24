local addonName, SheepMonitor = ...

SheepMonitor.auras = {}

-- LuaFormatter off
-- theses are the cc auras that we track
SheepMonitor.trackableAuras = {
    [118]    = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph
    [12824]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 2)
    [12825]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 3)
    [12826]  = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- Polymorph (Rank 4)
    [61305]  = 'Interface\\Icons\\Achievement_Halloween_Cat_01',        -- Polymorph (Black Cat)
    [277792] = 'Interface\\Icons\\Inv_Bee_Default',                     -- Polymorph (Bumblebee)
    [277787] = 'Interface\\Icons\\Inv_Pet_Direhorn',                    -- Polymorph (Direhorn)
    [321395] = 'Interface\\Icons\\Inv_RatMount',                        -- Polymorph (Mawrat)
    [161354] = 'Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey',    -- Polymorph (Monkey)
    [161372] = 'Interface\\Icons\\Inv_Pet_Peacock_Gold',                -- Polymorph (Peacock)
    [161355] = 'Interface\\Icons\\Inv_Misc_PenguinPet',                 -- Polymorph (Penguin)
    [28272]  = 'Interface\\Icons\\Spell_Magic_PolymorphPig',            -- Polymorph (Pig)
    [161353] = 'Interface\\Icons\\Inv_Pet_BabyBlizzardBear',            -- Polymorph (Polar Bear Cub)
    [126819] = 'Interface\\Icons\\Inv_Pet_Porcupine',                   -- Polymorph (Porcupine)
    [61721]  = 'Interface\\Icons\\Spell_Magic_PolymorphRabbit',         -- Polymorph (Rabbit)
    [61025]  = 'Interface\\Icons\\Spell_Nature_GuardianWard',           -- Polymorph (Serpent)
    [61780]  = 'Interface\\Icons\\Achievement_WorldEvent_Thanksgiving', -- Polymorph (Turkey)
    [28271]  = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',           -- Polymorph (Turtle)
--    [219393] = 'Interface\\Icons\\Spell_Nature_Polymorph',              -- [Crittermorph] Polymorph
--    [219407] = 'Interface\\Icons\\Achievement_Halloween_Cat_01',        -- [Crittermorph] Polymorph (Black Cat)
--    [277793] = 'Interface\\Icons\\Inv_Bee_Default',                     -- [Crittermorph] Polymorph (Bumblebee)
--    [277788] = 'Interface\\Icons\\Inv_Pet_Direhorn',                    -- [Crittermorph] Polymorph (Direhorn)
--    [219406] = 'Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey',    -- [Crittermorph] Polymorph (Monkey)
--    [219403] = 'Interface\\Icons\\Spell_Magic_PolymorphPig',            -- [Crittermorph] Polymorph (Pig)
--    [219401] = 'Interface\\Icons\\Inv_Pet_Porcupine',                   -- [Crittermorph] Polymorph (Porcupine)
--    [219398] = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',           -- [Crittermorph] Polymorph (Turtle)

    [51514]  = 'Interface\\Icons\\Spell_Shaman_Hex',                 -- Hex
    [76780]  = 'Interface\\Icons\\Spell_Shaman_BindElemental',       -- Bind Elemental
    [9484]   = 'Interface\\Icons\\Spell_Nature_Slow',                -- Shackle Undead
    [8122]   = 'Interface\\Icons\\Spell_Shadow_PsychicScream',       -- Psychic Scream
    [605]    = 'Interface\\Icons\\Spell_Shadow_ShadowWordDominate',  -- Mind Control
    [2637]   = 'Interface\\Icons\\Spell_Nature_Sleep',               -- Hibernate
    [6770]   = 'Interface\\Icons\\Ability_Sap',                      -- Sap
    [3355]   = 'Interface\\Icons\\Spell_Frost_ChainsOfIce',          -- Freezing Trap
    [19386]  = 'Interface\\Icons\\Inv_Spear_02',                     -- Wyvern Sting
    [1513]   = 'Interface\\Icons\\Ability_Druid_Cower',              -- Scare Beast
    [710]    = 'Interface\\Icons\\Spell_Shadow_Cripple',             -- Banish
    [5782]   = 'Interface\\Icons\\Spell_Shadow_Possession',          -- Fear
    [6358]   = 'Interface\\Icons\\Spell_Shadow_MindSteal',           -- Seduction
    [20066]  = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing',       -- Repentance
    [10326]  = 'Interface\\Icons\\Spell_Holy_TurnUndead',            -- Turn Evil
    [1098]   = 'Interface\\Icons\\Spell_Shadow_EnslaveDemon',        -- Enslave Demon
    [339]    = 'Interface\\Icons\\Spell_Nature_StrangleVines',       -- Entangling Roots
    [115078] = 'Interface\\Icons\\Ability_Monk_Paralysis',           -- Paralysis
    [217832] = 'Interface\\Icons\\Ability_DemonHunter_Imprison',     -- Imprison
} -- LuaFormatter on

function SheepMonitor:AuraApplied(aura)
    -- print('SheepMonitor:AuraApplied', aura.destGUID, aura.spellId)
    local index = self:UnitHasAura(aura.destGUID, aura.spellId)

    if index then
        table.remove(self.auras, index)
    end

    table.insert(self.auras, aura)
    self:POLYMORPH_APPLIED(aura)

    aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New()
    aura.timer:Start(aura)
end

function SheepMonitor:AuraBroken(destGUID, breakerName, breakerReason)
    -- print('SheepMonitor:AuraBroken', destGUID, breakerName, breakerReason)
    for index, aura in ipairs(self.auras) do
        if aura.destGUID == destGUID then
            self.auras[index].breakerName = breakerName
            self.auras[index].breakerReason = breakerReason
        end
    end
end

function SheepMonitor:AuraRemoved(destGUID, spellId)
    -- print('SheepMonitor:AuraRemoved', destGUID, spellId)
    local index, aura = self:UnitHasAura(destGUID, spellId)

    if index then
        -- we only need to watch damage in the combat logs during the brief moment the timer is up
        -- the flag must be a counter as it's possible that multiple timers are up at once
        self.watchForBreakers = self.watchForBreakers and self.watchForBreakers + 1 or 1

        -- delay removal of the aura so we can check who the breaker was
        self:ScheduleTimer(function()
            SheepMonitor.watchForBreakers = SheepMonitor.watchForBreakers - 1

            table.remove(SheepMonitor.auras, index)
            SheepMonitor:POLYMORPH_REMOVED(aura)

            if aura.timer then
                aura.timer:Stop()
            end

            SheepMonitor.Timer:UpdateTimers()
        end, 0.1)
    end
end

function SheepMonitor:UnitHasAura(destGUID, spellId)
    for index, aura in ipairs(self.auras) do
        if aura.destGUID == destGUID and aura.spellId == spellId then
            return index, aura
        end
    end
end
