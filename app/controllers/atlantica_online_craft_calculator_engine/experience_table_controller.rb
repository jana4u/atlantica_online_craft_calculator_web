require_dependency "atlantica_online_craft_calculator_engine/application_controller"

module AtlanticaOnlineCraftCalculatorEngine
  class ExperienceTableController < ApplicationController
    def show
      AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv
    end
  end
end
