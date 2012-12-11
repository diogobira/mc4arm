class Participante

	#Atributos
	attr_accessor :matricula
	attr_accessor :sexo
	attr_accessor :nascimento
	attr_accessor :datactps
	attr_accessor :quadro
	attr_accessor :classe
	attr_accessor :ats	
	attr_accessor :cargo
	attr_accessor :admissao
	attr_accessor :funcaoc
	attr_accessor :funcaom
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



