module AtlanticaOnlineCraftCalculatorEngine
  class CustomPricesSessionStore
    attr_reader :hash, :key

    def initialize(session, key = :custom_prices)
      @hash = session
      @key = key
    end

    def all
      storage || {}
    end

    def delete_all
      hash[key] = {}
    end

    def update_all(new_values)
      delete_all

      new_values.each do |item_name, price|
        unless price.blank?
          storage[item_name] = IntegerExtractor.non_negative_integer_from_string(price)
        end
      end
    end

    private

    def storage
      hash[key]
    end

  end
end
