module AdminHelper
  def hierarchy(*objects)
    html = ''.html_safe
    html << content_tag(:div, :id => 'hierarchy') do
      concat link_to("Admin", admin_path)
      objects.each do |obj|
        concat " &#187; ".html_safe
        concat case obj
        when String then obj
        when Symbol then [:admin, obj]
        else
          link_to "#{obj.class.to_s.titleize}: #{obj.try(:code)}", [:admin, obj]
        end
      end
    end
  end

  def table_tree(node, css_class = 'table-tree')
    content_tag(:table, :class => css_class) do
      content_tag(:tbody) do
        node.map {|k,v|
          concat content_tag(:tr) {
            content_tag(:th, k) +
            content_tag(:td, v.kind_of?(Hash) ? table_tree(v, css_class) : v)
          }
        }
      end
    end
  end

  def locale_fields(f, translations = nil)
    translations ||= f.object.translations
    f.fields_for :translations do |ft|
      table_tree(Hash[translations.map do |locale,value|
        value = nil if value =~ /^translation missing: /
        [ft.label(locale, locale), ft.text_field(locale, :value => value)]
      end])
    end
  end

end
