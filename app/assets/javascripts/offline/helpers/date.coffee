window.Helpers.Date =
  FORMATTERS:
    A: (d) -> Helpers.View.t("offline.helpers.dates.weekdays.#{d.wday}")  # locale weekday
    a: (d) -> @A(d).slice(0, 3)                                           # locale weekday, 3-chars
    B: (d) -> Helpers.View.t("offline.helpers.dates.months.#{d.month}")   # locale month
    b: (d) -> @B(d).slice(0, 3)                                           # locale month, 3-chars
    d: (d) -> (if d.day < 10 then '0' else '') + d.day                    # day, 2-digit w/ 0
    F: (d) -> "#{@Y(d)}-#{@m(d)}-#{@d(d)}"                                # YYYY-MM-DD
    H: (d) -> (if d.hour < 10 then '0' else '') + d.hour                  # hours, 2-digit w/ 0
    M: (d) -> (if d.minute < 10 then '0' else '') + d.minute              # minutes, 2-digit w/ 0
    m: (d) -> (if d.month < 10 then '0' else '') + d.month                # month, 2-digit w/ 0
    S: (d) -> (if d.second < 10 then '0' else '') + d.second              # seconds, 2-digit w/ 0
    T: (d) -> "#{@H(d)}-#{@M(d)}-#{@S(d)}"                                # HH:MM:SS, 24-hour
    u: (d) -> String(d.wday || 7)                                         # weekday, 1-7, Monday is 1
    w: (d) -> String(d.wday)                                              # weekday, 0-6, Sunday is 0
    Y: (d) -> d.year                                                      # year, 4-digit

  PARSERS:
    Y: -> ['([0-9]{4})', 'year']
    m: -> ['0?([1-9]|1[0-2])', 'month']
    d: -> ['0?([1-9]|[12][0-9]|3[01])', 'day']
    H: -> ['0?([0-9]|[1-5][0-9])', 'hour']
    M: -> ['0?([0-9]|[1-5][0-9])', 'minute']
    S: -> ['0?([0-9]|[1-5][0-9])', 'second']

  reformat: (strDate, oldFormat, newFormat) ->
    @DateStruct.parse(strDate, oldFormat)?.format(newFormat)

  parse: (strDate, format = '%Y-%m(?:-%d)?') ->
    @DateStruct.parse(strDate, format)

class Helpers.Date.DateStruct
  constructor: (@year, @month = 1, @day = 1, @hour = 0, @minute = 0, @second = 0, @wday) ->
    if _.isObject @year
      # passed in a hash/object of date parts
      [dateHash, @year] = [@year, undefined]
      @[k] = v for k,v of dateHash

    if jsDate = new window.Date(@year, @month-1, @day)
      @wday = jsDate?.getDay()
      if jsDate.getDate() != @day
        # date past edge of month boundary (i.e. feb 30)
        @year = jsDate.getFullYear()
        @month = jsDate.getMonth()+1
        @day = jsDate.getDate()

  @parse = (strDate = '', format = '%Y-%m-(?:-%d)?') ->
    order = []
    matchExpr = format.replace /%([^%])/g, (m, f) =>
      [regexp, key] = Helpers.Date.PARSERS[f]()
      order.push key
      regexp

    if m = strDate.match(new RegExp('^(?:' + matchExpr + ')$'))
      new @(order.reduce ((h,k,i) => h[k] = Number(m[i+1]) if m[i+1]?; h), {})
    else
      null

  format: (format) ->
    format.replace /%([^%])/g, (m, f) => Helpers.Date.FORMATTERS[f](@)

