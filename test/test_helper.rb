ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require_relative '../app/models/http_client'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    HttpClient.new.elastic.post_payload_as_json(
      "/blog/_delete_by_query",
      {
        "query":{
          "match_all": {}
        }
      }
    )
  end

  # Add more helper methods to be used by all tests here...
end
