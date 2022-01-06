class NewDexNav
  def initialize
	# Load encounter data for the given route
	encounter_array = getDexNavEncounterDataForMap()
	if !encounter_array || encounter_array.length == 0
		pbMessage(_INTL("There are no encounters on this map."))
		return
	end
 
	# Set up the two viewports to hold UI elements
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport1.z = 99999
	@viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
	@viewport2.z = 99999
    @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
    @viewport3.z = 999999
    $viewport = nil
    @sprites = {}
	
	# Set up all the sprites
	@sprites["background"] = IconSprite.new(0,0,@viewport1)
	@sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/Rework/dexnav"))
	
	@sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)
	@sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport2)
	pbSetSystemFont(@sprites["overlay"].bitmap)
	@sprites["name_overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport1)

    @sprites["nav_arrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
    @sprites["nav_arrow"].visible = false
    @sprites["nav_arrow"].play
	
	# Find which encounter sets the player has yet completed
	encounterTypesCompleted = {}
	encounter_array.each do |entry|
		encounterType = entry[0]
		next if encounterType == :Special
		if !encounterTypesCompleted.has_key?(encounterType)
			encounterTypesCompleted[encounterType] = true
		end
		encounterTypesCompleted[encounterType] = encounterTypesCompleted[encounterType] && $Trainer.owned?(entry[1].species)
	end
	@numEncounterTypesCompleted = 0
	encounterTypesCompleted.each do |encounter_type,isCompleted|
		@numEncounterTypesCompleted += 1 if isCompleted
	end
	
=begin
	# Remove encounters which you haven't been seen yet
	stripped_encounter_array = encounter_array.reject{ |entry|
		!$Trainer.seen?(entry[1].species)
	}
=end
	
	# Create the sprites that show the encounters for this area
	owned = 0
	@pkmnsprite = []
	displaySpecies = []
	allSeen = true
	allOwned = true
    encounter_array.each_with_index do |encounter_data,iconIndex|
		species_data = encounter_data[1]
		species = species_data.species
		displaySpecies.push(species_data)

        @pkmnsprite[iconIndex] = PokemonSpeciesIconSprite.new(species,@viewport2)
		
		if !$Trainer.pokedex.seen?(species)
			@pkmnsprite[iconIndex].silhouette = true
			allSeen = false
		end
		
		if !$Trainer.pokedex.owned?(species)
			allOwned = false
		end
		
		@pkmnsprite[iconIndex].x = 64 * (iconIndex % 7)
		@pkmnsprite[iconIndex].y = 30 + 64 * (iconIndex / 7)
    end
	
	# Determine what the status of the completion of this area is
	@status = "Incomplete"
	@status = "All seen!" if allSeen
	@status = "All owned!" if allOwned
	
	drawSprites()
	
    pbFadeInAndShow(@sprites)
	
    openMainDexNavScreen(displaySpecies)
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
	@viewport2.dispose
    @viewport3.dispose
  end
  
  def openMainDexNavScreen(encounters)
    navMon = 0
    lastMon = encounters.length - 1
	
	inputActive = encounters.length != 0
	@sprites["nav_arrow"].visible = true if inputActive
	
	if encounters.length != 0
		# Begin taking input for the main dexnav screen
		highestLeftRepeat = 0
		highestRightRepeat = 0
		loop do
		  Graphics.update
		  Input.update
		  pbUpdateSpriteHash(@sprites)
		  
		  @sprites["nav_arrow"].x = 6 + 64 * (navMon % 7)
		  @sprites["nav_arrow"].y = 48 + 64 * (navMon / 7)
		  
		  highlightedSpeciesData = encounters[navMon]
		  highlightedSpecies = highlightedSpeciesData.species
		  if Input.trigger?(Input::DOWN) && (navMon + 7) <= lastMon
			navMon += 7
			pbPlayCursorSE
		  elsif Input.trigger?(Input::UP) && navMon > 6
			navMon -= 7
			pbPlayCursorSE
		  elsif Input.repeat?(Input::LEFT) && navMon > 0
			highestRightRepeat = 0
			repeats = 1 + Input.time?(Input::LEFT) / 100000
			if  repeats > highestLeftRepeat
				highestLeftRepeat = repeats
				navMon -= 1
				pbPlayCursorSE
			end
		  elsif Input.repeat?(Input::RIGHT) && navMon < lastMon
			highestLeftRepeat = 0
			repeats = 1 + Input.time?(Input::RIGHT) / 100000
			if  repeats > highestRightRepeat
				highestRightRepeat = repeats
				navMon += 1
				pbPlayCursorSE
			end
		  elsif Input.trigger?(Input::C)
			if !($Trainer.pokedex.owned?(highlightedSpecies) || ($DEBUG && Input.press?(Input::CTRL)))
			    pbMessage(_INTL("You cannot search for this Pokémon, because you haven't owned one yet!"))
			    next
			else
				if $currentDexSearch != nil && $currentDexSearch.is_a?(Array) &&
					pbConfirmMessage("Would you like to replace your existing search?")
				end
				searchTime = 20 + rand(80)
				pbMessage(_INTL("Searching\\ts[15]...\\wtnp[#{searchTime}]"))
				pbMessage(_INTL("Oh! A #{highlightedSpeciesData.real_name} was found nearby!"))
				pbFadeOutAndHide(@sprites)
				beginSearchWithOverlay(highlightedSpeciesData)
				break
			end
		  elsif Input.trigger?(Input::B)
			navMon = -1
			dispose
			break
		  else
			highestLeftRepeat = 0
			highestRightRepeat = 0
		  end
		  speciesFormName =  highlightedSpeciesData.real_name 
		  speciesFormName += "(#{highlightedSpeciesData.real_form_name})" if highlightedSpeciesData.form != 0
		  @displayedName = $Trainer.pokedex.seen?(highlightedSpecies) ? speciesFormName : "Unknown"
		  drawSprites()
		end
	else
		pbFadeOutAndHide(@sprites)
	end
	@viewport1.dispose
	@viewport2.dispose
  end
  
  def drawSprites()
    @sprites["overlay"].bitmap.clear
	@sprites["overlay2"].bitmap.clear
	drawInformation()
	drawOwnedIcons()
  end
  
  def drawInformation()
	overlay = @sprites["overlay"].bitmap
	
	base   = Color.new(88, 88, 80)
	shadow = Color.new(168, 184, 184)
	
	xLeft = 40
	textpos = [[_INTL("#{$game_map.name}"),80,-4,0,Color.new(248, 248, 248),Color.new(0, 0, 0)]]
	yPos = 52
	if $PokemonGlobal.caughtCountsPerMap && $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
		caughtCount = $PokemonGlobal.caughtCountsPerMap[$game_map.map_id][0]
		caughtCountText = _INTL("#{caughtCount} caught")
		textpos.push([caughtCountText,xLeft+300,yPos,0,base,shadow])
	end
	
	textpos.push([@status,xLeft,yPos,0,base,shadow])
	yPos += 32
	
	if $PokemonGlobal.caughtCountsPerMap && $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
		receivedCount = $PokemonGlobal.caughtCountsPerMap[$game_map.map_id][1]
		receivedCountText = _INTL("#{receivedCount} received")
		textpos.push([receivedCountText,xLeft+300,yPos,0,base,shadow])
	end
	completions = "#{@numEncounterTypesCompleted} habitat#{@numEncounterTypesCompleted == 1 ? "" : "s"} completed"
	textpos.push([completions,xLeft,yPos,0,base,shadow])
	yPos += 32
	
	if @displayedName
		textpos.push([@displayedName,(Graphics.width-@displayedName.length*10)/2,yPos,0,base,shadow])
	end
	
	pbDrawTextPositions(overlay, textpos)
  end
  
  def drawOwnedIcons
	imagePos = []
	@pkmnsprite.each do |sprite|
		next unless $Trainer.pokedex.owned?(sprite.species)
		ownedIconX = sprite.x + 8
		ownedIconY = sprite.y + 8
		imagePos.push(["Graphics/Pictures/Battle/icon_own",ownedIconX,ownedIconY])
	end
	
	pbDrawImagePositions(@sprites["overlay2"].bitmap,imagePos)
  end

  def beginSearchWithOverlay(species_data)
	$currentDexSearch=[species_data,getRandomMentorMove(species_data.species)]
  	
	# Determine which of the Pokemon's abilities it will have, and store that info for later
    navRand = rand(2)
    $currentDexSearch[2] = navRand
    navAbil1 = species_data.abilities
    if navAbil1[1] != nil
      navAbil = [navAbil1[0],navAbil1[1]]
    else
      navAbil = [navAbil1[0],navAbil1[0]]
    end
	
	# Display information about the pokemon being searched for
	if $currentDexSearch[1] == nil
      dexMove = "-"
    else
      dexMove = GameData::Move.get($currentDexSearch[1]).name
    end
    @sprites["search"] = Window_AdvancedTextPokemon.newWithSize("",265,130,250,126,@viewport3)
    @sprites["search"].text = _INTL("{1}\n{2}\n{3}",
		species_data.name,GameData::Ability.get(navAbil[navRand]).name,dexMove)
    @sprites["search"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["search"].opacity = 140
    @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(species_data.species,@viewport3)
    @sprites["searchIcon"].x = 450
    @sprites["searchIcon"].y = 125
	@sprites["searchIcon"].z += 100

	Graphics.update
	$viewport = @viewport3
	@viewport3.z = 99998
    pbFadeInAndShow(@sprites) {pbUpdate}
  end
  
end

def getDexNavEncounterDataForMap(mapid = -1)
    mapid = $game_map.map_id if mapid == -1
    encounters = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    return nil if encounters == nil
    encounter_tables = Marshal.load(Marshal.dump(encounters.types))
	
	allEncounters = []
	encounters.types.keys.each do |encounter_type|
		next if encounter_type == :Special
		encounterList = encounter_tables[encounter_type]
		next if !encounterList
		encounterList.each do |encounter|
			speciesSym = encounter[1]
			species_data = GameData::Species.get(speciesSym)
			allEncounters.push([encounter_type,species_data])
		end
	end
	  
    allEncounters.uniq!
    allEncounters.compact!
    allEncounters.sort!{|a,b| GameData::Species.get(a[1]).id_number <=> GameData::Species.get(b[1]).id_number}
	return allEncounters
end

Events.onStartBattle+=proc {|_sender,e|
    $viewport.dispose if $viewport
}

Events.onMapChanging +=proc {|_sender,e|
    $viewport.dispose if $viewport
	$currentDexSearch = nil
}

Events.onWildPokemonCreate += proc {|sender,e|
    pokemon = e[0]
	next if pokemon.boss?
    # Checks current search value, if it exists, sets the Pokemon to it's qualities
    if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
		currentTileEncounterType = $PokemonEncounters.encounter_type
		species_data = $currentDexSearch[0]
		species = species_data.species
		# If the generated pokemon can actually be found here
		if $PokemonEncounters.speciesEncounterableInType(species,currentTileEncounterType)
			pokemon.species = species
			pokemon.name = GameData::Species.get(pokemon.species).name
			pokemon.ability_index = $currentDexSearch[2]
			pokemon.form = species_data.form
			pokemon.reset_moves
			pokemon.learn_move($currentDexSearch[1]) if $currentDexSearch[1]
			# There is a higher chance for shininess
			pokemon.shinyRerolls *= 2
			$currentDexSearch = nil
		else
			echoln("Cannot find #{species} in #{currentTileEncounterType}!")
		end
    end
}

# Gets a random ID of a legal egg move of the given species and returns it as a move object.
def getRandomMentorMove(species)
	return nil if !defined?($PokemonGlobal.dexNavEggMovesUnlocked) || !$PokemonGlobal.dexNavEggMovesUnlocked
	firstSpecies = GameData::Species.get(species)
	while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
		firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
	end
	
	moves = firstSpecies.egg_moves.concat(species.tutor_moves)
	return moves.sample
end


class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :silhouette

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = false
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
	@silhouette   = false
    refresh
  end
  
  def silhouette=(value)
    @silhouette = value
    refresh
  end

  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
	if @silhouette
		self.bitmap = @animBitmap.bitmap.clone
		for x in 0..bitmap.width
			for y in 0..bitmap.height
			  bitmap.set_pixel(x,y,Color.new(200,200,200,255)) if bitmap.get_pixel(x,y).alpha > 0
			end
		end
	end
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end
