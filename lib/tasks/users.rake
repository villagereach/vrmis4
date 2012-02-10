namespace :users do
  desc "create sample user"
  task :test_user => :environment do
    uname = "test"
    pass =  "demo"
    if u=User.where(:username=>uname).first
      puts "User #{uname} exists, id #{u.id}"
    else
      User.create!(:username=>uname, :password=>pass, :password_confirmation=>pass,
       :language=>'en', :name=>uname.titleize, :timezone=>'UTC', :role=>'admin')
      puts "User #{uname} created"
    end
  end
  
  desc "dev tool: sets all user passwords to 'demo' || ENV['VR_RESET_PASSWORD'].  Fails in production mode"
  task :reset_all_passwords => :environment do
    raise "this shouldn't be run on production" if Rails.env=='production' 
    new_password = ENV['VR_USER_PASSWORD'] || 'demo'
    User.transaction do
      User.all.each do |u|
        u.password = new_password
        u.save!
        puts "#{u.username} / #{new_password}"
      end
    end
  end 

end

      
      