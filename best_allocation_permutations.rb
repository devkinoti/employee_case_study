# how to run this
# ruby best_allocation_permutations.rb

require 'byebug'

class PlanterBox
  attr_reader :initial_customers, :churn_rate, :revenue_per_customer, :number_of_months
  attr_accessor :customer_base, :cumulative_revenue, :total_revenue_lost_to_churn

  def initialize(initial_customers, churn_rate, revenue_per_customer, number_of_months)
    @initial_customers = initial_customers
    @churn_rate = churn_rate
    @revenue_per_customer = revenue_per_customer
    @number_of_months = number_of_months
    @customer_base = initial_customers
    @cumulative_revenue = 0
    @total_revenue_lost_to_churn = 0
  end

  def reset
    @customer_base = initial_customers
    @cumulative_revenue = 0
    @total_revenue_lost_to_churn = 0
  end

  def calculate_metrics(new_business_acquisition_employees, account_manager_employees, support_employees, role_durations)
    reset

    monthly_organic_acquisition = 25

    monthly_metrics = []

    role_durations.each_with_index do |duration, month|
      current_month = month + 1

      new_business_acquisition_employees, account_manager_employees, support_employees = duration

      monthly_acquisition_rate = new_business_acquisition_employees * 5 + monthly_organic_acquisition

      account_manager_employees_capacity = account_manager_employees * 25

      # Calculate the new churn rate by applying the exponential decay formula
      # Here, 0.85 is because each agent reduces churn by 15%, so you retain 85% of the churn rate for each support employee.
      adjusted_churn_rate = churn_rate * (0.85 ** support_employees)

      # Calculate the number of customers lost to churn
      churned_customers = (customer_base * adjusted_churn_rate).round(2)

      net_customer_gain_loss = monthly_acquisition_rate - churned_customers

      self.customer_base += net_customer_gain_loss

      account_manager_customers = [customer_base, account_manager_employees_capacity].min
      account_manager_revenue_increase = calculate_account_manager_revenue_increase(account_manager_customers.to_i, current_month)

      mrr = (customer_base - account_manager_customers) * revenue_per_customer + account_manager_revenue_increase

      self.cumulative_revenue += mrr

      revenue_lost_to_churn = churned_customers * revenue_per_customer

      self.total_revenue_lost_to_churn += revenue_lost_to_churn

      monthly_metrics << {
        month: current_month,
        starting_customer_base: (customer_base - net_customer_gain_loss).round(2),
        monthly_acquisition: monthly_acquisition_rate.round(2),
        monthly_churn: churned_customers.round(2),
        end_customer_base: customer_base.round(2),
        mrr: mrr.round(2),
        cumulative_revenue: cumulative_revenue.round(2),
        revenue_lost_to_churn: revenue_lost_to_churn.round(2)
      }
    end


    monthly_metrics
  end

  def calculate_account_manager_revenue_increase(account_manager_customers, month)
    revenue_increase = 0

    account_manager_customers.times do
      increase = revenue_per_customer
      1.upto([6, month].min) do |m|
        increase *= 1.20
      end

      revenue_increase += increase - revenue_per_customer
    end
    revenue_increase
  end

  def generate_permutations(total_employees, number_of_months, current_month = 1, current_permutation = [], all_permutations = [])
    if current_month > number_of_months
      # We've filled up the role allocations for all months, add the permutation to all_permutations
      all_permutations << current_permutation.dup
    else
      # Try every possible combination of roles for the current month
      (0..total_employees).each do |new_business_employees|
        (0..(total_employees - new_business_employees)).each do |account_manager_employees|
          support_employees = total_employees - new_business_employees - account_manager_employees
          role_permutation = [new_business_employees, account_manager_employees, support_employees]
          # Append this month's permutation and recurse to fill the next month
          current_permutation << role_permutation
          generate_permutations(total_employees, number_of_months, current_month + 1, current_permutation, all_permutations)
          # Remove the last permutation to backtrack and try a new combination
          current_permutation.pop
        end
      end
    end
    all_permutations
  end


  def find_best_combination(total_employees)
    best_combination = nil
    highest_revenue = 0
    lowest_lost_revenue = Float::INFINITY

    # Generate all role permutations for the number of months
    role_permutations = generate_permutations(total_employees, @number_of_months)

    # Iterate through each possible role duration setup
    role_permutations.each do |role_durations|
      # Reset the state before calculating new metrics for this permutation
      reset

      # Calculate metrics for the current permutation
      monthly_metrics = calculate_metrics(*role_durations.transpose, role_durations)

      # Check if this combination gives better revenue or the same revenue but less lost revenue
      if self.cumulative_revenue > highest_revenue || (self.cumulative_revenue == highest_revenue && self.total_revenue_lost_to_churn < lowest_lost_revenue)
        highest_revenue = self.cumulative_revenue
        lowest_lost_revenue = self.total_revenue_lost_to_churn
        best_combination = { role_durations: role_durations, monthly_metrics: monthly_metrics }
      end
    end

    best_combination
  end

end

# Main script
initial_customers = 1000
churn_rate = 0.10
revenue_per_customer = 100
number_of_months = 24
total_employees = 20

planter_box = PlanterBox.new(initial_customers, churn_rate, revenue_per_customer, number_of_months)
best_combination = planter_box.find_best_combination(total_employees)

puts "Best combination for highest revenue and least lost revenue:"
role_durations = best_combination[:role_durations]
puts "New Business Acquisition Employees: #{role_durations.transpose[0].inspect}"
puts "Account Management Employees: #{role_durations.transpose[1].inspect}"
puts "Support Employees: #{role_durations.transpose[2].inspect}"
puts "Highest Cumulative Revenue: $#{best_combination[:monthly_metrics].last[:cumulative_revenue].round(2)}"
puts "Lowest Cumulative Revenue Lost to Churn: $#{best_combination[:monthly_metrics].last[:revenue_lost_to_churn].round(2)}"

# Print monthly metrics for the best combination
puts "Monthly metrics for the best combination:"
best_combination[:monthly_metrics].each do |metrics|
  puts "Month #{metrics[:month]}:"
  puts "  Starting Customer Base: #{metrics[:starting_customer_base]}"
  puts "  Monthly Acquisition: #{metrics[:monthly_acquisition]}"
  puts "  Monthly Churn: #{metrics[:monthly_churn]}"
  puts "  End Customer Base: #{metrics[:end_customer_base]}"
  puts "  MRR: $#{metrics[:mrr]}"
  puts "  Cumulative Revenue: $#{metrics[:cumulative_revenue]}"
  puts "  Revenue Lost to Churn: $#{metrics[:revenue_lost_to_churn]}"
  puts
end
