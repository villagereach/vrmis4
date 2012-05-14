# some or all versions of IE do not provide a :trim method
unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ''
