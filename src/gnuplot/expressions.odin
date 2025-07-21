package gnuplot
import "core:fmt"


// Operators
// pg. 50


Dummy_Variable:: string


@(private) Expression:: union {
	^Expression_abs,          ^Expression_acos,      ^Expression_acosh,      ^Expression_airy,
	^Expression_arg,          ^Expression_asin,      ^Expression_asinh,      ^Expression_atan,
	^Expression_atan2,        ^Expression_atanh,     ^Expression_besj0,      ^Expression_besj1,
	^Expression_besjn,        ^Expression_besy0,     ^Expression_besy1,      ^Expression_besyn,
	^Expression_besi0,        ^Expression_besi1,     ^Expression_besin,      ^Expression_cbrt,
	^Expression_ceil,         ^Expression_conj,      ^Expression_cos,        ^Expression_cosh,
	^Expression_EllipticK,    ^Expression_EllipticE, ^Expression_EllipticPi, ^Expression_erf,
	^Expression_erfc,         ^Expression_exp,       ^Expression_expint,     ^Expression_floor,
	^Expression_gamma,        ^Expression_ibeta,     ^Expression_inverf,     ^Expression_igamma,
	^Expression_imag,         ^Expression_integer,   ^Expression_invnorm,    ^Expression_invibeta,
	^Expression_invigamma,    ^Expression_LambertW,  ^Expression_lambertw,   ^Expression_lgamma,
	^Expression_lnGamma,      ^Expression_log,       ^Expression_log10,      ^Expression_norm,
	^Expression_rand,         ^Expression_real,      ^Expression_round,      ^Expression_sgn,
	^Expression_Sign,         ^Expression_sin,       ^Expression_sinh,       ^Expression_sqrt,
	^Expression_SynchrotronF, ^Expression_tan,       ^Expression_tanh,       ^Expression_uigamma,
	^Expression_voigt,        ^Expression_zeta,      Dummy_Variable }
@(private) expression_aprint:: proc(x: Expression) -> string {
	switch v in x {
	case ^Expression_abs:          return abs_aprint(v)
	case ^Expression_acos:         return acos_aprint(v)
	case ^Expression_acosh:        return acosh_aprint(v)
	case ^Expression_airy:         return airy_aprint(v)
	case ^Expression_arg:          return arg_aprint(v)
	case ^Expression_asin:         return asin_aprint(v)
	case ^Expression_asinh:        return asinh_aprint(v)
	case ^Expression_atan:         return atan_aprint(v)
	case ^Expression_atan2:        return atan2_aprint(v)
	case ^Expression_atanh:        return atanh_aprint(v)
	case ^Expression_besj0:        return besj0_aprint(v)
	case ^Expression_besj1:        return besj1_aprint(v)
	case ^Expression_besjn:        return besjn_aprint(v)
	case ^Expression_besy0:        return besy0_aprint(v)
	case ^Expression_besy1:        return besy1_aprint(v)
	case ^Expression_besyn:        return besyn_aprint(v)
	case ^Expression_besi0:        return besi0_aprint(v)
	case ^Expression_besi1:        return besi1_aprint(v)
	case ^Expression_besin:        return besin_aprint(v)
	case ^Expression_cbrt:         return cbrt_aprint(v)
	case ^Expression_ceil:         return ceil_aprint(v)
	case ^Expression_conj:         return conj_aprint(v)
	case ^Expression_cos:          return cos_aprint(v)
	case ^Expression_cosh:         return cosh_aprint(v)
	case ^Expression_EllipticK:    return EllipticK_aprint(v)
	case ^Expression_EllipticE:    return EllipticE_aprint(v)
	case ^Expression_EllipticPi:   return EllipticPi_aprint(v)
	case ^Expression_erf:          return erf_aprint(v)
	case ^Expression_erfc:         return erfc_aprint(v)
	case ^Expression_exp:          return exp_aprint(v)
	case ^Expression_expint:       return expint_aprint(v)
	case ^Expression_floor:        return floor_aprint(v)
	case ^Expression_gamma:        return gamma_aprint(v)
	case ^Expression_ibeta:        return ibeta_aprint(v)
	case ^Expression_inverf:       return inverf_aprint(v)
	case ^Expression_igamma:       return igamma_aprint(v)
	case ^Expression_imag:         return imag_aprint(v)
	case ^Expression_integer:      return integer_aprint(v)
	case ^Expression_invnorm:      return invnorm_aprint(v)
	case ^Expression_invibeta:     return invibeta_aprint(v)
	case ^Expression_invigamma:    return invigamma_aprint(v)
	case ^Expression_LambertW:     return LambertW_aprint(v)
	case ^Expression_lambertw:     return lambertw_aprint(v)
	case ^Expression_lgamma:       return lgamma_aprint(v)
	case ^Expression_lnGamma:      return lnGamma_aprint(v)
	case ^Expression_log:          return log_aprint(v)
	case ^Expression_log10:        return log10_aprint(v)
	case ^Expression_norm:         return norm_aprint(v)
	case ^Expression_rand:         return rand_aprint(v)
	case ^Expression_real:         return real_aprint(v)
	case ^Expression_round:        return round_aprint(v)
	case ^Expression_sgn:          return sgn_aprint(v)
	case ^Expression_Sign:         return Sign_aprint(v)
	case ^Expression_sin:          return sin_aprint(v)
	case ^Expression_sinh:         return sinh_aprint(v)
	case ^Expression_sqrt:         return sqrt_aprint(v)
	case ^Expression_SynchrotronF: return SynchrotronF_aprint(v)
	case ^Expression_tan:          return tan_aprint(v)
	case ^Expression_tanh:         return tanh_aprint(v)
	case ^Expression_uigamma:      return uigamma_aprint(v)
	case ^Expression_voigt:        return voigt_aprint(v)
	case ^Expression_zeta:         return zeta_aprint(v)
	case Dummy_Variable:          return v }
	return "" }


