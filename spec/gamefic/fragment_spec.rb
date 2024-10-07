# frozen_string_literal: true

describe Gamefic::Fragment do
  it 'runs' do
    klass = Class.new(Gamefic::Fragment) do
      def run
        actor[:executed] = config[:execute]
      end
    end

    actor = Gamefic::Actor.new
    klass.run(actor, execute: true)
    expect(actor[:executed]).to be(true)
  end
end
