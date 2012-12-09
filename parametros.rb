require 'yaml'
require 'probability.rb'

class Parametros

	def initialize(arquivo)

		@combinacoes_simbolos = Array.new
		@combinacoes_valores = Array.new

		#Carrega parâmetros de simulação do arquivo YAML

		config = YAML.load_file(arquivo)

		secoes = ["geral","previdencia","patrocinador","financeiro"]

		secoes.each do |secao|

			config[secao].each do |key, config_value|

				type, data_type, value = config_value.split(";").map{|x| x.strip!}

				case type

					#Parametros de lista fixa
					when "SimpleList"
						case data_type				
							when "String"
								instance_variable_set("@#{key}", value.split(",").map{|x| x.strip}) 
							when "Number"
								instance_variable_set("@#{key}", value.split(",").map{|x| x.to_f}) 					
						end

					#Parametros de lista aleatoria
					when "RandomList"
						partes = value.split(/\s+/)
						samples = partes[0].to_i
						dist_fun = partes[1]
						dist_params = partes[2,partes.length-1].map{|x| x.to_f}
						instance_variable_set("@#{key}", random_sample(samples,dist_fun,dist_params)) 					
				end

				#Atualiza array de nomes (simbolos) de parametros combinaveis
				@combinacoes_simbolos << key.to_sym if tipo != "geral"

			end

		end

		#Array com todas as combinações de valores de variáveis que serão simuladas
		parametros_combinaveis = Array.new
		@combinacoes_simbolos.each {|sym| parametros_combinaveis << instance_variable_get("@#{sym.to_s}")}
		@combinacoes_valores = produto_cartesiano(*parametros_combinaveis)

		#Arrays iniciais de participantes e dependentes
		@participantes = load_participantes(@geral_arquivo_pessoas)
		@dependentes = load_dependentes

	end

	########################################################################
	#Métodos de apoio
	########################################################################
	def produto_cartesiano(*args)
		result = [[]]
		while [] != args
		  t, result = result, []
		  b, *args = args
		  t.each do |a|
		    b.each do |n|
		      result << a + [n]
		    end
		  end
		end
		result.inspect
	end

end
