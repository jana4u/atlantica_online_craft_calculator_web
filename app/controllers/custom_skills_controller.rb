class CustomSkillsController < ApplicationController
  def update
    custom_skills_store.auto_craft = params[:auto_craft]

    redirect_to custom_skills_url
  end
end
