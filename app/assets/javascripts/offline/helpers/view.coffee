window.Helpers.View =
  to_pct: (num, denom, with_components=false) ->  #view helper
    pct = if _.isNumber(num) && _.isNumber(denom) && denom!=0  then Math.round(100.0 * num / denom)+"%" else "N/A"
    components = if with_components then " (#{num}/#{denom})"  else ""
    pct + components

  t: (args...) ->
    I18n.t(args...)

  xRequired: (name, value) ->
    hasValue = value? && value isnt '' && !(_.isArray(value) && _.isEmpty(value))
    xClass = if hasValue then 'x-valid' else 'x-invalid'
    "<span class=\"x #{xClass}\" id=\"#{name}-x\" title=\"This field is required.\">&nbsp;</span>"
