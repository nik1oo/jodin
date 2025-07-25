import ipykernel.kernelbase
import os
import sys
import platform
import time
import subprocess
import struct
import tempfile
import shutil
import pexpect
import pexpect.popen_spawn
import pexpect.replwrap
from .external_pipe import External_Pipe


TIMEOUT                        = 2.0
PIPE_TIMEOUT                   = 10.0
DELAY                          = 0.1
EXECUTE_TIMEOUT                = 10.0
KILOBYTE                       = 1024
MEGABYTE                       = 1024 * KILOBYTE
KERNEL_SOURCE_PIPE_BUFFER_SIZE = 64 * KILOBYTE
KERNEL_STDOUT_PIPE_BUFFER_SIZE = 16 * KILOBYTE
KERNEL_STDERR_PIPE_BUFFER_SIZE = 16 * KILOBYTE
KERNEL_IOPUB_PIPE_BUFFER_SIZE  = 16 * MEGABYTE
ANSI_RED                       = "\033[2;31m"
ANSI_GREEN                     = "\033[2;32m"
ANSI_RESET                     = "\033[0m"
KERNEL_LOG_PREFIX              = ANSI_GREEN + "[JodinKernel] " + ANSI_RESET
KERNEL_ERROR_PREFIX            = ANSI_RED + "[JodinKernel] " + ANSI_RESET


def get_odin_root():
    p = pexpect.popen_spawn.PopenSpawn('odin root')
    p.expect(pexpect.EOF)
    return str(p.before)[2:-1]


KERNEL_SOURCE_PIPE_NAME = r"jodin_kernel_source"
KERNEL_STDOUT_PIPE_NAME = r"jodin_kernel_stdout"
KERNEL_IOPUB_PIPE_NAME  = r"jodin_kernel_iopub"


def print_and_flush(*args):
    for arg in args:
        sys.__stdout__.write(arg)
    sys.__stdout__.write('\n')
    sys.__stdout__.flush()


MESSAGE_TYPE_NONE                = 0
MESSAGE_TYPE_STREAM              = 1
MESSAGE_TYPE_DISPLAY_DATA        = 2
MESSAGE_TYPE_UPDATE_DISPLAY_DATA = 3
MESSAGE_TYPE_EXECUTE_INPUT       = 4
MESSAGE_TYPE_EXECUTE_RESULT      = 5
MESSAGE_TYPE_ERROR               = 6
MESSAGE_TYPE_STATUS              = 7
MESSAGE_TYPE_CLEAR_OUTPUT        = 8
MESSAGE_TYPE_DEBUG_EVENT         = 9


message_type_names = [
    "TYPE_NONE",
    "TYPE_STREAM",
    "TYPE_DISPLAY_DATA",
    "TYPE_UPDATE_DISPLAY_DATA",
    "TYPE_EXECUTE_INPUT",
    "TYPE_EXECUTE_RESULT",
    "TYPE_ERROR",
    "TYPE_STATUS",
    "TYPE_CLEAR_OUTPUT",
    "TYPE_DEBUG_EVENT" ]


