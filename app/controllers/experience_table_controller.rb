class ExperienceTableController < ApplicationController
  def show
    AtlanticaOnlineCraftCalculator::CraftExperience.load_levels_from_csv
  end
end
