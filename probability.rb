module Probability

    #require 'RSRuby'
		require 'rubygems'
		require 'rsruby'

    @R = RSRuby.instance

	######################################################
	#Funções que geram amostras de uma dada distribuição
	######################################################

    #Bernoulli
	def Probability.bernoulli(num_samples, params)
        p = params[0] || 0.5 #prob de sucesso (se não informado, usar 0.5)
        
        #chama a função relacionada no R
        @R.rbinom(num_samples, 1, p)
	end

    #Normal
	def Probability.normal(num_samples, params)
        mean = params[0] || 0 #média (se não informada, usar 0)
        std_dev = params[1] || 1 #desvio-padrão (se não informado, usar 1)
        
        #chama a função relacionada no R
        @R.rnorm(num_samples, mean, std_dev)
	end

    #Uniforme (contínua)
	def Probability.uniform(num_samples, params)
        min = params[0] || 0 #mínimo (se não informado, usar 0)
        max = params[1] || 1 #máximo (se não informado, usar 1)

        #chama a função relacionada no R
        @R.runif(num_samples, min, max)
	end

    #Uniforme (discreta)
    def Probability.discrete_uniform(num_samples, params)
        min = params[0] || 0 #mínimo (se não informado, usar 0)
        max = params[1] || 5 #máximo (se não informado, usar 5)
        delta = params[2] || 1 #step entre elementos selecionados 
                              # (se não informado, usar 1)
        
        #obtém o array com os elementos que interessam
        elems = (min..max).step(delta).to_a

        #chama a função relacionada no R
        @R.sample(elems, num_samples, true)
    end

    #Array constante com referências para funções que implementam
    # as funções que geram as amostras segundo distribuições conhecidas
    DIST_FUNCS = {
        :Bernoulli => self.method(:bernoulli),
        :Normal => self.method(:normal),
        :Uniform => self.method(:uniform),
        :DiscreteUniform => self.method(:discrete_uniform)
    }

	def Probability.random_sample(num_samples, dist_name, dist_params)
        #obtém a função geradora de amostras adequada
        dist_func = DIST_FUNCS[dist_name.to_sym]
        #se dist_params for nil, usa [] no lugar
        dist_params = dist_params || [] 

        #gera a amostra chamando um wrapper da função do R
        samples = dist_func.call(num_samples, dist_params)
	end


end
