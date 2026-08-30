# -*- coding: utf-8 -*-
"""FCX 本地后端启动器（macOS / 通用 Python 版）

直接加载 backend/ 目录下的 main.pyc（Python 3.13 字节码，与 Windows EXE 同源），
并调用 main.start(port) 启动 FastAPI/uvicorn 服务。

用法：
    python3.13 run_server.py [端口]        # 默认 8080
"""
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(BASE_DIR, "backend"))

def main():
    port = 8080
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print(f"无效端口: {sys.argv[1]!r}，使用默认端口 {port}")
    print(f"FCX 后端启动中：http://127.0.0.1:{port}")
    print("请确认 Tampermonkey 脚本中的「本地后端端口」与之一致（FCX设置 → SBC求解 → 本地后端端口）")
    print("按 Ctrl+C 停止服务")
    import main as fcx_main
    fcx_main.start(port)

if __name__ == "__main__":
    main()
