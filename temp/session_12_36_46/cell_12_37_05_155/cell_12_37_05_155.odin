

		package cell_12_37_05_155

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) arbitrary_precision_mathematics :: proc() {
	fmt.println("\n# core:math/big")

	print_bigint :: proc(name: string, a: ^big.Int, base := i8(10), print_name := true, newline := true, print_extra_info := true) {
		big.assert_if_nil(a)

		as, err := big.itoa(a, base)
		defer delete(as)

		cb := big.internal_count_bits(a)
		if print_name {
			fmt.printf(name)
		}
		if err != nil {
			fmt.printf(" (Error: %v) ", err)
		}
		fmt.printf(as)
		if print_extra_info {
			fmt.printf(" (base: %v, bits: %v, digits: %v)", base, cb, a.used)
		}
		if newline {
			fmt.println()
		}
	}

	a, b, c, d, e, f, res := &big.Int{}, &big.Int{}, &big.Int{}, &big.Int{}, &big.Int{}, &big.Int{}, &big.Int{}
	defer big.destroy(a, b, c, d, e, f, res)

	// How many bits should the random prime be?
	bits   := 64
	// Number of Rabin-Miller trials, -1 for automatic.
	trials := -1

	// Default prime generation flags
	flags := big.Primality_Flags{}

	err := big.internal_random_prime(a, bits, trials, flags)
	if err != nil {
		fmt.printf("Error %v while generating random prime.\n", err)
	} else {
		print_bigint("Random Prime A: ", a, 10)
		fmt.printf("Random number iterations until prime found: %v\n", big.RANDOM_PRIME_ITERATIONS_USED)
	}

	// If we want to pack this Int into a buffer of u32, how many do we need?
	count := big.internal_int_pack_count(a, u32)
	buf := make([]u32, count)
	defer delete(buf)

	written: int
	written, err = big.internal_int_pack(a, buf)
	fmt.printf("\nPacked into u32 buf: %v | err: %v | written: %v\n", buf, err, written)

	// If we want to pack this Int into a buffer of bytes of which only the bottom 6 bits are used, how many do we need?
	nails := 2

	count = big.internal_int_pack_count(a, u8, nails)
	byte_buf := make([]u8, count)
	defer delete(byte_buf)

	written, err = big.internal_int_pack(a, byte_buf, nails)
	fmt.printf("\nPacked into buf of 6-bit bytes: %v | err: %v | written: %v\n", byte_buf, err, written)



	// Pick another random big Int, not necesssarily prime.
	err = big.random(b, 2048)
	print_bigint("\n2048 bit random number: ", b)

	// Calculate GCD + LCM in one fell swoop
	big.gcd_lcm(c, d, a, b)

	print_bigint("\nGCD of random prime A and random number B: ", c)
	print_bigint("\nLCM of random prime A and random number B (in base 36): ", d, 36)
}

		@(export) __update_symmap__:: proc() {

		}

		@(export) __apply_symmap__:: proc() {

		sum = auto_cast __symmap__["sum"]

		}



		@(export) __init__:: proc(_cell: ^jodin.Cell, _stdout: os.Handle, _stderr: os.Handle, _iopub: os.Handle, _symmap: ^map[string]rawptr) {
			__data_mutex__ = &_cell.session.data_mutex
			sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)
			__cell__ = _cell
			sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
			context = __cell__.cell_context
			__original_stdout__ = os.stdout
			__original_stderr__ = os.stderr
			__stdout__ = _stdout; os.stdout = __stdout__
			__stderr__ = _stderr; os.stderr = __stderr__
			__iopub__ = _iopub
			__symmap__ = _symmap
		}

		@(export) __main__:: proc() {

			sync.ticket_mutex_lock(__data_mutex__); defer sync.ticket_mutex_unlock(__data_mutex__)

			sync.mutex_lock(&__cell__.mutex); defer sync.mutex_unlock(&__cell__.mutex)
			context = __cell__.cell_context


			os.stdout = __original_stdout__
			os.stderr = __original_stderr__
		}