@(private) Expression_abs:: struct { x: Expression }
abs:: proc(x: Expression) -> Expression {
	abs_expr: = new(Expression_abs)
	abs_expr^ = Expression_abs{ x=x }
	return abs_expr }
@(private) abs_aprint:: proc(abs: ^Expression_abs) -> string {
	return fmt.aprintf("abs(%s)", expression_aprint(abs.x)) }


@(private) Expression_acos:: struct { x: Expression }
acos:: proc(x: Expression) -> Expression {
	acos_expr: = new(Expression_acos)
	acos_expr^ = Expression_acos{ x=x }
	return acos_expr }
@(private) acos_aprint:: proc(acos: ^Expression_acos) -> string {
	return fmt.aprintf("acos(%s)", expression_aprint(acos.x)) }


@(private) Expression_acosh:: struct { x: Expression }
acosh:: proc(x: Expression) -> Expression {
	acosh_expr: = new(Expression_acosh)
	acosh_expr^ = Expression_acosh{ x=x }
	return acosh_expr }
@(private) acosh_aprint:: proc(acosh: ^Expression_acosh) -> string {
	return fmt.aprintf("acosh(%s)", expression_aprint(acosh.x)) }


@(private) Expression_airy:: struct { x: Expression }
airy:: proc(x: Expression) -> Expression {
	airy_expr: = new(Expression_airy)
	airy_expr^ = Expression_airy{ x=x }
	return airy_expr }
@(private) airy_aprint:: proc(airy: ^Expression_airy) -> string {
	return fmt.aprintf("airy(%s)", expression_aprint(airy.x)) }


@(private) Expression_arg:: struct { x: Expression }
arg:: proc(x: Expression) -> Expression {
	arg_expr: = new(Expression_arg)
	arg_expr^ = Expression_arg{ x=x }
	return arg_expr }
@(private) arg_aprint:: proc(arg: ^Expression_arg) -> string {
	return fmt.aprintf("arg(%s)", expression_aprint(arg.x)) }


@(private) Expression_asin:: struct { x: Expression }
asin:: proc(x: Expression) -> Expression {
	asin_expr: = new(Expression_asin)
	asin_expr^ = Expression_asin{ x=x }
	return asin_expr }
@(private) asin_aprint:: proc(asin: ^Expression_asin) -> string {
	return fmt.aprintf("asin(%s)", expression_aprint(asin.x)) }


