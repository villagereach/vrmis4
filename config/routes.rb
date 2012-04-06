Vrmis::Application.routes.draw do


  get "/deliveries" => "deliveries#index"

  get "/offline" => redirect("/offline/en/niassa")
  get "/offline/en/:province" => "offline#index"
  get "/offline/en/:province/reset" => "offline#reset"

  namespace :offline do
    scope ":locale/:province" do
      get "/products"         => "products#index"
      get "/delivery_zones"   => "delivery_zones#index"
      get "/health_centers"   => "health_centers#index"
      get "/hc_visits"        => "hc_visits#index"
      get "/hc_visits/:month" => "hc_visits#index"
      post "/hc_visits/:code" => "hc_visits#update"
    end
  end

  get "/admin" => "admin#index"
  
  namespace :admin do
    match "translations/:key/edit", :to=>"translations#edit", :via=>:get, :as=>"edit_translation", :constraints=>{:key=>/\w{2}((?:\.[\w-]+)*)/}
    match "translations/update", :to=>"translations#update", :via=>:post, :as=>"update_translation"

    get "switch_user"
    resources :provinces, :delivery_zones, :districts,
      :health_centers, :warehouses, :users, :languages

    resources :products, :packages, :stock_cards, :equipment_types do
      post :sort, :on => :collection
    end

  end

#  map.from_plugin 'i18n_backend_database'

  root :to => redirect('/admin')

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
