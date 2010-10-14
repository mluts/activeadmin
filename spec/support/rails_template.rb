# Rails template to build the sample app for specs

# Create a cucumber database and environment
copy_file File.expand_path('../templates/cucumber.rb', __FILE__), "config/environments/cucumber.rb"
gsub_file 'config/database.yml', /^test:.*\n/, "test: &test\n"
gsub_file 'config/database.yml', /\z/, "\ncucumber:\n  <<: *test\n  database: db/cucumber.sqlite3"

# Generate some test models
generate :model, "post title:string body:text published_at:datetime author_id:integer"
inject_into_file 'app/models/post.rb', "  belongs_to :author, :class_name => 'User'\n  accepts_nested_attributes_for :author\n", :after => "class Post < ActiveRecord::Base\n"
generate :model, "user first_name:string last_name:string username:string"
inject_into_file 'app/models/user.rb', "  has_many :posts, :foreign_key => 'author_id'\n", :after => "class User < ActiveRecord::Base\n"
generate :model, 'category name:string'

# Add our local Active Admin to the load path
inject_into_file "config/environment.rb", "\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n", :after => "require File.expand_path('../application', __FILE__)"

run "rm Gemfile"
run "rm -r test"
run "rm -r spec"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
generate :'active_admin:install'

rake "db:migrate"
rake "db:test:prepare"
run "/usr/bin/env RAILS_ENV=cucumber /usr/bin/rake db:migrate"