@(private) Expression_asinh:: struct { x: Expression }
asinh:: proc(x: Expression) -> Expression {
	asinh_expr: = new(Expression_asinh)
	asinh_expr^ = Expression_asinh{ x=x }
	return asinh_expr }
@(private) asinh_aprint:: proc(asinh: ^Expression_asinh) -> string {
	return fmt.aprintf("asinh(%s)", expression_aprint(asinh.x)) }


@(private) Expression_atan:: struct { x: Expression }
atan:: proc(x: Expression) -> Expression {
	atan_expr: = new(Expression_atan)
	atan_expr^ = Expression_atan{ x=x }
	return atan_expr }
@(private) atan_aprint:: proc(atan: ^Expression_atan) -> string {
	return fmt.aprintf("atan(%s)", expression_aprint(atan.x)) }


@(private) Expression_atan2:: struct { y, x: Expression }
atan2:: proc(y, x: Expression) -> Expression {
	atan2_expr: = new(Expression_atan2)
	atan2_expr^ = Expression_atan2{ y=y, x=x }
	return atan2_expr }
@(private) atan2_aprint:: proc(atan2: ^Expression_atan2) -> string {
	return fmt.aprintf("atan2(%s,%s)", expression_aprint(atan2.y), expression_aprint(atan2.x)) }


@(private) Expression_atanh:: struct { x: Expression }
atanh:: proc(x: Expression) -> Expression {
	atanh_expr: = new(Expression_atanh)
	atanh_expr^ = Expression_atanh{ x=x }
	return atanh_expr }
@(private) atanh_aprint:: proc(atanh: ^Expression_atanh) -> string {
	return fmt.aprintf("atanh(%s)", expression_aprint(atanh.x)) }


@(private) Expression_besj0:: struct { x: Expression }
besj0:: proc(x: Expression) -> Expression {
	besj0_expr: = new(Expression_besj0)
	besj0_expr^ = Expression_besj0{ x=x }
	return besj0_expr }
@(private) besj0_aprint:: proc(besj0: ^Expression_besj0) -> string {
	return fmt.aprintf("besj0(%s)", expression_aprint(besj0.x)) }


@(private) Expression_besj1:: struct { x: Expression }
besj1:: proc(x: Expression) -> Expression {
	besj1_expr: = new(Expression_besj1)
	besj1_expr^ = Expression_besj1{ x=x }
	return besj1_expr }
@(private) besj1_aprint:: proc(besj1: ^Expression_besj1) -> string {
	return fmt.aprintf("besj1(%s)", expression_aprint(besj1.x)) }


@(private) Expression_besjn:: struct { n, x: Expression }
besjn:: proc(n: Expression, x: Expression) -> Expression {
	besjn_expr: = new(Expression_besjn)
	besjn_expr^ = Expression_besjn{ n=n, x=x }
	return besjn_expr }
@(private) besjn_aprint:: proc(besjn: ^Expression_besjn) -> string {
	return fmt.aprintf("besjn(%s,%s)", expression_aprint(besjn.n), expression_aprint(besjn.x)) }


@(private) Expression_besy0:: struct { x: Expression }
besy0:: proc(x: Expression) -> Expression {
	besy0_expr: = new(Expression_besy0)
	besy0_expr^ = Expression_besy0{ x=x }
	return besy0_expr }
@(private) besy0_aprint:: proc(besy0: ^Expression_besy0) -> string {
	return fmt.aprintf("besy0(%s)", expression_aprint(besy0.x)) }


@(private) Expression_besy1:: struct { x: Expression }
besy1:: proc(x: Expression) -> Expression {
	besy1_expr: = new(Expression_besy1)
	besy1_expr^ = Expression_besy1{ x=x }
	return besy1_expr }
@(private) besy1_aprint:: proc(besy1: ^Expression_besy1) -> string {
	return fmt.aprintf("besy1(%s)", expression_aprint(besy1.x)) }


@(private) Expression_besyn:: struct { n, x: Expression }
besyn:: proc(n: Expression, x: Expression) -> Expression {
	besyn_expr: = new(Expression_besyn)
	besyn_expr^ = Expression_besyn{ n=n, x=x }
	return besyn_expr }
