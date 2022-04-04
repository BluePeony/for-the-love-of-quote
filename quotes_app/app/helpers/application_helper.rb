module ApplicationHelper
	
	# Creates a custom title for each page
	def full_title(page_title = '')
		base_title = "For the Love of Quote"
		if page_title.empty?
			base_title
		else
			page_title + ' | ' + base_title
		end
	end
end
