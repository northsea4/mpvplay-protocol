#define _WIN32_WINNT 0x0600
#define _WIN32_IE 0x0600

#include <windows.h>
#include <shlwapi.h>
#include <wininet.h>
#include <time.h>
#include <stdio.h>
#include <wchar.h>
#include <stdlib.h>

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
#define WEBLINK_PREFIX L"mpvplay://weblink?url="
#define LOG_FILE L"mpvplay-protocol.log"
#define MAX_URL 2048

// 检查是否在控制台模式运行
BOOL is_console_mode() {
    DWORD processes[2];
    DWORD num_processes;
    if (GetConsoleProcessList(processes, 2) > 1) {
        return TRUE;  // 如果有父控制台进程，说明是从命令行启动的
    }
    return FALSE;
}

// 确保有控制台
void ensure_console() {
    if (is_console_mode()) {
        // 已经有控制台，不需要操作
        return;
    }
    
    // 如果没有控制台，创建一个
    if (AllocConsole()) {
        FILE* dummy;
        freopen_s(&dummy, "CONOUT$", "w", stdout);
        freopen_s(&dummy, "CONOUT$", "w", stderr);
    }
}

// 日志函数
void log_message(const wchar_t* format, ...) {
    wchar_t timestamp[64];
    wchar_t message[4096];
    time_t now;
    struct tm* tm_info;
    va_list args;
    
    time(&now);
    tm_info = localtime(&now);
    wcsftime(timestamp, sizeof(timestamp)/sizeof(wchar_t), L"%Y-%m-%d %H:%M:%S", tm_info);
    
    va_start(args, format);
    _vsnwprintf(message, sizeof(message)/sizeof(wchar_t), format, args);
    va_end(args);
    
    // 写入日志文件
    wchar_t log_path[MAX_PATH];
    GetTempPathW(MAX_PATH, log_path);
    wcscat(log_path, LOG_FILE);
    
    FILE* f = _wfopen(log_path, L"a");
    if (f) {
        fwprintf(f, L"[%s] %s\n", timestamp, message);
        fclose(f);
    }
    
    // 如果是控制台模式，也输出到控制台
    if (is_console_mode()) {
        wprintf(L"[%s] %s\n", timestamp, message);
    }
}

// URL 解码
wchar_t* decode_url(const wchar_t* encoded_url) {
    wchar_t* decoded = (wchar_t*)calloc(MAX_URL, sizeof(wchar_t));
    DWORD decoded_length = MAX_URL;
    
    if (!decoded) {
        log_message(L"Error: Failed to allocate memory for URL decoding");
        return NULL;
    }
    
    if (InternetCanonicalizeUrlW(encoded_url, decoded, &decoded_length, ICU_DECODE | ICU_NO_ENCODE)) {
        log_message(L"URL decoded successfully");
        return decoded;
    }
    
    DWORD error = GetLastError();
    log_message(L"Error: Failed to decode URL (error code: %lu)", error);
    free(decoded);
    return NULL;
}

// 修复损坏的 URL
wchar_t* fix_broken_url(wchar_t* url) {
    log_message(L"Fixing URL: %s", url);
    
    if (wcsncmp(url, L"http//", 6) == 0) {
        log_message(L"Found broken http URL format");
        // 在原字符串中插入 ":"
        size_t len = wcslen(url);
        memmove(url + 6, url + 5, (len - 5 + 1) * sizeof(wchar_t));  // +1 for null terminator
        url[4] = L':';
        log_message(L"Fixed http URL: %s", url);
    }
    else if (wcsncmp(url, L"https//", 7) == 0) {
        log_message(L"Found broken https URL format");
        // 在原字符串中插入 ":"
        size_t len = wcslen(url);
        memmove(url + 7, url + 6, (len - 6 + 1) * sizeof(wchar_t));  // +1 for null terminator
        url[5] = L':';
        log_message(L"Fixed https URL: %s", url);
    }
    return url;
}

// 检查URL是否合法
BOOL is_valid_url(const wchar_t* url) {
    return url && wcslen(url) > 0 && (wcsstr(url, L"http://") == url || wcsstr(url, L"https://") == url);
}

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow) {
    // 如果是从命令行启动的，确保有控制台输出
    if (is_console_mode()) {
        ensure_console();
    }
    
    log_message(L"Starting MPV Protocol Handler");
    log_message(L"Command line: %s", pCmdLine);
    
    if (wcslen(pCmdLine) < 10) {
        log_message(L"Error: Command line too short");
        return 1;
    }

    // Handle quotes
    if (pCmdLine[0] == '"') {
        pCmdLine++;
        if (pCmdLine[wcslen(pCmdLine)-1] == '"') {
            pCmdLine[wcslen(pCmdLine)-1] = 0;
        }
    }

    wchar_t* url = _wcsdup(pCmdLine);
    wchar_t* final_url = NULL;

    // Remove mpvplay:// prefix
    if (wcsncmp(url, L"mpvplay://", 10) == 0) {
        wcscpy(url, url + 10);
        log_message(L"Removed mpvplay:// prefix: %s", url);
    }

    // Handle weblink format
    if (wcsncmp(url, L"weblink?url=", 11) == 0 || wcsncmp(url, L"weblink/?url=", 12) == 0) {
        wchar_t* weblink_url = wcsstr(url, L"url=");
        if (weblink_url) {
            weblink_url += 4;  // Skip "url="
            log_message(L"Extracting weblink URL: %s", weblink_url);
            
            // URL decode
            wchar_t* decoded = decode_url(weblink_url);
            if (!decoded) {
                log_message(L"Error: URL decoding failed");
                free(url);
                return 1;
            }
            
            final_url = decoded;
            log_message(L"Decoded URL: %s", final_url);
        } else {
            log_message(L"Error: Invalid weblink format");
            free(url);
            return 1;
        }
        free(url);
    } else {
        final_url = fix_broken_url(url);
    }

    // 检查URL合法性
    if (!is_valid_url(final_url)) {
        log_message(L"Error: Invalid URL: %s", final_url);
        free(final_url);
        return 1;
    }

    // 确保空格被编码
    for (wchar_t* p = final_url; *p; p++) {
        if (*p == L' ') *p = L'+';
    }

    // 获取 MPV 路径
    wchar_t path[MAX_PATH];
    DWORD path_size = sizeof(path);
    // google显示，默认安装位置`%APPDATA%/mpv/`，但mpv有很多种安装方式，
    // 这里只考虑跟`mpvplay-protocol.exe`在同一目录下的情况。
    // if (RegGetValueW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\VideoLAN\\VL..", L"InstallDir", RRF_RT_REG_SZ, NULL, path, &path_size) != ERROR_SUCCESS) {
    //     log_message(L"Error: Failed to get MPV path from registry");
    //     free(final_url);
    //     return 1;
    // }
    // wcscat(path, L"\\mpv.exe");
    wcscpy(path, L"mpv.exe");

    log_message(L"MPV path: %s", path);

    // 构建命令行参数
    wchar_t* args = (wchar_t*)malloc(sizeof(wchar_t) * (wcslen(final_url) + 3));
    wcscpy(args, L"\"");
    wcscat(args, final_url);
    wcscat(args, L"\"");

    log_message(L"Arguments: %s", args);

    // Start mpvplay.exe
    int ret = (INT_PTR)ShellExecute(NULL, NULL, path, args, NULL, SW_SHOWNORMAL);
    if (ret <= 32) {
        log_message(L"Error: Failed to start MPV (error code: %d)", ret);
        free(args);
        free(final_url);
        return ret;
    }

    log_message(L"MPV started successfully");
    free(args);
    free(final_url);
    return 0;
}
