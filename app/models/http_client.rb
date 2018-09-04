# frozen_string_literal: true

class HttpClient
  CODE_SUCCESS = 'success'
  CODE_DUPLICATION = 'duplication'

  def elastic 
    if Rails.env == 'test'
      @con = connect("http://localhost:9200")
    else
      @con = connect("http://localhost:9200")
    end
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

  def put_payload_as_json(target, params)
    @con.put do |req|
      req.url target
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    
    end
  end

  def delete(target)
    @con.delete(target)
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