@(private) besyn_aprint:: proc(besyn: ^Expression_besyn) -> string {
	return fmt.aprintf("besyn(%s,%s)", expression_aprint(besyn.n), expression_aprint(besyn.x)) }


@(private) Expression_besi0:: struct { x: Expression }
besi0:: proc(x: Expression) -> Expression {
	besi0_expr: = new(Expression_besi0)
	besi0_expr^ = Expression_besi0{ x=x }
	return besi0_expr }
@(private) besi0_aprint:: proc(besi0: ^Expression_besi0) -> string {
	return fmt.aprintf("besi0(%s)", expression_aprint(besi0.x)) }


@(private) Expression_besi1:: struct { x: Expression }
besi1:: proc(x: Expression) -> Expression {
	besi1_expr: = new(Expression_besi1)
	besi1_expr^ = Expression_besi1{ x=x }
	return besi1_expr }
@(private) besi1_aprint:: proc(besi1: ^Expression_besi1) -> string {
	return fmt.aprintf("besi1(%s)", expression_aprint(besi1.x)) }


@(private) Expression_besin:: struct { n, x: Expression }
besin:: proc(n: Expression, x: Expression) -> Expression {
	besin_expr: = new(Expression_besin)
	besin_expr^ = Expression_besin{ n=n, x=x }
	return besin_expr }
@(private) besin_aprint:: proc(besin: ^Expression_besin) -> string {
	return fmt.aprintf("besin(%s,%s)", expression_aprint(besin.n), expression_aprint(besin.x)) }


@(private) Expression_cbrt:: struct { x: Expression }
cbrt:: proc(x: Expression) -> Expression {
	cbrt_expr: = new(Expression_cbrt)
	cbrt_expr^ = Expression_cbrt{ x=x }
	return cbrt_expr }
@(private) cbrt_aprint:: proc(cbrt: ^Expression_cbrt) -> string {
	return fmt.aprintf("cbrt(%s)", expression_aprint(cbrt.x)) }


@(private) Expression_ceil:: struct { x: Expression }
ceil:: proc(x: Expression) -> Expression {
	ceil_expr: = new(Expression_ceil)
	ceil_expr^ = Expression_ceil{ x=x }
	return ceil_expr }
@(private) ceil_aprint:: proc(ceil: ^Expression_ceil) -> string {
	return fmt.aprintf("ceil(%s)", expression_aprint(ceil.x)) }


@(private) Expression_conj:: struct { x: Expression }
conj:: proc(x: Expression) -> Expression {
	conj_expr: = new(Expression_conj)
	conj_expr^ = Expression_conj{ x=x }
	return conj_expr }
@(private) conj_aprint:: proc(conj: ^Expression_conj) -> string {
	return fmt.aprintf("conj(%s)", expression_aprint(conj.x)) }


@(private) Expression_cos:: struct { x: Expression }
cos:: proc(x: Expression) -> Expression {
	cos_expr: = new(Expression_cos)
	cos_expr^ = Expression_cos{ x=x }
	return cos_expr }
@(private) cos_aprint:: proc(cos: ^Expression_cos) -> string {
	return fmt.aprintf("cos(%s)", expression_aprint(cos.x)) }


@(private) Expression_cosh:: struct { x: Expression }
cosh:: proc(x: Expression) -> Expression {
	cosh_expr: = new(Expression_cosh)
	cosh_expr^ = Expression_cosh{ x=x }
	return cosh_expr }
@(private) cosh_aprint:: proc(cosh: ^Expression_cosh) -> string {
	return fmt.aprintf("cosh(%s)", expression_aprint(cosh.x)) }


@(private) Expression_EllipticK:: struct { k: Expression }
EllipticK:: proc(k: Expression) -> Expression {
	EllipticK_expr: = new(Expression_EllipticK)
	EllipticK_expr^ = Expression_EllipticK{ k=k }
	return EllipticK_expr }
@(private) EllipticK_aprint:: proc(EllipticK: ^Expression_EllipticK) -> string {
	return fmt.aprintf("EllipticK(%s)", expression_aprint(EllipticK.k)) }


