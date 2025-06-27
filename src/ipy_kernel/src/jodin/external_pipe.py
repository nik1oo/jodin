import os
import sys
import platform
import time
import win32pipe
import win32file
import win32api
SECOND = 1_000_000_000
MILLISECOND = 1_000_000
DEFAULT_TIMEOUT = 10 * SECOND
DEFAULT_DELAY = 100 * MILLISECOND
class External_Pipe:
    path = None
    handle = None
    os = None
    def __init__(self, name, mode):
        self.os = platform.system()
        if self.os == "Windows":
            self.path = r"\\.\pipe\%s" % name
            start_time = time.time_ns()
            print("Connecting to", self.path, flush=True)
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    self.handle = win32file.CreateFile(self.path, mode, 0, None, win32file.OPEN_EXISTING, 0, 0)
                    break
                except: time.sleep(DEFAULT_DELAY / SECOND)
            if self.handle == win32file.INVALID_HANDLE_VALUE:
                raise Exception("Could not connect to pipe" + self.path + ".")
        elif self.os == "Linux":
            self.path = r"/tmp/pipe_%s" % name
            raise Exception("Linux is bad.")
    def read_string(self):
        return self.read_bytes().decode().strip()
    def read_bytes(self):
        if self.os == "Windows":
            start_time = time.time_ns()
            result = ""
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try: result = win32file.ReadFile(self.handle, 65_536)[1]
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
                break
            return result
        elif self.os == "Linux":
            raise Exception("Linux is bad.")
    def write_string(self, input):
        return self.write_bytes(input.encode('utf-8'))
    def write_bytes(self, input):
        if self.os == "Windows":
            start_time = time.time_ns()
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    win32file.WriteFile(self.handle, input)
                    return True
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
            return False
        elif self.os == "Linux":
            raise Exception("Linux is bad.")
    def destroy_windows(self):
        win32file.WriteHandle(self.handle)