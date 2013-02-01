require 'algorithms.rb'
include Containers

class Tabua < Trie

	#Carrega a Trie a partir de um array de hashes
	def load(arr)
		arr.each do |p|
			key = p[:sexo] + p[:idade].to_i.to_s
			self.push(key,p)
		end
	end

	#Faz uma pesquisa na Trie a partir do sexo e da idade
	def detect(sexo,idade)
		key = sexo + idade.to_i.to_s
		node = self.get(key)
	end

end


