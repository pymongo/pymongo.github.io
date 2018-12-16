# python的sqliteAPI

Tags: [数据库](/), [python](/)

首发于: 18-12-08 最后修改于: 18-12-08

## 用ORM还是SQL语句

Flask-SQLAlchemy可以用python的数据类型去操作数据库

优点:更换数据库只需要更改driver即可,不需要懂太多数据库

但我觉得并没简化多少语句, 而且操作也不透明

sqliteAPI跟SQLAlchemy一样都是用fetchOne或者fetchmany获取查询结果

还不如用原生sqliteAPI去操作,查询速度也更快

## 资源回收

为了确保return前一定要把数据库驱动/接口给关闭掉

必须使用try...catch语句, 因为finally里面的语句是在return前执行的

```python
@app.route('/search', methods=['GET'])
def search():
    try:
        conn = sqlite3.connect('dict.sqlite')
        cur = conn.cursor()
        q = request.args.get('q')
        lang = request.args.get('lang')
        cur.execute(f'''
            SELECT * FROM dict
            WHERE "{lang}"="{q}"
            ''')
        query_result = cur.fetchone()
        if query_result is None:
            query_result = ("","未收录该单词","","","","")
        return jsonify( # 0是主键所在列
            japanese=query_result[1],
            romaji=query_result[2],
            furigana=query_result[3],
            chinese=query_result[4],
            english=query_result[5])
    except Exception as e:
        pass
    finally:
        cur.close()
        conn.close()
```