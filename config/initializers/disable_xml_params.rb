# address a critical rails security vulnerability:
# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
