class Pokemon
	PERSONALITY_THRESHOLD_ONE = 50
	PERSONALITY_THRESHOLD_TWO = 150
	PERSONALITY_THRESHOLD_THREE = 200
	PERSONALITY_THRESHOLD_FOUR = 255

	TRAITS =
	[
		"Adorable",
		"Adventurous",
		"Alert",
		"Aloof",
		"Ambitious",
		"Athletic",
		"Boastful",
		"Brooding",
		"Collector",
		"Courageous",
		"Cowardly",
		"Dramatic",
		"Elegant",
		"Energetic",
		"Friendly",
		"Hopeful",
		"Innocent",
		"Inviting",
		"Judgey",
		"Lucky",
		"Loyal",
		"Partier",
		"Patient",
		"Persistent",
		"Profound",
		"Rogueish",
		"Selfless",
		"Shy",
		"Stoic",
		"Studious",
		"Sweettooth"
	]

	def trait1
		return nil if happiness < PERSONALITY_THRESHOLD_ONE
		while @Trait1.nil? || @Trait1 == @Trait2 || @Trait1 == @Trait3
			@Trait1 = TRAITS.sample
		end
		return @Trait1
	end
	  
	def trait2
	    return nil if happiness < PERSONALITY_THRESHOLD_TWO
		while @Trait2.nil? || @Trait2 == @Trait1 || @Trait2 == @Trait3
			@Trait2 = TRAITS.sample
		end
		return @Trait2
	end
	  
	def trait3
		return nil if happiness < PERSONALITY_THRESHOLD_THREE
		while @Trait3.nil? || @Trait3 == @Trait1 || @Trait3 == @Trait2
			@Trait3 = TRAITS.sample
		end
		return @Trait3
	end
	
	LIKES = ["Scary Movies","Berries","Beach Walks","Swimming","Stories","Camping","Breeze","Beach Trips","Comedy Movies","EDM","Introspection","Spicy Food","Soda","Hiking","Paintings","People Watching","Bike Rides","Languages","Fishing","Gardening","Dumpster Diving","Judo","Shopping","Fashion","Jogging","Card Games","Video Games","Computers","Math","Chemistry","Documentaries","History","Rainy Days","Tightropes","Astronomy","Horoscopes","Tree Climbing","Meditation","Acrobatics","Cakes","Ice Cream","Expensive Food","Cooking","Baking","Action Movies","Lo-Fi","Rock Music","Rocks","Snow","Exercise","Marathons","Weightlifting","Heavy Metal","Coffee","Iced Latte","Hot Cocao","Chocolate Milk","Flowers","Avant-garde","Novelty","Routines","Yoga","The Occult","Skiing","Plays","Fireworks","Salsa","Naps","Pizza","Jigsaw Puzzles","Firemaking","Following You","Taking Pictures","Attention","Being Spoiled","Parkour","Destruction","Pottery","Weaving","Reality TV","Tournament Arcs","Competition","Banter","Cleaning","Milkshakes"]
	def like
		return nil if happiness < PERSONALITY_THRESHOLD_FOUR
		while @Like.nil? || @Like == @Dislike
			@Like = LIKES.sample
		end
		return @Like
	end
	
	DISLIKES = ["Scary Movies","Petting","Loud Noises","Smalltalk","Directions","Introspection","Sour Food","Bitter Coffee","Sweet Coffee","The Vet","Pollen","Tight Spaces","Crowds","Commuting","Hiking","Doing Nothing","Sad Stories","Heights","Storms","Hot Days","Cold Days","The Dark","Defeatists","Babies","Forests","Deserts","Exercise","Babysitting","Loud Cars","Responsibilities","Cleaning","Spicy Food","Soda","Loud Music","Cooking","Snow","Exercise","Routines","Fireworks","Attention","Being Spoiled"]
	def dislike
		return nil if happiness < PERSONALITY_THRESHOLD_FOUR
		while @Dislike.nil? || @Dislike == @Like
			@Dislike = DISLIKES.sample
		end
		return @Dislike
	end
	
  # Changes the happiness of this Pokémon depending on what happened to change it.
  # @param method [String] the happiness changing method (e.g. 'walking')
  def changeHappiness(method)
    gain = 0
    happiness_range = @happiness / 100
    case method
    when "walking"
      gain = [2, 2, 1][happiness_range]
    when "levelup"
      gain = [5, 4, 3][happiness_range]
    when "groom"
      gain = [10, 10, 4][happiness_range]
    when "evberry"
      gain = [10, 5, 2][happiness_range]
    when "vitamin"
      gain = [5, 3, 2][happiness_range]
    when "wing"
      gain = [3, 2, 1][happiness_range]
    when "machine", "battleitem"
      gain = [1, 1, 0][happiness_range]
    else
      echo(_INTL("Unknown happiness-changing method: {1}", method.to_s))
    end
    if gain > 0
      gain += 1 if @obtain_map == $game_map.map_id
      gain += 1 if @poke_ball == :LUXURYBALL
      gain = (gain * 1.5).floor if hasItem?(:SOOTHEBELL)
    end
	prevHappiness = @happiness
    @happiness = (@happiness + gain).clamp(0, 255)
	
	traitUnlocked = nil
	likeUnlocked = nil
	dislikeUnlocked = nil
	ordinal = ""
	if prevHappiness < PERSONALITY_THRESHOLD_ONE && @happiness >= PERSONALITY_THRESHOLD_ONE
		traitUnlocked = trait1
		ordinal = "first"
	elsif prevHappiness < PERSONALITY_THRESHOLD_TWO && @happiness >= PERSONALITY_THRESHOLD_TWO
		traitUnlocked = trait2
		ordinal = "second"
	elsif prevHappiness < PERSONALITY_THRESHOLD_THREE && @happiness >= PERSONALITY_THRESHOLD_THREE
		traitUnlocked = trait3
		ordinal = "final"
	elsif prevHappiness < PERSONALITY_THRESHOLD_FOUR && @happiness >= PERSONALITY_THRESHOLD_FOUR
		likeUnlocked = like
		dislikeUnlocked = dislike
	end
	
	if !traitUnlocked.nil?
		msgwindow = pbCreateMessageWindow
		pbMessageDisplay(msgwindow,_INTL("\\wm{1} is happy enough to show off its {2} trait: {3}!\\me[Egg get]\\wtnp[80]\1",name,ordinal,traitUnlocked))
		pbDisposeMessageWindow(msgwindow)
	elsif !likeUnlocked.nil? && !dislikeUnlocked.nil?
		msgwindow = pbCreateMessageWindow
		pbMessageDisplay(msgwindow,_INTL("\\wm{1} is at maximum happiness! It loves you so much!\1",name))
		pbMessageDisplay(msgwindow,_INTL("\\wm{1} reveals that it likes {2} and that it dislikes {3}!\\me[Egg get]\\wtnp[100]\1",name,likeUnlocked,dislikeUnlocked))
		pbDisposeMessageWindow(msgwindow)
	end
  end
