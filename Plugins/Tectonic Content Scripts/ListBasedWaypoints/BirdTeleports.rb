BIRD_LOCATIONS = {
    :CARNATION_TOWER => {
        :map_name => "Carnation Tower",
        :map_id => 186,
        :event_id => 60,
        :unlock_switch => 278,
    },
    :NOVO_APARTMENTS => {
        :map_name => "Novo Apartments",
        :map_id => 56,
        :event_id => 89,
        :unlock_switch => 276,
    },
}

def unlockBirdSpot(birdID,ignoreAlreadyActive=false)
    birdInfo = BIRD_LOCATIONS[birdID]
    raise _INTL("Bird ID {1} has no unlock_switch defined. Cannot unlock!",birdID) if birdInfo[:unlock_switch].nil?
    return if getGlobalSwitch(birdInfo[:unlock_switch]) && !ignoreAlreadyActive
    mapName = _INTL(birdInfo[:map_name])
    text = _INTL("You can now travel to <imp>{1}</imp> on the Corviknight Network!",mapName)
    pbMessage("\\wm#{text}\\me[Slots win]\\wtnp[80]\1")
    pbSetGlobalSwitch(birdInfo[:unlock_switch])
end

def unlockAllBirdSpots
    BIRD_LOCATIONS.each do |birdID, birdInfo|
        next unless birdInfo[:unlock_switch]
        pbSetGlobalSwitch(birdInfo[:unlock_switch])
    end
    pbMessage("All bird travel spots were unlocked.")
end

def birdTravel(currentBird = nil)
    commands = []
    validBirdIDs = []

    BIRD_LOCATIONS.each do |birdID, birdInfo|
        next if birdID == currentBird
        next if birdInfo[:unlock_switch] && !getGlobalSwitch(birdInfo[:unlock_switch])
        commands.push(_INTL(birdInfo[:map_name]))
        validBirdIDs.push(birdID)
    end

    if commands.empty?
        pbMessage("There are no other places you can travel to.")
        return
    end

    commands.push(_INTL("Cancel"))

    choiceNumber = pbMessage(_INTL("Where would you like to go?"),commands,commands.length)

    return if choiceNumber == commands.length - 1 # Cancel

    chosenBirdID = validBirdIDs[choiceNumber]

    warpToBirdWaypoint(chosenBirdID)
end

def warpToBirdWaypoint(birdID)
    birdInfo = BIRD_LOCATIONS[birdID]
    pbSetGlobalSwitch(birdInfo[:visit_switch]) if birdInfo[:visit_switch]

    direction = birdInfo[:direction] || Up
    transferPlayerToEvent(birdInfo[:event_id],direction,birdInfo[:map_id])
end