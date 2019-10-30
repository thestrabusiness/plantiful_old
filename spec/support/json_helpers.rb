module JsonHelpers
  def response_json
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_post(path, params:, headers:)
    post path, headers: headers.merge("Content-Type": 'application/json'),
               params: params.to_json
  end
end
