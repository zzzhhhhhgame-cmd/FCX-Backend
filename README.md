# FCX 本地求解后端（Windows / macOS 双端）

FC26 滚卡插件「一阵失心风FCX」的本地 SBC 求解后端，Windows 与 macOS 双平台分发。
两端后端字节码完全同源（macOS 版 `backend/*.pyc` 直接提取自 Windows EXE），
行为一致；用户脚本同一份，两端通用。

- **脚本版本**：一阵失心风FCX **26.1.5**（2026-08-30）
- **后端版本**：2026-08-28 修改版（Windows EXE 与 macOS 包同源）

## 本版修复（相对 26.1.2 / 0818 修复版）

1. **「特殊卡」要求修复**：EA 现在接受任意特殊卡满足 PLAYER_RARITY_GROUP（特殊卡）类要求。
   前端随球员发送 `special` 标记，后端按标记筛选，不再按 EA 稀有度组 ID 匹配
   （旧逻辑在组 ID 缺失时会静默跳过整条约束，导致提交被 EA 拒绝）。
2. **奖励卡不可提交**：被标记为 `reward` 的 SBC / 目标奖励卡会从候选池中剔除，
   永远不会出现在求解结果里。

> 必须搭配 26.1.5 版用户脚本使用（本仓库已附带）。旧版脚本不发送新标记，享受不到修复。

## 目录结构

```
├── README.md                       # 本说明
├── windows/
│   ├── FCX后端_修改版.exe           # Windows 后端（双击运行）
│   └── 一阵失心风FCX-26.1.5.txt     # 用户脚本（Tampermonkey 导入）
└── macos/
    ├── 启动后端.command             # macOS 一键启动脚本
    ├── run_server.py               # macOS 启动器入口
    ├── requirements.txt            # Python 依赖清单
    ├── README-macOS.md             # macOS 详细说明
    ├── backend/                    # 后端模块（Python 3.13 字节码，勿改动）
    │   ├── main.pyc / optimize.pyc / setup.pyc / logger.pyc
    └── 一阵失心风FCX-26.1.5.txt     # 用户脚本（与 windows 目录同一份）
```

## Windows 使用

1. 浏览器安装 [Tampermonkey](https://www.tampermonkey.net/) 扩展（Chrome / Edge / Firefox 均可）。
2. Tampermonkey → 管理面板 → 实用工具 → **导入文件**，选择 `windows/一阵失心风FCX-26.1.5.txt` 保存。
   （如装过 26.1.2 等旧版脚本，先删除旧版再导入，避免重复运行。）
3. 双击 `windows/FCX后端_修改版.exe`，看到 `Uvicorn running on http://127.0.0.1:8080` 即启动成功。
4. 打开 EA Web App，确认 FCX 面板正常，保持后端窗口开着即可滚卡。
5. SmartScreen 拦截时：点「更多信息」→「仍要运行」。

## macOS 使用

准备（只需一次）：

```bash
brew install uv        # 或 brew install python@3.13
```

启动：

```bash
cd macos
bash 启动后端.command   # 首次运行自动建虚拟环境并装依赖，之后秒启
```

- 看到 `Uvicorn running on http://127.0.0.1:8080` 即成功，保持终端窗口开着。
- 用户脚本导入 `macos/一阵失心风FCX-26.1.5.txt`（步骤同上）。
- 双击 `启动后端.command` 也可运行；若提示无法验证开发者：右键 → 打开，
  或执行 `xattr -d com.apple.quarantine 启动后端.command`。
- 更多细节见 `macos/README-macOS.md`。

## 端口说明

默认端口 **8080**，需与 Tampermonkey 脚本里「FCX设置 → SBC求解参数 → 本地后端端口」一致。
换端口：Windows 启动 exe 时按提示输入（或见窗口说明）；macOS 用 `bash 启动后端.command 8000`。

同一台机器上 Windows 版与 macOS 版（如装了虚拟机）不要同时占用同一端口。

## 常见问题

| 现象 | 处理 |
|---|---|
| 提示未找到 Python 3.13 / uv | 按脚本内提示安装后重试（仅 macOS） |
| 依赖安装失败 | 多为网络问题，重跑启动脚本；已装部分会跳过 |
| 端口被占用 | 换端口，脚本设置同步修改 |
| 「候选球员列表为空」 | 非后端问题：当前 SBC 按评分/价格/排除设置筛不出球员，调整筛选 |
| 确认后端是否存活 | 浏览器访问 `http://127.0.0.1:8080/health`，有 JSON 即正常 |
| 关闭后端 | 关窗口 / 终端 Ctrl+C；macOS 也可访问 `/shutdown` |

## 后端接口（排查用）

- `GET  /health` — 健康检查
- `POST /solve` — 求解 SBC（脚本自动调用）
- `POST /relay` — 中继请求（脚本自动调用）
- `GET  /solver-logs`、`GET /logs` — 运行日志
- `GET  /clear-logs`、`/clear-solver-logs` — 清空日志
- `GET  /shutdown` — 关闭后端

## 声明

本项目仅供个人学习与研究。使用第三方工具可能违反游戏服务条款，
由此产生的账号风险由使用者自行承担。
