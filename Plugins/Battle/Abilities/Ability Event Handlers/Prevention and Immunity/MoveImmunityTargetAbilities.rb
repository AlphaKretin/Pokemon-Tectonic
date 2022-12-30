BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.bombMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |_ability, user, target, _move, type, battle, showMessages|
      next false if user.index == target.index
      next false if type != :FIRE
      battle.pbShowAbilitySplash(target) if showMessages
      if !target.effectActive?(:FlashFire)
          target.applyEffect(:FlashFire)
      elsif showMessages
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(target)
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ELECTRIC, :SPECIAL_ATTACK, 1, battle,
showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ELECTRIC, :SPEED, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :GRASS, :ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.soundMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :WATER, :SPECIAL_ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |_ability, user, target, move, _type, battle, showMessages|
      next false if move.statusMove?
      next false if user.index == target.index || target.opposes?(user)
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :ELECTRIC, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :WATER, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB, :DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |_ability, _user, target, move, type, battle, showMessages|
      next false if move.statusMove?
      next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :FLYING, :SPEED, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :BUG, :ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:COLDRECEPTION,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :ICE, :ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :POISON, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CHALLENGER,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :FIGHTING, :ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTOFJUSTICE,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :DARK, :ATTACK, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:HEARTLESS,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :FAIRY, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:INDUSTRIALIZE,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityStatAbility(user, target, move, type, :STEEL, :SPEED, 1, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DRAGONSLAYER,
  proc { |_ability, user, target, _move, type, battle, showMessages|
      next false if user.index == target.index
      next false if type != :DRAGON
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:PECKINGORDER,
  proc { |_ability, user, target, _move, type, battle, showMessages|
      next false if user.index == target.index
      next false if type != :FLYING
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FINESUGAR,
  proc { |_ability, user, target, move, type, battle, showMessages|
      next pbBattleMoveImmunityHealAbility(user, target, move, type, :FIRE, battle, showMessages)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SLICKSURFACE,
  proc { |_ability, _user, target, move, _type, battle, showMessages|
      next false unless move.healingMove?
      if showMessages
          battle.pbShowAbilitySplash(target)
          battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
          battle.pbHideAbilitySplash(target)
      end
      next true
  }
)
