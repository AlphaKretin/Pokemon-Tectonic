
def isCat?(species)
	array = [:MEOWTH,:PERSIAN,:AMEOWTH,:APERSIAN,:GMEOWTH,:PERRSERKER,:ESPEON,:FLAREON,:GLACEON,
		:JOLTEON,:LEAFEON,:SYLVEON,:UMBREON,:VAPOREON,:SKITTY,:DELCATTY,:ZANGOOSE,:MZANGOOSE,:ABSOL,
		:ABSOLUS,:SHINX,:LUXIO,:LUXRAY,:GLAMEOW,:PURUGLY,:PURRLOIN,:LIEPARD,:LITLEO,:PYROAR,:ESPURR,
		:MEOWSTIC,:LITTEN,:TORRACAT,:INCINEROAR,:GIGANTEON]
	return array.include?(species)
end

def isAlien?(species)
	array = [:CLEFFA,:CLEFAIRY,:CLEFABLE,:STARYU,:STARMIE,:LUNATONE,:SOLROCK,:ELGYEM,:BEHEEYEM,:KYUREM,:ETERNATUS,:DEOXYS,:MROGGENROLA,:MBOLDORE,:MGIGALITH]
	return array.include?(species)
end

def isBat?(species)
	array = [:ZUBAT,:GOLBAT,:CROBAT,:GLIGAR,:GLISCOR,:WOOBAT,:SWOOBAT,:NOIBAT,:NOIVERN]
	return array.include?(species)
end

def isSmart?(species)
	array = [:ABRA,:KADABRA,:ALAKAZAM,:BELDUM,:METANG,:METAGROSS,:SOLOSIS,:DUOSION,:REUNICLUS,:ORBEETLE,:DOTTLER,:BLIPBUG,:GSLOWKING,:SLOWKING,:UXIE]
	return array.include?(species)
end

def isKnight?(species)
	array = [:CORVIKNIGHT,:GALLADE,:ESCAVALIER,:BISHARP,:SIRFETCHD,:SAMUROTT,:GOLURK,:ROSERADE]
	return array.include?(species)
end

def isFrog?(species)
	array = [:BULBASAUR,:IVYSAUR,:VENUSAUR,:POLIWHIRL,:POLIWRATH,:POLITOED,:POLIWAG,:SEISMITOAD,:PALPITOAD,:TYMPOLE,:FROAKIE,:FROGADIER,:GRENINJA,:TOXICROAK,:CROAGUNK]
	return array.include?(species)
end

def isQuestionable?(species)
	array = [:LUCARIO,:GARDEVOIR,:UMBREON,:CHARIZARD,:HAEROBIC,:ZOROARK,:DELPHOX,:ARCANINE,:GLACEON,:BLAZIKEN,:SYLVEON,:ZANGOOSE,:VAPOREON,:RAICHU,:TYPHLOSION,:ESPEON,:GOODRA,:CINDERACE,:SALAZZLE]
	return array.include?(species)
end

def isBandMember?(species)
	array = [:WIGGLYTUFF,:JIGGLYPUFF,:IGGLYBUFF,:WHISMUR,:LOUDRED,:EXPLOUD,:PRIMARINA,:BRIONNE,:POPPLIO,:KRICKETUNE,:KRICKETOT,:CHATOT,:TOXEL,:TOXTRICITY,:ARCLAMOR,:MARACTUS,:RILLABOOM,:THWACKEY,:GROOKEY,:NOIBAT,:NOIVERN]
	return array.include?(species)
end

def isTMNT?(species)
	array = [:CARRACOSTA,:TIRTOUGA,:TORKOAL,:TORTERRA,:GROTLE,:TURTWIG,:CHEWTLE,:DREDNAW,:SEISMAW,:SQUIRTLE,:WARTORTLE,:BLASTOISE,:RATICATE,:RATTATA,:CUBONE,:MAROWAK]
	return array.include?(species)
end

def isKing?(species)
	array = [:KINGDRA,:KINGLER,:NIDOKING,:SLAKING,:SLOWKING,:GSLOWKING,:SEAKING]
	return array.include?(species)
end

def isQueen?(species)
	array = [:VESPIQUEN,:TSAREENA,:GARDEVOIR,:NIDOQUEEN,:SALAZZLE]
	return array.include?(species)
end

def isSmasher?(species)
	array = [:LUCARIO,:PIKACHU,:GRENINJA,:CHARIZARD,:JIGGLYPUFF,:IVYSAUR,:LUCARIO,:SQUIRTLE]
	return array.include?(species)
end

def isPirateCrew?(species)
	array = [:EMPOLEON,:AMBIPOM,:DHELMISE,:OCTILLERY,:SCARODON,:RUBARIOR,:CHATOT,:BLASTOISE,:CRAWDAUNT]
	return array.include?(species)
end

def isMushroom?(species)
	array = [:PARAS,:PARASECT,:SHROOMISH,:BRELOOM,:FOONGUS,:AMOONGUSS,:MORELULL,:SHIINOTIC]
	return array.include?(species)
end