class OdinKernel(ipykernel.kernelbase.Kernel):


    implementation         = "JOdin"
    implementation_version = "0.1.0-alpha"
    language               = "odin"
    language_version       = "dev-2025-02-nightly"
    language_info          = { "mimetype": "text/odin", "name": "odin", "file_extension": ".odin" }
    banner                 = "JOdin"
    code_pipe              = None
    stdout_pipe            = None
    message_pipe           = None
    interpreter_path       = ""
    interpreter_process    = ""
    counter                = 1


    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        redirected_stdout = sys.stdout
        sys.stdout = sys.__stdout__
        if platform.system() == "Windows":
            temp_directory = os.getcwd() + r"\.temp"
            self.interpreter_path = 'jodin.exe'
        elif platform.system() == "Linux":
            temp_directory = os.getcwd() + r"/.temp"
            self.interpreter_path = 'jodin.out'
        print_and_flush(KERNEL_LOG_PREFIX + " Temp directory: " + temp_directory)
        if os.path.exists(temp_directory):
            try:
                shutil.rmtree(temp_directory)
            except:
                pass
        try: subprocess.Popen(self.interpreter_path)
        except FileNotFoundError:
            print_and_flush(KERNEL_ERROR_PREFIX + " Could not find interpreter executable " + self.interpreter_path + ".")
            return
        print_and_flush(KERNEL_LOG_PREFIX + " Started jodin interpreter.")
        self.connect_to_server()
        sys.stdout = redirected_stdout
        print_and_flush(KERNEL_LOG_PREFIX + " Started jodin kernel.")


    def send_message(self, message):
        return self.code_pipe.write_string(message)


    def parse_message_stream(self, stream):
        if len(stream) < 5:
            return []
        metaheader_fields = struct.unpack('=BI', stream[0:5])
        metaheader = {
            'type': int(metaheader_fields[0]),
            'size': metaheader_fields[1] }
        message_len = metaheader['size']
        if metaheader['type'] == MESSAGE_TYPE_NONE:
            pass
        elif metaheader['type'] == MESSAGE_TYPE_STREAM:
            header_fields = struct.unpack('=32B', stream[5:37])
            header = {
                'name': bytes(header_fields[0:32]).decode('utf-8').rstrip('\x00') }
            self.send_response_stream(header['name'], stream[74:message_len])
        elif metaheader['type'] == MESSAGE_TYPE_DISPLAY_DATA:
            header_fields = struct.unpack('=32BHH?32B', stream[5:74])
            header = {
                'mime_type' : bytes(header_fields[0:32]).decode('utf-8').rstrip('\x00'),
                'width'     : int(header_fields[32]),
                'height'    : int(header_fields[33]),
                'expanded'  : bool(header_fields[34]),
                'display_id': bytes(header_fields[35:67]).decode('utf-8').rstrip('\x00') }
            self.send_response_display_data(
                stream[74:message_len],
                header['mime_type'],
                header['width'],
                header['height'])
        elif metaheader['type'] == MESSAGE_TYPE_UPDATE_DISPLAY_DATA:
            header_fields = struct.unpack('=32BHH?32B', stream[5:74])
            header = {
                'mime_type' : bytes(header_fields[0:32]).decode('utf-8').rstrip('\x00'),
                'width'     : int(header_fields[32]),
                'height'    : int(header_fields[33]),
                'expanded'  : bool(header_fields[34]),
                'display_id': bytes(header_fields[35:67]).decode('utf-8').rstrip('\x00') }
            self.send_response_update_display_data(
                stream[74:message_len],
                header['mime_type'],
                header['width'],
                header['height'],
                header['display_id'])
        elif metaheader['type'] == MESSAGE_TYPE_EXECUTE_INPUT:
            header_fields = struct.unpack('=H', stream[5:7])
            header = {
                'execution_count': int(header_fields[0]) }
            self.send_response_execute_input(
                stream[7:message_len],
                header['execution_count'])
        elif metaheader['type'] == MESSAGE_TYPE_EXECUTE_RESULT:
            header_fields = struct.unpack('=32BHH?32BH', stream[5:76])
            header = {
                'mime_type'      : bytes(header_fields[0:32]).decode('utf-8').rstrip('\x00'),
                'width'          : int(header_fields[32]),
                'height'         : int(header_fields[33]),
                'expanded'       : bool(header_fields[34]),
                'display_id'     : bytes(header_fields[35:67]).decode('utf-8').rstrip('\x00'),
                'execution_count': int(header_fields[67]) }
            self.send_response_execute_result(
                header['execution_count'],
                stream[76:message_len],
                header['mime_type'],
                header['width'],
                header['height'])
        elif metaheader['type'] == MESSAGE_TYPE_ERROR:
            header_fields = struct.unpack('=32B32B', stream[5:69])
            header = {
                'ename' : bytes(header_fields[0:32]).decode('utf-8').rstrip('\x00'),
                'evalue': bytes(header_fields[32:64]).decode('utf-8').rstrip('\x00') }
            self.send_response_error(
                ename = header['ename'],
                evalue = header['evalue'],
                traceback = stream[76:message_len].split('\x00'))
        elif metaheader['type'] == MESSAGE_TYPE_STATUS:
            header_fields = struct.unpack('=B', stream[5:6])
            execution_states = [ 'busy', 'idle', 'starting' ]
            header = {
                'execution_state' : int(header_fields[0]) }
            self.send_response_status(
                execution_state = execution_states[header['execution_state']])
        elif metaheader['type'] == MESSAGE_TYPE_CLEAR_OUTPUT:
            header_fields = struct.unpack('=?', stream[5:6])
            header = {
                'wait' : bool(header_fields[0]) }
            self.send_response_clear_output(self, header['wait'])
        elif metaheader['type'] == MESSAGE_TYPE_DEBUG_EVENT:
            pass
        if len(stream) > message_len:
            self.parse_message_stream(stream[message_len:])


    def send_response_stream(self, stream_name, response_text):
        message = {
            'name': stream_name, 'text': response_text }
        self.send_response(self.iopub_socket, 'stream', message)


    def send_response_display_data(self, image_data, mime_type, width, height, display_id=''):
        message = {
            'data': { mime_type: image_data },
            'metadata': { mime_type: { 'width': width, 'height': height } } }
        if display_id != '':
            message['transient'] = { 'display_id': display_id }
        self.send_response(self.iopub_socket, 'display_data', message)


    def send_response_update_display_data(self, image_data, mime_type, width, height, display_id):
        message = {
            'data': { mime_type: image_data },
            'metadata': { mime_type: { 'width': width, 'height': height } },
            'transient': { 'display_id': display_id } }
        self.send_response(self.iopub_socket, 'update_display_data', message)


    def send_response_execute_input(self, code, execution_count):
        message = {
            'code': code, 'execution_count': execution_count }
        self.send_response(self.iopub_socket, 'execute_input', message)


    def send_response_execute_result(self, execution_count, image_data, mime_type, width, height, display_id=''):
        message = {
            'execution_count': execution_count, 'data': { mime_type: image_data },
            'metadata': { mime_type: { 'width': width, 'height': height } } }
        if display_id != '':
            message['transient'] = { 'display_id': display_id }
        self.send_response(self.iopub_socket, 'execute_result', message)


    def send_response_error(self, ename, evalue, traceback):
        message = {
            'ename': ename, 'evalue': evalue, 'traceback': traceback }
        self.send_response(self.iopub_socket, 'error', message)


    def send_response_status(self, execution_state):
        message = {
            'execution_state': execution_state }
        self.send_response(self.iopub_socket, 'status', message)


    def send_response_clear_output(self, wait):
        message = {
            'wait': wait }
        self.send_response(self.iopub_socket, 'clear_output', message)


    def do_execute(self, code, silent, store_history=True, user_expressions=None, allow_stdin=False):
        current_counter = self.counter
        if code.strip() in ['quit', 'exit']:
            self.do_shutdown(True)
            return
        cell_id = str(self._parent_header['metadata']['cellId'])
        if self.send_message(cell_id + '\n' + code):
            stdout_message, message_message = (self.stdout_pipe.read_string(), self.message_pipe.read_bytes())
            self.send_response_stream('stdout', stdout_message)
            if message_message != None: self.parse_message_stream(message_message)
        else:
            self.send_response_stream('stdout', KERNEL_ERROR_PREFIX + "No response from interpreter. Restart kernel.")
        return {'status': 'ok',
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {}}


    def do_shutdown(self, restart):
        ipykernel.kernelbase.Kernel.do_shutdown(self, restart)


    def connect_to_server(self):
        self.code_pipe = External_Pipe(KERNEL_SOURCE_PIPE_NAME, "write", KERNEL_SOURCE_PIPE_BUFFER_SIZE)
        self.stdout_pipe = External_Pipe(KERNEL_STDOUT_PIPE_NAME, "read", KERNEL_STDOUT_PIPE_BUFFER_SIZE)
        self.message_pipe = External_Pipe(KERNEL_IOPUB_PIPE_NAME, "read", KERNEL_IOPUB_PIPE_BUFFER_SIZE)
        print_and_flush(ANSI_GREEN + "[JodinKernel]" + ANSI_RESET + " Connected to jodin interpreter.")

