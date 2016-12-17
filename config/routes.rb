Rails.application.routes.draw do
  devise_for :users

  get 'recommendation/index'

  get 'movie/index'
  post 'movie/index'
  
  get 'movie/submit-rating' => 'movie#submit_rating'
  get 'movie/add_to_watchlist' => 'movie#add_to_watchlist'
  get 'movie/remove_from_watchlist' => 'movie#remove_from_watchlist'
  get 'movie/update_recommendations_list_in_background' => 'movie#update_recommendations_list_in_background'

  get 'search/index'
  post 'search/index'
  get 'search/movietitlelookup' => 'search#movie_title_lookup'
  get 'search/movietitlelocal' => 'search#movie_title_autocomplete_local'
  get 'search/movietitleremote' => 'search#movie_title_autocomplete_remote'

  get 'welcome/index'
  post 'welcome/index'
  
  get 'welcome/update' => 'welcome#update_db'
  
  root 'welcome#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
