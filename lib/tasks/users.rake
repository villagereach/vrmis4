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
end

      
      