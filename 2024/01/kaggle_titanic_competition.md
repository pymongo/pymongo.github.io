# [kaggle机器学习竞赛](/2024/01/kaggle_titanic_competition.md)

使用泰坦尼克号乘客的数据(姓名、年龄、票价等)来预测谁会幸存

submission.csv的格式是两列，第一列是乘客id，第二列是是否存储布尔值

pip install kaggle

kaggle competitions download -c titanic

OSError: Could not find kaggle.json

需要在kaggle官方生成个api json放到 $HOME/.kaggle

## 特征工程

> 我对数据集的分析是，首先上船位置embarked这列肯定是没有用的是噪声数据可排除，船难跟上船位置关联性很低，然后我可能偏向于 是否是成年男性这样的特征的权重更大，你是怎么分析泰坦尼克数据集每列的权重的

对于泰坦尼克号数据集，每列的权重分析实际上是通过特征工程和机器学习模型来确定的。以下是分析过程中可能采取的一些步骤：

1. **理解数据集**：首先，你需要理解每列数据的含义以及它们可能与生存结果的关系。比如，`Sex`（性别）和`Age`（年龄）通常被认为是重要的特征，因为历史资料表明妇女和儿童有更高的生存率。

2. **数据可视化**：使用图表来观察不同特征与生存率之间的关系。例如，可以使用条形图查看不同登船地点（`Embarked`）的乘客生存率是否有显著差异。

3. **相关性分析**：计算特征之间的相关系数，以及特征与生存结果之间的相关性。这有助于识别潜在的关键特征。

4. **特征工程**：转换或创建新特征，以便更好地捕捉预测生存率的因素。例如，可以创建一个新的特征来表明乘客是否是成年男性。

5. **构建模型**：使用不同的机器学习算法构建预测模型，并通过交叉验证来评估它们的性能。

6. **特征重要性评估**：一旦模型被训练，可以使用模型本身来评估特征的重要性。例如，决策树和随机森林模型可以提供直接的特征重要性估计。

7. **迭代优化**：根据模型的反馈调整特征工程，去掉或创建新的特征，然后重新训练模型，直至达到满意的准确度。

关于船舱位置（`Embarked`）的特征，虽然乍看可能与生存率关联性不大，但实际上可能存在一些间接关联。例如，某些船舱可能更靠近救生艇，或者船舱位置可能与乘客的社会经济状态相关，而后者可能影响了他们的生存率。因此，在没有具体证据表明某个特征完全无关之前，直接排除任何特征可能并非最佳实践。

在实际操作中，应该在数据探索阶段保持开放的心态，让数据指导你的决策。通过逐步的分析和模型验证，来确定每个特征的实际重要性。

## 模型选择

> 我对python3 sklearn比较熟悉点，kaggle titanic train data 适合用怎样的模型？我数学功底很差只熟悉线性建模

如果您的数学基础不是很扎实，而且您熟悉线性模型，那么可以从简单的模型开始，并逐步尝试更复杂的模型。以下是几种适用于Kaggle Titanic数据集的机器学习模型，从简单到复杂排列：

1. **逻辑回归（Logistic Regression）**：这是一种广泛使用的线性模型，适用于二分类问题，比如Titanic生存预测。尽管简单，但逻辑回归在许多二分类问题上表现都相当不错。

2. **决策树（Decision Tree）**：决策树是一种基本的非线性模型，它通过一系列规则来进行预测。它们易于理解和解释，可以处理特征间的非线性关系。

3. **随机森林（Random Forest）**：随机森林是一种集成学习方法，它构建多个决策树并取它们的平均预测值。这种方法通常能提高模型的性能和泛化能力。

4. **支持向量机（Support Vector Machine, SVM）**：SVM是一种强大的分类器，它在数据集中找到最佳的边界线（或超平面）来区分不同的类别。对于非线性问题，可以使用核技巧来使数据在更高维度空间中线性可分。

5. **梯度提升决策树（Gradient Boosting Decision Trees, GBDT）**：GBDT是一种集成学习技术，它结合了多个决策树模型的预测。模型通过迭代地改进来增强性能，通常在各种数据集上都能达到很高的准确率。

6. **K-最近邻（K-Nearest Neighbors, KNN）**：KNN是一种基于实例的学习，它根据最近的K个邻居的类别来预测新数据点的类别。

7. **朴素贝叶斯（Naive Bayes）**：朴素贝叶斯分类器基于贝叶斯定理，它假设特征之间相互独立。尽管这个假设在现实中往往不成立，但朴素贝叶斯在很多情况下仍然工作得很好。

