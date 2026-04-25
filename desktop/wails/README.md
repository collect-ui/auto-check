# Wails Desktop Wrapper

这个子工程把当前 Web 项目包装成 Windows 桌面客户端。

运行逻辑：

1. 启动 `AutoCheck.exe`
2. 检查 `conf/application.properties` 里的 `server_port`
3. 如果本地端口未监听，则在同目录启动 `main.exe`
4. Wails 窗口自动打开 `http://127.0.0.1:<server_port>/collect-ui`

目录要求：

- `AutoCheck.exe`
- `main.exe`
- `conf/`
- `collect/`
- `frontend/`
- `database/`

构建：

```bash
cd desktop/wails
go install github.com/wailsapp/wails/v2/cmd/wails@latest
wails build -platform windows/amd64 -webview2 download
```

说明：

- Wails 客户端面向 Windows 10/11，依赖 WebView2。
- `build/windows/icon.ico` 会作为 EXE 图标参与打包。
