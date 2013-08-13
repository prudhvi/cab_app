require 'rubygems'
require 'sinatra'
require 'mongo'
require 'haml'
require 'json/ext'
require './cab'

include Mongo

configure do
  mongo_uri = ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/cabs"
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  client = MongoClient.from_uri(mongo_uri)
  set :mongo_db, client.db(db_name)
  settings.mongo_db['cabs'].ensure_index({location: Mongo::GEO2DSPHERE})
end


get '/' do
  haml :index
end

get '/cabs/new/' do
  @title = 'Add a new cab'
  haml :new
end

get '/cabs/show/' do
  cab_list = settings.mongo_db['cabs'].find().map{|cab| Cab.new(cab)}
  cab_icon = 'http://icons.iconarchive.com/icons/cemagraphics/classic-cars/16/yellow-pickup-icon.png'
  markers  = "|" + cab_list.map{|c| [c.latitude,c.longitude].join(',')}.join('|') + "|"

  @google_maps_url = "http://maps.googleapis.com/maps/api/staticmap?size=600x600&zoom=1&maptype=roadmap&sensor=false&markers=icon:#{cab_icon}"
  @google_maps_url += URI.encode(markers)

  haml :show
end

#1 Create/Update cab
put '/cabs/create' do
  cab_id = params[:id]
  cab = settings.mongo_db['cabs'].save({
    _id: cab_id,
    location: {
      type: "Point",
      coordinates: [params[:longitude].to_f, params[:latitude].to_f]
    }
  })

  if cab
    @message = 'Cab is saved'
    status 200
  else
    @message = "Cab isn't saved"
  end
  haml :create
end

#2 Get a cab info
get '/cabs/:id' do
  content_type :json
  cab_doc = settings.mongo_db['cabs'].find_one({_id: params[:id]})
  if cab_doc
    Cab.new(cab_doc).to_hash.to_json
  else
    {}.to_json
  end
end


#3 Query
get '/cabs' do
  content_type :json

  limit = params[:limit]? params[:limit].to_i : 8

  results = settings.mongo_db.command({
    geoNear: 'cabs',
    near: {
      type: "Point",
      coordinates: [params[:longitude].to_f, params[:latitude].to_f]
    },
    maxDistance: params[:radius].to_f,
    num: limit,
    spherical: true
  })

  nearest_cabs =[]
  cab_documents = results["results"].map {|h| h.fetch("obj")}

  cab_documents.each do |cab_doc|
    nearest_cabs << Cab.new(cab_doc).to_hash
  end

  nearest_cabs.to_json
end

#4 Destroy a cab
delete '/cabs/:id' do
  settings.mongo_db['cabs'].remove({_id: params[:id]})
  status 200
end



