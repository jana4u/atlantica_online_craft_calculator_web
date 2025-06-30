Rails.application.routes.draw do
  get 'about' => 'atlantica_online_craft_calculator_engine/about#show', :as => :about
  get 'custom-prices' => 'atlantica_online_craft_calculator_engine/custom_prices#index', :as => :custom_prices
  put 'custom-prices' => 'atlantica_online_craft_calculator_engine/custom_prices#update'
  delete 'custom-prices' => 'atlantica_online_craft_calculator_engine/custom_prices#destroy'
  get 'custom-skills' => 'atlantica_online_craft_calculator_engine/custom_skills#index', :as => :custom_skills
  put 'custom-skills' => 'atlantica_online_craft_calculator_engine/custom_skills#update'
  get 'experience-table' => 'atlantica_online_craft_calculator_engine/experience_table#show', :as => :experience_table

  root :to => 'atlantica_online_craft_calculator_engine/items#index'
end
