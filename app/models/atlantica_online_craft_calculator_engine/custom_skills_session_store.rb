module AtlanticaOnlineCraftCalculatorEngine
  class CustomSkillsSessionStore
    attr_reader :hash, :auto_craft_key

    def initialize(session, auto_craft_key = :auto_craft)
      @hash = session
      @auto_craft_key = auto_craft_key
    end

    def auto_craft
      hash[auto_craft_key]
    end

    def auto_craft=(value)
      if value.blank?
        hash[auto_craft_key] = nil
      else
        hash[auto_craft_key] = AutoCraftIntegerExtractor.non_negative_integer_from_string(value)
      end
    end
  end
end
