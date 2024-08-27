# [solana os trap](/2024/08/solana_and_move_parallel.md)

<https://docs.solanalabs.com/proposals/embedding-move>

> The biggest design difference between Solana's runtime and Libra's Move VM is how they manage safe invocations between modules. Solana took an operating systems approach and Libra took the domain-specific language approach. In the runtime, a module must trap back into the runtime to ensure the caller's module did not write to data owned by the callee. Likewise, when the callee completes, it must again trap back to the runtime to ensure the callee did not write to data owned by the caller. Move, on the other hand, includes an advanced type system that allows these checks to be run by its bytecode verifier. Because Move bytecode can be verified, the cost of verification is paid just once, at the time the module is loaded on-chain. In the runtime, the cost is paid each time a transaction crosses between modules. The difference is similar in spirit to the difference between a dynamically-typed language like Python versus a statically-typed language like Java. Solana's runtime allows applications to be written in general purpose programming languages, but that comes with the cost of runtime checks when jumping between programs.

solana 使用的 trap 机制可以在某种程度上与 RISC-V 的特权模式进行类比。在 RISC-V 架构中，特权模式 (Privilege Modes) 定义了不同的执行级别，其中某些指令只能在更高的特权级别下执行。当 CPU 检测到某个指令的权限不足时，会触发一个异常或 trap，转而交由更高特权级别的处理程序（例如 Supervisor 或 Hypervisor）来处理。这是确保安全性和隔离性的一种机制。

- 在 Solana 的运行时，模块间的调用也遵循类似的原则，在进行跨模块调用时，需要返回到运行时以确保调用者和被调用者之间的数据访问安全性。这意味着，在执行期间，运行时会对调用的权限进行验证
- Move 语言的并发执行依赖于其类型系统和字节码的事先验证，所有的检查在模块加载时完成，因此调用之间的安全性得到了更高的保障且不需要每次调用时都进行额外检查。

Solana 的 trap 机制则是一种动态检查，确保跨程序调用时需要trap回到执行环境进行权限验证，这一机制在每次跨模块调用中都需要付出额外的执行成本

[Sui, Aptos, Solana 的技术（并行执行）之争（Sui和Aptos项目方的联合 创始人 纷纷加入讨论）](https://move-china.com/topic/264)
