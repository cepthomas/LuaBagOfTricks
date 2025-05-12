import sys
import os
import time
import socket
import threading
import queue
import datetime
import traceback


#------------------------- Configuration --------------------------------

# TCP host.
HOST = '127.0.0.1'

# TCP port
PORT = 59120

# Indicate internal message
MSG_IND = '!'

#------------------------------------------------------------------------------
class DebugexClient(object):

    def __init__(self):
        self.sock = None
        self.commif = None

        # Human polling time in msec.
        self.loop_time = 50

        # Server must reply to client in msec or it's considered dead.
        self.server_response_time = 200  # 100?

        # User command read queue.
        self.cmdQ = queue.Queue()

        # Last command time. Non zero implies waiting for a response.
        self.sendts = 0

    def go(self):
        '''Run the main loop.'''

        try:
            self.do_info(f'Starting client on {HOST}:{PORT}')
            run = True

            ##### Run user cli input in a thread.
            def worker():
                while run:
                    self.cmdQ.put_nowait(sys.stdin.readline().replace('\n', ''))
            threading.Thread(target=worker, daemon=True).start()

            ##### Forever loop #####
            while run:
                timed_out = False

                ##### Try (re)connecting? #####
                if self.commif is None:
                    # TCP socket client
                    self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

                    # Block with timeout.
                    self.sock.settimeout(float(self.server_response_time) / 1000.0)

                    try:
                        self.sock.connect((HOST, PORT))
                        # Didn't fault so must be success.
                        self.commif = self.sock.makefile('rw', newline='\n')
                        self.do_info('Connected to server')

                    except TimeoutError:
                        # Server is not running or not listening right now. Normal operation.
                        timed_out = True
                        self.reset()

                    except ConnectionError as e:
                        # BrokenPipeError, ConnectionAbortedError, ConnectionRefusedError, ConnectionResetError.
                        # Ignore and retry later.
                        self.reset()

                    except Exception as e:
                        # Other unexpected error.
                        self.do_error(e)

                ##### Check for server not responding but still connected. #####
                if self.commif is not None and self.sendts > 0:
                    dur = self.get_msec() - self.sendts
                    if dur > self.server_response_time:
                        self.do_info('Server not listening')
                        self.reset()

                ##### Anything to send? Check for user input. #####
                while not self.cmdQ.empty():
                    s = self.cmdQ.get()

                    if self.commif is not None:
                        self.commif.write(s)
                        self.commif.flush()
                        # Measure round trip for timeout.
                        self.sendts = self.get_msec()
                    else:
                        self.do_info('Execute command failed - not connected')

                ##### Get any server responses. #####
                if self.commif is not None:
                    try:
                        # Don't block.
                        self.sock.settimeout(0)  # pyright: ignore

                        done = False
                        while not done:
                            s = self.commif.read(100)

                            if s == '':
                                done = True
                            else:
                                sys.stdout.write(s)  # (self.make_readable(s))
                                sys.stdout.flush()
                                # Reset watchdog.
                                self.sendts = 0

                    except TimeoutError:
                        # Nothing to read.
                        timed_out = True
                        self.reset()

                    except ConnectionError:
                        # Server disconnected.
                        self.reset()

                    except Exception as e:
                        self.do_error(e)

                ##### If there was no timeout, delay a bit. #####
                slp = (float(self.loop_time) / 1000.0) if timed_out else 0
                time.sleep(slp)

        except KeyboardInterrupt:
            # Hard shutdown, ignore and quit.
            pass

        except Exception as e:
            # Other unexpected errors.
            self.do_error(e)

        self.quit(0)

    def get_msec(self):
        '''Get current msec.'''
        return time.perf_counter_ns() / 1000000

    def reset(self):
        '''Reset comms, resource management.'''

        if self.commif is not None:
            self.commif.close()
            self.commif = None

        if self.sock is not None:
            self.sock.close()
        #     self.sock = None

        # Reset watchdog.
        self.sendts = 0
        # Clear queue.
        while not self.cmdQ.empty():
            self.cmdQ.get()

    def do_error(self, e):
        sys.stdout.write(f'{MSG_IND} Error: {e}\n')
        sys.stdout.flush()
        self.quit(1)

    def do_info(self, msg):
        sys.stdout.write(f'{MSG_IND} {msg}\n')
        sys.stdout.flush()

    def quit(self, code):
        '''Clean up and go home.'''
        self.reset()
        if self.sock is not None:
            self.sock.close()
            self.sock = None
        sys.exit(code)

    def make_readable(self, s):
        '''So we can see things like LF, CR, ESC in log.'''
        return s.replace('\n', '_N\n').replace('\r', '_R\r')
        # return s.replace('\n', '_N').replace('\r', '_R').replace('\033', '_E\033')

#------------------------------------------------------------------------------
if __name__ == '__main__':

    client = DebugexClient()
    client.go()