@(private) Expression_EllipticE:: struct { k: Expression }
EllipticE:: proc(k: Expression) -> Expression {
	EllipticE_expr: = new(Expression_EllipticE)
	EllipticE_expr^ = Expression_EllipticE{ k=k }
	return EllipticE_expr }
@(private) EllipticE_aprint:: proc(EllipticE: ^Expression_EllipticE) -> string {
	return fmt.aprintf("EllipticE(%s)", expression_aprint(EllipticE.k)) }


@(private) Expression_EllipticPi:: struct { n, k: Expression }
EllipticPi:: proc(n, k: Expression) -> Expression {
	EllipticPi_expr: = new(Expression_EllipticPi)
	EllipticPi_expr^ = Expression_EllipticPi{ n=n, k=k }
	return EllipticPi_expr }
@(private) EllipticPi_aprint:: proc(EllipticPi: ^Expression_EllipticPi) -> string {
	return fmt.aprintf("EllipticPi(%s,%s)", expression_aprint(EllipticPi.n), expression_aprint(EllipticPi.k)) }


@(private) Expression_erf:: struct { x: Expression }
erf:: proc(x: Expression) -> Expression {
	erf_expr: = new(Expression_erf)
	erf_expr^ = Expression_erf{ x=x }
	return erf_expr }
@(private) erf_aprint:: proc(erf: ^Expression_erf) -> string {
	return fmt.aprintf("erf(%s)", expression_aprint(erf.x)) }


@(private) Expression_erfc:: struct { x: Expression }
erfc:: proc(x: Expression) -> Expression {
	erfc_expr: = new(Expression_erfc)
	erfc_expr^ = Expression_erfc{ x=x }
	return erfc_expr }
@(private) erfc_aprint:: proc(erfc: ^Expression_erfc) -> string {
	return fmt.aprintf("erfc(%s)", expression_aprint(erfc.x)) }


@(private) Expression_exp:: struct { x: Expression }
exp:: proc(x: Expression) -> Expression {
	exp_expr: = new(Expression_exp)
	exp_expr^ = Expression_exp{ x=x }
	return exp_expr }
@(private) exp_aprint:: proc(exp: ^Expression_exp) -> string {
	return fmt.aprintf("exp(%s)", expression_aprint(exp.x)) }


@(private) Expression_expint:: struct { n, x: Expression }
expint:: proc(n, x: Expression) -> Expression {
	expint_expr: = new(Expression_expint)
	expint_expr^ = Expression_expint{ n=n, x=x }
	return expint_expr }
@(private) expint_aprint:: proc(expint: ^Expression_expint) -> string {
	return fmt.aprintf("expint(%s,%s)", expression_aprint(expint.n), expression_aprint(expint.x)) }


@(private) Expression_floor:: struct { x: Expression }
floor:: proc(x: Expression) -> Expression {
	floor_expr: = new(Expression_floor)
	floor_expr^ = Expression_floor{ x=x }
	return floor_expr }
@(private) floor_aprint:: proc(floor: ^Expression_floor) -> string {
	return fmt.aprintf("floor(%s)", expression_aprint(floor.x)) }


@(private) Expression_gamma:: struct { x: Expression }
gamma:: proc(x: Expression) -> Expression {
	gamma_expr: = new(Expression_gamma)
	gamma_expr^ = Expression_gamma{ x=x }
	return gamma_expr }
@(private) gamma_aprint:: proc(gamma: ^Expression_gamma) -> string {
	return fmt.aprintf("gamma(%s)", expression_aprint(gamma.x)) }


@(private) Expression_ibeta:: struct { a, b, x: Expression }
ibeta:: proc(a, b, x: Expression) -> Expression {
	ibeta_expr: = new(Expression_ibeta)
	ibeta_expr^ = Expression_ibeta{ a=a, b=b, x=x }
	return ibeta_expr }
@(private) ibeta_aprint:: proc(ibeta: ^Expression_ibeta) -> string {
	return fmt.aprintf("ibeta(%s,%s,%s)", expression_aprint(ibeta.a), expression_aprint(ibeta.b), expression_aprint(ibeta.x)) }


