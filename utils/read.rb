$:.unshift "lib"
require 'rlp/corpus'
require 'rlp/grammar'

include Rlp::Corpus

Corpus.instance.open_database("data/pap")
Rlp::Grammar::Client.instance.open_database("data/rlp")

forms = {}
counts = Hash.new(0)
ARGV.each.with_index do |arg,index|
  flexemes = Rlp::Grammar::Flexeme.find(arg)
  forms[index] =
    if flexemes.to_a.empty?
      [Rlp::Grammar::WordForm.find_by_value(arg)]
    else
      flexemes.map{|f| f.word_forms.to_a}
    end.flatten

  forms[index].each do |form|
    counts[index] += Segment.find_all_by_form(form).count || 0
  end
  if counts[index] == 0
    puts "Form missing: #{arg}"
    exit
  end
end

counts = counts.sort_by{|k,v| v}
sentence_ids = {}
forms[counts[0][0]].each do |form|
  Segment.find_all_by_form(form).each do |segment|
    sentence_ids[segment.sentence.rod_id] = [segment.position]
  end
end

counts[1..-1].each do |arg_index,index|
  new_sentence_ids = {}
  forms[arg_index].each do |form|
    Segment.find_all_by_form(form).each do |segment|
      rod_id = segment.sentence.rod_id
      if sentence_ids.has_key?(rod_id)
        positions = sentence_ids[rod_id]
        positions << segment.position
        new_sentence_ids[rod_id] = positions
      end
    end
  end
  sentence_ids = new_sentence_ids
end

sentence_ids.each do |rod_id,positions|
  puts Sentence.find_by_rod_id(rod_id).to_s(true,positions)
end

Rlp::Grammar::Client.instance.close_database
Corpus.instance.close_database
