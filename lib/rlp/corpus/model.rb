require 'rlp/corpus/corpus'

module Rlp
  module Corpus
    class Model < Rod::Model
      database_class Corpus
    end
  end
end
