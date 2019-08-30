module JsonHelpers
  def response_json
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_post(path, params:)
    post path,
         headers: { "Content-Type": 'application/json' },
         params: params.to_json
  end
end
