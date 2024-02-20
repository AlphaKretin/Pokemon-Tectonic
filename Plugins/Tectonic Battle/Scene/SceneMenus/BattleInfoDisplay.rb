FADED_EFFECT_BASE = Color.new(120, 120, 120)

DEBUGGING_EFFECT_DISPLAY = false

class BattleInfoDisplay < SpriteWrapper
    attr_accessor   :battle
    attr_accessor   :selected
    attr_accessor	:individual

    def initialize(viewport, z, battle)
        super(viewport)
        self.x = 0
        self.y = 0
        self.battle = battle

        @sprites = {}
        @spriteX      			= 0
        @spriteY      			= 0
        @selected	= 0
        @individual = nil
        @field	= false
        @battleInfoMain	= AnimatedBitmap.new("Graphics/Pictures/Battle/battle_info_main")
        @battleInfoIndividual	= AnimatedBitmap.new("Graphics/Pictures/Battle/battle_info_individual")
        @backgroundBitmap = @battleInfoMain
        @statusCursorBitmap	= AnimatedBitmap.new("Graphics/Pictures/Battle/cursor_status")

        @contents = BitmapWrapper.new(@backgroundBitmap.width, @backgroundBitmap.height)
        self.bitmap = @contents
        pbSetNarrowFont(bitmap)

        @battlerScrollingValue = 0
        @fieldScrollingValue = 0

        @turnOrder = @battle.pbTurnOrderDisplayed

        self.z = z
        refresh
    end

    def dispose
        pbDisposeSpriteHash(@sprites)
        @battleInfoMain.dispose
        @battleInfoIndividual.dispose
        super
    end

    def visible=(value)
        super
        for i in @sprites
            i[1].visible = value unless i[1].disposed?
        end
    end

    def refresh
        bitmap.clear

        if @individual
            @backgroundBitmap	= @battleInfoIndividual
            bitmap.blt(0, 0, @backgroundBitmap.bitmap,
  				Rect.new(0, 0, @backgroundBitmap.width, @backgroundBitmap.height))
            drawIndividualBattlerInfo(@individual)
        else
            @backgroundBitmap	= @battleInfoMain
            bitmap.blt(0, 0, @backgroundBitmap.bitmap,
  				Rect.new(0, 0, @backgroundBitmap.width, @backgroundBitmap.height))
            drawWholeBattleInfo
        end
    end

    def drawWholeBattleInfo
        base        = MessageConfig::DARK_TEXT_MAIN_COLOR
        shadow      = MessageConfig::DARK_TEXT_SHADOW_COLOR
        lightBase   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        lightShadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR

        textToDraw = []

        # Draw the title
        battleInfoTitleX = 102
        textToDraw.push([_INTL("BATTLE INFO"), battleInfoTitleX, 0, 2, lightBase, lightShadow])

        # Draw the individual battler selection buttons
        battlerNameX = 8
        battlerCursorX = 148
        yourPokemonStartingY = 62
        theirPokemonStartingY = yourPokemonStartingY + 164
        distanceBetweenButtons = 54
        battlerNameOffset = 4

        battlerIndex = 0
        yPos = yourPokemonStartingY

        # Entries for allies
        @battle.eachSameSideBattler do |b|
            next if b.nil?
            textToDraw.push([b.name, battlerNameX, yPos + battlerNameOffset, 0, base, shadow])
            cursorX = @selected == battlerIndex ? @statusCursorBitmap.width / 2 : 0
            bitmap.blt(battlerCursorX, yPos, @statusCursorBitmap.bitmap,
  				Rect.new(cursorX, 0, @statusCursorBitmap.width / 2, @statusCursorBitmap.height))
            # if @turnOrder.key?(b.index)
            #     turnDescription = _INTL("# {1}", @turnOrder[b.index].to_s)
            #     textToDraw.push([turnDescription, battlerCursorX + 140, yPos + 4, 0, base,
            #                      shadow,])
            # end

            yPos += distanceBetweenButtons
            battlerIndex += 1
        end

        # Entries for enemies
        yPos = theirPokemonStartingY
        @battle.eachOtherSideBattler do |b|
            next if b.nil?
            textToDraw.push([b.name, battlerNameX, yPos + battlerNameOffset, 0, base, shadow])
            cursorX = @selected == battlerIndex ? @statusCursorBitmap.width / 2 : 0
            bitmap.blt(battlerCursorX, yPos, @statusCursorBitmap.bitmap,
  				Rect.new(cursorX, 0, @statusCursorBitmap.width / 2, @statusCursorBitmap.height))
            # if @turnOrder.key?(b.index)
            #     turnDescription = _INTL("# {1}", @turnOrder[b.index].to_s)
            #     textToDraw.push([turnDescription, battlerCursorX + 140, yPos + 4, 0, base,
            #                      shadow,])
            # end

            yPos += distanceBetweenButtons
            battlerIndex += 1
        end

        # Draw the turn count
        turnCountX = battleInfoTitleX + 152
        turnCountMessage = "Turn #{@battle.turnCount + 1}"
        textToDraw.push([turnCountMessage, turnCountX, 0, 2, base, shadow])

        # Draw the weather name with duration
        weatherMessage = _INTL("No Weather")
        weatherColor = FADED_EFFECT_BASE
        if @battle.field.weather != :None
            weatherColor = base
            weatherName = GameData::BattleWeather.get(@battle.field.weather).name
            weatherDuration = @battle.field.weatherDuration
            weatherDuration = _INTL("Inf.") if weatherDuration < 0
            weatherMessage = _INTL("{1} ({2})", weatherName, weatherDuration)
            # if %i[Eclipse RingEclipse Moonglow BloodMoon].include?(@battle.field.weather)
            #     turnsTillActivation = PokeBattle_Battle::SPECIAL_EFFECT_WAIT_TURNS - @battle.field.specialTimer
            #     weatherMessage = _INTL("{1} ({2},{3})", weatherName, weatherDuration, turnsTillActivation)
            # end
        end
        weatherX = turnCountX + 152
        textToDraw.push([weatherMessage, weatherX, 0, 2, weatherColor, shadow])

        # Whole field effects
        wholeFieldX = 324
        wholeFieldY = 58
        textToDraw.push([_INTL("Field Effects"), wholeFieldX + 60, wholeFieldY, 2, lightBase, lightShadow])

        # Compile array of descriptors of each field effect
        fieldEffects = []
        pushEffectDescriptorsToArray(@battle.field, fieldEffects)
        @battle.sides.each do |side|
            thisSideEffects = []
            pushEffectDescriptorsToArray(side, thisSideEffects)
            if side.index == 1
                thisSideEffects.map do |descriptor|
                    "#{descriptor} [O]"
                end
            end
            fieldEffects.concat(thisSideEffects)
        end

        fieldEffects.concat($Trainer.tribalBonus.getActiveBonusesList(true, false))
        @battle.opponent&.each do |opponent|
            fieldEffects.concat(opponent.tribalBonus.getActiveBonusesList(true, true))
        end

        # Render out the field effects
        baseEffectY = wholeFieldY + 36
        scrollingBoundYMin = wholeFieldY + 36
        scrollingBoundYMax = wholeFieldY + 290
        if fieldEffects.length != 0
            scrolling = true if fieldEffects.length > 8
            index = 0
            repeats = scrolling ? 2 : 1
            for repeat in 0...repeats
                fieldEffects.each do |effectName|
                    index += 1
                    calcedY = baseEffectY + 32 * index
                    if scrolling
                        calcedY -= @fieldScrollingValue
                        calcedY += 8
                    end
                    next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
                    distanceFromFade = [calcedY - scrollingBoundYMin, scrollingBoundYMax - calcedY].min
                    textAlpha = scrolling ? ([distanceFromFade / 20.0, 1.0].min * 255).floor : 255
                    textBase = Color.new(base.red, base.blue, base.green, textAlpha)
                    textShadow = Color.new(shadow.red, shadow.blue, shadow.green, textAlpha)
                    textToDraw.push([effectName, wholeFieldX, calcedY, 0, textBase, textShadow])
                end
            end
        else
            textToDraw.push(["None", wholeFieldX, baseEffectY, 0, FADED_EFFECT_BASE, shadow])
        end

        # Reset the scrolling once its scrolled through the entire list once
        @fieldScrollingValue = 0 if @fieldScrollingValue > fieldEffects.length * 32

        pbDrawTextPositions(bitmap, textToDraw)
    end

    def drawIndividualBattlerInfo(battler)
        base = MessageConfig::DARK_TEXT_MAIN_COLOR
        shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR
		lightBase = MessageConfig::LIGHT_TEXT_MAIN_COLOR
    	lightShadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        textToDraw = []

        battlerName = battler.name
        if battler.pokemon.nicknamed?
            speciesData = GameData::Species.get(battler.species)
            battlerName += " (#{speciesData.name})"
            battlerName += " [#{speciesData.form_name}]" if speciesData.form != 0
        end
        textToDraw.push([battlerName, 256, 6, 2, lightBase, lightShadow])

        # Stat Steps
        statStepsSectionTopY = 58
        statLabelX = 10
        statStepX = 112
        statMultX = 162
        statValueX = 224
        battlerEffectsX = 308
        textToDraw.push(["Stat", statLabelX, statStepsSectionTopY, 0, lightBase, lightShadow])
        textToDraw.push(["Step", statStepX - 16, statStepsSectionTopY, 0, lightBase, lightShadow])
        textToDraw.push(["Mult", statMultX, statStepsSectionTopY, 0, lightBase, lightShadow])
        textToDraw.push(["Value", statValueX, statStepsSectionTopY, 0, lightBase, lightShadow])

        statsToNames = {
            :ATTACK => "Atk",
            :DEFENSE => "Def",
            :SPECIAL_ATTACK => "Sp. Atk",
            :SPECIAL_DEFENSE => "Sp. Def",
            :SPEED => "Speed",
            :ACCURACY => "Acc",
            :EVASION => "Evade",
        }

        # Hash containing info about each stat
        # Each key is a symbol of a stat
        # Each value is an array of [statName, statStep, statMult, statFinalValue]
        calculatedStatInfo = {}

        # Display the info about each stat
        highestStat = nil
        highestStatValue = -65_536 # I chose these caps somewhat arbitrarily
        lowestStat = nil
        lowestStatValue = 65_536
        statsToNames.each do |stat, name|
            statValuesArray = []

            statData = GameData::Stat.get(stat)
            statValuesArray.push(name)

            # Stat step
            step = battler.steps[stat]
            step = (step / 2.0).round(2) if step != 0 && battler.boss? && AVATAR_DILUTED_STAT_STEPS
            statValuesArray.push(step)

            # Multiplier
            statValuesArray.push(battler.statMultiplierAtStep(battler.steps[stat]))

            # Draw the final stat value label
            if %i[ACCURACY EVASION].include?(stat)
                value = 100
            else
                value = battler.getFinalStat(stat)
            end
            statValuesArray.push(value)

            # Track the highest and lowest main battle stat (not accuracy or evasion)
            if statData.type == :main_battle
                if value > highestStatValue
                    highestStat = stat
                    highestStatValue = value
                end

                if value < lowestStatValue
                    lowestStat = stat
                    lowestStatValue = value
                end
            end

            calculatedStatInfo[stat] = statValuesArray
        end

        index = 0
        calculatedStatInfo.each do |stat, calculatedInfo|
            name 		= calculatedInfo[0]
            step 		= calculatedInfo[1]
            statMult	= calculatedInfo[2]
            statValue	= calculatedInfo[3]

            # Calculate text display info
            y = statStepsSectionTopY + 40 + 40 * index

            # Display the stat's name
            textToDraw.push([name, statLabelX, y, 0, base, shadow])

            # Display the stat step
            x = statStepX
            x -= 12 if step != 0
            stepLabel = step.to_s
            stepLabel = "+" + stepLabel if step > 0
            textToDraw.push([stepLabel, x, y, 0, base, shadow])

            # Display the stat multiplier
            multLabel = statMult.round(2).to_s
            textToDraw.push([multLabel, statMultX, y, 0, base, shadow])

            # Display the final calculated stat
            textToDraw.push([statValue.to_s, statValueX, y, 0, base, shadow])

            index += 1
        end

        # Effects
        textToDraw.push(["Battler Effects", battlerEffectsX, statStepsSectionTopY, 0, lightBase, lightShadow])

        # Compile a descriptor for each effect on the battler or its position
        battlerEffects = []
        pushEffectDescriptorsToArray(battler, battlerEffects)
        pushEffectDescriptorsToArray(@battle.positions[battler.index], battlerEffects)

        # List abilities that were added by effects
        battler.addedAbilities.each do |abilityID|
            battlerEffects.push("Ability: #{getAbilityName(abilityID)}")
        end

        scrolling = true if battlerEffects.length > 8

        # Print all the battler effects to screen
        scrollingBoundYMin = statStepsSectionTopY + 36
        scrollingBoundYMax = statStepsSectionTopY + 290
        index = 0
        repeats = scrolling ? 2 : 1
        if battlerEffects.length != 0
            for repeat in 0...repeats
                battlerEffects.each do |effectName|
                    index += 1
                    calcedY = statStepsSectionTopY + 4 + 32 * index
                    calcedY -= @battlerScrollingValue if scrolling
                    next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
                    distanceFromFade = [calcedY - scrollingBoundYMin, scrollingBoundYMax - calcedY].min
                    textAlpha = scrolling ? ([distanceFromFade / 20.0, 1.0].min * 255).floor : 255
                    textBase = Color.new(base.red, base.blue, base.green, textAlpha)
                    textShadow = Color.new(shadow.red, shadow.blue, shadow.green, textAlpha)
                    textToDraw.push([effectName, battlerEffectsX, calcedY, 0, textBase, textShadow])
                end
            end
        else
            textToDraw.push(["None", battlerEffectsX, statStepsSectionTopY + 36, 0, FADED_EFFECT_BASE, shadow])
        end

        # Reset the scrolling once its scrolled through the entire list once
        @battlerScrollingValue = 0 if @battlerScrollingValue > battlerEffects.length * 32

        pbDrawTextPositions(bitmap, textToDraw)
    end

    def pushEffectDescriptorsToArray(effectHolder, descriptorsArray)
        effectHolder.eachEffect(!DEBUGGING_EFFECT_DISPLAY) do |_effect, value, effectData|
            next unless effectData.info_displayed
            effectName = effectData.name
            effectName = "#{effectName}: #{effectData.value_to_string(value, @battle)}" if effectData.type != :Boolean
            descriptorsArray.push(effectName)
        end
    end

    def update(_frameCounter = 0)
        super()
        pbUpdateSpriteHash(@sprites)
        if @individual.nil?
            @battlerScrollingValue = 0
            @fieldScrollingValue += 1
        else
            @battlerScrollingValue += 1
            @fieldScrollingValue = 0
        end
    end
end
