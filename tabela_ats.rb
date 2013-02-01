require 'algorithms.rb'
include Containers

class TabelaAts < Trie

	#Carrega a Trie a partir de um array de hashes
	def load(arr)
		arr.each do |c|
			key = c[:quadro] + c[:tempo_empresa].to_i.to_s
			self.push(key,c)
		end
	end

	#Faz uma pesquisa na Trie
	def detect(quadro,tempo_empresa)
		key = quadro + tempo_empresa.to_i.to_s
		node = self.get(key)
	end

end


