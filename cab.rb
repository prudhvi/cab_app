require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext'


get '/' do
  'Hello Uber!'
end

include Mongo

configure do
  conn = MongoClient.new("localhost", 27017)
  set :mongo_db, conn.db('cabs')
  settings.mongo_db['cabs'].ensure_index({location: "2dsphere"})
end

#curl -i -H "Accept: application/json" -X PUT -d "latitude=90&longitude=123" http://0.0.0.0:4567/cabs/1
#1 Create/Update
put '/cabs/:id' do
  cab_id = params[:id]
  cab = settings.mongo_db['cabs'].save({_id: cab_id, location: {type: "Point", coordinates: [params[:longitude].to_f, params[:latitude].to_f]}})

  if cab
    status 200
  end
end

#2 Get
get '/cabs/:id' do
  content_type :json
  cab = settings.mongo_db['cabs'].find_one({_id: params[:id]})
  if cab
   # cab.to_json
    {"id" => cab["_id"], "longitude" => cab["location"]["coordinates"].first, "latitude" => cab["location"]["coordinates"].last}.to_json
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
  final_results = results["results"].map {|h| h.fetch("obj")}
  final_results.each do |v|
    all << {"id" => v["_id"], "latitude" => v["location"]["coordinates"].last, "longitude" =>v["location"]["coordinates"].first }
  end

  all.to_json
end

#4 Destroy

delete '/cabs/:id' do
  settings.mongo_db['cabs'].remove({_id: params[:id]})
  status 200
end

#5 Destroy all

delete '/cabs' do
  settings.mongo_db['cabs'].remove()
  status 200
end


