#!/usr/bin/env bash
# minimax-docx Quick Environment Check (Sandbox Super Optimized)
# Cross-platform: macOS, Linux, WSL, Git Bash

# echo "=== dotnet check ==="
# if [ -d "/usr/share/dotnet" ]; then
#     echo "【结论】: /usr/share/dotnet 目录竟然是存在的！"
#     echo "里面的内容是："
#     ls -la /usr/share/dotnet
# else
#     echo "【结论】: 破案了！/usr/share/dotnet 目录在当前容器里压根不存在！"
# fi
# echo "======================================"

set -euo pipefail

DOTNET_CMD="dotnet"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOTNET_DIR="$SCRIPT_DIR/dotnet"

# Force English output for dotnet CLI
export DOTNET_CLI_UI_LANGUAGE=en

echo "=== minimax-docx Environment Check ==="
echo ""

STATUS="READY"
WARNINGS=0

# --- Detect platform ---
OS="unknown"
case "$(uname -s)" in
    Darwin)  OS="macos" ;;
    Linux)
        OS="linux"
        grep -qi microsoft /proc/version 2>/dev/null && OS="wsl"
        ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows-shell" ;;
esac

# --- Critical: .NET SDK (使用局部变量探测，规避 export PATH 拦截) ---
if [ -x "/usr/share/dotnet/dotnet" ]; then
    DOTNET="/usr/share/dotnet/dotnet"
elif command -v dotnet >/dev/null 2>&1; then
    DOTNET="$(command -v dotnet)"
else
    echo "[FAIL] dotnet missing"
    exit 1
fi

if [ "$DOTNET_CMD" = "dotnet" ] && ! command -v dotnet &>/dev/null; then
    printf "[FAIL]    %-14s not found\n" "dotnet"
    echo "  .NET SDK is REQUIRED but missing in this environment."
    STATUS="NOT READY"
else
    # 使用探测到的命令执行
    local_ver=$("$DOTNET_CMD" --version 2>/dev/null || echo "0.0.0")
    local_major="${local_ver%%.*}"
    if [ "$local_major" -ge 8 ] 2>/dev/null; then
        printf "[OK]      %-14s %s (>= 8.0)\n" "dotnet" "$local_ver"
    else
        printf "[FAIL]    %-14s %s (requires >= 8.0)\n" "dotnet" "$local_ver"
        STATUS="NOT READY"
    fi
fi

# --- Critical: Local project artifacts only (offline-safe) ---
if [ -d "$DOTNET_DIR" ]; then
    DLL_FOUND=""
    for dll in \
        "$DOTNET_DIR/MiniMaxAIDocx.Cli/bin/Release/net8.0/MiniMaxAIDocx.Cli.dll" \
        "$DOTNET_DIR/MiniMaxAIDocx.Cli/bin/Debug/net8.0/MiniMaxAIDocx.Cli.dll" \
        "$DOTNET_DIR/MiniMaxAIDocx.Cli/bin/Release/net10.0/MiniMaxAIDocx.Cli.dll" \
        "$DOTNET_DIR/MiniMaxAIDocx.Cli/bin/Debug/net10.0/MiniMaxAIDocx.Cli.dll"
    do
        if [ -f "$dll" ]; then
            DLL_FOUND="$dll"
            break
        fi
    done

    if [ -n "$DLL_FOUND" ]; then
        printf "[OK]      %-14s offline build detected\n" "project"
        printf "           %s\n" "$DLL_FOUND"
    else
        printf "[FAIL]    %-14s compiled DLL not found\n" "project"
        echo "  Offline sandbox mode requires prebuilt artifacts."
        STATUS="NOT READY"
    fi
else
    printf "[FAIL]    %-14s directory not found: %s\n" "project" "$DOTNET_DIR"
    STATUS="NOT READY"
fi

# --- Optional: pandoc ---
if command -v pandoc &>/dev/null; then
    pandoc_ver=$(pandoc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "?")
    printf "[OK]      %-14s %s (content preview)\n" "pandoc" "$pandoc_ver"
else
    printf "[WARN]    %-14s not found — docx_preview.sh will use fallback\n" "pandoc"
    WARNINGS=$((WARNINGS + 1))
fi

# --- Optional: LibreOffice ---
if command -v soffice &>/dev/null; then
    soffice_ver=$(soffice --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "?")
    printf "[OK]      %-14s %s (.doc conversion)\n" "soffice" "$soffice_ver"
else
    soffice_found=false
    for p in \
        "/Applications/LibreOffice.app/Contents/MacOS/soffice" \
        "/usr/lib/libreoffice/program/soffice" \
        "/snap/bin/libreoffice" \
        "/opt/libreoffice/program/soffice"; do
        if [ -x "$p" ]; then
            printf "[OK]      %-14s found at %s (.doc conversion)\n" "soffice" "$p"
            soffice_found=true
            break
        fi
    done
    if ! $soffice_found; then
        printf "[WARN]    %-14s not found — .doc files cannot be converted\n" "soffice"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# --- Optional: zip/unzip ---
zip_ok=true
if ! command -v zip &>/dev/null; then
    printf "[WARN]    %-14s not found (optional, .NET handles DOCX natively)\n" "zip"
    zip_ok=false
    WARNINGS=$((WARNINGS + 1))
fi
if ! command -v unzip &>/dev/null; then
    printf "[WARN]    %-14s not found (optional, .NET handles DOCX natively)\n" "unzip"
    zip_ok=false
    WARNINGS=$((WARNINGS + 1))
fi
if $zip_ok; then
    printf "[OK]      %-14s available\n" "zip/unzip"
fi

# --- Encoding check ---
current_lang="${LANG:-}"
if [ -n "$current_lang" ] && echo "$current_lang" | grep -qi "utf-8\|utf8"; then
    printf "[OK]      %-14s %s\n" "locale" "$current_lang"
else
    if [ -z "$current_lang" ]; then
        printf "[WARN]    %-14s LANG not set (CJK text may have issues)\n" "locale"
    else
        printf "[WARN]    %-14s %s (not UTF-8, CJK text may have issues)\n" "locale" "$current_lang"
    fi
    WARNINGS=$((WARNINGS + 1))
fi

# --- Shell script permissions ---
perm_issues=0
for s in "$SCRIPT_DIR"/*.sh; do
    if [ -f "$s" ] && [ ! -x "$s" ]; then
        perm_issues=$((perm_issues + 1))
    fi
done
if [ "$perm_issues" -gt 0 ]; then
    printf "[WARN]    %-14s %d script(s) not executable\n" "permissions" "$perm_issues"
    WARNINGS=$((WARNINGS + 1))
else
    printf "[OK]      %-14s all scripts executable\n" "permissions"
fi

# --- Result ---
echo ""
if [ "$STATUS" = "READY" ]; then
    if [ "$WARNINGS" -gt 0 ]; then
        echo "Status: READY (with $WARNINGS warning(s) — optional features may be limited)"
    else
        echo "Status: READY"
    fi
else
    echo "Status: NOT READY"
    echo "Critical dependencies missing."
    exit 1
fi
