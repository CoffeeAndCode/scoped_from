ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("#{__dir__}/../lib/scoped_from")

# Support
Dir["#{__dir__}/support/**/*.rb"].each { |f| require File.expand_path(f) }

# Mocks
ActiveSupport::Dependencies.autoload_paths << "#{__dir__}/mocks"

RSpec.configure do |config|
  config.include(UserMacro)

  config.before(:each) do
    Comment.delete_all
    Post.delete_all
    User.delete_all
    Vote.delete_all

    create_user(:john, firstname: 'John', lastname: 'Doe', enabled: true, admin: true)
    create_user(:jane, firstname: 'Jane', lastname: 'Doe', enabled: false, admin: false)
  end
end