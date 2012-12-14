class Participante

	#Atributos
	attr_accessor :matricula
	attr_accessor :sexo
	attr_accessor :nascimento
	attr_accessor :vivo
	attr_accessor :quadro 
	attr_accessor :nivel
	attr_accessor :classe
	attr_accessor :topado
	attr_accessor :ats	
	attr_accessor :cargo
	attr_accessor :admissao
	attr_accessor :tempo_empresa
	attr_accessor :funcao_ativa
	attr_accessor :funcao_incorporada
	attr_accessor :funcao_incorporada_prc
	attr_accessor :status
	attr_accessor :idade
	attr_accessor :salario
	attr_accessor :dependentes

	#Inicialização
	def initialize(params)

		if params.nil?
		else
			params.each_pair {|key,value| instance_variable_set("@#{key}",value)} 			
			#self.class.send(:attr_accessor, key)
		end

	end

end



