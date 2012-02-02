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
        else link_to obj.class.to_s.titleize, [:admin, obj]
        end
      end
    end
  end

end
