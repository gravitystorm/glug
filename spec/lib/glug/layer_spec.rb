# frozen_string_literal: true

describe Glug::Layer do
  describe 'zoom levels' do
    it 'treats an integer as both min and max' do
      stylesheet = Glug::Stylesheet.new do
        source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
      end
      l = described_class.new(stylesheet, { zoom: 7 })
      l.add_property(:line_width, 1)

      h = l.to_hash
      expect(h['minzoom']).to be(7)
      expect(h['maxzoom']).to be(7)
    end

    it 'splits a range into min and max' do
      stylesheet = Glug::Stylesheet.new do
        source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
      end
      l = described_class.new(stylesheet, { zoom: 1..5 })
      l.add_property(:line_width, 1)

      h = l.to_hash
      expect(h['minzoom']).to be(1)
      expect(h['maxzoom']).to be(5)
    end

    context 'with endless ranges' do
      it 'does not set a max zoom' do
        stylesheet = Glug::Stylesheet.new do
          source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
        end
        l = described_class.new(stylesheet, { zoom: 1.. })
        l.add_property(:line_width, 1)

        h = l.to_hash
        expect(h).to have_key('minzoom')
        expect(h['minzoom']).to be(1)
        expect(h).not_to have_key('maxzoom')
      end

      it 'does not set a min zoom' do
        stylesheet = Glug::Stylesheet.new do
          source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
        end
        l = described_class.new(stylesheet, { zoom: ..5 })
        l.add_property(:line_width, 1)

        h = l.to_hash
        expect(h).not_to have_key('minzoom')
        expect(h).to have_key('maxzoom')
        expect(h['maxzoom']).to be(5)
      end
    end
  end

  describe 'type deduction' do
    def layer_with(properties)
      stylesheet = Glug::Stylesheet.new do
        source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
      end
      layer = described_class.new(stylesheet, { id: :test })
      properties.each { |k, v| layer.add_property(k, v) }
      layer
    end

    {
      { line_width: 1 } => :line,
      { icon_size: 1, text_color: 'red' } => :symbol,
      { fill_extrusion_rounded_corner_distance: 1 } => :"fill-extrusion",
      { color_relief_opacity: 0.5 } => :"color-relief",
      { resampling: 'nearest', raster_opacity: 0.5 } => :raster,
      { hillshade_method: 'standard', resampling: 'nearest' } => :hillshade
    }.each do |properties, type|
      it "deduces #{type} from #{properties.keys.join(', ')}" do
        expect(layer_with(properties).to_hash['type']).to eq(type)
      end
    end

    it 'raises if properties belong to different layer types' do
      expect { layer_with(line_width: 1, fill_color: 'red').to_hash }.to raise_error(/conflicts/)
    end

    it 'leaves the type unset if the properties are valid for several layer types' do
      expect(layer_with(visibility: 'none').to_hash['type']).to be_nil
    end
  end
end
