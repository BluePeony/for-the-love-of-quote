module StaticPagesHelper

	def find_images
		all_images = []
		Dir.entries("app/assets/images").each do |el|
			if el[-4..-1] == ".jpg"
				all_images << el
			end
		end
		return all_images
	end

end
