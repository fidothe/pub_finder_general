require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require 'sinatra'
require 'erubis'
require 'data_mapper'
require 'open-uri'
require 'nokogiri'

DataMapper.setup(:default, "sqlite://#{File.expand_path('../', __FILE__)}/#{ENV['RACK_ENV']}.sqlite3")

class Pub
  include DataMapper::Resource

  property :id,          Serial    # An auto-increment integer key
  property :name,        String
  property :description, Text
  property :lat,         String
  property :lon,         String

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
#DataMapper.auto_migrate! # Warning - this will wipe out any existing data in tables whose 
                         # schema has changed. If this scares you, try .auto_upgrade! instead

DataMapper.auto_upgrade! # Will create new tables, and add columns where needed. 
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
  pub_params = params[:pub]
  if pub_params[:lat].nil? || pub_params[:lat] == ''
    pub_params = pub_params.merge(fetch_pub_from_google(pub_params[:name]))
  end
  pub = Pub.create(pub_params)
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

def fetch_pub_from_google(name)
  starting_lat = '51.753177'
  starting_lon = '-1.250081'

  params = {
    location: "#{starting_lat},#{starting_lon}",
    radius: 1000,
    sensor: 'false',
    key: ENV['GAPI_KEY'],
    name: name,
    types: 'bar'
  }
  qs = Rack::Utils.build_query(params)
  query_url = "https://maps.googleapis.com/maps/api/place/search/xml?#{qs}"

  results = Nokogiri::XML(open(query_url))
  pub = results.css('result:first')
  name = pub.css('name').text
  lat = pub.css('location lat').text
  lon = pub.css('location lng').text
  {name: name, lat: lat, lon: lon}
end
