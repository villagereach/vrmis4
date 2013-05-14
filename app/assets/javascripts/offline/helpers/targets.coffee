window.Helpers.Targets = 
  #child and adult codes assumed uniq!
  target_pcts: 
    child:
      'full':    4.0 / 12 / 100
      'bcg':     4.0 / 12 / 100
      'polio0':  3.9 / 12 / 100
      'polio1':  3.9 / 12 / 100
      'polio2':  3.9 / 12 / 100
      'polio3':  3.9 / 12 / 100
      'penta1':  3.9 / 12 / 100
      'penta2':  3.9 / 12 / 100
      'penta3':  3.9 / 12 / 100
      'measles': 3.9 / 12 / 100
      'pcv':     3.9 / 12 / 100
    child_dropout:
      'penta1_penta3':  "< 10%"
      'penta1_measles': "< 10%"
    adult:
      'w_pregnant': 5.0 / 12 / 100
      'student':    5.0 / 12 / 100
      'labor':    5.0 / 12 / 100
    adult_targetless:  ['w_15_49_community','w_15_49_student','w_15_49_labor','other']
    