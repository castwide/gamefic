require 'gamefic/query/abstract'
require 'gamefic/query/definition'
require 'gamefic/query/general'
require 'gamefic/query/relative'
require 'gamefic/query/textual'

# Steps in parsing a command:
# * Tokenize from syntaxes
# * For each argument:
#     * Filter by scope (available, children, etc.)
#     * Match objects to tokens
# * If all arguments have a matching object, we win!
