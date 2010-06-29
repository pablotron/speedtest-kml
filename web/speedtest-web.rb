require 'speedtest'
require 'rubygems'
require 'sinatra/base'
require 'rack/utils'

module SpeedTest
  class Web < Sinatra::Base
    HTML = %(
      <html>
        <head>
          <title>SpeedTest CSV to KML</title>
        </head>

        <body>
          <form method='post'>
            <label for='csv'>CSV:</label>
            <input type='file' id='csv' name='csv'/>
            <input type='submit' value='Convert'/>
          </form>
        </body>
      </html>
    ).strip

    get '/' do
      status 200
      content_type 'text/html'
      body [HTML]
    end

    post '/' do
      req = Rack::Request.new(env)
      data = req.params['csv'][:tempfile]

      status 200
      content_type 'text/html'
      body [data]
# 
#       return [200
# 
#       attachment   'speedtest.kml'
#       content_type 'application/vnd.google-earth.kml+xml'
#       body         SpeedTest::Converter.run(data)
# 
    end
  end
end
