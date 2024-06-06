# [订单不平衡因子过拟合](/2024/06/order_imbalance_factor.md)

npz文件格式是多个numpy array序列化成文件的意思

```python
# https://data.binance.vision/data/futures/cm/daily/bookTicker/ETCUSD_PERP/ETCUSD_PERP-bookTicker-2024-06-01.zip

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
#使用逻辑回归模型进行分类预测(二分类问题)
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# 读取CSV文件
data = pd.read_csv('ETCUSD_PERP-bookTicker-2024-06-01.csv')

# 计算中间价格
data['mid_price'] = (data['best_bid_price'] + data['best_ask_price']) / 2

# 计算订单不平衡因子（OIF）Order Imbalance Factor
data['OIF'] = (data['best_bid_qty'] - data['best_ask_qty']) / (data['best_bid_qty'] + data['best_ask_qty'])

# 计算下一个tick的中间价格
data['next_mid_price'] = data['mid_price'].shift(-1)

# 定义涨跌（1表示涨，0表示跌）
data['up_down'] = np.where(data['next_mid_price'] >= data['mid_price'], 1, 0)

# 去除最后一个无效数据点（因为没有下一个tick的中间价格）
data = data[:-1]

# 分割特征和标签
X = data[['OIF']]
y = data['up_down']
print(X.head())
print(y.head())

# 分割训练集和测试集
#X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.4)

# 构建逻辑回归模型
model = LogisticRegression()
model.fit(X_train, y_train)

# 预测
y_pred = model.predict(X_test)

# 评估准确率
accuracy = accuracy_score(y_test, y_pred)
# 准确率87% 过拟合了, 需要做一些dropout
print(f'预测准确率: {accuracy:.2f}')

# 打印前几行数据
print(data.head())
```
