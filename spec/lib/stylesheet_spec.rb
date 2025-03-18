describe Glug::Stylesheet do
  it 'processes a basic stylesheet' do
    json = Glug::Stylesheet.new do
      version 8
      center [0.5, 53]
    end.to_json
    expect(json).to eql('{"version":8,"center":[0.5,53],"sources":{},"layers":[]}')
  end

  it 'processes the example stylesheet' do
    json = Glug::Stylesheet.new do
      version 8
      name 'My first stylesheet'
      source :osm_data, type: 'vector', url: 'http://my-server.com/osm.tilejson'

      layer(:roads, zoom: 10..13, source: :osm_data) do
        line_width 6
        line_color 0x888888
        on(highway == 'motorway', highway == 'motorway_link') { line_color :blue }
        on(highway == 'trunk', highway == 'trunk_link') { line_color :green }
        on(highway == 'primary', highway == 'primary_link') { line_color :red }
        on(highway == 'secondary') { line_color :orange }
        on(highway == 'residential') { line_width 4 }
      end
    end.to_json
    expect(json).to eq(<<~DOC
      {
        "version":8,
        "name":"My first stylesheet",
        "sources":{"osm_data":{"type":"vector","url":"http://my-server.com/osm.tilejson"}},
        "layers":[
          {
            "paint":{"line-width":6,"line-color":"#888888"},
            "source":"osm_data",
            "id":"roads",
            "source-layer":"roads",
            "type":"line",
            "minzoom":10,
            "maxzoom":13
          },
          {
            "paint":{"line-width":6,"line-color":"blue"},
            "source":"osm_data",
            "id":"roads__1",
            "source-layer":"roads",
            "type":"line",
            "filter":[
              "any",
              ["==",["get","highway"],"motorway"],
              ["==",["get","highway"],"motorway_link"]
            ],
            "minzoom":10,
            "maxzoom":13
          },
          {
            "paint":{"line-width":6,"line-color":"green"},
            "source":"osm_data",
            "id":"roads__2",
            "source-layer":"roads",
            "type":"line",
            "filter":[
              "any",
              ["==",["get","highway"],"trunk"],
              ["==",["get","highway"],"trunk_link"]
            ],
            "minzoom":10,
            "maxzoom":13
          },
          {
            "paint":{"line-width":6,"line-color":"red"},
            "source":"osm_data",
            "id":"roads__3",
            "source-layer":"roads",
            "type":"line",
            "filter":[
              "any",
              ["==",["get","highway"],"primary"],
              ["==",["get","highway"],"primary_link"]
            ],
            "minzoom":10,
            "maxzoom":13
          },
          {
            "paint":{"line-width":6,"line-color":"orange"},
            "source":"osm_data",
            "id":"roads__4",
            "source-layer":"roads",
            "type":"line",
            "filter":["==",["get","highway"],"secondary"],
            "minzoom":10,
            "maxzoom":13
          },
          {
            "paint":{"line-width":4,"line-color":"#888888"},
            "source":"osm_data",
            "id":"roads__5",
            "source-layer":"roads",
            "type":"line",
            "filter":["==",["get","highway"],"residential"],
            "minzoom":10,
            "maxzoom":13
          }
        ]
      }
    DOC
         .strip)
  end
end