由于您熟悉线性模型，可以从逻辑回归开始，它是解决二分类问题的一个很好的起点。在Python中，您可以使用scikit-learn库来实现这些模型。逻辑回归模型可以这样创建：

```python
from sklearn.linear_model import LogisticRegression

# 创建逻辑回归模型
model = LogisticRegression()

# 训练模型
model.fit(X_train, y_train)

# 进行预测
predictions = model.predict(X_test)
```

在这里，`X_train` 是训练数据集的特征变量，`y_train` 是训练数据集的目标变量（即生存与否）。`X_test` 是测试数据集的特征变量。

记得在使用模型之前，您需要进行数据预处理，包括处理缺失值、转换类别变量（如使用独热编码），以及特征缩放等。

随着您对数据和模型的进一步理解，您可以尝试使用更复杂的模型，并对它们进行调优以获得更好的结果。

## 缺失值填充

典型的机器学习二分类问题，train.csv的第二列Survived表示是否存活的布尔值，不过csv有缺失值需要填充

```python
print(df.isnull().any())
# Age,Cabin,Embarked column has null
rows_with_null_age = df[df['Age'].isnull()]
print(f"rows_with_null_age count={rows_with_null_age.count()}")
print(rows_with_null_age)
```

Age 缺失177条, Cabin(船舱号)缺失177条, Embarked(登船地点)缺失两条 这三列有缺失，首先登船地点是一个枚举只有三种，而且只缺失两条，直接用众数填充

Imputation: You can fill in the missing values with the mean, median, or mode(众数) age, or use k-Nearest Neighbors to predict the missing age values based on the other features

年龄是一个大概率正态分布的，用中位数填充，登船地点只有两条数据用众数填充即可，麻烦的是船舱号

```
age_imputer = SimpleImputer(strategy='median')
df['Age'] = age_imputer.fit_transform(df[['Age']]).astype(int)
```

### 船舱号缺失处理

You're right; using the mode to fill in missing values for the 'Cabin' column in the Titanic dataset could be misleading because it would imply that 177 passengers shared the same cabin, which is not realistic.

The 'Cabin' column presents a more complex case for imputation because it is not only categorical but also has a high percentage of missing values. Here are a few alternative strategies for handling missing 'Cabin' data:

1. **Create a new category for missing values**: You can treat missing cabins as a separate category. This is a common approach when the fact that data is missing might be informative in itself.

    ```python
    df['Cabin'].fillna('Missing', inplace=True)
    ```

2. **Use a placeholder value**: Replace missing cabins with a placeholder like 'U' for 'Unknown'.

    ```python
    df['Cabin'].fillna('U', inplace=True)
    ```

3. **Extract deck information**: Sometimes the first letter of the cabin number is used to indicate the deck. You could extract this and treat the deck as a feature, filling in missing decks with a placeholder.

    ```python
    df['Deck'] = df['Cabin'].apply(lambda x: x[0] if pd.notnull(x) else 'U')
    ```

4. **Model-based imputation**: Use a model to predict the missing cabin based on other features. This is a more sophisticated approach and might be overkill for this variable, given the high proportion of missing values.

5. **Discard the 'Cabin' column**: If the 'Cabin' information is not critical to your analysis or predictions, and the high proportion of missing data makes imputation unreliable, you might choose to drop the column altogether.

    ```python
    df.drop('Cabin', axis=1, inplace=True)
    ```

6. **Group cabins by fare**: Group passengers into different cabin categories based on the fare they paid. This approach assumes a relationship between fare and cabin.

    ```python
    fare_bins = pd.qcut(df['Fare'], 4, labels=['Low', 'Medium', 'High', 'Very_High'])
    df['Cabin_Imputed'] = df['Cabin'].fillna(fare_bins)
    ```

7. **Hierarchical imputation**: If there's a hierarchy or some dependency between 'Pclass' (Passenger Class) and 'Cabin', you could fill in missing cabins differently for each class.

    ```python
    df['Cabin'] = df.groupby('Pclass')['Cabin'].transform(lambda x: x.fillna(x.mode()[0] if not x.mode().empty else "U"))
    ```

The choice of method depends on the importance of the 'Cabin' feature in your analysis, the assumptions you are willing to make, and the complexity you want to introduce into your data preprocessing step.

我选择忽略 Cabin 列

## 枚举值处理

Convert categorical variables to numeric variables

### LabelEncoder 二元编码

Sex 列只有 male/female 两种可能的取值，需要将字符串转换成f64方便模型读取处理

> df['Sex'].replace({"male": 1, "female": 0}, inplace=True)

或者用 scikit-learn 的 LabelEncoder

