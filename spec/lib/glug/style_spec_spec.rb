# frozen_string_literal: true

RSpec.describe Glug::StyleSpec do
  def glug_names(spec_names)
    spec_names.map { |name| name.tr('-', '_').to_sym }
  end

  it 'records which upstream release it was generated from' do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it 'lets layers set every upstream layout property' do
    expect(Glug::Layer::LAYOUT).to match_array(glug_names(described_class::LAYOUT.values.flatten.uniq))
  end

  it 'lets layers set every upstream paint property' do
    expect(Glug::Layer::PAINT).to match_array(glug_names(described_class::PAINT.values.flatten.uniq))
  end

  it 'can express every upstream expression' do
    missing = described_class::EXPRESSIONS.reject do |name|
      Glug::Layer::OPERATOR_EXPRESSIONS.include?(name) ||
        Glug::Layer::EXPRESSIONS.include?(Glug::Layer.expression_method(name))
    end
    expect(missing).to be_empty
  end

  it 'implements each operator expression as a Condition method' do
    Glug::Layer::OPERATOR_EXPRESSIONS.each do |op|
      expect(Glug::Condition.public_method_defined?(op)).to be(true), "Condition##{op} is not defined"
    end
  end

  it 'only exposes expressions as plain Ruby method names' do
    # An upstream operator with no word equivalent (like '^' => pow) needs adding to
    # Condition::SUBSTITUTIONS or Layer::OPERATOR_EXPRESSIONS
    invalid = Glug::Layer::EXPRESSIONS.grep_v(/\A[a-z_][a-z0-9_]*!?\z/)
    expect(invalid).to be_empty
  end
end
