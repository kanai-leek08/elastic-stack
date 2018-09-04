require 'test_helper'

class BlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blog = blogs(:one)
  end

  test "should get index" do
    get blogs_url
    assert_response :success
  end

  test "should create blog" do
    # HttpClient.new.elastic.post_payload_as_json(
    #   "/blog/_delete_by_query",
    #   {
    #     "query":{
    #       "match_all": {}
    #     }
    #   }
    # )
    assert_difference('Blog.count') do
      post blogs_url, params: { blog: { auther: @blog.auther, body: @blog.body, category: @blog.category, title: @blog.title } }
    end
    sleep 1
    res = Faraday.get "http://localhost:9200/blog/_search"

    assert_equal 1, JSON.parse(res.body)['hits']['total']
    assert_redirected_to blog_url(Blog.last)
  end

end
