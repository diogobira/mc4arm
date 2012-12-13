module Probability
    require 'RSRuby'

    R = RSRuby.instance

	######################################################
	#Funções de distribuição
	######################################################

	def Probability.bernoulli(num_samples, params)
        p = params[0] || 0.5 # prob de sucesso (se não informado, usar 0.5)
        
        # chama a função relacionada no R
        R.rbinom(num_samples, 1, p)
	end

	def Probability.normal(num_samples, params)
        mean = params[0] || 0 # média (se não informada, usar 0)
        std_dev = params[1] || 1 # desvio-padrão (se não informado, usar 1)
        
        # chama a função relacionada no R
        R.rnorm(num_samples, mean, std_dev)
	end

	def Probability.uniform(num_samples, params)
        min = params[0] || 0 # mínimo (se não informado, usar 0)
        max = params[1] || 1 # máximo (se não informado, usar 1)

        # chama a função relacionada no R
        R.runif(num_samples, min, max)
	end

    DIST_FUNCS = {
        :bern => self.method(:bernoulli),
        :norm => self.method(:normal),
        :unif => self.method(:uniform)
    }

	def Probability.random_sample(num_samples,dist_name,dist_params)
        # obtém a função geradora de amostras adequada
        dist_func = DIST_FUNCS[dist_name.to_sym]
        # se dist_params for nil, usa [] no lugar
        dist_params = dist_params || [] 

        # gera a amostra chamando um wrapper da função do R
        samples = dist_func.call(num_samples, dist_params)
	end


end
