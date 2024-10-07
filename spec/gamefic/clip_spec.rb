# frozen_string_literal: true

describe Gamefic::Clip do
  it 'runs' do
    klass = Class.new(Gamefic::Clip) do
      def run
        actor[:executed] = config[:execute]
      end
    end

    actor = Gamefic::Actor.new
    klass.run(actor, execute: true)
    expect(actor[:executed]).to be(true)
  end
end
