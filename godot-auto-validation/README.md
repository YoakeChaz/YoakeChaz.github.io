# Godot 4.6 免手動 F5 自動驗證迴圈

把這個 `_verify/` 資料夾整包複製到你的 Godot 專案根目錄，就能用「一行指令」完成
**headless 編譯/場景驗證 ＋ 自動截圖**，輸出全部存進 `_verify/`（會雲端同步給你的協作 AI）。

> ⚠️ **關於這次的環境**：產生這些檔案的 Claude Code session 跑在雲端 Linux 容器裡，
> **不是你的 Mac**，看不到 `~/Desktop/Claude/遊戲/第六次遊戲試做/`，也沒有 Godot。
> 所以「實跑一次」必須由你在 Mac 上執行下面的指令。腳本本身已在容器裡做過
> bash 語法檢查 + 用 mock godot 跑過完整流程（PASS / FAIL / 截圖輸出都驗證過）。

---

## 一、安裝（30 秒）

把本資料夾裡的 `_verify/` 複製進你的專案：

```bash
cp -R "_verify" "$HOME/Desktop/Claude/遊戲/第六次遊戲試做/_verify"
```

最終你的專案應該長這樣：

```
第六次遊戲試做/
├── project.godot
├── Main.tscn
└── _verify/
    ├── verify.sh        ← 主指令
    ├── validate.gd      ← headless 錯誤掃描
    └── screenshot.gd    ← 截圖
```

---

## 二、② 可重複使用的指令

```bash
cd "$HOME/Desktop/Claude/遊戲/第六次遊戲試做"
bash "_verify/verify.sh"
```

腳本會自動：

1. **找 Godot CLI** — 依序找 `/Applications/Godot.app/Contents/MacOS/Godot`、
   `~/Applications/...`，再用 Spotlight (`mdfind`) 找 bundle id `org.godotengine.godot`，
   最後找 PATH 裡的 `godot`。找不到會請你設 `GODOT_PATH`。
2. **headless 匯入**：`godot --headless --path ... --import`（建 `.godot/`，這步就會噴
   broken `ext_resource` / 壞 uid / 匯入失敗）。
3. **headless 驗證**：跑 `validate.gd`，逐一 `load()` 每個 `.gd / .tscn / .tres`，
   抓 GDScript 編譯錯、場景載入/instantiate 失敗、資源載入失敗。
4. **截圖**：跑 `screenshot.gd`（**開窗渲染**，因為 headless 沒有 framebuffer），
   載入 `Main.tscn` 算 3 秒後抓一張 PNG。先試 **Metal**，失敗自動 fallback 到
   **GL Compatibility (opengl3)**。

### 找不到 Godot 時

```bash
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot" bash "_verify/verify.sh"
```

---

## 三、④ 輸出長怎樣

全部寫進 `_verify/`：

| 檔案 | 內容 |
|------|------|
| `log.txt` | 整次執行的完整 log（含 Godot 版本、import、驗證結果、引擎 stderr、SUMMARY） |
| `shot_<時間>.png` | 執行中 `Main.tscn` 的截圖，每次跑都有新時間戳 |

`log.txt` 結尾的 `### SUMMARY ###` 會直接告訴你：

```
Validation : PASS / FAIL
Screenshot : OK -> .../shot_....png   /  MISSING
```

**離開碼**：驗證通過 = `0`，有任何編譯/載入錯 = `1`（方便接 CI 或 watch 工具）。

驗證失敗時，log 裡會有像這樣的行，AI/你都讀得到：

```
VERIFY_FAIL: 2 problem(s) found:
  - Script failed to load/compile: res://Player.gd
  - Scene failed to load (broken ext_resource / missing uid?): res://Enemy.tscn
```

---

## 四、⑤ 接 Godot MCP 到 Claude Code

> 這一步要在**你的 Mac 上的 Claude Code** 執行（不是雲端 session）。

### 我的推薦：`Coding-Solo/godot-mcp`（免費、最穩、有維護）

評估了你列的三個 + 現況（2026-06）：

| 方案 | 狀態 | 適合度 |
|------|------|--------|
| **Coding-Solo/godot-mcp** ⭐推薦 | MIT、~3.9k stars、2026-04 仍更新；CLI/headless 路線，跟本腳本同思路 | 跑專案＋抓 debug 最穩、零成本 |
| mkdevkit/godot-mcp（你清單裡） | Node.js、控制 Godot 4 編輯器，支援 Claude Code/Cursor/Codex | 想直接操作編輯器可選 |
| GDAI（3ddelano/gdai-mcp-plugin-godot，你清單裡） | 編輯器內 plugin、WebSocket 即時、自動截圖，約 $19 付費 | 要「編輯器內即時截圖＋改場景」最強，但要錢 |
| Erodenn/godot-mcp-runtime | 知名度/維護度較低 | 暫不建議 |

`Coding-Solo` 的工具包含：`run_project`、`get_debug_output`、`stop_project`、
`launch_editor`、`get_godot_version`、`get_project_info`、`create_scene`、`add_node`、
`get_uid`、`update_project_uids` 等——正好涵蓋你要的「跑場景 / 讀 debug」。

### 安裝（一行）

```bash
claude mcp add godot -e GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot" -- npx @coding-solo/godot-mcp
```

需要 Node.js ≥ 18。裝完**重啟 Claude Code**。

### 驗證 list 得到工具

```bash
claude mcp list
```

應看到 `godot` 已連線；在對話裡這些工具會以 `run_project`、`get_debug_output` 等出現。
之後就能叫 AI：「run 這個專案、把 debug 貼給我」。

> 注意：MCP 的截圖能力以「編輯器/執行中視窗」為主；本資料夾的 `verify.sh` 不依賴 MCP，
> 是獨立、最穩的那條路——**就算 MCP 沒接成，第 2～4 點照樣能動。**

---

## 五、③ 怎麼證明它有效（在 Mac 上跑一次）

1. **抓得到錯**：故意在某個 `.gd` 打錯字（例如刪掉一個 `)`），跑 `bash "_verify/verify.sh"`，
   `log.txt` 會出現 `VERIFY_FAIL` + 那支腳本路徑，離開碼 = 1。
2. **真的有截圖**：改回來再跑一次，`_verify/` 裡會出現 `shot_<時間>.png`，
   `SUMMARY` 顯示 `Screenshot : OK`。

---

## 六、撞牆排查

| 症狀 | 處理 |
|------|------|
| `Godot 4.x CLI not found` | 用 `GODOT_PATH=...` 指定，或確認 Godot.app 在 /Applications |
| 截圖 `MISSING`，log 有 `viewport image is null` | Metal 沒成 → 腳本已自動試 GL；若仍失敗，確認不是用 SSH 無頭環境跑（需有桌面） |
| `--import` 不被支援（很舊的 4.x） | 4.6 沒問題；若報錯把那行改成 `--editor --quit` |
| 場景一開就需要輸入/會自己關 | 截圖等 180 frame（3 秒）；可改 `screenshot.gd` 的 `WAIT_FRAMES` |
| 想換主場景 | 改 `screenshot.gd` 的 `MAIN_SCENE`（預設 `res://Main.tscn`） |
| 想跳過 `addons/` 第三方碼的驗證 | 在 `validate.gd` 的 `SKIP_DIRS` 加 `"addons"` |