@(private) Expression_inverf:: struct { x: Expression }
inverf:: proc(x: Expression) -> Expression {
	inverf_expr: = new(Expression_inverf)
	inverf_expr^ = Expression_inverf{ x=x }
	return inverf_expr }
@(private) inverf_aprint:: proc(inverf: ^Expression_inverf) -> string {
	return fmt.aprintf("inverf(%s)", expression_aprint(inverf.x)) }


@(private) Expression_igamma:: struct { a, z: Expression }
igamma:: proc(a, z: Expression) -> Expression {
	igamma_expr: = new(Expression_igamma)
	igamma_expr^ = Expression_igamma{ a=a, z=z }
	return igamma_expr }
@(private) igamma_aprint:: proc(igamma: ^Expression_igamma) -> string {
	return fmt.aprintf("igamma(%s,%s)", expression_aprint(igamma.a), expression_aprint(igamma.z)) }


@(private) Expression_imag:: struct { x: Expression }
imag:: proc(x: Expression) -> Expression {
	imag_expr: = new(Expression_imag)
	imag_expr^ = Expression_imag{ x=x }
	return imag_expr }
@(private) imag_aprint:: proc(imag: ^Expression_imag) -> string {
	return fmt.aprintf("imag(%s)", expression_aprint(imag.x)) }


@(private) Expression_integer:: struct { x: Expression }
integer:: proc(x: Expression) -> Expression {
	integer_expr: = new(Expression_integer)
	integer_expr^ = Expression_integer{ x=x }
	return integer_expr }
@(private) integer_aprint:: proc(integer: ^Expression_integer) -> string {
	return fmt.aprintf("int(%s)", expression_aprint(integer.x)) }


@(private) Expression_invnorm:: struct { x: Expression }
invnorm:: proc(x: Expression) -> Expression {
	invnorm_expr: = new(Expression_invnorm)
	invnorm_expr^ = Expression_invnorm{ x=x }
	return invnorm_expr }
@(private) invnorm_aprint:: proc(invnorm: ^Expression_invnorm) -> string {
	return fmt.aprintf("invnorm(%s)", expression_aprint(invnorm.x)) }


@(private) Expression_invibeta:: struct { a, b, p: Expression }
invibeta:: proc(a, b, p: Expression) -> Expression {
	invibeta_expr: = new(Expression_invibeta)
	invibeta_expr^ = Expression_invibeta{ a=a, b=b, p=p }
	return invibeta_expr }
@(private) invibeta_aprint:: proc(invibeta: ^Expression_invibeta) -> string {
	return fmt.aprintf("invibeta(%s,%s,%s)", expression_aprint(invibeta.a), expression_aprint(invibeta.b), expression_aprint(invibeta.p)) }


@(private) Expression_invigamma:: struct { a, p: Expression }
invigamma:: proc(a, p: Expression) -> Expression {
	invigamma_expr: = new(Expression_invigamma)
	invigamma_expr^ = Expression_invigamma{ a=a, p=p }
	return invigamma_expr }
@(private) invigamma_aprint:: proc(invigamma: ^Expression_invigamma) -> string {
	return fmt.aprintf("invigamma(%s,%s)", expression_aprint(invigamma.a), expression_aprint(invigamma.p)) }


@(private) Expression_LambertW:: struct { z, k: Expression }
LambertW:: proc(z, k: Expression) -> Expression {
	LambertW_expr: = new(Expression_LambertW)
	LambertW_expr^ = Expression_LambertW{ z=z, k=k }
	return LambertW_expr }
@(private) LambertW_aprint:: proc(LambertW: ^Expression_LambertW) -> string {
	return fmt.aprintf("LambertW(%s,%s)", expression_aprint(LambertW.z), expression_aprint(LambertW.k)) }


@(private) Expression_lambertw:: struct { x: Expression }
lambertw:: proc(x: Expression) -> Expression {
	lambertw_expr: = new(Expression_lambertw)
	lambertw_expr^ = Expression_lambertw{ x=x }
	return lambertw_expr }
