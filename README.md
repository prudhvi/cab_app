###Running the app locally:
   * Start `mongod`
   * bundle exec rackup config.ru -p 4567

   ####Sample Requests:
   
     * Create/Update cab:
      curl -i -H "Accept: application/json" -X PUT -d "latitude=90&longitude=123" http://0.0.0.0:4567/cabs/1
      curl -i -H "Accept: application/json" -X PUT -d "latitude=90&longitude=120" http://0.0.0.0:4567/cabs/2

     * Get cab info:
      curl -i  http://0.0.0.0:4567/cabs/1

     * Get nearest cabs info:
      curl -i "http://localhost:4567/cabs?latitude=90&longitude=-120=&radius=1000&limit=15"

     * Delete cab:
      curl -i -X DELETE  http://0.0.0.0:4567/cabs/2

     * Delete all cabs:
       curl -i -X DELETE  http://0.0.0.0:4567/cabs/

  ######Running the app live:
  
  * Replace `http://0.0.0.0:4567/` from Step c) with `http://serene-meadow-2077.herokuapp.com/`
