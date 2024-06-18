# [python导入路径不同类id不同](2024/06/python3_same_class_different_import_path_class_id_not_same.md)

Python踩坑遇到同一个类在不同文件中静态变量不一样的问题 gpt说可能原因if class importing in different ways or from different paths, Python might treat them as different modules

原因是一个文件相对路径导入类，另一个文件从项目根目录绝对路径导入 用id函数打印了下两处文件类结果id不一样...

Python3没有循环依赖检测，gpt说循环依赖出现时也会同一个类多次导入出现多个id

公司项目代码历史遗留问题，sys.path被多个地方修改，同一个py有多种导入路径

还有连__init__.py也没有 同事解释说古老版本pycharm要写http://init.py才能识别包导入，现在都不用啦