@(private) lambertw_aprint:: proc(lambertw: ^Expression_lambertw) -> string {
	return fmt.aprintf("lambertw(%s)", expression_aprint(lambertw.x)) }


@(private) Expression_lgamma:: struct { x: Expression }
lgamma:: proc(x: Expression) -> Expression {
	lgamma_expr: = new(Expression_lgamma)
	lgamma_expr^ = Expression_lgamma{ x=x }
	return lgamma_expr }
@(private) lgamma_aprint:: proc(lgamma: ^Expression_lgamma) -> string {
	return fmt.aprintf("lgamma(%s)", expression_aprint(lgamma.x)) }


@(private) Expression_lnGamma:: struct { x: Expression }
lnGamma:: proc(x: Expression) -> Expression {
	lnGamma_expr: = new(Expression_lnGamma)
	lnGamma_expr^ = Expression_lnGamma{ x=x }
	return lnGamma_expr }
@(private) lnGamma_aprint:: proc(lnGamma: ^Expression_lnGamma) -> string {
	return fmt.aprintf("lnGamma(%s)", expression_aprint(lnGamma.x)) }


@(private) Expression_log:: struct { x: Expression }
log:: proc(x: Expression) -> Expression {
	log_expr: = new(Expression_log)
	log_expr^ = Expression_log{ x=x }
	return log_expr }
@(private) log_aprint:: proc(log: ^Expression_log) -> string {
	return fmt.aprintf("log(%s)", expression_aprint(log.x)) }


@(private) Expression_log10:: struct { x: Expression }
log10:: proc(x: Expression) -> Expression {
	log10_expr: = new(Expression_log10)
	log10_expr^ = Expression_log10{ x=x }
	return log10_expr }
@(private) log10_aprint:: proc(log10: ^Expression_log10) -> string {
	return fmt.aprintf("log10(%s)", expression_aprint(log10.x)) }


@(private) Expression_norm:: struct { x: Expression }
norm:: proc(x: Expression) -> Expression {
	norm_expr: = new(Expression_norm)
	norm_expr^ = Expression_norm{ x=x }
	return norm_expr }
@(private) norm_aprint:: proc(norm: ^Expression_norm) -> string {
	return fmt.aprintf("norm(%s)", expression_aprint(norm.x)) }


@(private) Expression_rand:: struct { x: Expression }
rand:: proc(x: Expression) -> Expression {
	rand_expr: = new(Expression_rand)
	rand_expr^ = Expression_rand{ x=x }
	return rand_expr }
@(private) rand_aprint:: proc(rand: ^Expression_rand) -> string {
	return fmt.aprintf("rand(%s)", expression_aprint(rand.x)) }


@(private) Expression_real:: struct { x: Expression }
real:: proc(x: Expression) -> Expression {
	real_expr: = new(Expression_real)
	real_expr^ = Expression_real{ x=x }
	return real_expr }
@(private) real_aprint:: proc(real: ^Expression_real) -> string {
	return fmt.aprintf("real(%s)", expression_aprint(real.x)) }


@(private) Expression_round:: struct { x: Expression }
round:: proc(x: Expression) -> Expression {
	round_expr: = new(Expression_round)
	round_expr^ = Expression_round{ x=x }
	return round_expr }
@(private) round_aprint:: proc(round: ^Expression_round) -> string {
	return fmt.aprintf("round(%s)", expression_aprint(round.x)) }


@(private) Expression_sgn:: struct { x: Expression }
sgn:: proc(x: Expression) -> Expression {
	sgn_expr: = new(Expression_sgn)
	sgn_expr^ = Expression_sgn{ x=x }
	return sgn_expr }
@(private) sgn_aprint:: proc(sgn: ^Expression_sgn) -> string {
	return fmt.aprintf("sgn(%s)", expression_aprint(sgn.x)) }


@(private) Expression_Sign:: struct { x: Expression }
Sign:: proc(x: Expression) -> Expression {
	Sign_expr: = new(Expression_Sign)
	Sign_expr^ = Expression_Sign{ x=x }
	return Sign_expr }
@(private) Sign_aprint:: proc(Sign: ^Expression_Sign) -> string {
	return fmt.aprintf("Sign(%s)", expression_aprint(Sign.x)) }


