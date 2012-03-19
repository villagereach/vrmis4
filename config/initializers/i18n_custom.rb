module ApplicationHelper
  def t(key, options = {})
    # NOTES: method does not support scoping (i.e. ".foo"), must use full key.
    #        does not try to figure out if should HTML escape or not.
    default = options[:default] || key
    options = {:rescue_format => :html}.merge(options)
    content_tag :span, (I18n.t(key, options) || default), :data => { :i18n => key }.merge(options)
  end
end