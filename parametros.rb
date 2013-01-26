require 'yaml'
#require 'probability.rb'
require 'loader.rb'

class Parametros

	#Includes
	#include Probability
	include Loader

	#Accessors para atributos derivados.
	attr_accessor :combinacoes
    attr_accessor :nao_combinaveis
	attr_accessor :participantes
	attr_accessor :dependentes

	#Inicialização
	def initialize(arquivo)

		@combinacoes = Array.new
		simbolos_combinaveis = Array.new
		valores_combinaveis = Array.new
        @nao_combinaveis = Hash.new
		simbolos_nao_combinaveis = Array.new
		valores_nao_combinaveis = Array.new
		@participantes = Array.new

		config = YAML.load_file(arquivo)

		secoes = ["geral","previdencia","patrocinador","financeiro"]

		secoes.each do |secao|

			config[secao].each do |key, config_value|

				#Separa valor do parametro em partes
				type, data_type, value = config_value.split(";").map{|x| x.strip}

				#Cria accessor para o atributo
				self.class.send(:attr_accessor, key)

				case type

					#Simples
					when "Simple"
						case data_type				
							when "String"
								instance_variable_set("@#{key}", value.strip.to_s) 
							when "Number"
								instance_variable_set("@#{key}", value.strip.to_f) 					
						end

					#Lista fixa
					when "SimpleList"
						case data_type				
							when "String"
								instance_variable_set("@#{key}", value.split(",").map{|x| x.strip}) 
							when "Number"
								instance_variable_set("@#{key}", value.split(",").map{|x| x.to_f}) 					
						end

					#Lista aleatoria baseada em distribuição de probabilidade
					when "RandomList"
						partes = value.split(/\s+/)
						samples = partes[0].to_i
						dist_fun = partes[1]
						dist_params = partes[2,partes.length-1].map{|x| x.to_f}
						instance_variable_set("@#{key}", random_sample(samples,dist_fun,dist_params)) 					

					#Distribuição de probabilidade
					when "Distribution"	
						partes = value.split(/\s+/)
						dist_fun = partes[0]
						dist_params = partes[1,partes.length-1].map{|x| x.to_f}
						instance_variable_set("@#{key}", {:distr=>dist_fun, :params=>dist_params}) 					

				end


				#Parâmetros combináveis	
				if secao != "geral" and type != "Distribution"
					simbolos_combinaveis << key.to_sym
					valores_combinaveis << instance_variable_get("@#{key}")
                else #Parâmetros não combináveis
                    simbolos_nao_combinaveis << key.to_sym
                    valores_nao_combinaveis << instance_variable_get("@#{key}")
				end

			end

		end

		#Intercala simbolos e valores combináveis
		x = simbolos_combinaveis.zip(valores_combinaveis)

		#Gera um vetor flat com as combinações dos parâmetros combináveis
		@combinacoes = x.map{|s,v| v.map {|p| [s,p]}}.map{|k| k.map{|j| Hash[*j]}}

        # Acrescenta os parâmetros não combináveis
		x = simbolos_nao_combinaveis.zip(valores_nao_combinaveis)

        # Gera um hash flat com os parâmetros não combináveis
        @nao_combinaveis = Hash[*x.flatten]

		#Arrays iniciais de participantes e dependentes
		@participantes = load_participantes(@geral_arquivo_pessoas)

	end


end
