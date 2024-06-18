# how to run this
# cd data_visualization
# streamlit run app.py

import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(layout="wide")

df = pd.read_csv("../month_3_calculated_metrics.csv")

st.title("Best Staff Allocation Permutations trend - Month 3 View")

# Initialize a figure for all permutations
fig, ax = plt.subplots(figsize=(30, 15))  # Increase figure size for clarity with many bars

# Generate positions for the bars
positions = range(len(df))
width = 0.35  # Width of the bars

# Plot bars for each permutation in the same plot
revenue_bars = ax.bar([p - width/2 for p in positions], df["Net Monthly Revenue"], width=width, color="blue", label="Net Monthly Revenue")
churn_bars = ax.bar([p + width/2 for p in positions], df["Revenue Lost to Churn"], width=width, color="red", label="Revenue Lost to Churn")

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel("Dollars")
ax.set_title("Comparison of Monthly Revenue and Revenue Lost to Churn across all Permutations")
ax.set_xticks(positions)
ax.set_xticklabels(df["Permutation"], rotation=90)  # Rotate labels to prevent overlap

# Legend to help identify the bars
ax.legend()

# Create a custom labels on top of the bars to show staffing details (optional)
for rect, nb, am, sup in zip(revenue_bars, df["New Business Acquisition Employees"], df["Account Manager Employees"], df["Support Employees"]):
    ax.annotate(f'NB({nb}), AM({am}), S({sup})',
                xy=(rect.get_x() + rect.get_width() / 2, rect.get_height()),
                xytext=(0, 3),  # 3 points vertical offset
                textcoords="offset points",
                ha='center', va='bottom', rotation=90, fontsize=10)

# Display the plot in Streamlit
st.pyplot(fig)