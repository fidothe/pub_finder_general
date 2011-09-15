require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require 'sinatra'
require 'erubis'
require 'data_mapper'

# need OmniAuth for Twitter sign-in
require 'oa-oauth'

set :sessions, true

DataMapper.setup(:default, "sqlite://#{File.expand_path('../', __FILE__)}/#{ENV['RACK_ENV']}.sqlite3")

class Pub
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :name,        String
  property :description, Text

  has n, :reviews
end

class Reviewer
  include DataMapper::Resource
  
  property :id,          Serial    # An auto-increment integer key
  property :uid,         String    # the twitter uid
  property :twitterid,   String, :required => true # called nickname by twitter
  property :name,        String    # called name by twitter
  
  has n, :reviews
  
end

class Review
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :text,        Text

  belongs_to :pub,       :required => true
  belongs_to :reviewer,  :required => true
end

DataMapper.finalize
DataMapper.auto_migrate! # Warning - this will wipe out any existing data in tables whose 
                         # schema has changed. If this scares you, try .auto_upgrade! instead

# DataMapper.auto_upgrade! # Will create new tables, and add columns where needed. 
                           # It won't change column constraints or drop columns

# add some stuff for testing
@pub = Pub.create(
  :name => "white",
  :description => "another pub"
)

@reviewer = Reviewer.create(
  :twitterid => "laurendw",
  :name => "my name"
)

@review = Review.create(
  :pub_id => 1,
  :reviewer_id => 1,
  :text => "my first review of the white pub"
)

# Now the twitter stuff, filling in CONSUMER_KEY and CONSUMER_SECRET

use OmniAuth::Strategies::Twitter, 'IZXyIwBrkrV9KJXHkYo4HQ', 'dbbAWBA3V52ExlImrYQ9BXGDebcIt4vZQ30C55pNs'

helpers do
  def current_reviewer
    @current_reviewer ||= Reviewer.get(session[:reviewer_id]) if session[:reviewer_id]
  end
end


get '/' do
  @title = "Pub Finder General"
  erubis :index
end

get '/pubs' do
  @title = "List of Pubs"
  pubs = Pub.all
  erubis :'pubs/index', :locals => {:pubs => pubs}
end

get '/pubs/new' do
  @title = "Add a pub"
  erubis :'pubs/new'
end

post '/pubs' do
  @title = "Add a pub"
  pub = Pub.create(params[:pub])
  redirect to("/pubs/#{pub.id}")
end

get '/pubs/:pub_id' do
  @title = "Pub Details"
  pub = Pub.get(params[:pub_id])
  erubis :'pubs/show', :locals => {:pub => pub}
end

post '/pubs/:pub_id/reviews' do
  @title = "Create a pub review"
  pub = Pub.get(params[:pub_id])
  review = pub.reviews.create(params[:review])
  redirect to("/pubs/#{params[:pub_id]}")
end

get '/pubs/:pub_id/reviews' do
  @title = "Create a pub review"
  pub = Pub.get(params[:pub_id])
  reviews = pub.reviews
  erubis :'reviews/index', :locals => {:pub => pub, :reviews => reviews}
end

get '/reviewers' do
  @title = "List the reviewers"
  reviewers = Reviewer.all
  erubis :'reviewers/index', :locals => {:reviewers => reviewers}
end

get '/reviewers/new' do
  @title = "Add a reviewer"
  redirect '/auth/twitter'
#  erubis :'reviewers/new'
end

post '/reviewers' do
  @title = "Reviewer list"
  reviewer = Reviewer.create(params[:reviewer])
  redirect to("/reviewers/#{reviewer.id}")
end

get '/reviewers/:reviewer_id' do
  @title = "Reviewer details"
  reviewer = Reviewer.get(params[:reviewer_id])
  reviews = reviewer.reviews
  erubis :'reviewers/show', :locals => {:reviewer => reviewer, :reviews => reviews}
end

# sign in under /login
get '/login' do
  redirect '/auth/twitter'
end

# log out too
get '/logout' do
  session[:reviewer_id] = nil
  redirect '/'
end

# get the info from twitter
get '/auth/twitter/callback' do
  auth = request.env['omniauth.auth']
  reviewer = Reviewer.first_or_create({ :uid => auth["uid"]}, {
    :uid => auth["uid"],
    :twitterid => auth["user_info"]["nickname"],
    :name => auth["user_info"]["name"] })
  session[:reviewer_id] = reviewer.id
  redirect '/'
end
