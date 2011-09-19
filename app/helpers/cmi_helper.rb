module CmiHelper
  # Returns a link which sorts by the named column.
  #
  # - column is the name of an attribute in the sorted record collection.
  # - the optional caption explicitly specifies the displayed link text.
  # - 2 CSS classes reflect the state of the link: sort and asc or desc
  #
  def sort_link(column, caption, default_order)
    css, order = nil, default_order

    if @sort == column
      if @order == 'asc'
        css = 'sort asc'
        order = 'desc'
      else
        css = 'sort desc'
        order = 'asc'
      end
    end
    caption = column.to_s.humanize unless caption

    sort_options = { :sort => column.to_s, :order => order }
    url_options = params.merge(sort_options)

    # Add project_id to url_options
    url_options = url_options.merge(:project_id => params[:project_id]) if params.has_key?(:project_id)

    link_to_content_update(caption, url_options, :class => css)
  end

  # Returns a table header <th> tag with a sort link for the named column
  # attribute.
  #
  # Options:
  #   :caption     The displayed link name (defaults to titleized column name).
  #   :title       The tag's 'title' attribute (defaults to 'Sort by :caption').
  #
  # Other options hash entries generate additional table header tag attributes.
  #
  # Example:
  #
  #   <%= sort_header_tag('id', :title => 'Sort by contact ID', :width => 40) %>
  #
  def sort_header_tag(column, options = {})
    caption = options.delete(:caption) || column.to_s.humanize
    default_order = options.delete(:default_order) || 'asc'
    options[:title] = l(:label_sort_by, "\"#{caption}\"") unless options[:title]
    content_tag('th', sort_link(column, caption, default_order), options)
  end

  def show_detail(detail, no_html=false)
    if detail.property == 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, "")
      label = l(("field_" + field).to_sym)
      if detail.prop_key == 'scheduled_role_effort'
        value = YAML.load(detail.value).sort_by{ |role, effort| role }.collect{ |x, y| "#{x}: #{y}" }.join(", ")
        old_value = YAML.load(detail.old_value).sort_by{ |role, effort| role }.collect{ |x, y| "#{x}: #{y}" }.join(", ")
      end
    end

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value

    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      old_value = content_tag("strike", old_value) if detail.old_value and (!detail.value or detail.value.empty?)
      value = content_tag("i", h(value)) if value
    end

    if detail.property == 'attr' && detail.prop_key == 'scheduled_role_effort'
      s = l(:text_journal_changed_no_detail, :label => label)
      s << content_tag("p", old_value + "->")
      s << content_tag("p", value)
      s
    elsif !detail.value.blank?
      case detail.property
      when 'attr', 'cf'
        if !detail.old_value.blank?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value)
        else
          l(:text_journal_set_to, :label => label, :value => value)
        end
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value)
    end
  end

  def render_notes(issue, journal, options={})
    content = ''
    editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) || (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)))
    links = []
    if !journal.notes.blank?
      links << link_to_remote(image_tag('comment.png'),
                              { :url => {:controller => 'journals', :action => 'new', :id => issue, :journal_id => journal} },
                              :title => l(:button_quote)) if options[:reply_links]
      links << link_to_in_place_notes_editor(image_tag('edit.png'), "journal-#{journal.id}-notes", 
                                             { :controller => 'journals', :action => 'edit', :id => journal },
                                                :title => l(:button_edit)) if editable
    end
    content << content_tag('div', links.join(' '), :class => 'contextual') unless links.empty?
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable" if editable
    content_tag('div', content, :id => "journal-#{journal.id}-notes", :class => css_classes)
  end

  def link_to_in_place_notes_editor(text, field_id, url, options={})
    onclick = "new Ajax.Request('#{url_for(url)}', {asynchronous:true, evalScripts:true, method:'get'}); return false;"
    link_to text, '#', options.merge(:onclick => onclick)
  end
end
