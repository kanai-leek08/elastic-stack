require 'test_helper'

class BlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blog = blogs(:one)
  end

  test "should get index" do
    get blogs_url
    assert_response :success
  end
  
  test "should migrate blog" do
    res = HttpClient.new.elastic.get "/blog"
    assert_equal "1", res[:blog][:settings][:index][:number_of_shards]
  end

  test "should create blog" do
    assert_difference('Blog.count') do
      post blogs_url, params: { blog: { auther: @blog.auther, body: @blog.body, category: @blog.category, title: @blog.title } }
    end
    res = HttpClient.new.elastic.get '/blog/_search'

    assert_equal 1, res[:hits][:total]
    assert_redirected_to blog_url(Blog.last)
  end

end
