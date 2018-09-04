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
    assert_difference('Blog.count') do
      post blogs_url, params: { blog: { auther: @blog.auther, body: @blog.body, category: @blog.category, title: @blog.title } }
    end

    res = Faraday.get "http://localhost:9200/blog/_search"

    assert_equal 'index_not_found_exception', JSON.parse(res.body)['error']['type']
    assert_redirected_to blog_url(Blog.last)
  end

end
