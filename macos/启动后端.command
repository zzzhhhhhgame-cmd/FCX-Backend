#!/bin/bash
# FCX 本地后端 macOS 启动器
# 用法：双击运行，或在终端执行  bash 启动后端.command [端口]
# 默认端口 8080（与本机 Tampermonkey 脚本中的「本地后端端口」保持一致）

PORT="${1:-8080}"
cd "$(dirname "$0")" || exit 1

# uv 若通过官方脚本安装，默认在 ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

if [ ! -x ".venv/bin/python" ]; then
	if command -v uv >/dev/null 2>&1; then
		echo "[FCX] 使用 uv 准备 Python 3.13 虚拟环境（首次运行可能需要下载）..."
		uv venv --python 3.13 .venv || { echo "[FCX] uv 创建虚拟环境失败"; read -r -p "按回车键退出..."; exit 1; }
	elif command -v python3.13 >/dev/null 2>&1; then
		echo "[FCX] 使用 python3.13 创建虚拟环境..."
		python3.13 -m venv .venv || { echo "[FCX] 创建虚拟环境失败"; read -r -p "按回车键退出..."; exit 1; }
	else
		echo "[FCX] 未找到 Python 3.13 或 uv，请先安装其一："
		echo "    方式一（推荐）：brew install uv"
		echo "    方式二：brew install python@3.13"
		echo "    或到 https://www.python.org/downloads/ 下载 Python 3.13"
		read -r -p "安装完成后按回车重试（Ctrl+C 退出）..."
		exec bash "$0" "$PORT"
	fi
fi

echo "[FCX] 检查/安装依赖（首次运行需要几分钟，之后很快）..."
if command -v uv >/dev/null 2>&1; then
	uv pip install --python .venv/bin/python -q -r requirements.txt || { echo "[FCX] 依赖安装失败，请检查网络后重试"; read -r -p "按回车键退出..."; exit 1; }
else
	.venv/bin/python -m pip install -q -r requirements.txt || { echo "[FCX] 依赖安装失败，请检查网络后重试"; read -r -p "按回车键退出..."; exit 1; }
fi

echo "[FCX] 启动后端：http://127.0.0.1:${PORT}"
echo "[FCX] 请确认 Tampermonkey 脚本的「本地后端端口」= ${PORT}（FCX设置 → SBC求解参数）"
echo "[FCX] 关闭本窗口或按 Ctrl+C 停止服务"
exec .venv/bin/python run_server.py "$PORT"
