# [switch downcast interface](/2023/07/golang_switch_downcast_interface.md)

我这段 downcast interface 的代码有点丑陋，gpt 建议我改成 swich 写法

> how to refactor these golang type assert code

```go
var sparse_features map[string]uint64;
var predict_input map[string]interface{};
// ...
for key := range sparse_features {
	var hash uint64
	if str, ok := predict_input[key].(string); ok {
		hash = hashStr((str))
	} else if integer, ok := predict_input[key].(uint64); ok {
		hash = hashUint64(integer)
	} else if integer, ok := predict_input[key].(int); ok {
		hash = hashUint64(uint64(integer))
	} else if float, ok := predict_input[key].(float64); ok {
		integer := *(*uint64)(unsafe.Pointer(&float))
		hash = hashUint64(integer)
	} else {
		valueType := reflect.TypeOf(predict_input[key])
		fmt.Println("Type:", valueType)
		panic(fmt.Sprintf("key %v not a string/uint64/float64\n", key))
	}

	predict_input[key] = hash % sparse_features[key]
}
```

```go
for key := range sparse_features {
	value := predict_input[key]

	switch value := value.(type) {
	case string:
		hash := hashStr(value)
		predict_input[key] = hash % sparse_features[key]
	case uint64:
		hash := hashUint64(value)
		predict_input[key] = hash % sparse_features[key]
	case int:
		hash := hashUint64(uint64(value))
		predict_input[key] = hash % sparse_features[key]
	case float64:
		intVal := *(*uint64)(unsafe.Pointer(&value))
		hash := hashUint64(intVal)
		predict_input[key] = hash % sparse_features[key]
	default:
		return fmt.Errorf("%w: key %v", ErrInvalidValueType, key)
	}
}
```

看来 `switch v := value.(type)` 用来解析多层嵌套 json 也是可以了的
