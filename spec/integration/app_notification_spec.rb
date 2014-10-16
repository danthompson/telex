require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Routes
  end

  before do
    header "Content-Type", "application/json"

    producer = Fabricate(:producer, api_key: 'foo')
    authorize producer.id, 'foo'

    @h_user1 = HerokuAPIMock.create_heroku_user
    Fabricate(:user, email: "outdated@email.com", heroku_id: @h_user1.heroku_id)
    @h_user2 = HerokuAPIMock.create_heroku_user
    heroku_app = HerokuAPIMock.create_heroku_app(owner: @h_user1, collaborators:[@h_user1, @h_user2])

    @message_body = {
      title: Faker::Company.bs,
      body: Faker::Company.bs,
      target: {type: 'app', id: heroku_app.id}
    }
  end

  def do_post
    post '/producer/messages', MultiJson.encode(@message_body)
  end

  it 'works' do
    # sanity checks
    expect(User.count).to eq(1)
    existing_user = User.first
    expect(existing_user.email).to eq("outdated@email.com")
    expect(@h_user1.email).to_not eq("outdated@email.com")
    expect(existing_user.heroku_id).to eq(@h_user1.heroku_id)

    # action
    Sidekiq::Testing.inline! do
      do_post
      existing_user.reload
    end

    # verification
    expect(last_response.status).to eq(201)
    expect(User.count).to eq(2)
    expect(existing_user.email).to eq(@h_user1.email)

    notifications = Notification.all
    users = User.all
    expect(notifications.map(&:user_id)).to match(users.map(&:id))
    expect(notifications.count).to eq(2)

    deliveries = Mail::TestMailer.deliveries
    expect(deliveries.map(&:to).flatten).to match(users.map(&:email))
    expect(deliveries.size).to eq(2)
  end
end
