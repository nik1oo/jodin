

		package cell_12_37_05_157

		import "shared:jodin"
		import "core:io"
		import "core:os"
		import "core:sync"


		@(export) __cell__: ^jodin.Cell = nil
		__data_mutex__: ^sync.Ticket_Mutex = nil
		__stdout__, __stderr__, __iopub__, __original_stdout__, __original_stderr__: os.Handle
		__symmap__: ^map[string]rawptr = nil

			sum : proc(nums: ..int, init_value:= 0) -> (result: int) = nil

			@(export) matrix_type :: proc() {
	fmt.println("\n# matrix type")
	// A matrix is a mathematical type built into Odin. It is a regular array of numbers,
	// arranged in rows and columns

	{
		// The following represents a matrix that has 2 rows and 3 columns
		m: matrix[2, 3]f32

		m = matrix[2, 3]f32{
			1, 9, -13,
			20, 5, -6,
		}

		// Element types of integers, float, and complex numbers are supported by matrices.
		// There is no support for booleans, quaternions, or any compound type.

		// Indexing a matrix can be used with the matrix indexing syntax
		// This mirrors other type usages: type on the left, usage on the right

		elem := m[1, 2] // row 1, column 2
		assert(elem == -6)


		// Scalars act as if they are scaled identity matrices
		// and can be assigned to matrices as them
		b := matrix[2, 2]f32{}
		f := f32(3)
		b = f

		fmt.println("b", b)
		fmt.println("b == f", b == f)

	}

	{ // Matrices support multiplication between matrices
		a := matrix[2, 3]f32{
			2, 3, 1,
			4, 5, 0,
		}

		b := matrix[3, 2]f32{
			1, 2,
			3, 4,
			5, 6,
		}

		fmt.println("a", a)
		fmt.println("b", b)

		c := a * b
		#assert(type_of(c) == matrix[2, 2]f32)
		fmt.println("c = a * b", c)
	}

	{ // Matrices support multiplication between matrices and arrays
		m := matrix[4, 4]f32{
			1, 2, 3, 4,
			5, 5, 4, 2,
			0, 1, 3, 0,
			0, 1, 4, 1,
		}

		v := [4]f32{1, 5, 4, 3}

		// treating 'v' as a column vector
		fmt.println("m * v", m * v)

		// treating 'v' as a row vector
		fmt.println("v * m", v * m)

		// Support with non-square matrices
		s := matrix[2, 4]f32{ // [4][2]f32
			2, 4, 3, 1,
			7, 8, 6, 5,
		}

		w := [2]f32{1, 2}
		r: [4]f32 = w * s
		fmt.println("r", r)
	}

	{ // Component-wise operations
		// if the element type supports it
		// Not support for '/', '%', or '%%' operations

		a := matrix[2, 2]i32{
			1, 2,
			3, 4,
		}

		b := matrix[2, 2]i32{
			-5,  1,
			 9, -7,
		}

		c0 := a + b
		c1 := a - b
		c2 := a & b
		c3 := a | b
		c4 := a ~ b
		c5 := a &~ b

		// component-wise multiplication
		// since a * b would be a standard matrix multiplication
		c6 := intrinsics.hadamard_product(a, b)


		fmt.println("a + b",  c0)
		fmt.println("a - b",  c1)
		fmt.println("a & b",  c2)
		fmt.println("a | b",  c3)
		fmt.println("a ~ b",  c4)
		fmt.println("a &~ b", c5)
		fmt.println("hadamard_product(a, b)", c6)
	}

	{ // Submatrix casting square matrices
		// Casting a square matrix to another square matrix with same element type
		// is supported.
		// If the cast is to a smaller matrix type, the top-left submatrix is taken.
		// If the cast is to a larger matrix type, the matrix is extended with zeros
		// everywhere and ones in the diagonal for the unfilled elements of the
		// extended matrix.

		mat2 :: distinct matrix[2, 2]f32
		mat4 :: distinct matrix[4, 4]f32

		m2 := mat2{
			1, 3,
			2, 4,
		}

		m4 := mat4(m2)
		assert(m4[2, 2] == 1)
		assert(m4[3, 3] == 1)
		fmt.printf("m2 %#v\n", m2)
		fmt.println("m4", m4)
		fmt.println("mat2(m4)", mat2(m4))
		assert(mat2(m4) == m2)

		b4 := mat4{
			1, 2, 0, 0,
			3, 4, 0, 0,
			5, 0, 6, 0,
			0, 7, 0, 8,
		}
		fmt.println("b4", intrinsics.matrix_flatten(b4))
	}

	{ // Casting non-square matrices
		// Casting a matrix to another matrix is allowed as long as they share
		// the same element type and the number of elements (rows*columns).
		// Matrices in Odin are stored in column-major order, which means
		// the casts will preserve this element order.

		mat2x4 :: distinct matrix[2, 4]f32
		mat4x2 :: distinct matrix[4, 2]f32

		x := mat2x4{
			1, 3, 5, 7,
			2, 4, 6, 8,
		}

		y := mat4x2(x)
		fmt.println("x", x)
		fmt.println("y", y)
	}

	// TECHNICAL INFORMATION: the internal representation of a matrix in Odin is stored
	// in column-major format
	// e.g. matrix[2, 3]f32 is internally [3][2]f32 (with different a alignment requirement)
	// Column-major is used in order to utilize (SIMD) vector instructions effectively on
	// modern hardware, if possible.
	//
	// Unlike normal arrays, matrices try to maximize alignment to allow for the (SIMD) vectorization
	// properties whilst keeping zero padding (either between columns or at the end of the type).
	//
	// Zero padding is a compromise for use with third-party libraries, instead of optimizing for performance.
	// Padding between columns was not taken even if that would have allowed each column to be loaded
	// individually into a SIMD register with the correct alignment properties.
	//
	// Currently, matrices are limited to a maximum of 16 elements (rows*columns), and a minimum of 1 element.
	// This is because matrices are stored as values (not a reference type), and thus operations on them will
	// be stored on the stack. Restricting the maximum element count minimizing the possibility of stack overflows.

	// 'intrinsics' Procedures (Compiler Level)
	// 	transpose(m)
	//		transposes a matrix
	// 	outer_product(a, b)
	// 		takes two array-like data types and returns the outer product
	//		of the values in a matrix
	// 	hadamard_product(a, b)
	// 		component-wise multiplication of two matrices of the same type
	// 	matrix_flatten(m)
	//		converts the matrix into a flatten array of elements
	//		in column-major order
	//		Example:
	//		m := matrix[2, 2]f32{
	//			x0, x1,
	//			y0, y1,
	//		}
	//		array: [4]f32 = matrix_flatten(m)
	//		assert(array == {x0, y0, x1, y1})
	//	conj(x)
	//		conjugates the elements of a matrix for complex element types only

	// Procedures in "core:math/linalg" and related (Runtime Level) (all square matrix procedures)
	// 	determinant(m)
	// 	adjugate(m)
	// 	inverse(m)
	// 	inverse_transpose(m)
	// 	hermitian_adjoint(m)
	// 	trace(m)
	// 	matrix_minor(m)
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
