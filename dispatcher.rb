require 'parametros.rb'

arquivo_configuracoes = ARGV[0]
quantidade_execucoes = ARGV[1]

cashFlows = Array.new

parametros = Parametros.new(arquivo_configuracoes)

s = Simulador.new(parametros)

=begin
(1..quantidade_execucoes).each do |i|
	Thread.new { cashFlows << s.executar }
end
=end


