package gnuplot


Data:: struct {
	file_name: string
}


// {binary <binary list>}
// {{nonuniform|sparse} matrix}
// {index <index list> | index "<name>"}
// {every <every list>}
// {skip <number-of-lines>}
// {using <using list>}
// {convexhull} {concavehull}
// {smooth <option>}
// {bins <options>}
// {mask}
// {volatile} {zsort} {noautoscale}
// {if (<expression>)}
data_file:: proc(
		file_name: string,
		skip_n: int = 0,
		binary: bool = false,
		bins: bool = false,
		) -> Data {
	return Data{}
}