end

class PokemonSummary_Scene
	  def drawPageTwo
		overlay = @sprites["overlay"].bitmap
		memo = ""
		
		# Traits
		if !@pokemon.shadowPokemon? || @pokemon.heartStage>3
		  memo += _INTL("<c3=F83820,E09890>Traits:<c3=404040,B0B0B0>")
		  memo += _INTL("<r><c3=F83820,E09890>Likes:<c3=404040,B0B0B0>")
		  memo += "\n"
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}",@pokemon.trait1 || "Unknown",@pokemon.trait1 ? "FF" : "77")
		  memo += _INTL("<r><c3=404040{2},B0B0B0>{1}",@pokemon.like || "Unknown",@pokemon.like ? "FF" : "77")
		  memo += "\n"
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}",@pokemon.trait2 || "Unknown",@pokemon.trait2 ? "FF" : "77")
		  memo += _INTL("<r><c3=F83820,E09890>Dislikes:<c3=404040,B0B0B0>")
		  memo += "\n"
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}",@pokemon.trait3 || "Unknown",@pokemon.trait3 ? "FF" : "77")
		  memo += _INTL("<r><c3=404040{2},B0B0B0>{1}",@pokemon.dislike || "Unknown",@pokemon.dislike ? "FF" : "77")
		  memo += "\n"
		  memo += "\n"
		end

		# Write date received
		if @pokemon.timeReceived
		  date  = @pokemon.timeReceived.day
		  month = pbGetMonthName(@pokemon.timeReceived.mon)
		  year  = @pokemon.timeReceived.year
		  memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
		end
		
		# Write map name Pokémon was received on
		mapname = pbGetMapNameFromId(@pokemon.obtain_map)
		mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
		mapname = _INTL("Faraway place") if !mapname || mapname==""
		memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
		
		# Write how Pokémon was obtained
		mettext = [_INTL("Met at Lv. {1}.",@pokemon.obtain_level),
				   _INTL("Egg received."),
				   _INTL("Traded at Lv. {1}.",@pokemon.obtain_level),
				   "",
				   _INTL("Had a fateful encounter at Lv. {1}.",@pokemon.obtain_level)
				  ][@pokemon.obtain_method]
		memo += sprintf("<c3=404040,B0B0B0>%s\n",mettext) if mettext && mettext!=""

		# If Pokémon was hatched, write when and where it hatched
		if @pokemon.obtain_method == 1
		  if @pokemon.timeEggHatched
			date  = @pokemon.timeEggHatched.day
			month = pbGetMonthName(@pokemon.timeEggHatched.mon)
			year  = @pokemon.timeEggHatched.year
			memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
		  end
		  mapname = pbGetMapNameFromId(@pokemon.hatched_map)
		  mapname = _INTL("Faraway place") if !mapname || mapname==""
		  memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
		  memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
		else
		  memo += "\n"   # Empty line
		end
		
		# Write all text
		drawFormattedTextEx(overlay,232,82,268,memo)
	  end
end

