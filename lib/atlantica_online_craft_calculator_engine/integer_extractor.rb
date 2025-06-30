module AtlanticaOnlineCraftCalculatorEngine
  module IntegerExtractor
    def self.non_negative_integer_from_string(string)
      string.gsub(/[^0-9]/, '').to_i
    end
  end
end
