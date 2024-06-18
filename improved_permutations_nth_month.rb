# how to run this
# ruby improved_permutations_one_month.rb

require 'csv'

class PlanterBox
  attr_reader :initial_customers, :base_churn_rate, :revenue_per_customer
  attr_accessor :customer_base, :net_monthly_revenue, :total_revenue_lost_to_churn, :current_month

  def initialize(customer_base, churn_rate, revenue_per_customer, current_month = 1)
    @initial_customers = customer_base
    @customer_base = customer_base
    @base_churn_rate = churn_rate
    @revenue_per_customer = revenue_per_customer
    @net_monthly_revenue = 0
    @total_revenue_lost_to_churn = 0
    @current_month = current_month
  end

  def calculate_monthly_metrics(new_business_acquisition_employees, account_manager_employees, support_employees)
    @net_monthly_revenue = 0
    @total_revenue_lost_to_churn = 0

    monthly_organic_acquisition = 25
    monthly_acquisition_rate = new_business_acquisition_employees * 5 + monthly_organic_acquisition
    account_manager_customers = [customer_base, account_manager_employees * 25].min

    churn_rate = calculate_churn_rate(support_employees)

    churned_customers = (customer_base * churn_rate).floor

    net_customer_gain_loss = monthly_acquisition_rate - churned_customers

    temp_customer_base = @customer_base + net_customer_gain_loss

    account_manager_revenue_increase = calculate_account_manager_revenue_increase(account_manager_customers)

    mrr = (temp_customer_base - account_manager_customers) * revenue_per_customer + account_manager_revenue_increase

    revenue_lost_to_churn = churned_customers * revenue_per_customer

    @net_monthly_revenue += (mrr - revenue_lost_to_churn)

    @total_revenue_lost_to_churn += revenue_lost_to_churn

    # puts "Debug Info:"
    # puts "Permutation: #{new_business_acquisition_employees}-#{account_manager_employees}-#{support_employees}"
    # puts "Churn Rate: #{adjusted_churn_rate}, Churned Customers: #{churned_customers}, MRR: #{mrr}"
    # puts "Net Monthly Revenue: #{net_monthly_revenue}, Revenue Lost to Churn: #{revenue_lost_to_churn}"


    {
      permutation: "#{new_business_acquisition_employees}-#{account_manager_employees}-#{support_employees}",
      new_business_acquisition_employees: new_business_acquisition_employees,
      account_manager_employees: account_manager_employees,
      support_employees: support_employees,
      monthly_acquisition: monthly_acquisition_rate,
      monthly_churn: churned_customers,
      end_customer_base: temp_customer_base,
      mrr: mrr,
      net_monthly_revenue: net_monthly_revenue,
      revenue_lost_to_churn: revenue_lost_to_churn,
      churn_rate: churn_rate
    }
  end

  # def calculate_account_manager_revenue_increase(account_manager_customers, current_month)
  #   revenue_increase = 0

  #   months_managed = [current_month, 6].min

  #   account_manager_customers.times do
  #     increase = revenue_per_customer * (1.20 ** months_managed)
  #     revenue_increase += increase - revenue_per_customer
  #   end
  #   revenue_increase
  # end

  def calculate_account_manager_revenue_increase(account_manager_customers)
    revenue_increase = 0

    account_manager_customers.times do |i|
      months_managed = [current_month - i, 6].min
      increase = revenue_per_customer * (1.20 ** months_managed)
      revenue_increase += increase - revenue_per_customer
    end

    revenue_increase
  end
  # def adjust_churn_rate(support_employees)
  #   @churn_rate *= (0.85 ** support_employees)
  # end

  def calculate_churn_rate(support_employees)
    csat_increase = support_employees
    csat = 70 + csat_increase
    churn_rate_reduction = 1 - 0.15 * (csat - 70) / 100
    new_churn_rate = base_churn_rate * churn_rate_reduction

    new_churn_rate
  end
end

elements = (1..20).to_a
permutations = elements.repeated_permutation(3).to_a
valid_permutations = permutations.select { |a, b, c| a + b + c == 20 }

# Create an instance of PlanterBox
current_scenario = {
  customer_base: 1000,
  churn_rate: 0.10,
  revenue_per_customer: 100
}

(1..24).each do |month|
  planter_box = PlanterBox.new(
    current_scenario[:customer_base],
    current_scenario[:churn_rate],
    current_scenario[:revenue_per_customer],
    month
  )

  results = valid_permutations.map do |perm|
    planter_box.calculate_monthly_metrics(*perm)
  end

  sorted_results = results.sort_by { |result| -result[:net_monthly_revenue]}

  CSV.open("month_#{month}_calculated_metrics.csv", "wb") do |csv|
    csv << ["Permutation", "New Business Acquisition Employees", "Account Manager Employees", "Support Employees", "Monthly Revenue", "Net Monthly Revenue", "Revenue Lost to Churn", "Churn Rate"]

    sorted_results.each do |result|
      csv << [
        result[:permutation],
        result[:new_business_acquisition_employees],
        result[:account_manager_employees],
        result[:support_employees],
        result[:mrr],
        result[:net_monthly_revenue],
        result[:revenue_lost_to_churn]
      ]
    end
  end

  best_scenario = results.max_by { |result| result[:net_monthly_revenue] }

  # Update the current scenario with the best from this month
  current_scenario[:churn_rate] = best_scenario[:churn_rate]

  # Update the current scenario with the best from this month
  current_scenario[:customer_base] = best_scenario[:end_customer_base]

  puts "Best scenario metrics for month #{month}:"
  p best_scenario

  # planter_box.adjust_churn_rate(best_scenario[:support_employees])


end








# puts "All Results in tabular form"
# puts "============================"

# puts "New Business Acquisition | Acct Mgmt | Support | Monthly Revenue | Cumulative Revenue | Revenue Lost to Churn"
# sorted_results.each do |result|
#   puts "#{result[:new_business_acquisition_employees].round(2)}     | #{result[:account_manager_employees]}      | #{result[:support_employees]}     | #{result[:mrr].round(2)}           | #{result[:cumulative_revenue].round(2)}           | #{result[:revenue_lost_to_churn].round(2)}"
# end
