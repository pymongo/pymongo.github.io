# [go post json 初体验](/2022/08/go_http_client.md)

## json 序列化反序列化

一种反序列方法类似 serde_json::Value，用 `map[string]interface{}` 类型一堆堆 interface 模拟 Any 去解

另一种是定义结构体加上 json tag

```go
type Resp struct {
    code int `json:"code"`
    Message string `json:"message"`
    // Data interface{} `json:"data"`
}
```

但结构体每个字段必须是 public 才能被 json 库去运行时反射实现反序列化，例如上述代码的 code 不是 public 会导致 go vet 报错:

> struct field code has json tag but is not exported

可以用 vscode 的 gomodifytags 一键给结构体的所有字段加上 json tag

## json post 请求

我试着写了个 json POST 请求的例子，请求用 map 序列化 body 响应用结构体反序列化

```go
base_url := "http://api.example.com"
api_path := "/0/api/v1/user"
client := &http.Client{}

// json account+password
account := "w@go.dev"
password_before_hash := "1234qwer"
h := md5.New()
io.WriteString(h, password_before_hash)
password := fmt.Sprintf("%x", h.Sum(nil))
// printf can format string
req_body := make(map[string]string)
req_body["account"] = account
req_body["password"] = password
req_body_str, err := json.Marshal(req_body)
if err != nil {
    panic(err)
}
url := fmt.Sprintf("%s%s/account/register", base_url, api_path)
req, err := http.NewRequest("POST", url, bytes.NewBuffer(req_body_str))
if err != nil {
    panic(err)
}
req.Header.Set("Content-Type", "application/json")

resp, err := client.Do(req)
if err != nil {
    panic(err)
}
resp_body, err := ioutil.ReadAll(resp.Body)
fmt.Printf("resp %d %s\n%s\n\n", resp.StatusCode, url, resp_body)
rsp := Resp{}
if err := json.Unmarshal(resp_body, &rsp); err != nil {
    panic(err)
}
fmt.Printf("%+v\n", rsp)
```

整体看上去 go 代码还算比较简单，标准库自带 md5+json 跟 python 标准库一样很全，只不过类似 `defer resp.Body.Close()` 这些我可能想不到要加，我试了下不加也没报错

体验上比 python 之类的好些至少编译器能查出很多错误有很多强制要求，

但这个 json 读写的效率尤其是序列化结构体需要人肉给每个字段加 tag 太难受了，命名要首字母但是 json 传输又要重命名另一个名字也太麻烦了，json 读写确实不如 serde_json
