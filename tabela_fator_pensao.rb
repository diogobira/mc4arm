require 'algorithms.rb'
include Containers

class TabelaFatorPensao < Trie

	#Carrega a Trie a partir de um array de hashes
	def load(arr)
		arr.each do |c|
			key = c[:sexo] + c[:tempo_empresa].to_i.to_s
			self.push(key,c)
		end
	end

	#Faz uma pesquisa na Trie
	def detect(sexo,tempo_empresa)
		key = sexo + tempo_empresa.to_i.to_s
		node = self.get(key)
	end

end


