Rails.application.routes.draw do
  resources :performances
  resources :trophies
  resources :scores
  resources :rounds
  resources :games
  resources :players
  
  get "wizard/new_game", to: "wizard#game_step_0", as: "new_game_wizard"
  post "wizard/create_new_game", to: "wizard#game_step_1", as: "game_step_1"
  get "games/:id/round/:round_number", to: "games#edit_round", as: "game_edit_round"
  post "games/:id/round/:round_number", to: "games#save_round", as: "game_save_round"
  get "games/:id/recap", to: "games#recap", as: "game_recap"
  get "games/:id/compute_results", to: "games#compute_results", as: "game_compute_results"
  get "games/:id/spectator", to: "games#spectator", as: "game_spectator"
  post "games/:id/save_graph", to: "games#save_graph", as: "game_save_graph"
  post "trophies/recompute_all", to: "trophies#recalculate_all_trophies_for_all_games", as: "trophies_recompute_all"
  
  get "dashboard", to: "home#dashboard", as: "dashboard"

  root to: 'home#index'
  
  devise_for :users
  
end
