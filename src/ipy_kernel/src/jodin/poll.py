# import time


# CONTINUE:: true
# BREAK::    false


# def start():
# 	return time.time_ns


# def timed_out(start_time, timeout):
# 	if (time.time_ns() - start_time) > timeout: return true
# 	else: return false


# poll_with_cond:: proc(cond: bool, start_time: time.Time, timeout: time.Duration, sleep: time.Duration) -> (done: bool) {
# 	if cond == true do return BREAK
# 	if time.diff(start_time, time.time_ns()) > timeout do return BREAK
# 	time.sleep(sleep)
# 	return CONTINUE }


# poll_without_cond:: proc(start_time: time.Time, timeout: time.Duration, sleep: time.Duration) -> (done: bool) {
# 	if time.diff(start_time, time.time_ns()) > timeout do return BREAK
# 	time.sleep(sleep)
# 	return CONTINUE }

