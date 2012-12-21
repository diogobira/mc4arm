require 'parametros'
require 'simulador'

arquivo_configuracoes = ARGV[0]
quantidade_execucoes = ARGV[1].to_i

cashFlows = Array.new

parametros = Parametros.new(arquivo_configuracoes)


s = Simulador.new(parametros)

(1..quantidade_execucoes).each do |i|
	#Thread.new { cashFlows << s.executar }
    s.executar
end


