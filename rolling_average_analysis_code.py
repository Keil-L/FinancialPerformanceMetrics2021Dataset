
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Creating the dataset
np.random.seed(0)
num_rows = 300
dates = pd.date_range('2021-01-01', periods=num_rows, freq='D')
data = {
    'Date': dates,
    'Sales': np.random.rand(num_rows) * 1000,  # Random sales data
    'Expenses': np.random.rand(num_rows) * 800,  # Random expenses data
    'Profit': np.random.rand(num_rows) * 200   # Random profit data
}
df = pd.DataFrame(data)
df.set_index('Date', inplace=True)

# Rolling 7-day average of Sales, Expenses, and Profit
rolling_avg_data = df.rolling(window=7).mean()

# Creating a line graph
fig, ax = plt.subplots(figsize=(12, 6))
rolling_avg_data.plot(ax=ax)
plt.title('7-Day Rolling Average of Sales, Expenses, and Profit')
plt.ylabel('Amount in USD')
plt.xlabel('Date')
plt.grid(True)
plt.savefig('/path/to/save/image.png')
plt.show()
