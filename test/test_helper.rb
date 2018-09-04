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
    migrate_elasticsearch
  end

  def migrate_elasticsearch
    HttpClient.new.elastic.put_payload_as_json(
      "/blog",
      {
        "mappings": {
          "_doc": {
            "properties": {
              "auther": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "body": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "category": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              },
              "title": {
                "type": "text",
                "fields": {
                  "keyword": {
                    "type": "keyword",
                    "ignore_above": 256
                  }
                }
              }
            }
          }
        },
        "settings": {
          "index": {
            "number_of_shards": "1",
            "number_of_replicas": "1",
          }
        }
      }
    )
  end

  # Add more helper methods to be used by all tests here...
end
