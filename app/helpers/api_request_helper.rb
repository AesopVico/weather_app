# Since multiple services will be making API requests, all external
# requests will be handled by these helper methods
module ApiRequestHelper

  def get(url:, params: {})
    response = RestClient.get(url, params: params)
    parse_json_response(response: response)
  end

  private

  def parse_json_response(response:)
    JSON.parse(response.body)
  end

end

