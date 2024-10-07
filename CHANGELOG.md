## 3.7.0
- Nuanced scans
- Active#command
- Command hooks
- Refactored queries
- Clips

## 3.6.0 - October 6, 2024
- Normalized arguments accept strings
- Smarter picks and proxies
- Commands prefer strictness over precision
- Queries scan for ambiguity before filtering through arguments
- Abstract queries
- Command logging

## 3.5.0 - October 5, 2024
- Configurable scanners
- Refactored scanners and queries
- Allow assignment to nil instance variables in stage
- Lazy proxies
- Remove buggy index proxies
- Chapter inherits Narrative
- Plot attribute proxy for chapters and subplots
- Entity#leave
- Descendants query
- Persistent subplots
- Entity#broadcast
- Ascendants in family query

## 3.4.0 - September 10, 2024
- Chapters
- Subplots and chapters do not repeat plot scripts
- Scriptable.no_scripts is deprecated
- Refactoring/removing unused methods

## 3.3.0 - September 1, 2024
- Node#take
- Node#include?
- Reject non-string tokens in Text queries

## 3.2.2 - July 21, 2024
- Describable#described?

## 3.2.1 - July 1, 2024
- MultipleChoice accepts shortened text
- Return Proxy::Agent from attr_seed and make_seed
- MultipleChoice skips finish blocks for invalid input

## 3.2.0 - April 9, 2024
- Bug fix for marshal of structs in Opal
- Add last_input and last_prompt at start of take

## 3.1.0 - April 8, 2024
- Dispatcher prioritizes strict token matches
- Scanner builds commands
- Tokenize expressions and execute commands
- Delete concluded subplots last in Plot#ready
- Fix plot conclusion check after subplots conclude
- Correct contexts for conclude and output blocks
- Reinstate Active#last_input

## 3.0.0 - January 27, 2024
- Instantiate subplots from snapshots
- Split Action into Response and Action
- Logging
- Remove deprecated Active#perform behavior
- Snapshots use single static index
- Hydration improvements
- Snapshot metadata validation

## 2.4.0 - February 11, 2023
- Fix arity of delegated methods in scripts
- Action hooks accept verb filters
- Opal exception for delegated methods
- Support separation of kwargs in Ruby >= 2.7

## 2.3.0 - January 25, 2023
- Remove unused Active#actions method
- Add before_action and after_action hooks

## 2.2.3 - July 9, 2022
- Fix Ruby version incompatibilities
- Fix private attr_accessor call

## 2.2.2 - September 6, 2021
- Darkroom indexes non-static elements

## 2.2.1 - September 5, 2021
- Retain unknown values in restored snapshots

## 2.2.0 - September 4, 2021
- Dynamically inherit default attributes

## 2.1.1 - July 23, 2021
- Remove gamefic/scene/custom autoload

## 2.1.0 - June 21, 2021
- Remove redundant MultipleChoice prompt
- Deprecate Scene::Custom

## 2.0.3 - December 14, 2020
- Remove unused Index class
- Active#conclude accepts data argument

## 2.0.2 - April 25, 2020
- Improved snapshot serialization
