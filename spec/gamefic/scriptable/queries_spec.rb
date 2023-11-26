describe Gamefic::Scriptable::Actions do
  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  let(:object) {
    klass = Class.new do
      include Gamefic::Scriptable::Queries

      def entities
        @entities ||= [
          Gamefic::Entity.new(name: 'entity one'),
          Gamefic::Entity.new(name: 'entity two')
        ]
      end
    end

    klass.new
  }

  describe '#anywhere' do
    it 'returns a general query' do
      query = object.anywhere
      expect(query).to be_a(Gamefic::Query::General)
    end
  end
end
