class PokemonPokedexInfoScreen
  def pbStartScreen(dexlist,index,region,linksEnabled=false)
    @scene.pbStartScene(dexlist,index,region,false,linksEnabled)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   #  Last species viewed in dexlist
  end

  def pbStartSceneSingle(species,battle=false)   # For use from a Pokémon's summary screen
		region = -1
		if Settings::USE_CURRENT_REGION_DEX
		  region = pbGetCurrentRegion
		  region = -1 if region >= $Trainer.pokedex.dexes_count - 1
		else
		  region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
		end
    dexlist = []
    species_data = GameData::Species.get(species)

    # Find all evolution tree members of the pokemon
    allSpecies = []
    allSpecies = allSpecies.concat(species_data.get_prevolutions.map{|entry| entry[0]})
    allSpecies.push(species)
    getEvolutionsRecursive(species_data).each do |key, value|
      value.each do |evo|
        allSpecies.push(evo[0])
      end
    end
    allSpecies.uniq!
    allSpecies.compact!
    echoln("Opening the dex with species: #{allSpecies.to_s}")

    # Create a dexlist with all the evo members
    allSpecies.each do |sp|
      dexnum = pbGetRegionalNumber(region,sp)
      dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
      dexlist.push([sp,GameData::Species.get(sp).name,0,0,dexnum,dexnumshift])
    end

    # Start the scene
		@scene.pbStartScene(dexlist,0,region,battle,true)
		ret = @scene.pbScene
		@scene.pbEndScene
    return ret   # Last species viewed in dexlist
	end
end