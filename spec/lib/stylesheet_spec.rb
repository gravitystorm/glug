describe Glug::Stylesheet do
  it 'processes a basic stylesheet' do
    json = Glug::Stylesheet.new {
      version 8
      center [0.5,53]
    }.to_json
    expect(json).to eql("{\"version\":8,\"center\":[0.5,53],\"sources\":{},\"layers\":[]}")
  end
end
