require "parametros.rb"
require 'array.rb'

p = Parametros.new("parametros.yml")

puts p.participantes.length

puts p.participantes[0].cargo

=begin
p.combinacoes.comprehend do |c|
	h = Hash.new
	c.each {|p| h.merge!(p)}
end
=end




