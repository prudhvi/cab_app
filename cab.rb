# Wrapper for Cab document.
class Cab
  def initialize(cab_doc)
    @id = cab_doc["_id"]
    @longitude = cab_doc["location"]["coordinates"].first
    @latitude = cab_doc["location"]["coordinates"].last
  end

  def to_hash
    {
      "id" => @id,
      "latitude" => @latitude,
      "longitude" => @longitude
    }
  end
end