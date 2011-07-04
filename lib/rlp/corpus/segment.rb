# encoding: utf-8
require 'rlp/grammar/text_segment'

module Rlp
  module Corpus
    class Segment < Model
      include Rlp::Grammar::TextSegment

      field :space_after, :string
      field :position, :integer

      has_one :sentence

      # The next segment in the sentence.
      def next
        return nil if self.position == 0
        self.sentence.segments[self.position-1]
      end

      # The previous segment in the sentence.
      def previous
        return nil if self.position == self.sentence.segments.count - 1
        self.sentence.segments[self.position+1]
      end
    end
  end
end
