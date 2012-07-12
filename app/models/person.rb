class Person
  include MongoMapper::EmbeddedDocument
  
  # No point saving this, since it's already embedded in the crash
  attr_accessor :accn
  
  key :addcor, String
  key :airbag, Integer
  key :age, Integer
  key :alctest, String
  key :alctype, Integer
  key :ambserv, String
  key :dlclass, String
  key :dlcounty, Integer
  key :dlstat, Integer
  key :dlstate, String
  key :dlrest, String
  key :dlzip, Integer
  key :drtest, String
  key :drtype, Integer
  key :eject, Integer
  key :hospitl, String
  key :injsev, String
  key :methhos, String
  key :newbac, Integer
  key :physcnd, Integer
  key :positn, Integer
  key :recomnd, Integer
  key :rpn, Integer
  key :runnum, String
  key :rvn, Integer
  key :safeqp, Integer
  key :safetyp, Integer
  key :sex, String
  key :viols, String
  
end