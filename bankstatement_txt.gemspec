Gem::Specification.new do |s|
  s.name = 'bankstatement_txt'
  s.version = '0.1.0'
  s.summary = 'Experimental gem for querying a running bank statement.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/bankstatement_txt.rb']
  s.add_runtime_dependency('polyrex', '~> 0.10', '>=0.10.2')
  s.signing_key = '../privatekeys/bankstatement_txt.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/bankstatement_txt'
end
