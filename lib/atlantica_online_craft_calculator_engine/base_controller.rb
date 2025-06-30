module AtlanticaOnlineCraftCalculatorEngine
  module BaseController
    def self.included(controller)
      controller.class_eval do
        helper_method :item_custom_prices_url, :custom_skills_store

        def item_custom_prices_url
          custom_prices_path(:item_name => params[:item_name])
        end

        def custom_prices_store
          @custom_prices_store ||= CustomPricesSessionStore.new(session)
        end

        def crafting_disabled_store
          @crafting_disabled_store ||= CraftingDisabledSessionStore.new(session)
        end
      end

      def custom_skills_store
        @custom_skills_store ||= CustomSkillsSessionStore.new(session)
      end
    end
  end
end
