module GameData
    class Move
        attr_reader :animation_move

        def initialize(hash)
          @id                 = hash[:id]
          @id_number          = hash[:id_number]   || -1
          @real_name          = hash[:name]        || "Unnamed"
          @function_code      = hash[:function_code]
          @base_damage        = hash[:base_damage]
          @type               = hash[:type]
          @category           = hash[:category]
          @accuracy           = hash[:accuracy]
          @total_pp           = hash[:total_pp]
          @effect_chance      = hash[:effect_chance]
          @target             = hash[:target]
          @priority           = hash[:priority]
          @flags              = hash[:flags]
          @real_description   = hash[:description] || "???"
          @animation_move     = hash[:animation_move]
        end


    end
end