require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require 'sinatra'
require 'erubis'
require 'data_mapper'

DataMapper.setup(:default, "sqlite://#{File.expand_path('../', __FILE__)}/#{ENV['RACK_ENV']}.sqlite3")

class Pub
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :name,        String
  property :description, Text

  has n, :reviews
end

class Review
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :reviewer,    String
  property :text,        Text

  belongs_to :pub
end

DataMapper.finalize
DataMapper.auto_migrate! # Warning - this will wipe out any existing data in tables whose 
                         # schema has changed. If this scares you, try .auto_upgrade! instead

# DataMapper.auto_upgrade! # Will create new tables, and add columns where needed. 
                           # It won't change column constraints or drop columns

get '/' do
  erubis :index
end

get '/pubs' do
  pubs = Pub.all
  erubis :'pubs/index', :locals => {:pubs => pubs}
end

get '/pubs/new' do
  erubis :'pubs/new'
end

post '/pubs' do
  pub = Pub.create(params[:pub])
  redirect to("/pubs/#{pub.id}")
end

get '/pubs/:pub_id' do
  pub = Pub.get(params[:pub_id])
  erubis :'pubs/show', :locals => {:pub => pub}
end

post '/pubs/:pub_id/reviews' do
  pub = Pub.get(params[:pub_id])
  review = pub.reviews.create(params[:review])
  redirect to("/pubs/#{params[:pub_id]}")
end

get '/pubs/:pub_id/reviews' do
  pub = Pub.get(params[:pub_id])
  reviews = pub.reviews
  erubis :'reviews/index', :locals => {:pub => pub, :reviews => reviews}
end
