module Telex
  module HerokuClient
    extend self

    def account_info(user_uuid)

    end

    def app_info(app_uuid)
      get("/apps/#{app_uuid}")
    end

    def app_collaborators(app_uuid)
      get("/apps/#{app_uuid}/collaborators")
    end

    private

    def client
      Excon.new('https://api.heroku.com', user: 'telex', password: Config.heroku_api_key)
    end

    def get(path)
      headers = {"Accept"=>"application/vnd.heroku+json; version=3"}
      result = client.get(path: path, headers: headers)
      MultiJson.decode(result.body)
    end
  end
end
