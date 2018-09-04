class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  # GET /blogs
  # GET /blogs.json
  def index
    @blogs = Blog.all
  end

  # GET /blogs/1
  # GET /blogs/1.json
  def show
  end

  # GET /blogs/new
  def new
    @blog = Blog.new
  end

  # GET /blogs/1/edit
  def edit
  end

  # POST /blogs
  # POST /blogs.json
  def create
    @blog = Blog.new(blog_params)

    respond_to do |format|
      if @blog.save
        res = HttpClient.new.erastic.post_payload_as_json(
          '/blog/_doc',
          blog_params
        )
        format.html { redirect_to @blog, notice: 'Blog was successfully created.' }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /blogs/1
  # PATCH/PUT /blogs/1.json
  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to @blog, notice: 'Blog was successfully updated.' }
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.json
  def destroy
    @blog.destroy
    respond_to do |format|
      format.html { redirect_to blogs_url, notice: 'Blog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_params
      params.require(:blog).permit(:title, :body, :category, :auther)
    end
end

# frozen_string_literal: true

class HttpClient
  CODE_SUCCESS = 'success'
  CODE_DUPLICATION = 'duplication'

  def erastic 
    @con = connect("http://localhost:9200")
    self
  end

  def get(target, params = {})
    json_parse(get_body(target, params))
  end

  def get_body(target, params)
    response = @con.get do |req|
      req.url target
      if params.present?
        req.params = params
      end
      req.headers['Referer'] = 'pd_operation'
      req.headers['token'] = auth_token
    end
    raise if status_error?(response)
    response.body
  end

  def post_with_json(target, params)
    response = post_payload_as_json(target, params)
    raise response.body if status_error?(response)
    json_parse(response.body)
  end

  def post_payload_as_json(target, params)
    @con.post do |req|
      req.url target
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    end
  end

  private

  def connect(base_url)
    Faraday.new(url: base_url) do |builder|
      builder.ssl.verify = false
      builder.request :url_encoded
      # builder.adapter Faraday.default_adapter
      builder.adapter :typhoeus
    end
  end

  def status_error?(response)
    response.status != 200
  end

  def json_parse(body)
    JSON.parse(body, {symbolize_names: true})
  end
end

