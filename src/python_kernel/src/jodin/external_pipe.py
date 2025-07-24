import os
import sys
import platform
import time
if platform.system() == "Windows":
    import win32pipe
    import win32file
    import win32api
if platform.system() == "Linux":
    import stat


SECOND = 1_000_000_000
MILLISECOND = 1_000_000
DEFAULT_TIMEOUT = 10 * SECOND
DEFAULT_DELAY = 100 * MILLISECOND


class External_Pipe:


    path = None
    handle = None
    os = None
    size = None


    def __init__(self, name, mode, size):
        self.os = platform.system()
        self.size = size
        if self.os == "Windows":
            if mode == "read": mode = win32file.GENERIC_READ
            elif mode == "write": mode = win32file.GENERIC_WRITE
            else: raise Exception("Invalid mode.")
            self.path = r"\\.\pipe\%s" % name
            start_time = time.time_ns()
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    self.handle = win32file.CreateFile(self.path, mode, 0, None, win32file.OPEN_EXISTING, 0, 0)
                    break
                except: time.sleep(DEFAULT_DELAY / SECOND)
            if self.handle == win32file.INVALID_HANDLE_VALUE:
                raise Exception("Could not connect to pipe" + self.path + ".")
        elif self.os == "Linux":
            if mode == "read": mode = os.O_RDONLY
            elif mode == "write": mode = os.O_WRONLY
            else: raise Exception("Invalid mode.")
            self.path = os.getcwd() + r"/.temp/" + r"pipe_%s" % name
            start_time = time.time_ns()
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    if not os.path.lexists(self.path):
                        print("pipe", self.path, "does not exist. creating",flush=True)
                        os.mknod(self.path, stat.S_IFIFO | stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)
                    self.handle = os.open(self.path, mode)
                    break
                except: time.sleep(DEFAULT_DELAY / SECOND)
            # if self.handle == win32file.INVALID_HANDLE_VALUE:
            #     raise Exception("Could not connect to pipe" + self.path + ".")


    def read_string(self):
        bytes_read = self.read_bytes()
        if bytes_read == None: return ""
        else: return bytes_read.decode().strip()


    def read_bytes(self):
        if self.os == "Windows":
            start_time = time.time_ns()
            result = None
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try: result = win32file.ReadFile(self.handle, self.size)[1]
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
                break
            return result
        elif self.os == "Linux":
            start_time = time.time_ns()
            result = None
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try: result = os.read(self.handle, self.size)
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
                break
            return result


    def write_string(self, input_string):
        return self.write_bytes(input_string.encode('utf-8'))


    def write_bytes(self, input_bytes):
        if self.os == "Windows":
            start_time = time.time_ns()
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    win32file.WriteFile(self.handle, input_bytes)
                    return True
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
            return False
        elif self.os == "Linux":
            start_time = time.time_ns()
            while (time.time_ns() - start_time) < DEFAULT_TIMEOUT:
                try:
                    os.write(self.handle, input_bytes)
                    return True
                except:
                    time.sleep(DEFAULT_DELAY / SECOND)
                    continue
            return False


    def destroy_windows(self):
        win32file.CloseHandle(self.handle)

