# frozen_string_literal: true

describe Gamefic::Dispatcher do
  let(:stage_func) { Object.new }

  it 'filters and orders actions' do
    rulebook = Gamefic::Rulebook.new
    response1 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    response2 = rulebook.calls.add_response Gamefic::Response.new(:command, stage_func) { |_| nil }
    actor = Gamefic::Actor.new
    actor.epic.add OpenStruct.new(rulebook: rulebook)
    dispatcher = Gamefic::Dispatcher.dispatch(actor, 'command')
    expect(dispatcher.execute.response).to be(response2)
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

      respond(:look, pick!('books')) { |_, _| }
      respond(:look, pick!('bookshelf')) { |_, _| }
    end

    plot = klass.new
    player = plot.introduce
    player.parent = plot.pick('room')

    dispatcher = Gamefic::Dispatcher.dispatch(player, 'look books')
    action = dispatcher.execute
    # Dispatcher should find an exact match for the @books response, even
    # though @bookshelf gets tested first
    expect(action.arguments.first.name).to eq('books')
  end
end
