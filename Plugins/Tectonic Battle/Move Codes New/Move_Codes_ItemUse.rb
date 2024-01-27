#===============================================================================
# User gives one of its items to the target. (Bestow)
#===============================================================================
class PokeBattle_Move_0F3 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def validItem(user,item)
        return !(user.unlosableItem?(item) || GameData::Item.get(item).is_mega_stone?)
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.hasAnyItem?
            if show_message
                msg = _INTL("#{user.pbThis} doesn't have an item to give away!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't lose any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} give away?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.canAddItem?(@chosenItem)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have room for a new item!")) if show_message
            return true
        end
        if target.unlosableItem?(@chosenItem)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't accept an #{getItemName(@chosenItem)}!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.giveItem(@chosenItem)
        user.removeItem(@chosenItem)
        itemName = getItemName(@chosenItem)
        @battle.pbDisplay(_INTL("{1} received {2} from {3}!", target.pbThis, itemName, user.pbThis(true)))
        target.pbHeldItemTriggerCheck
    end

    def resetMoveUsageState
        @chosenItem = nil
    end

    def getEffectScore(user, target)
        if user.hasActiveItem?(%i[FLAMEORB POISONORB FROSTORB STICKYBARB
                                  IRONBALL]) || user.hasActiveItem?(CHOICE_LOCKING_ITEMS)
            if user.opposes?(target)
                return 100
            else
                return 0
            end
        end
        return 50
    end
end

