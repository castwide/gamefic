# frozen_string_literal: true

describe Gamefic::Dispatcher do
  it 'selects strict over fuzzy matches' do
    # @type klass [Class<Gamefic::Plot>]
    klass = Class.new(Gamefic::Plot) do
      construct :room, Gamefic::Entity, name: 'room'
      construct :bookshelf, Gamefic::Entity, name: 'bookshelf', parent: room
      construct :books, Gamefic::Entity, name: 'books', parent: room

      respond(:look, books) { |_, _| }
      respond(:look, bookshelf) { |_, _| }
    end

    plot = klass.new
    player = plot.introduce
    player.parent = plot.room

    dispatcher = Gamefic::Dispatcher.dispatch(player, 'look books')
    action = dispatcher.execute
    # Dispatcher should find an exact match for the @books response, even
    # though @bookshelf gets tested first
    expect(action.command.arguments.first.name).to eq('books')
  end

  it 'cancels commands' do
    executed = false
    klass = Class.new(Gamefic::Narrative) do
      respond(:foo) { executed = true }
      before_command { |_, command| command.stop }
    end

    plot = klass.new
    player = plot.introduce
    player.perform('foo')
    expect(executed).to be(false)
  end
end
