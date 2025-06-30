module AtlanticaOnlineCraftCalculatorEngine
  module AutoCraftIntegerExtractor
    def self.non_negative_integer_from_string(string)
      [[IntegerExtractor.non_negative_integer_from_string(string), 1].max, 120].min
    end
  end
end
