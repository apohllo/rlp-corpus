require 'rlp/corpus/model'

module Rlp
  module Corpus
    class Document < Model
      field :title, :string, :index => :flat
      field :position, :integer

      has_one :source
      has_many :sentences
    end
  end
end
