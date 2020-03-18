# [spring官方集成测试Demo的错误](/2020/03/spring_integration_test_error.md)

spring官网的get start教程中的[单元测试部分](https://spring.io/guides/gs/spring-boot#_add_unit_tests)

第一段代码Demo是使用mockMvc进行单元测试的，我手动敲了一遍，没问题

第二段代码Demo是使用Junit单元测试框架，我试了下修改期待值，可以无论怎么修改都是通过测试

```java
  @Test
  public void getIndex() throws Exception {
    ResponseEntity<String> response = template.getForEntity(base.toString(),
      String.class);
    System.out.println(response);
    Assertions.assertThat(response.getBody()).isEqualTo("Index");
    // 下面是spring官方「错误的」代码样例 https://spring.io/guides/gs/spring-boot#_add_unit_tests
    // Assertions.assertThat(response.getBody().equals("Index"));
  }
```

原来官方代码的期待值语句`assertThat(response.getBody()).isEqualTo("Index")`无论如何都不会报错

应该改成`ssertThat(response.getBody().equals("Index"))`
