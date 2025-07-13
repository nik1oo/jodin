package poll
import "core:time"
import "core:os"


CONTINUE:: true
BREAK::    false


start:: proc() -> time.Time {
	return time.now() }


error:: proc(start_time: time.Time, timeout: time.Duration) -> os.Error {
	if time.diff(start_time, time.now()) > timeout do return os.General_Error.Timeout
	else do return os.General_Error.None }


timed_out:: proc(start_time: time.Time, timeout: time.Duration) -> bool {
	if time.diff(start_time, time.now()) > timeout do return true
	else do return false }


poll:: proc{ poll_with_cond, poll_without_cond }


poll_with_cond:: proc(cond: bool, start_time: time.Time, timeout: time.Duration, sleep: time.Duration) -> (done: bool) {
	if cond == true do return BREAK
	if time.diff(start_time, time.now()) > timeout do return BREAK
	time.sleep(sleep)
	return CONTINUE }


poll_without_cond:: proc(start_time: time.Time, timeout: time.Duration, sleep: time.Duration) -> (done: bool) {
	if time.diff(start_time, time.now()) > timeout do return BREAK
	time.sleep(sleep)
	return CONTINUE }

