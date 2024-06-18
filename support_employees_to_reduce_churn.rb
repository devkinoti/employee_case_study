require 'bigdecimal'
require 'bigdecimal/math'

include BigMath

# Calculate the number of CSAT points needed
original_churn_rate = 0.10
new_churn_rate = 0.01
csat_effectiveness = 0.85

number_of_csat_points = (BigMath.log(new_churn_rate / original_churn_rate, 10) / BigMath.log(csat_effectiveness, 10)).to_f
number_of_csat_points.ceil

puts number_of_csat_points
