RecurringScheduler::Engine.routes.draw do
  resources :schedulers, except: [:index] do
    collection { post :update_summary }
  end
end
