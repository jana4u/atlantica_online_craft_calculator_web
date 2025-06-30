module AtlanticaOnlineCraftCalculatorEngine
  class CraftingDisabledSessionStore
    attr_reader :hash, :key

    def initialize(session, key = :crafting_disabled)
      @hash = session
      @key = key
    end

    def all
      storage || []
    end

    def delete_all
      hash[key] = []
    end

    def update_all(new_values)
      hash[key] = new_values
    end

    private

    def storage
      hash[key]
    end

  end
end
