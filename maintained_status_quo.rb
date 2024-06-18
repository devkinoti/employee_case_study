# ruby maintained_status_quo.rb

# initial metrics for the planter box inc

initial_customers = 1000
monthly_acquisition = 25
churn_rate = 0.10
revenue_per_customer = 100
number_of_months = 24

#variables over time
customer_base = initial_customers
cumulative_revenue = 0
total_revenue_lost_to_churn = 0


#store monthly values for analysis
monthly_customers = []
monthly_recurring_revenue = []
monthly_churn = []
monthly_net_gain_loss = []
cumulative_revenue_list = []
monthly_revenue_lost_to_churn = []

final_mrr = 0

# Iterate over each month to calculate the metrics
(1..number_of_months).each do |month|

  churned_customers = (customer_base * churn_rate)

  net_customer_gain_loss = monthly_acquisition - churned_customers

  customer_base += net_customer_gain_loss

  mrr = customer_base * revenue_per_customer

  cumulative_revenue += mrr


  revenue_lost_to_churn = churned_customers * revenue_per_customer

  total_revenue_lost_to_churn += revenue_lost_to_churn



  monthly_customers << customer_base

  monthly_recurring_revenue << mrr

  monthly_churn << churned_customers

  monthly_net_gain_loss << net_customer_gain_loss

  cumulative_revenue_list << cumulative_revenue

  monthly_revenue_lost_to_churn << revenue_lost_to_churn

  final_mrr = mrr


    # Print metrics for the current month
    puts "Month #{month}:"
    puts "  Starting Customer Base: #{monthly_customers[month-2].round(2) if month > 1 || initial_customers}"
    puts "  Monthly Acquisition: #{monthly_acquisition.round(2)}"
    puts "  Monthly Churn: #{churned_customers.round(2)}"
    puts "  End Customer Base: #{customer_base.round(2)}"
    puts "  MRR: $#{mrr.round(2)}"
    puts "  Cumulative Revenue: $#{cumulative_revenue.round(2)}"
    puts "  Revenue Lost to churn: #{revenue_lost_to_churn.round(2)}"
    puts

end

puts "Final summary if status quo is not changed"
puts "Final Customer Base after #{number_of_months} months: #{customer_base.round(2)}"
puts "Final Monthly Recurring Revenue (MRR): $#{final_mrr.round(2)}"
puts "Cumulative Revenue over #{number_of_months} months: $#{cumulative_revenue.round(2)}"
puts "Total cumulative revenue lost due to churn: $#{total_revenue_lost_to_churn.round(2)}"
