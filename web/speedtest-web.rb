require 'speedtest'
require 'rubygems'
require 'sinatra/base'
require 'rack/utils'

module SpeedTest
  class Web < Sinatra::Base
    HTML = %(
      <html>
        <head>
          <title>SpeedTest KML Generator</title>
          <style type='text/css'>
            body { 
              background-color: white;
              font-family: verdana, helvetica, arial, sans-serif;
              font-size: 9pt;
            }

            div.title {
              font-size: 12pt;
              font-weight: bold;
              margin-bottom: 10px;
            }

            td.label {
              text-align: right;
              font-size:  9pt;
              color: #333;
            }
          </style>
        </head>

        <body>
          <div class='title'>
            SpeedTest KML Generator
          </div>

          <form method='post' enctype='multipart/form-data'>
            <table>
              <tr>
                <td class='label'><label for='name'>Name:</label></td>
                <td><input type='text' id='name' name='name'/></td>
              </tr>

              <tr>
                <td class='label'><label for='desc'>Description:</label></td>
                <td><input type='text' id='desc' name='desc'/></td>
              </tr>

              <tr>
                <td class='label'><label for='csv'>CSV (required):</label></td>
                <td><input type='file' id='csv' name='csv'/></td>
              </tr>

              <tr>
                <td colspan='2'>
                  <input type='submit' value='Create KML'/>
                </td>
              </tr>
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
      # get name and data
      name = params[:csv][:name].gsub(/\.[^.]+$/, '') + '.kml'
      data = params[:csv][:tempfile].read

      attachment   name
      content_type 'application/vnd.google-earth.kml+xml'
      body         SpeedTest::Converter.run(
        params[:name] || '',
        params[:desc] || '',
        params[:csv][:tempfile].read
      )
    end
  end
end
