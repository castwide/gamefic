require 'gamefic/grammar'

module Gamefic::Grammar
    class VerbSet
      def initialize infinitive, *forms
        # TODO what to do with the tense?
        @infinitive = infinitive.to_s
        @forms = {}
        form = forms[0]
        @forms["1:singular"] = form.nil? ? @infinitive.to_s : form.to_s
        form = forms[1]
        @forms["2:singular"] = form.nil? ? @infinitive.to_s : form.to_s
        form = forms[2]
        @forms["3:singular"] = form.nil? ? generate_third_singular : form.to_s
        form = forms[3]
        @forms["1:plural"] = form.nil? ? @infinitive.to_s : form.to_s
        form = forms[4]
        @forms["2:plural"] = form.nil? ? @forms["1:plural"] : form.to_s
        form = forms[5]
        @forms["3:plural"] = form.nil? ? @forms["1:plural"] : form.to_s
      end
      def conjugate pronoun
        form = @forms["#{pronoun.person}"]
        if form.nil?
          form = @forms["#{pronoun.person}:#{pronoun.plural? ? 'plural' : 'singular'}"]
        end
        if form.nil?
          raise "Unable to conjugate #{@infinitive}"
        end
        form
      end
      private
      def generate_third_singular
        if @infinitive.end_with?('o')
          @infinitive + "es"
        elsif @infinitive.end_with?('ry')
          @infinitive[0..-2] + "ies"
        else
          @infinitive + "s"
        end
      end
    end
end
