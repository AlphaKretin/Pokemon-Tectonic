BattleHandlers::DamageCalcUserAbility.add(:AUDACITY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.specialMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HEADACHE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mods[:attack_multiplier] *= 2.0 if user.effects[PBEffects::Confusion]>0 && move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:POWERUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ENERGYUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEEPSTING,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TEMPERATURE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if user.lastMoveUsed!=move.id && !user.lastMoveFailed
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXPERTISE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MIDNIGHTSUN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Sun && type == :DARK
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SUNCHASER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Sun && move.physicalMove?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLIZZBOXER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Hail && move.physicalMove?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:STEELWORKER,:PULVERIZE)

BattleHandlers::DamageCalcUserAbility.add(:SUBZERO,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PALEOLITHIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCALDINGSMOKE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:PUNKROCK,:LOUD)

BattleHandlers::DamageCalcUserAbility.add(:SWORDSMAN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.slashMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SUNCHASER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Rain && move.specialMove?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MYSTICFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BIGTHORNS,
  proc { |ability,user,target,move,mults,baseDmg,type|
	if move.physicalMove? && user.battle.field.terrain == :Grassy
		mults[:base_damage_multiplier] *= 1.3
	end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STORMFRONT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Rain && [:Electric,:Flying,:Water].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRATAGEM,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :Rock
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ARMORPIERCING,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.stages[:DEFENSE] > 0 || target.stages[:SPECIAL_DEFENSE] > 0
      mults[:base_damage_multiplier] *= 2.0
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TERRITORIAL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.battle.field.terrain != :None
      mults[:attack_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BROODING,
  proc { |ability,user,target,move,mults,baseDmg,type|
	dragonCount = 0
	user.battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
		dragonCount += 1 if pkmn.pbHasType?(:DRAGON)
	end
	mults[:attack_multiplier] *= (1.0 + dragonCount * 0.05) 
  }
)