```python
label_encoder = LabelEncoder()
# 默认会按照类别的出现顺序进行编码, 使用 fit 方法拟合编码器，显式指定编码映射
label_encoder.fit(["female", "male"])
df['Sex'] = label_encoder.fit_transform(df['Sex'])
```

### OneHotEncoder 独热编码

Embarked 上船地点列有 C,Q,S 三种取值，一般经验上可以转换成二元值得 Embarked_C  Embarked_Q  Embarked_S 三列

```python
onehot_encoder = OneHotEncoder(sparse=False)  # 使用 sparse=False 来直接得到一个密集矩阵
encoded_data_enum = onehot_encoder.fit_transform(df[['Embarked']])
# 创建一个包含独热编码后列的 DataFrame
# 不再需要传入 ['Embarked'] 给 get_feature_names_out
onehot_df_enum = pd.DataFrame(encoded_data_enum, columns=onehot_encoder.get_feature_names_out())
# 连接独热编码后的 DataFrame 与原始 DataFrame
# 确保 DataFrame 的索引匹配，以避免任何潜在的数据错位问题
df = pd.concat([df.reset_index(drop=True), onehot_df_enum.reset_index(drop=True)], axis=1)
# 删除原始的 'Embarked' 列
df.drop('Embarked', axis=1, inplace=True)
```

#### 多重共线性问题

多重共线性（Multicollinearity）是指在多元回归分析中，自变量（解释变量）之间存在高度相关关系的现象。在统计模型中，多重共线性可能会导致模型估计的不稳定性和解释能力的下降，因为它使得模型中的一个或多个变量难以独立地解释输出变量的变化。

当使用独热编码（One-Hot Encoding）处理分类变量时，每个类别都被转换成一个新的二元特征，其中一个类别对应的特征为1，其他都为0。如果一个变量有 $N$ 个类别，标准的独热编码会创建 $N$ 个二元特征。这就引入了一个潜在的多重共线性问题，因为这 $N$ 个特征之间是完全相关的：任何一个特征都可以通过其他 $N-1$ 个特征的组合来完美预测。换句话说，这些特征之间的关系可以用一个线性方程来表示，这就违反了多元线性回归模型中自变量应该相互独立的假设。

为了避免这个问题，通常会从独热编码的特征中移除一个，以确保自变量之间的独立性。这称作“去掉一个等级”或“减少一个维度”，通常是移除一个特征列。例如，如果有三个类别 `A`、`B` 和 `C`，独热编码会创建三个特征 `is_A`、`is_B` 和 `is_C`。为了避免多重共线性，我们可以移除 `is_A`，这样只保留 `is_B` 和 `is_C`。由于如果一个观测不属于 `B` 和 `C`，它必然属于 `A`，我们仍然可以通过 `is_B` 和 `is_C` 的值推断出 `is_A` 的值。

在 `OneHotEncoder` 中，可以通过设置参数 `drop='first'` 来自动地去除第一个类别对应的特征，从而避免多重共线性问题。这在创建模型，尤其是需要变量间独立性的线性模型中是一种常见的做法。

多重共线性问题在某些统计模型中可能会导致问题，特别是在回归分析中，因为它可能会影响到模型参数的估计和解释。然而，在某些情况下，特别是当使用一些不受多重共线性影响的算法时（比如决策树或随机森林），避免多重共线性并不是必须的。

## 模型训练测试推理

在我之前最小二乘法的文章中已经详细学过记录过split切分训练测试数据集的过程，xy特征列定义等，本文不在赘述

test.csv kaggle测试数据集中踩坑1是Fare票价列有null值，我用中位数填充了

第二个坑就是对 df 和 series 之间转换还不出很熟练，由于模型predict输出是一个ndarry一维数组

一开始我用以下写法结果报错了，原来 test_df['PassengerId'] 返回的是series而不是df

> submission_df = test_df['PassengerId']; submission_df['Survived'] = test_predictions

虽然本地运行结果中准确率有80%，但是上传到kaggle提交通过后，我的评分排名就只有后10% 太卷了~

---

## 最终代码

