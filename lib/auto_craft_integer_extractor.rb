module AutoCraftIntegerExtractor
  def self.non_negative_integer_from_string(string)
    IntegerExtractor.non_negative_integer_from_string(string).clamp(1, 120)
  end
end
