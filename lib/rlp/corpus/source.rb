require 'rlp/corpus/model'

module Rlp
  module Corpus
    class Source < Model
      field :name, :string, :index => :flat
    end
  end
end
