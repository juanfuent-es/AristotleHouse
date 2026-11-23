module PostsHelper

  def time_ago (date)
    return time_ago_in_words(date)
  end

  def tag_cloud(tags, classes)
    max = tags.sort_by(&:count).last
    tags.each do |tag|
      index = tag.count.to_f / max.count * (classes.size - 1)
      yield(tag, classes[index.round])
    end
  end

  def link_to_add_fields(name, f, association)
		new_object = f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render("admin/#{f.object.class.name.pluralize.downcase}/#{association.to_s.singularize}_fields", f: builder, idx: id)
		end
		link_to(name, '#', :id => "add-new-relation", :class => "btn btn-outline-primary btn-sm float-right", data: { id: id, fields: fields.gsub("\n", "") })
	end

end