require 'rlp/corpus/model'

module Rlp
  module Corpus
    class Sentence < Model
      field :position, :integer

      has_one :document
      has_one :previous, :class_name => "Rlp::Corpus::Sentence"
      has_one :next, :class_name => "Rlp::Corpus::Sentence"
      has_many :segments

      def to_s(raw=true,hl_indices=[])
        simple = segments.map.with_index do |segment,index|
          str = "#{segment.word_form}#{segment.space_after}"
          str = "<#{str}>" unless raw
          hl_indices.include?(index) ? str.hl(:blue) : str
        end.join("").gsub(/\s*(\n|\r)\s*/," ")
        return simple if raw

        previous = self.previous ? self.previous.to_s : ""
        next_s = self.next ? self.next.to_s : ""
        "#{previous[-10..-1]}[#{simple}]#{next_s[0..10]}"
      end
    end
  end
end
