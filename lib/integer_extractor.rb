module IntegerExtractor
  def non_negative_integer_from_string(string)
    string.gsub(/[^0-9]/, "").to_i
  end
end
