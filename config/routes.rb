Rails.application.routes.draw do
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
  post "games/:id/save_graph", to: "games#save_graph", as: "game_save_graph"
  
  root to: 'home#index'
  
  devise_for :users
  
end