```python
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import OneHotEncoder, LabelEncoder

# Step 1: Load the data
df = pd.read_csv('train.csv')

def preprocess_data(df: pd.DataFrame) -> pd.DataFrame:
    # Step 2: Handle missing values
    # For simplicity, we'll fill missing numerical values with the median and missing categorical with the most frequent value
    # print("data.isnull()", data.isnull())
    # print("df.isnull().any()", df.isnull().any())
    # Age,Cabin,Embarked column has null

    # rows_with_null_age = df[df['Age'].isnull()]
    # print(f"rows_with_null_age count={rows_with_null_age.count()}", rows_with_null_age)
    # rows_with_null_cabin = df[df['Cabin'].isnull()] # 船仓号
    #print(f"rows_with_null_cabin count={rows_with_null_age.count()}", rows_with_null_cabin)
    # rows_with_null_embarked = df[df['Embarked'].isnull()]
    # print(f"rows_with_null_embarked count={rows_with_null_embarked.count()}", rows_with_null_embarked)

    # 首先登船地点Embarked是一个枚举只有三种，而且只缺失两条，直接用众数填充
    embarked_mode = df['Embarked'].mode()[0]
    df['Embarked'].fillna(embarked_mode, inplace=True)

    # 年龄大概率是正态分布，用中位数填充缺失值 astype(int) 将中位数可能出现转换
    age_imputer = SimpleImputer(strategy='median')
    df['Age'] = age_imputer.fit_transform(df[['Age']]).astype(int)

    # 训练数据Fare没有null，但测试数据里面Fare有null
    fare_imputer = SimpleImputer(strategy='median')
    df['Fare'] = fare_imputer.fit_transform(df[['Fare']])

    # skip useless/not-relative columns
    df.drop(['Cabin', 'Ticket', 'Name', 'PassengerId'], axis=1, inplace=True)

    # Step 3: Convert categorical variables to numeric variables

    # 将性别（gender）这样的二元类别变量转换为数值 0 和 1 的过程被称为二元编码（binary encoding）或二值编码（binarization）
    # We'll use LabelEncoder for simplicity, but one-hot encoding is often a better choice

    # LabelEncoder 二元编码
    label_encoder = LabelEncoder()
    # 默认会按照类别的出现顺序进行编码, 使用 fit 方法拟合编码器，显式指定编码映射
    label_encoder.fit(["female", "male"])
    df['Sex'] = label_encoder.fit_transform(df['Sex'])
    # same as df['Sex'].replace({"male": 1, "female": 0}, inplace=True)

    # OneHotEncoder 独热编码
    # one-hot encoding enum Embarked(C,Q,S) -> Embarked_C  Embarked_Q  Embarked_S
    onehot_encoder = OneHotEncoder(sparse_output=False)  # 使用 sparse=False 来直接得到一个密集矩阵
    encoded_data_enum = onehot_encoder.fit_transform(df[['Embarked']])

    # 创建一个包含独热编码后列的 DataFrame
    # 不再需要传入 ['Embarked'] 给 get_feature_names_out
    onehot_df_enum = pd.DataFrame(encoded_data_enum, columns=onehot_encoder.get_feature_names_out())

    # 连接独热编码后的 DataFrame 与原始 DataFrame
    # 确保 DataFrame 的索引匹配，以避免任何潜在的数据错位问题
    df = pd.concat([df.reset_index(drop=True), onehot_df_enum.reset_index(drop=True)], axis=1)

    # 删除原始的 'Embarked' 列
    df.drop('Embarked', axis=1, inplace=True)

    return df

df = preprocess_data(df)
# Step 4: Split the dataset into training and test sets
# Selecting relevant features for simplicity (you might want to engineer more features)
features = ['Pclass', 'Sex', 'Age', 'SibSp', 'Parch', 'Fare', 'Embarked_C', 'Embarked_Q', 'Embarked_S']
X = df[features]
y = df['Survived']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Step 5: Train the model
X = df.drop('Survived', axis=1)
y = df['Survived']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Model selection
model = RandomForestClassifier(n_estimators=100, random_state=42)

# Train the model
model.fit(X_train, y_train)

# Predict and evaluate
# Step 6: Evaluate the model (optional)
predictions = model.predict(X_test)
accuracy = accuracy_score(y_test, predictions)
print(f'Accuracy: {accuracy}')

# Step 7: predict kaggle test data
# If you want to predict the test set from Kaggle, you'll need to preprocess it in the same way as the training set
test_df = pd.read_csv('test.csv')
# Make sure submission_df is a DataFrame with one column
# NOTE 'test_df['PassengerId']' is a Series not a dataframe
submission_df = test_df[['PassengerId']]
test_data_preprocessed = preprocess_data(test_df)
print(test_data_preprocessed)
# print("test_data_preprocessed.isnull().any()", test_data_preprocessed.isnull().any())

# ... apply the same preprocessing ...
test_predictions = model.predict(test_data_preprocessed)
# ... and then generate a submission file.
submission_df['Survived'] = test_predictions
print(submission_df)

# index=False to exclude rowid row
submission_df.to_csv('submission.csv', index=False)
```
