require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext'
require './cab'

include Mongo

configure do
  conn = MongoClient.new("localhost", 27017)
  set :mongo_db, conn.db('cabs')
  settings.mongo_db['cabs'].ensure_index({location: "2dsphere"})
end



#curl -i -H "Accept: application/json" -X PUT -d "latitude=90&longitude=123" http://0.0.0.0:4567/cabs/1

#1 Create/Update cab
put '/cabs/:id' do
  cab_id = params[:id]
  cab = settings.mongo_db['cabs'].save({
    _id: cab_id,
    location: {
      type: "Point",
      coordinates: [params[:longitude].to_f, params[:latitude].to_f]
    }
  })

  if cab
    status 200
  end
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

  latitude = params[:latitude].to_f
  longitude = params[:longitude].to_f
  limit = params[:limit].to_i
  radius = params[:radius].to_i

  results = settings.mongo_db.command({
    geoNear: 'cabs',
    near: {
      type: "Point",
      coordinates: [longitude, latitude]
    },
    maxDistance: radius,
    num: limit,
    spherical: true
  })

  all =[]
  cab_documents = results["results"].map {|h| h.fetch("obj")}

  cab_documents.each do |cab_doc|
    all << Cab.new(cab_doc).to_hash
  end

  all.to_json
end

#4 Destroy a cab

delete '/cabs/:id' do
  settings.mongo_db['cabs'].remove({_id: params[:id]})
  status 200
end

#5 Destroy all cabs

delete '/cabs/' do
  settings.mongo_db['cabs'].remove()
  status 200
end