#===============================================================================
# User recovers the last item it held and consumed. (Recycle)
#===============================================================================
class PokeBattle_Move_0F6 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.recyclableItem
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an item to recycle!"))
            end
            return true
        end
        if user.hasItem?(user.recyclableItem)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has the item it would recycle!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.recycleItem
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#===============================================================================
class PokeBattle_Move_0F7 < PokeBattle_Move
    def initialize(battle, move)
        super
        @flingPowers = {}

        # Highest BP
        category1 = %i[IRONBALL PEARLOFFATE]

        # Middle BP
        category2 = []
        category2.concat(CHOICE_LOCKING_ITEMS)
        category2.concat(WEATHER_ROCK_ITEMS)
        category2.concat(RECOIL_ITEMS)

        @flingPowers[150] = category1
        @flingPowers[100] = category2
    end

    def validItem(user,item)
        return !(user.unlosableItem?(item) || GameData::Item.get(item).is_mega_stone?)
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.hasAnyItem?
            if show_message
                msg = _INTL("#{user.pbThis} doesn't have an item to fling!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        unless user.itemActive?
            if show_message
                msg = _INTL("#{user.pbThis} can't use items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't lose any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} fling?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbDisplayUseMessage(user, targets)
        super
        @battle.pbDisplay(_INTL("{1} flung its {2}!", user.pbThis, getItemName(@chosenItem)))
    end

    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbBaseDamage(_baseDmg, user, _target)
        @flingPowers.each do |power, items|
            return power if items.include?(@chosenItem)
        end
        return 75
    end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.substitute
        return unless canApplyRandomAddedEffects?(user, target, true)
        case @chosenItem
        when :POISONORB
            target.applyPoison(user) if target.canPoison?(user, false, self)
        when :FLAMEORB
            target.applyBurn(user) if target.canBurn?(user, false, self)
        when :FROSTORB
            target.applyFrostbite(user) if target.canFrostbite?(user, false, self)
        when :BIGROOT
            target.applyLeeched(user) if target.canLeech?(user, false, self)
        when :BINDINGBAND
            target.applyLeeched(user) if target.canLeech?(user, false, self)
        else
            target.pbHeldItemTriggerCheck(@chosenItem, true)
        end
    end

    def pbEndOfMoveUsageEffect(user, _targets, _numHits, _switchedBattlers)
        # NOTE: The item is consumed even if this move was Protected against or it
        #       missed. The item is not consumed if the target was switched out by
        #       an effect like a target's Red Card.
        # NOTE: There is no item consumption animation.
        user.consumeItem(@chosenItem, belch: false) if user.hasItem?(@chosenItem)
    end

    def resetMoveUsageState
        @chosenItem = nil
    end
end

#===============================================================================
# Power and type depend on the user's held berry. Destroys the berry.
# (Natural Gift, Seed Surprise)
#===============================================================================
class PokeBattle_Move_096 < PokeBattle_Move
    def initialize(battle, move)
        super
        @typeArray = {
            :NORMAL   => [:CHILANBERRY],
            :FIRE     => %i[CHERIBERRY BLUKBERRY WATMELBERRY OCCABERRY],
            :WATER    => %i[CHESTOBERRY NANABBERRY DURINBERRY PASSHOBERRY],
            :ELECTRIC => %i[PECHABERRY WEPEARBERRY BELUEBERRY WACANBERRY],
            :GRASS    => %i[RAWSTBERRY PINAPBERRY RINDOBERRY LIECHIBERRY],
            :ICE      => %i[ASPEARBERRY POMEGBERRY YACHEBERRY GANLONBERRY],
            :FIGHTING => %i[LEPPABERRY KELPSYBERRY CHOPLEBERRY SALACBERRY],
            :POISON   => %i[AMWIBERRY QUALOTBERRY KEBIABERRY PETAYABERRY],
            :GROUND   => %i[PERSIMBERRY HONDEWBERRY SHUCABERRY APICOTBERRY],
            :FLYING   => %i[LUMBERRY GREPABERRY COBABERRY LANSATBERRY],
            :PSYCHIC  => %i[SITRUSBERRY TAMATOBERRY PAYAPABERRY STARFBERRY],
            :BUG      => %i[FIGYBERRY CORNNBERRY TANGABERRY ENIGMABERRY],
            :ROCK     => %i[WIKIBERRY MAGOSTBERRY CHARTIBERRY MICLEBERRY],
            :GHOST    => %i[MAGOBERRY RABUTABERRY KASIBBERRY CUSTAPBERRY],
            :DRAGON   => %i[AGUAVBERRY NOMELBERRY HABANBERRY JABOCABERRY],
            :DARK     => %i[IAPAPABERRY SPELONBERRY COLBURBERRY ROWAPBERRY MARANGABERRY],
            :STEEL    => %i[RAZZBERRY PAMTREBERRY BABIRIBERRY],
            :FAIRY    => %i[ROSELIBERRY KEEBERRY],
        }
        @chosenItem = nil
    end

    def validItem(user,item)
        return false if user.unlosableItem?(item)
        return GameData::Item.get(item).is_berry?
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.itemActive?
            if show_message
                msg = _INTL("#{user.pbThis} can't use items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't use any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} use?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbDisplayUseMessage(user, targets)
        super
        if @chosenItem
            typeName = GameData::Type.get(pbBaseType(user)).name
            @battle.pbDisplay(_INTL("The {1} turned the attack {2}-type!", getItemName(@chosenItem), typeName))
        end
    end

    # NOTE: The AI calls this method via pbCalcType, but it involves user.item
    #       which here is assumed to be not nil (because item.id is called). Since
    #       the AI won't want to use it if the user has no item anyway, perhaps
    #       this is good enough.
    def pbBaseType(user)
        item = @chosenItem
        ret = :NORMAL
        unless item.nil?
            @typeArray.each do |type, items|
                next unless items.include?(item)
                ret = type if GameData::Type.exists?(type)
                break
            end
        end
        return ret
    end

    def pbEndOfMoveUsageEffect(user, _targets, _numHits, _switchedBattlers)
        # NOTE: The item is consumed even if this move was Protected against or it
        #       missed. The item is not consumed if the target was switched out by
        #       an effect like a target's Red Card.
        # NOTE: There is no item consumption animation.
        user.consumeItem(@chosenItem, belch: false) if user.hasItem?(@chosenItem)
    end

    def resetMoveUsageState
        @chosenItem = nil
    end
end

#===============================================================================
# User and target swap their first items. They remain swapped after wild battles.
# (Switcheroo, Trick)
#===============================================================================
class PokeBattle_Move_0F2 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if @battle.wildBattle? && user.opposes? && !user.boss
            @battle.pbDisplay(_INTL("But it failed, since this is a wild battle!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.hasAnyItem?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an item!"))
            end
            return true
        end
        unless user.hasAnyItem?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an item!")) if show_message
            return true
        end
        if target.unlosableItem?(target.firstItem) ||
           target.unlosableItem?(user.firstItem) ||
           user.unlosableItem?(user.firstItem) ||
           user.unlosableItem?(target.firstItem)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if user.firstItem == :PEARLOFFATE || target.firstItem == :PEARLOFFATE
             @battle.pbDisplay(_INTL("But it failed, since the Pearl of Fate cannot be exchanged!")) if show_message
            return true
        end
        if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
            if show_message
                @battle.pbShowAbilitySplash(target, ability)
                @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        oldUserItem = user.firstItem
        oldUserItemName = getItemName(oldUserItem)
        oldTargetItem = target.firstItem
        oldTargetItemName = getItemName(target.firstItem)
        user.removeItem(oldUserItem)
        target.removeItem(oldTargetItem)
        if @battle.curseActive?(:CURSE_SUPER_ITEMS)
            @battle.pbDisplay(_INTL("{1}'s {2} turned to dust.", user.pbThis, oldUserItemName)) if oldUserItem
            @battle.pbDisplay(_INTL("{1}'s {2} turned to dust.", target.pbThis, oldTargetItemName)) if oldTargetItem
        else
            user.giveItem(oldTargetItem)
            target.giveItem(oldUserItem)
            @battle.pbDisplay(_INTL("{1} switched items with its opponent!", user.pbThis))
            @battle.pbDisplay(_INTL("{1} obtained {2}.", user.pbThis, oldTargetItemName)) if oldTargetItem
            @battle.pbDisplay(_INTL("{1} obtained {2}.", target.pbThis, oldUserItemName)) if oldUserItem
            user.pbHeldItemTriggerCheck
            target.pbHeldItemTriggerCheck
        end
    end

    def getEffectScore(user, target)
        if user.hasActiveItem?(%i[FLAMEORB POISONORB STICKYBARB IRONBALL])
            return 130
        elsif user.hasActiveItem?(CHOICE_LOCKING_ITEMS)
            return 100
        elsif !user.firstItem && target.firstItem
            if user.lastMoveUsed && GameData::Move.get(user.lastMoveUsed).function_code == "0F2" # Trick/Switcheroo
                return 0
            end
        end
        return 0
    end
end