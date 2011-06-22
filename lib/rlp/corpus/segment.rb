# encoding: utf-8

module Rlp
  module Corpus
    class Segment < Model
      field :space_after, :string
      field :position, :integer
      field :letter_case, :string

      has_one :form, :class_name => "Rlp::Grammar::WordForm", :index => :segmented
      has_one :previous, :class_name => "Rlp::Corpus::Segment"
      has_one :next, :class_name => "Rlp::Corpus::Segment"
      has_one :sentence

      def word_form=(string)
        self.letter_case = string.each_char.map do |char|
          case char
          when /\p{Lower}/
            "m"
          when /\p{Upper}/
            "M"
          else
            "x"
          end
        end.join("").sub(/(.)(\1)+$/,"\\1+")
        string = UnicodeUtils.downcase(string)
        rlp_form = Rlp::WordForm.find_by_value(string)
        if rlp_form.nil?
          rlp_form = Rlp::WordForm.new(:value => string)
          rlp_form.store
        end
        self.form = rlp_form
      end

      def word_form
        self.form.value.each_char.map.with_index do |char,index|
          case self.letter_case[index]
          when "M"
            UnicodeUtils.upcase(char)
          when "+",nil
            if self.letter_case[-2] == "M"
              UnicodeUtils.upcase(char)
            else
              char
            end
          else
            char
          end
        end.join("")
      end
    end
  end
end
