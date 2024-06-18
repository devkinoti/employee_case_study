# how to run this
# ruby improved_permutations_one_month.rb

require 'csv'

class PlanterBox
  attr_reader :initial_customers, :churn_rate, :revenue_per_customer
  attr_accessor :customer_base, :cumulative_revenue, :total_revenue_lost_to_churn, :current_month, :new_churn_rate

  def initialize(initial_customers, churn_rate, revenue_per_customer)
    @initial_customers = initial_customers
    @churn_rate = churn_rate
    @revenue_per_customer = revenue_per_customer
    @customer_base = initial_customers
    @cumulative_revenue = 0
    @total_revenue_lost_to_churn = 0
    @current_month = 1
    @new_churn_rate = churn_rate
  end

  def reset
    @customer_base = initial_customers
    @cumulative_revenue = 0
    @total_revenue_lost_to_churn = 0
  end

  def calculate_monthly_metrics(new_business_acquisition_employees, account_manager_employees, support_employees)
    reset

    monthly_organic_acquisition = 25
    monthly_acquisition_rate = new_business_acquisition_employees * 5 + monthly_organic_acquisition
    account_manager_employees_capacity = account_manager_employees * 25

    adjusted_churn_rate = churn_rate * (0.85 ** support_employees)

    @new_churn_rate = adjusted_churn_rate

    churned_customers = (customer_base * adjusted_churn_rate).round(2)

    net_customer_gain_loss = monthly_acquisition_rate - churned_customers

    self.customer_base += net_customer_gain_loss

    account_manager_customers = [customer_base, account_manager_employees_capacity].min
    account_manager_revenue_increase = calculate_account_manager_revenue_increase(account_manager_customers.to_i, current_month)

    mrr = (customer_base - account_manager_customers) * revenue_per_customer + account_manager_revenue_increase

    revenue_lost_to_churn = churned_customers * revenue_per_customer

    self.cumulative_revenue += (mrr - revenue_lost_to_churn)

    self.total_revenue_lost_to_churn += revenue_lost_to_churn

    {
      permutation: "#{new_business_acquisition_employees}-#{account_manager_employees}-#{support_employees}",
      starting_customer_base: initial_customers,
      new_business_acquisition_employees: new_business_acquisition_employees,
      account_manager_employees: account_manager_employees,
      support_employees: support_employees,
      monthly_acquisition: monthly_acquisition_rate,
      monthly_churn: churned_customers,
      end_customer_base: customer_base,
      mrr: mrr,
      cumulative_revenue: cumulative_revenue,
      revenue_lost_to_churn: revenue_lost_to_churn,
      new_churn_rate: @new_churn_rate
    }
  end

  def calculate_account_manager_revenue_increase(account_manager_customers, current_month)
    revenue_increase = 0

    months_managed = [current_month, 6].min

    account_manager_customers.times do
      increase = revenue_per_customer * (1.20 ** months_managed)
      revenue_increase += increase - revenue_per_customer
    end
    revenue_increase
  end
end

elements = (1..20).to_a
permutations = elements.repeated_permutation(3).to_a
valid_permutations = permutations.select { |a, b, c| a + b + c == 20 }

# Create an instance of PlanterBox
planter_box = PlanterBox.new(1000, 0.10, 100)

results = []

results = valid_permutations.map do |perm|
  planter_box.calculate_monthly_metrics(*perm)
end

sorted_results = results.sort_by { |result| -result[:cumulative_revenue].round(2)}
CSV.open("one_month_calculated_metrics.csv", "wb") do |csv|
  csv << ["Permutation", "New Business Acquisition Employees", "Account Manager Employees", "Support Employees", "Monthly Revenue", "Cumulative Revenue", "Revenue Lost to Churn"]

  sorted_results.each do |result|
    csv << [
      result[:permutation],
      result[:new_business_acquisition_employees],
      result[:account_manager_employees],
      result[:support_employees],
      result[:mrr].round(2),
      result[:cumulative_revenue].round(2),
      result[:revenue_lost_to_churn].round(2),
      result[:new_churn_rate].round(2)
    ]
  end

end



puts "All Results in tabular form"
puts "============================"

puts "New Business Acquisition | Acct Mgmt | Support | Monthly Revenue | Cumulative Revenue | Revenue Lost to Churn"
sorted_results.each do |result|
  puts "#{result[:new_business_acquisition_employees].round(2)}     | #{result[:account_manager_employees]}      | #{result[:support_employees]}     | #{result[:mrr].round(2)}           | #{result[:cumulative_revenue].round(2)}           | #{result[:revenue_lost_to_churn].round(2)}"
end


best_scenario = results.max_by { |result| result[:cumulative_revenue] }

puts "Best scenario metrics:"
p best_scenario
