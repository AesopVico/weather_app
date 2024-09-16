module ApiRequestHelper

  def get(url:, params: {})
    response = RestClient.get(url, params)
    parse_json_response(response: response)
  end

  private

  def parse_json_response(response:)
    JSON.parse(response.body)
  end

end

