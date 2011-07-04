# encoding: utf-8
$:.unshift "lib"

require 'srx/polish/sentence'
require 'benchmark'
require 'rlp/grammar'
require 'rlp/corpus'
#require 'ruby-debug'


Rlp::Corpus::Corpus.instance.create_database("data/pap")
Rlp::Grammar::Client.instance.open_database("data/rlp",:readonly => false)

#Benchmark.bm do |bm|
#  bm.report do
source = Rlp::Corpus::Source.new
source.name = "Notatki PAP"
source.store
SPLIT_RULES = {
  :word => "\\p{Alpha}\\p{Word}*",
  :digits => "\\p{Digit}+(?:[:., _/-]\\p{Digit}+)*",
  :punct => "\\p{Punct}",
  :graph => "\\p{Graph}",
  :other => "[^\\p{Word}\\p{Graph}]+"
}

SPLIT_RE = /#{SPLIT_RULES.values.map{|v| "(?:#{v})"}.join("|")}/m
SPACE_RE = /#{SPLIT_RULES[:other]}/
puts SPACE_RE
puts SPLIT_RE
forms = {}


files = Dir.glob("work/inutf/0*")
puts "Total: #{files.size}"
files.each.with_index do |file_name,index|
  print "#{index}. "
  puts if index % 20 == 0
  document = Rlp::Corpus::Document.new(
    :title => file_name[file_name.rindex("/")+1..-1],
    :source => source, :position => index)
  File.open(file_name) do |file|
    last_space = ""
    last_sentence = nil
    sentence_index = 0
    SRX::Polish::Sentence.new(file).each do |sentence_str|
      sentence = Rlp::Corpus::Sentence.new(:document => document)
      sentence_index += 1
      document.sentences << sentence
      unless last_sentence.nil?
        last_sentence.store
      end
      last_sentence = sentence

      last_segment = nil
      segment_index = 0
      sentence_str.scan(SPLIT_RE) do |segment_str|
        #puts segment_str
        if segment_str =~ SPACE_RE
          #puts "space"
          unless last_segment.nil?
            last_segment.space_after = segment_str
          end
          next
        end
        segment = Rlp::Corpus::Segment.new(:position => segment_index,
              :space_after => "")
        segment.sentence = sentence
        #if index >= 380 && segment_str == "mandat"
        #  debugger
        #end
        segment.word_form = segment_str
        segment_index += 1
        sentence.segments << segment
        unless last_segment.nil?
          last_segment.store
        end
        last_segment = segment
      end
      last_segment.store unless last_segment.nil?
    end
    last_sentence.store unless last_sentence.nil?
  end
  document.store
end
#  end
#end

Rlp::Grammar::Client.instance.close_database
Rlp::Corpus::Corpus.instance.close_database
puts
