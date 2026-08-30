# FCX 本地后端 macOS 版使用说明（26.1.5 / 0828修改版）

本包让 FC26 滚卡插件（一阵失心风FCX-26.1.5）的本地求解后端在 macOS 上运行。
后端与 Windows 最新版 `FCX后端_修改版.exe`（2026-08-28）完全同源——
backend/ 目录下的 .pyc 文件就是从该 EXE 内直接提取的 Python 3.13 字节码，
行为与 Windows 版完全一致。

## 本版相对旧版（26.1.2 / 0818修复版）的变化

1. **「特殊卡」要求修复**：EA 现在接受任意特殊卡满足 PLAYER_RARITY_GROUP
   （特殊卡）类要求。前端会随球员发送 `special` 标记，后端按标记筛选，
   不再按 EA 稀有度组 ID 匹配（旧逻辑在组 ID 缺失时会静默跳过整条约束，
   导致提交被 EA 拒绝）。
2. **奖励卡不可提交**：被前端标记为 `reward` 的 SBC/目标奖励卡会从候选池中
   剔除，永远不会出现在求解结果里。
3. 必须搭配 `一阵失心风FCX-26.1.5.txt` 脚本使用（本包已附带）。

## 包内文件

```
FCX后端-macOS/
├── 启动后端.command            # 一键启动脚本（双击或 bash 运行）
├── run_server.py               # 启动器入口
├── requirements.txt            # Python 依赖清单
├── README-macOS.md             # 本说明
├── backend/                    # 后端模块（从最新 EXE 提取，勿改动）
│   ├── main.pyc
│   ├── optimize.pyc
│   ├── setup.pyc
│   └── logger.pyc
└── 一阵失心风FCX-26.1.5.txt     # 用户脚本（最新版）
```

## 一、准备工作（只需一次）

1. **安装 Python 3.13 或 uv**（二选一，推荐 uv，更快）：
   - `brew install uv`
   - 或 `brew install python@3.13`
   - 没有 Homebrew 的话：`curl -LsSf https://astral.sh/uv/install.sh | sh`
   - 或到 https://www.python.org/downloads/ 装 Python 3.13

2. **浏览器装 Tampermonkey 扩展**：
   - 推荐 Chrome / Edge / Brave / Firefox
   - Safari 需从 App Store 购买安装 Tampermonkey

## 二、启动后端

把整个 `FCX后端-macOS` 文件夹拷到 Mac 上（比如桌面），打开「终端」：

```bash
cd ~/Desktop/FCX后端-macOS     # 进入文件夹（按实际路径调整）
bash 启动后端.command           # 首次运行自动建虚拟环境并装依赖
```

- 首次运行会下载 Python 3.13（如未安装）和依赖（fastapi / uvicorn / pandas /
  ortools 等），需几分钟；之后启动只需几秒。
- 看到 `Uvicorn running on http://127.0.0.1:8080` 即启动成功。
- 以后可以 `chmod +x 启动后端.command`，然后直接双击运行。
- 若双击提示无法验证开发者：右键点文件 → 打开，或执行
  `xattr -d com.apple.quarantine 启动后端.command`

**端口**：默认 `8080`。换端口：`bash 启动后端.command 8000`，
并同步修改 Tampermonkey 脚本里的「FCX设置 → SBC求解参数 → 本地后端端口」。

## 三、安装用户脚本

1. Tampermonkey → 管理面板 → 实用工具 → 导入文件，选择本包里的
   `一阵失心风FCX-26.1.5.txt`（或新建脚本粘贴全文后保存）。
   如果之前装过 26.1.2 旧版脚本，先删除旧版再导入，避免重复运行。
2. 打开 EA Web App（https://www.ea.com/... ultimateteam），确认 FCX 面板正常。
3. 保持「启动后端.command」的终端窗口开着（后端运行中），即可正常滚卡。

## 四、常见问题

- **提示未找到 Python 3.13 / uv**：按脚本里的提示安装后重试。
- **依赖安装失败**：多为网络问题；可给 pip 换国内镜像，或重跑脚本
  （已装部分会跳过）。
- **端口被占用**：换一个端口（见上），两边保持一致即可。
- **滚卡时报「候选球员列表为空」**：这不是后端问题，说明当前 SBC 按你的
  评分范围 / 价格区间 / 排除 / 保护设置筛不出球员，按提示调整设置。
- **验证后端是否活着**：浏览器访问 `http://127.0.0.1:8080/health`，
  有 JSON 响应即正常。
- **关闭后端**：关闭终端窗口，或在其内按 Ctrl+C。

## 五、与 Windows 版的关系

Windows 用 `FCX后端0824\FCX后端_修改版.exe`，macOS 用本包。两者字节码同源、
行为一致，但**不能同时在同一台机器/同一端口运行**。用户脚本同一份
（26.1.5），浏览器端设置（端口等）在两边分别保存。

## 六、后端接口（供排查用）

- `GET  /health` — 健康检查
- `POST /solve` — 求解 SBC（脚本自动调用）
- `POST /relay` — 中继请求（脚本自动调用）
- `GET  /solver-logs` / `GET /logs` — 查看运行日志
- `GET  /clear-logs` / `/clear-solver-logs` — 清空日志
- `GET  /shutdown` — 关闭后端
