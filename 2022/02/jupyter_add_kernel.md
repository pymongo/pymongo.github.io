# [jupyter add kernel](/2022/03/jupyter_add_kernel.md)

就在 /home/w/.local/share/jupyter/kernels 文件夹里面建一个文件夹就行了，很简单

```
[w@ww jupyter]$ tree kernels/
kernels/
├── mypython
│   └── kernel.json
└── python3
    ├── kernel.json
    ├── logo-32x32.png
    └── logo-64x64.png
[w@ww jupyter]$ cat kernels/mypython/kernel.json 
{
    "argv": ["python", "-m", "IPython.kernel",
             "-f", "{connection_file}"],
    "display_name": "mypython",
    "language": "python"
}
```

kernel.json 里面的 {connection_file} 看上去就是 ipython 自身自动生成的

kernels 内新增一个文件夹之后 重启 jupyter notebook 即可

```
[w@ww jupyter]$ jupyter kernelspec list
Available kernels:
  mypython    /home/w/.local/share/jupyter/kernels/mypython
  python3     /home/w/.local/share/jupyter/kernels/python3
```

只不过我这个照着 Jupyter 文档加的 kernel 在网页上能看到只不过不能用而已...
