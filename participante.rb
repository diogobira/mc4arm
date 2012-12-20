require 'loader.rb'
require 'probability.rb'
require 'string.rb'

class Participante

	include Loader
	include Probability

	#Atributos
	attr_accessor :matricula
	attr_accessor :sexo
	attr_accessor :nascimento
	attr_accessor :vivo
	attr_accessor :invalido
	attr_accessor :quadro 
	attr_accessor :nivel
	attr_accessor :classe
	attr_accessor :topado
	attr_accessor :ats	
	attr_accessor :cargo
	attr_accessor :tempo_empresa
	attr_accessor :funcao_ativa
	attr_accessor :funcao_incorporada
	attr_accessor :funcao_incorporada_prc
	attr_accessor :status
	attr_accessor :idade
	attr_accessor :salario
	attr_accessor :dependentes

	#Inicialização
	def initialize(h)

		if params.nil?

			@matricula = 
			@sexo = Probability.
			@vivo = true
			@invalido = false
			@quadro = h[:quadro]
			@nivel = h[:nivel]
			@classe = h[:classe]
			@topado = false
			@ats = 0
			@cargo = "Default"
			@tempo_empresa = 0
			@funcao_ativa = nil
			@funcao_incorporada = nil
			@funcao_incorporada_prc = nil
			@status = "Ativo"
			@idade = Probability.
			@salario = h[:salario]
			@dependentes = Probability.

		else
			h.each_pair {|key,value| instance_variable_set("@#{key}",value)} 			

			#Conversões de tipo
			#@matricula
			#@sexo
			@vivo = @vivo.to_bool
			@invalido = @invalido.to_bool
			#@quadro
			#@nivel
			#@classe
			@topado = @topado.to_bool
			@ats = @ats.to_f
			#@cargo
			@tempo_empresa = @tempo_empresa.to_i
			#@funcao_ativa
			#@funcao_incorporada
			@funcao_incorporada_prc = @funcao_incorporada_prc.to_f
			#@status
			@idade = @idade.to_i
			@salario = @salario.to_f
			#@dependentes

		end

	end

end



