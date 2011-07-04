require 'rlp/corpus/model'

module Rlp
  module Corpus
    class Sentence < Model
      field :position, :integer

      has_one :document
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

      # The next sentence in the document.
      def next
        return nil if self.position == 0
        self.document.sentences[self.position-1]
      end

      # The previous sentence in the document.
      def previous
        return nil if self.position == self.documents.sentences.count - 1
        self.document.sentences[self.position+1]
      end
    end
  end
end
