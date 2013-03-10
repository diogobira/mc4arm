class Dependente

	attr_accessor :matricula
	attr_accessor :sexo
	attr_accessor :idade
	attr_accessor :vivo
	attr_accessor :tipo
	attr_accessor :pensao
	attr_accessor :invalido

	def initialize(params)
		@sexo = params[:sexo]
		@idade = params[:idade]
		@tipo = params[:tipo]
		@pensao = params[:pensao]
		@invalido = false
		@vivo = true
	end

end
