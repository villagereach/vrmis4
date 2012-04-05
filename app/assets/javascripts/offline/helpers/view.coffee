window.Helpers.View =
  to_pct: (num, denom, with_components=false) ->  #view helper
    pct = if _.isNumber(num) && _.isNumber(denom) && denom!=0  then Math.round(100.0 * num / denom)+"%" else "N/A"
    components = if with_components then " (#{num}/#{denom})"  else ""    
    pct + components
  
  t: (args...) ->
    I18n.t(args...)
    