@(private) Expression_sin:: struct { x: Expression }
sin:: proc(x: Expression) -> Expression {
	sin_expr: = new(Expression_sin)
	sin_expr^ = Expression_sin{ x=x }
	return sin_expr }
@(private) sin_aprint:: proc(sin: ^Expression_sin) -> string {
	return fmt.aprintf("sin(%s)", expression_aprint(sin.x)) }


@(private) Expression_sinh:: struct { x: Expression }
sinh:: proc(x: Expression) -> Expression {
	sinh_expr: = new(Expression_sinh)
	sinh_expr^ = Expression_sinh{ x=x }
	return sinh_expr }
@(private) sinh_aprint:: proc(sinh: ^Expression_sinh) -> string {
	return fmt.aprintf("sinh(%s)", expression_aprint(sinh.x)) }


@(private) Expression_sqrt:: struct { x: Expression }
sqrt:: proc(x: Expression) -> Expression {
	sqrt_expr: = new(Expression_sqrt)
	sqrt_expr^ = Expression_sqrt{ x=x }
	return sqrt_expr }
@(private) sqrt_aprint:: proc(sqrt: ^Expression_sqrt) -> string {
	return fmt.aprintf("sqrt(%s)", expression_aprint(sqrt.x)) }


@(private) Expression_SynchrotronF:: struct { x: Expression }
SynchrotronF:: proc(x: Expression) -> Expression {
	SynchrotronF_expr: = new(Expression_SynchrotronF)
	SynchrotronF_expr^ = Expression_SynchrotronF{ x=x }
	return SynchrotronF_expr }
@(private) SynchrotronF_aprint:: proc(SynchrotronF: ^Expression_SynchrotronF) -> string {
	return fmt.aprintf("SynchrotronF(%s)", expression_aprint(SynchrotronF.x)) }


@(private) Expression_tan:: struct { x: Expression }
tan:: proc(x: Expression) -> Expression {
	tan_expr: = new(Expression_tan)
	tan_expr^ = Expression_tan{ x=x }
	return tan_expr }
@(private) tan_aprint:: proc(tan: ^Expression_tan) -> string {
	return fmt.aprintf("tan(%s)", expression_aprint(tan.x)) }


@(private) Expression_tanh:: struct { x: Expression }
tanh:: proc(x: Expression) -> Expression {
	tanh_expr: = new(Expression_tanh)
	tanh_expr^ = Expression_tanh{ x=x }
	return tanh_expr }
@(private) tanh_aprint:: proc(tanh: ^Expression_tanh) -> string {
	return fmt.aprintf("tanh(%s)", expression_aprint(tanh.x)) }


@(private) Expression_uigamma:: struct { a, x: Expression }
uigamma:: proc(a, x: Expression) -> Expression {
	uigamma_expr: = new(Expression_uigamma)
	uigamma_expr^ = Expression_uigamma{ a=a, x=x }
	return uigamma_expr }
@(private) uigamma_aprint:: proc(uigamma: ^Expression_uigamma) -> string {
	return fmt.aprintf("uigamma(%s,%s)", expression_aprint(uigamma.a), expression_aprint(uigamma.x)) }


@(private) Expression_voigt:: struct { x, y: Expression }
voigt:: proc(x, y: Expression) -> Expression {
	voigt_expr: = new(Expression_voigt)
	voigt_expr^ = Expression_voigt{ x=x, y=y }
	return voigt_expr }
@(private) voigt_aprint:: proc(voigt: ^Expression_voigt) -> string {
	return fmt.aprintf("voigt(%s,%s)", expression_aprint(voigt.x), expression_aprint(voigt.y)) }


@(private) Expression_zeta:: struct { s: Expression }
zeta:: proc(s: Expression) -> Expression {
	zeta_expr: = new(Expression_zeta)
	zeta_expr^ = Expression_zeta{ s=s }
	return zeta_expr }
@(private) zeta_aprint:: proc(zeta: ^Expression_zeta) -> string {
	return fmt.aprintf("zeta(%s)", expression_aprint(zeta.s)) }

