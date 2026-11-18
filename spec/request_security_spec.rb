require 'rack/test'

describe 'Request and storage security' do
  def browser
    Rack::Test::Session.new(Rack::MockSession.new(MakersBnb))
  end

  def token(client)
    client.last_response.body[/name="csrf_token" value="([^"]+)"/, 1]
  end

  def register(client, username = 'owner')
    client.get('/signup')
    client.post('/signup', username: username, email: 'owner@example.com', password: 'strong-password', csrf_token: token(client))
    expect(client.last_response.status).to eq(302)
    client.follow_redirect!
  end

  def listing
    { space_name: 'House', space_description: 'Garden', space_price: '100',
      availability_start: '2026-12-01', availability_end: '2026-12-10' }
  end

  it 'requires authentication and CSRF before creating a listing' do
    client = browser
    client.get('/signup')
    client.post('/spaces/new', **listing, csrf_token: token(client))
    expect(client.last_response.status).to eq(302)
    expect(client.last_response.headers['location']).to end_with('/login')
    expect(Space.count).to eq(0)
    register(client)
    client.post('/spaces/new', listing)
    expect(client.last_response.status).to eq(403)
    expect(Space.count).to eq(0)
  end

  it 'binds ownership to the signed-in user even when another owner ID is submitted' do
    other = User.create(username: 'other', email: 'other@example.com', password: 'other-password')
    client = browser
    register(client)
    owner = User.first(email: 'owner@example.com')
    client.post('/spaces/new', **listing, user_id: other.id, csrf_token: token(client))
    expect(client.last_response.status).to eq(302)
    expect(Space.first.user_id).to eq(owner.id)
  end

  it 'escapes stored names and descriptions in both listing and booking pages' do
    client = browser
    register(client, '<img src=x onerror=alert(1)>')
    expect(client.last_response.body).to include('&lt;img src=x onerror=alert(1)&gt;')
    expect(client.last_response.body).not_to include('<img src=x onerror=alert(1)>')
    client.post('/spaces/new', **listing.merge(space_name: '<svg/onload=alert()>', space_description: '<script>alert(1)</script>'), csrf_token: token(client))
    client.follow_redirect!
    expect(client.last_response.body).to include('&lt;svg/onload=alert()&gt;')
    expect(client.last_response.body).not_to include('<svg/onload=alert()>')
    client.post('/spaces/booking', post_id: Space.first.id.to_s, csrf_token: token(client))
    client.follow_redirect!
    expect(client.last_response.body).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    expect(client.last_response.body).not_to include('<script>alert(1)</script>')
  end

  it 'rejects oversized bcrypt inputs and still authenticates existing short-password hashes' do
    user = User.new(username: 'long', email: 'long@example.com', password: 'a' * 73)
    expect(user.save).to be_nil
    expect(User.count).to eq(0)
    legacy = User.create(username: 'legacy', email: 'legacy@example.com', password_hash: BCrypt::Password.create('123', cost: BCrypt::Engine::MIN_COST).to_s)
    expect(User.authenticate(legacy.email, '123').id).to eq(legacy.id)
    expect(User.authenticate(legacy.email, '123' + 'a' * 72)).to be_nil
  end

  it 'preserves existing rows when the initial migration is applied to existing tables' do
    user = User.create(username: 'existing', email: 'existing@example.com', password: 'existing-password')
    space = Space.create(**listing, user_id: user.id)
    DB[:schema_info].update(version: 0)
    Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__))
    expect(User[user.id].password_hash).to eq(user.password_hash)
    expect(Space[space.id].space_description).to eq('Garden')
  end
end
