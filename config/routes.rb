Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: redirect('/games/new_player')

  namespace :games do
    get :clear
    get :new_player
    post :enter_player
    post :drop_player
    get :show
    post :leave_answer
    post :choose_winner_answer
  end
end
