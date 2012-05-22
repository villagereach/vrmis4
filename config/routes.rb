Vrmis::Application.routes.draw do
  namespace :admin do
    get '',      :action => 'index'
    get 'login', :action => 'login'
    get 'logout' => redirect('/admin/login')

    match 'translations/:key/edit', :to=>'translations#edit', :via=>:get, :as=>'edit_translation', :constraints=>{:key=>/\w{2}((?:\.[\w-]+)*)/}
    match 'translations/update', :to=>'translations#update', :via=>:post, :as=>'update_translation'

    resources :provinces, :delivery_zones, :districts,
      :health_centers, :warehouses, :users, :languages

    resources :products, :packages, :stock_cards, :equipment_types do
      post :sort, :on => :collection
    end
  end

  get '/offline' => redirect('/offline/en/cabo-delgado')
  scope ':mode/:locale/:province', :module => 'offline', :constraints => {:mode=>/online|offline/} do
    get  '',      :action => 'index'
    get  'ping',  :action => 'ping'
    get  'login', :action => 'login'
    get  'reset', :action => 'reset'

    get  'products'                 => 'products#index'
    get  'delivery_zones'           => 'delivery_zones#index'
    get  'health_centers'           => 'health_centers#index'
    get  'warehouses'               => 'warehouses#index'
    get  'hc_visits'                => 'hc_visits#index'
    get  'hc_visits/:months'        => 'hc_visits#index'
    post 'hc_visits/:code'          => 'hc_visits#update'
    get  'warehouse_visits'         => 'warehouse_visits#index'
    get  'warehouse_visits/:months' => 'warehouse_visits#index'
    post 'warehouse_visits/:code'   => 'warehouse_visits#update'
    get  'users/current'            => 'users#current'
    get  'snapshots'                => 'config_snapshots#index'
    get  'translations'             => 'translations#index'
  end

  get '/offline/:locale/:province/manifest' => lambda {|env|
    params = env['action_dispatch.request.path_parameters']
    manifest = Rack::Offline.configure do
      digest = Rails.application.config.assets.digest
      digests = Rails.application.config.assets.digests

      # assets
      css = ['application.css', 'offline.css']
      javascript = ['application.js', 'offline.js']
      images = ['favicon.ico', 'icons-16px.png', 'vr-mis-logo-small.png']
      [*css, *javascript, *images].each do |name|
        asset = Rails.application.assets[name]
        cache '/assets/' + (digest ? digests[asset.logical_path] : asset.logical_path)
        if Rails.env.development?
          asset.dependencies.each {|a| cache '/assets/' + (digest ? digests[a.logical_path] : a.logical_path)}
        end
      end

      #cache "/offline/#{params[:locale]}/#{params[:province]}" - not needed, implicit
      cache "/offline/#{params[:locale]}/#{params[:province]}/reset"
      cache "/offline/#{params[:locale]}/#{params[:province]}/translations"

      network "/"
    end
    manifest.call(env)
  }

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
