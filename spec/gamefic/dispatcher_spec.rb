describe Gamefic::Dispatcher do
  let(:stage_func) { Object.new }

  it 'filters and orders actions' do
    rulebook = Gamefic::Rulebook.new(stage_func)
    response1 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    response2 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    actor = Gamefic::Actor.new
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    dispatcher = Gamefic::Dispatcher.dispatch(actor, 'command')
    expect(dispatcher.proceed.response).to be(response2)
    expect(dispatcher.proceed.response).to be(response1)
    expect(dispatcher.proceed).to be_nil
  end

  it 'selects strict over fuzzy matches' do
    # @type klass [Class<Gamefic::Plot>]
    klass = Class.new(Gamefic::Plot) do
      seed do
        @room = make Gamefic::Entity, name: 'room'
        @bookshelf = make Gamefic::Entity, name: 'bookshelf', parent: @room
        @books = make Gamefic::Entity, name: 'books', parent: @room
      end

      respond(:look, proxy(:@books)) { |_, _| }
      respond(:look, proxy(:@bookshelf)) { |_, _| }
    end

    plot = klass.new
    player = plot.introduce
    player.parent = plot.pick('room')

    command = Gamefic::Command.new(:look, ['books'])
    dispatcher = Gamefic::Dispatcher.new(player, [command], plot.rulebook.responses)
    action = dispatcher.proceed
    # Dispatcher should find an exact match for the @books response, even
    # though @bookshelf gets tested first
    expect(action.arguments.first.name).to eq('books')
  end
end
