###########################################################
###                  BREAK_ETERNITY.GD                  ###
###               Ported by Minemaker0430               ###
###                                                     ###
###             Original Library by Patashu             ###
###    https://github.com/Patashu/break_eternity.js/    ###
###                                                     ###
###             Feel free to contribute at              ###
### https://github.com/Minemaker0430/break_eternity.gd/ ###
###         if you have any fixes/improvements!         ###
###########################################################

class_name Decimal

var ssign: int = 0
var layer: int = 0
var mag: float = 0.00

var m: float = 0.00
var e: int = 0

#Constants
const ZERO = 0
const ONE = 1
const NEG_ONE = -1

const E = 2.7182818284590452353602874713527 # No Godot internal variable for Euler's Number so this will have to do

const MAX_SIGNIFICANT_DIGITS = 17
const EXP_LIMIT = 9e15
const LAYER_DOWN = log(9e15) / log(10)
const FIRST_NEG_LAYER = (1 / 9e15)
const NUMBER_EXP_MAX = 308
const NUMBER_EXP_MIN = -324
const MAX_ES_IN_A_ROW = 5
const MAX_ARROWS_IN_A_ROW = 5

const _EXPN1 = 0.36787944117144232159553 # exp(-1)
const OMEGA = 0.56714329040978387299997 # W(1, 0)

const critical_headers = [2, E, 3, 4, 5, 6, 7, 8, 9, 10]
const critical_tetr_values = [[
	# Base 2 (using http://myweb.astate.edu/wpaulsen/tetcalc/tetcalc.html )
	1, 1.0891180521811202527, 1.1789767925673958433, 1.2701455431742086633, 1.3632090180450091941, 1.4587818160364217007, 1.5575237916251418333, 1.6601571006859253673, 1.7674858188369780435, 1.8804192098842727359, 2], [
	# Base E (using http://myweb.astate.edu/wpaulsen/tetcalc/tetcalc.html )
	1, 1.1121114330934078681, 1.2310389249316089299, 1.3583836963111376089, 1.4960519303993531879, 1.6463542337511945810, 1.8121385357018724464, 1.9969713246183068478, 2.2053895545527544330, 2.4432574483385252544, E # 1.0
	], [
	# Base 3
	1, 1.1187738849693603, 1.2464963939368214, 1.38527004705667, 1.5376664685821402, 1.7068895236551784, 1.897001227148399, 2.1132403089001035, 2.362480153784171, 2.6539010333870774, 3], [
	# Base 4
	1, 1.1367350847096405, 1.2889510672956703, 1.4606478703324786, 1.6570295196661111, 1.8850062585672889, 2.1539465047453485, 2.476829779693097, 2.872061932789197, 3.3664204535587183, 4], [
	# Base 5
	1, 1.1494592900767588, 1.319708228183931, 1.5166291280087583, 1.748171114438024, 2.0253263297298045, 2.3636668498288547, 2.7858359149579424, 3.3257226212448145, 4.035730287722532, 5], [
	# Base 6
	1, 1.159225940787673, 1.343712473580932, 1.5611293155111927, 1.8221199554561318, 2.14183924486326, 2.542468319282638, 3.0574682501653316, 3.7390572020926873, 4.6719550537360774, 6], [
	# Base 7
	1, 1.1670905356972596, 1.3632807444991446, 1.5979222279405536, 1.8842640123816674, 2.2416069644878687, 2.69893426559423, 3.3012632110403577, 4.121250340630164, 5.281493033448316, 7], [
	# Base 8
	1, 1.1736630594087796, 1.379783782386201, 1.6292821855668218, 1.9378971836180754, 2.3289975651071977, 2.8384347394720835, 3.5232708454565906, 4.478242031114584, 5.868592169644505, 8], [
	# Base 9
	1, 1.1793017514670474, 1.394054150657457, 1.65664127441059, 1.985170999970283, 2.4069682290577457, 2.9647310119960752, 3.7278665320924946, 4.814462547283592, 6.436522247411611, 9], [
	# Base 10 (using http://myweb.astate.edu/wpaulsen/tetcalc/tetcalc.html )
	1, 1.1840100246247336579, 1.4061375836156954169, 1.6802272208863963918, 2.026757028388618927, 2.4770056063449647580, 3.0805252717554819987, 3.9191964192627283911, 5.1351528408331864230, 6.9899611795347148455, 10]]
var critical_slog_values = [[
	# Base 2
	-1, -0.9194161097107025, -0.8335625019330468, -0.7425599821143978, -0.6466611521029437, -0.5462617907227869, -0.4419033816638769, -0.3342645487554494, -0.224140440909962, -0.11241087890006762, 0], [
	# Base E
	-1, -0.90603157029014, -0.80786507256596, -0.7064666939634, -0.60294836853664, -0.49849837513117, -0.39430303318768, -0.29147201034755, -0.19097820800866, -0.09361896280296, 0 # 1.0
	], [
	# Base 3
	-1, -0.9021579584316141, -0.8005762598234203, -0.6964780623319391, -0.5911906810998454, -0.486050182576545, -0.3823089430815083, -0.28106046722897615, -0.1831906535795894, -0.08935809204418144, 0], [
	# Base 4
	-1, -0.8917227442365535, -0.781258746326964, -0.6705130326902455, -0.5612813129406509, -0.4551067709033134, -0.35319256652135966, -0.2563741554088552, -0.1651412821106526, -0.0796919581982668, 0], [
	# Base 5
	-1, -0.8843387974366064, -0.7678744063886243, -0.6529563724510552, -0.5415870994657841, -0.4352842206588936, -0.33504449124791424, -0.24138853420685147, -0.15445285440944467, -0.07409659641336663, 0], [
	# Base 6
	-1, -0.8786709358426346, -0.7577735191184886, -0.6399546189952064, -0.527284921869926, -0.4211627631006314, -0.3223479611761232, -0.23107655627789858, -0.1472057700818259, -0.07035171210706326, 0], [
	# Base 7
	-1, -0.8740862815291583, -0.7497032990976209, -0.6297119746181752, -0.5161838335958787, -0.41036238255751956, -0.31277212146489963, -0.2233976621705518, -0.1418697367979619, -0.06762117662323441, 0], [
	# Base 8
	-1, -0.8702632331800649, -0.7430366914122081, -0.6213373075161548, -0.5072025698095242, -0.40171437727184167, -0.30517930701410456, -0.21736343968190863, -0.137710238299109, -0.06550774483471955, 0], [
	# Base 9
	-1, -0.8670016295947213, -0.7373984232432306, -0.6143173985094293, -0.49973884395492807, -0.394584953527678, -0.2989649949848695, -0.21245647317021688, -0.13434688362382652, -0.0638072667348083, 0], [
	# Base 10
	-1, -0.8641642839543857, -0.732534623168535, -0.6083127477059322, -0.4934049257184696, -0.3885773075899922, -0.29376029055315767, -0.2083678561173622, -0.13155653399373268, -0.062401588652553186, 0]]

func _init(_sign: int, _layer: int, _mag: float):
	ssign = _sign
	layer = _layer
	mag = _mag

### MATH UTILS ###
func num_log10(input):
	return log(input) / log(10)

func num_log2(input):
	return log(input) / log(2)

func f_maglog10(n):
	return sign(n) * num_log10(abs(n))

func f_gamma(n):
	if not is_finite(n):
		return n
	if n < -50:
		if n == snappedi(n, 1):
			return -INF
		return 0
	var scal1 = 1
	while n < 10:
		scal1 = scal1 * n
		n += 1

	n -= 1
	var l = 0.9189385332046727; # 0.5*log(2*PI)
	l = l + (n + 0.5) * log(n)
	l = l - n
	var n2 = n * n
	var np = n
	l = l + 1 / (12 * np)
	np = np * n2
	l = l + 1 / (360 * np)
	np = np * n2
	l = l + 1 / (1260 * np)
	np = np * n2
	l = l + 1 / (1680 * np)
	np = np * n2
	l = l + 1 / (1188 * np)
	np = np * n2
	l = l + 691 / (360360 * np)
	np = np * n2
	l = l + 7 / (1092 * np)
	np = np * n2
	l = l + 3617 / (122400 * np)
	return exp(l) / scal1

func decimal_places(value, places):
	var length = places + 1
	var numDigits = ceil(num_log10(abs(value)))
	var rounded = round(value * pow(10, length - numDigits)) * pow(10, numDigits - length)
	return snapped(rounded, max(length - numDigits, 0))

func f_lambertw(z, tol: float = 1e-10):
	var w
	var wn
	if not is_finite(z):
		return z
	if z == 0:
		return z
	if z == 1:
		return OMEGA
	if z < 10:
		w = 0
	else:
		w = log(z) - log(log(z))

	for i in range(0, 100):
		wn = (z * exp(-w) + w * w) / (w + 1)
		if abs(wn - w) < tol * abs(wn):
			return wn;
		else:
			w = wn
	print("Iteration failed to converge: " + str(z))

func d_lambertw(z: Decimal, tol: float = 1e-10):
	var w
	var ew
	var wewz
	var wn

	if not is_finite(z.mag):
		return z
	if z.eq(from_components(0, 0, 0)):
		return z
	if z.eq(from_components(1, 0, 1)):
		#Split out this case because the asymptotic series blows up
		return from_number(OMEGA)

	#Get an initial guess for Halley's method
	w = z.ln()
	#Halley's method; see 5.9 in [1]
	for i in range(0, 100):
		ew = w.neg()._exp()
		wewz = w.subtract(z.multiply(ew));
		wn = w.sub(wewz.divide(w.add(from_number(1)).subtract(w.add(from_number(2)).multiply(wewz).divide(w.multiply(from_number(2)).add(from_number(2))))))
		if (wn.subtract(w)).abs().lt(wn.abs().multiply(tol)):
			return wn
		else:
			w = wn
	print("Iteration failed to converge: " + str(z))

### CONSTRUCTORS ###

static func from_decimal(value: Decimal):
	return Decimal.new(value.ssign, value.layer, value.mag).normalize()

static func from_components(_sign: int, _layer: int, _mag: float):
	return Decimal.new(_sign, _layer, _mag).normalize()

static func from_number(input):
	return Decimal.new(sign(input), 0, abs(input)).normalize()

static func from_string(_input: String):
	#TODO
	pass

### CONSTRUCTORS (NO NORMALIZE) ###

static func from_components_no_normalize(_sign: int, _layer: int, _mag: float):
	return Decimal.new(_sign, _layer, _mag)

static func from_number_no_normalize(input):
	return Decimal.new(sign(input), 0, abs(input))

#Normalize (Internal)
func normalize():
	#Any 0 is totally 0
	if (ssign == 0) or (mag == 0 and layer == 0) or (mag == -INF and layer > 0 and is_finite(layer)):
		ssign = 0
		mag = 0
		layer = 0
		return self
	#extract ssign from negative mag at layer 0
	if (layer == 0 and mag < 0):
		mag = - mag
		ssign = - ssign
	#Handle infinities
	if (mag == INF or layer == INF or mag == -INF or layer == -INF):
		if (ssign == 1):
			mag = INF;
			layer = int(INF);
		elif (ssign == -1):
			mag = - INF;
			layer = - int(INF);
		return self
	#Handle shifting from layer 0 to negative layers.
	if (layer == 0 and mag < FIRST_NEG_LAYER):
		layer += 1
		mag = num_log10(mag)
		return self
	var absmag = abs(mag)
	var signmag = sign(mag);
	if (absmag >= EXP_LIMIT):
		layer += 1
		mag = signmag * num_log10(absmag);
		return self
	else:
		while (absmag < LAYER_DOWN and layer > 0):
			layer -= 1
			if (layer == 0):
				mag = pow(10, mag);
			else:
				mag = signmag * pow(10, absmag);
				absmag = abs(mag);
				signmag = sign(mag);
		if (layer == 0):
			if (mag < 0):
				#extract ssign from negative mag at layer 0
				mag = - mag
				ssign = - ssign
			elif (mag == 0):
				#excessive rounding can give us all zeroes
				ssign = 0
	if (is_nan(ssign) or is_nan(layer) or is_nan(mag)):
		ssign = int(NAN)
		layer = int(NAN)
		mag = NAN

	return self

### DECONSTRUCTORS ###

func to_number():
	if (mag == INF and layer == INF and ssign == 1):
		return INF
	if (mag == -INF and layer == -INF and ssign == -1):
		return -INF
	if (!is_finite(layer)):
		return NAN
	if (layer == 0):
		return ssign * mag;
	elif (layer == 1):
		return ssign * pow(10, mag);
	#overflow for any normalized Decimal
	else:
		if (mag > 0):
			if (ssign > 0):
				return INF
			else:
				return 0
		else:
			return -INF

func _to_string():
	if is_nan(layer) or is_nan(ssign) or is_nan(mag):
		return "NaN"
	if mag == INF or layer == INF or mag == -INF or layer == -INF:
		if ssign == 1:
			return "Infinity"
		else:
			return "-Infinity"
	if layer == 0:
		if (mag < 1e21 and mag > 1e-7) or (mag == 0):
			return str(ssign * mag)
		else:
			return str("%1.2f" % get_m()) + "e" + str(get_e())
	elif (layer == 1):
		return str("%1.2f" % get_m()) + "e" + str(get_e())
	else:
		#layer 2+
		if (layer <= MAX_ES_IN_A_ROW):
			if ssign == -1:
				return "-e".repeat(layer) + str(mag)
			else:
				return "e".repeat(layer) + str(mag)
		else:
			if ssign == -1:
				return "-(e^" + str(layer) + ")" + str(mag)
			else:
				return "(e^" + str(layer) + ")" + str(mag)

func to_exponential(places: int):
	if layer == 0:
		#Not sure what to do here, just have it return to_number() for now ~MM
		#return (ssign * mag).to_exponential(places)
		return to_number()
	return to_string_with_decimal_places(places)

func to_fixed(places: int):
	if layer == 0:
		#Not sure what to do here either, just have it return snappedi(to_number(), 1) for now ~MM
		#return (ssign * mag).to_fixed(places)
		return snappedi(to_number(), 1)
	return to_string_with_decimal_places(places)

func to_precision(places: int):
	if get_e() <= -7:
		return to_exponential(places - 1);
	if places > get_e():
		return to_fixed(places - get_e() - 1);
	return to_exponential(places - 1);

func to_string_with_decimal_places(places: int):
	if layer == 0:
		if (mag < 1e21 and mag > 1e-7) or mag == 0:
			#Still don't know how to convert this here, so just return to_fixed
			#return (ssign * mag).to_fixed(places)
			return str(to_fixed(places))
		return str(decimal_places(get_m(), places)) + "e" + str(decimal_places(get_e(), places))
	elif layer == 1:
		return str(decimal_places(get_m(), places)) + "e" + str(decimal_places(get_e(), places))
	else:
		#layer 2+
		if layer <= MAX_ES_IN_A_ROW:
			if ssign == -1:
				return "-e".repeat(layer) + str(decimal_places(mag, places))
			else:
				return "e".repeat(layer) + str(decimal_places(mag, places))
		else:
			if ssign == -1:
				return "-(e^" + str(layer) + ")" + str(decimal_places(mag, places))
			else:
				return "(e^" + str(layer) + ")" + str(decimal_places(mag, places))

### MAGNITUDE/MANTISSA WITH DECIMAL PLACES ###

func mantissa_with_decimal_places(places: int):
	# https://stackoverflow.com/a/37425022
	if is_nan(get_m()):
		return NAN
	if get_m() == 0:
		return 0
	return decimal_places(get_m(), places)

func magnitude_with_decimal_places(places: int):
	# https://stackoverflow.com/a/37425022
	if is_nan(mag):
		return NAN
	if mag == 0:
		return 0
	return decimal_places(mag, places)

### HANDLE MANTISSA/EXPONENTS/POWERS OF 10 ###

func power_of_10(power):
	var powersOf10 = [];
	for i in range(NUMBER_EXP_MIN + 1, NUMBER_EXP_MAX):
		powersOf10.append(float("1e" + str(i)))
	var indexOf0InPowersOf10 = 323
	return powersOf10[power + indexOf0InPowersOf10]

func get_m():
	if (ssign == 0):
		return 0
	elif (layer == 0):
		var expnum = floor(num_log10(mag))
		#handle special case 5e-324
		var man
		if (mag == 5e-324):
			man = 5
		else:
			man = mag / power_of_10(expnum)
			return ssign * man
	elif (layer == 1):
		var residue = mag - floor(mag)
		return ssign * pow(10, residue)
	else:
		#mantissa stops being relevant past 1e9e15 / ee15.954
		return ssign

func get_e():
	if (ssign == 0):
		return 0
	elif (layer == 0):
		return floor(num_log10(mag))
	elif (layer == 1):
		return floor(mag)
	elif (layer == 2):
		return floor(sign(mag) * pow(10, abs(mag)))
	else:
		return mag * INF

### BASIC OPERATIONS ###

#Add
func add(value: Decimal):
	if not is_finite(layer):
		return self
	if not is_finite(value.layer):
		return value

	#Special case - if one of the numbers is 0, return the other number.
	if (ssign == 0):
		return value
	if (value.ssign == 0):
		return self

	#Special case - Adding a number to its negation produces 0, no matter how large.
	if (ssign == -value.ssign) and (layer == value.layer) and (mag == value.mag):
		return from_components_no_normalize(0, 0, 0)

	var a
	var b

	#Special case: If one of the numbers is layer 2 or higher, just take the bigger number.
	if (layer >= 2) or (value.layer >= 2):
		return maxabs(value)
	if (cmpabs(value) > 0):
		a = self
		b = value
	else:
		a = value
		b = self

	if (a.layer == 0 && b.layer == 0):
		return from_number(a.ssign * a.mag + b.ssign * b.mag)

	var layera = a.layer * sign(a.mag);
	var layerb = b.layer * sign(b.mag);

	#If one of the numbers is 2+ layers higher than the other, just take the bigger number.
	if (layera - layerb >= 2):
		return a
	if (layera == 0 and layerb == -1):
		if (abs(b.mag - num_log10(a.mag)) > MAX_SIGNIFICANT_DIGITS):
			return a
		else:
			var magdiff = pow(10, num_log10(a.mag) - b.mag)
			var mantissa = b.ssign + a.ssign * magdiff
			return from_components(sign(mantissa), 1, b.mag + num_log10(abs(mantissa)))

	if (layera == 1 and layerb == 0):
		if (abs(a.mag - num_log10(b.mag)) > MAX_SIGNIFICANT_DIGITS):
			return a
		else:
			var _magdiff = pow(10, a.mag - num_log10(b.mag))
			var _mantissa = b.ssign + a.ssign * _magdiff
			return from_components(sign(_mantissa), 1, num_log10(b.mag) + num_log10(abs(_mantissa)))

	if (abs(a.mag - b.mag) > MAX_SIGNIFICANT_DIGITS):
		return a
	else:
		var _magdiff2 = pow(10, a.mag - b.mag)
		var _mantissa2 = b.ssign + a.ssign * _magdiff2
		return from_components(sign(_mantissa2), 1, b.mag + num_log10(abs(_mantissa2)))

#Subtract
func subtract(value: Decimal):
	return add(value.neg())

#Multiply
func multiply(value: Decimal):
	#inf/nan check
	if not is_finite(layer):
		return self
	if not is_finite(value.layer):
		return value

	#Special case - if one of the numbers is 0, return 0.
	if ssign == 0 or value.ssign == 0:
		return from_components_no_normalize(0, 0, 0)

	#Special case - Multiplying a number by its own reciprocal yields +/- 1, no matter how large.
	if (layer == value.layer) and (mag == -value.mag):
		return from_components_no_normalize(ssign * value.ssign, 0, 1)

	var a
	var b

	#Which number is bigger in terms of its multiplicative distance from 1?
	if (layer > value.layer) or ((layer == value.layer) and (abs(mag) > abs(value.mag))):
		a = self
		b = value
	else:
		a = value
		b = self

	if a.layer == 0 and b.layer == 0:
		return from_number(a.ssign * b.ssign * a.mag * b.mag)

	#Special case: If one of the numbers is layer 3 or higher or one of the numbers is 2+ layers bigger than the other, just take the bigger number.
	if a.layer >= 3 or (a.layer - b.layer >= 2):
		return from_components(a.ssign * b.ssign, a.layer, a.mag)
	if a.layer == 1 and b.layer == 0:
		return from_components(a.ssign * b.ssign, 1, a.mag + num_log10(b.mag))
	if a.layer == 1 and b.layer == 1:
		return from_components(a.ssign * b.ssign, 1, a.mag + b.mag)
	if a.layer == 2 and b.layer == 1:
		var newmag = from_components(sign(a.mag), a.layer - 1, abs(a.mag)).add(from_components(sign(b.mag), b.layer - 1, abs(b.mag)));
		return from_components(a.ssign * b.ssign, newmag.layer + 1, newmag.ssign * newmag.mag)
	if a.layer == 2 and b.layer == 2:
		var _newmag = from_components(sign(a.mag), a.layer - 1, abs(a.mag)).add(from_components(sign(b.mag), b.layer - 1, abs(b.mag)));
		return from_components(a.ssign * b.ssign, _newmag.layer + 1, _newmag.ssign * _newmag.mag)
	else:
		print("Bad arguments to multiply: " + str(self) + ", " + str(value))
		return self

#Divide
func divide(value: Decimal):
	return multiply(value.recip())

#Mod
func mod(value: Decimal):
	if value.eq(from_components(0, 0, 0)):
		return from_components(0, 0, 0)

	var num_this = self.to_number()
	var num_decimal = value.to_number()
	#Special case: To avoid precision issues, if both numbers are valid JS numbers, just call % on those
	if is_finite(num_this) and is_finite(num_decimal) and (not num_this == 0) and (not num_decimal == 0):
		return from_number(int(num_this) % int(num_decimal))
	if (self.subtract(value).eq(self)):
		#decimal is too small to register to this
		return from_components(0, 0, 0)
	if (value.subtract(self).eq(value)):
		#this is too small to register to decimal
		return self
	if ssign == -1:
		return _abs().mod(value).neg()

	return subtract(divide(value).floor().multiply(value))

### NUMBER MODIFICATIONS ###

#Reciprocal
func recip():
	if mag == 0:
		return from_components(0, 0, NAN)
	elif layer == 0:
		return from_components(ssign, 0, 1 / mag)
	else:
		return from_components(ssign, layer, -mag);

#Negate
func neg():
	return from_components_no_normalize(-ssign, layer, mag)

#Abs
func _abs():
	return from_components_no_normalize(abs(ssign), layer, mag)

#Max
func _max(value: Decimal):
	if lt(value):
		return value
	else:
		return self

#Min
func _min(value: Decimal):
	if gt(value):
		return value
	else:
		return self

#Max Abs
func maxabs(value: Decimal):
	if cmpabs(value) < 0:
		return value
	else:
		return self

#Min Abs
func minabs(value: Decimal):
	if cmpabs(value) > 0:
		return value
	else:
		return self

#Clamp
func _clamp(minD: Decimal, maxD: Decimal):
	return _max(minD)._min(maxD)

#Clamp Min
func clamp_min(minD: Decimal):
	return _max(minD)

#Clamp Max
func clamp_max(maxD: Decimal):
	return _min(maxD)

#Round
func _round():
	if (mag < 0):
		return from_number(0)
	if (layer == 0):
		return from_components(ssign, 0, round(mag))
	return self

#Floor
func _floor():
	if (mag < 0):
		if (ssign == -1):
			return from_number(-1)
		else:
			return from_number(0)
	if (ssign == -1):
		var a = self.neg()
		var b = a._ceil()
		return b.neg()
	if (layer == 0):
		return from_components(ssign, 0, floor(mag));
	return self

#Ceiling
func _ceil():
	if (mag < 0):
		if (ssign == 1):
			return from_number(1) # The ceiling function called on something tiny like 10^10^-100 should return 1, since 10^10^-100 is still greater than 0
		else:
			return from_number(0)
	if (ssign == -1):
		var a = self.neg()
		var b = a._floor()
		return b.neg()
	if (layer == 0):
		return from_components(ssign, 0, ceil(mag))
	return self

#Truncate
func trunc():
	if (mag < 0):
		return from_number(0);
	if (layer == 0):
		return from_components(ssign, 0, snappedi(mag, 1))
	return self

#Square
func sqr():
	return _pow(from_number(2))

#Square Root
func _sqrt():
	if layer == 0:
		return from_number(sqrt(ssign * mag))
	elif layer == 1:
		return from_components(1, 2, num_log10(mag) - 0.3010299956639812)
	else:
		var result = from_components_no_normalize(ssign, layer - 1, mag).divide(from_components_no_normalize(1, 0, 2))
		result.layer += 1
		result.normalize()
		return result

#Cube
func cube():
	return _pow(from_number(3))

#Cubed Root
func cbrt():
	return _pow(from_number(1.0 / 3.0))

### ADVANCED NUMBER MODIFIERS ###

#Positive Log10
func p_log10():
	if lt(from_components(0, 0, 0)):
		return from_components(0, 0, 0)
	return log10()

#Abs Log10
func abs_log10():
	if ssign == 0:
		return from_components(0, 0, NAN)
	elif layer > 0:
		return from_components(sign(mag), layer - 1, abs(mag))
	else:
		return from_components(1, 0, num_log10(mag))

#Log10
func log10():
	if ssign <= 0:
		return from_components(0, 0, NAN)
	elif layer > 0:
		return from_components(sign(mag), layer - 1, abs(mag))
	else:
		return from_components(ssign, 0, num_log10(mag))

#Log
func _log(base: Decimal):
	if ssign <= 0:
		return from_components(0, 0, NAN)
	if base.ssign <= 0:
		return from_components(0, 0, NAN)
	if base.ssign == 1 and base.layer == 0 and base.mag == 1:
		return from_components(0, 0, NAN)
	elif layer == 0 and base.layer == 0:
		return from_components(ssign, 0, log(mag) / log(base.mag));
	return log10().divide(base._log10())

#Log2
func log2():
	if ssign <= 0:
		return from_components(0, 0, NAN)
	elif layer == 0:
		return from_components(ssign, 0, num_log2(mag))
	elif layer == 1:
		return from_components(sign(mag), 0, abs(mag) * 3.321928094887362) # log2(10)
	elif layer == 2:
		return from_components(sign(mag), 1, abs(mag) + 0.5213902276543247) # -log10(log10(2))
	else:
		return from_components(sign(mag), layer - 1, abs(mag))

#Natural Log
func ln():
	if ssign <= 0:
		return from_components(0, 0, NAN)
	elif layer == 0:
		return from_components(ssign, 0, log(mag))
	elif layer == 1:
		return from_components(sign(mag), 0, abs(mag) * 2.302585092994046) # ln(10)
	elif layer == 2:
		return from_components(sign(mag), 1, abs(mag) + 0.36221568869946325) # log10(log10(e))
	else:
		return from_components(sign(mag), layer - 1, abs(mag))

#Power
func _pow(value: Decimal):
	var a = self
	var b = value

	#special case: if a is 0, then return 0 (UNLESS b is 0, then return 1)
	if a.ssign == 0:
		if b.eq(from_number(0)):
			return from_components_no_normalize(1, 0, 1)
		else:
			return a

	#special case: if a is 1, then return 1
	if a.ssign == 1 and a.layer == 0 and a.mag == 1:
		return a

	#special case: if b is 0, then return 1
	if b.ssign == 0:
		return from_components_no_normalize(1, 0, 1)

	#special case: if b is 1, then return a
	if b.ssign == 1 and b.layer == 0 and b.mag == 1:
		return a

	var result = a.abs_log10().multiply(b).pow10()

	if ssign == -1:
		if abs(b.to_number() % 2) % 2 == 1:
			return result.neg()
		elif abs(b.to_number() % 2) % 2 == 0:
			return result
		return from_components(0, 0, NAN)

	return result

#10 to the Power of N
func pow10():
	#There are four cases we need to consider:
	#1) positive ssign, positive mag (e15, ee15): +1 layer (e.g. 10^15 becomes e15, 10^e15 becomes ee15)
	#2) negative ssign, positive mag (-e15, -ee15): +1 layer but ssign and mag ssign are flipped (e.g. 10^-15 becomes e-15, 10^-e15 becomes ee-15)
	#3) positive ssign, negative mag (e-15, ee-15): layer 0 case would have been handled in the Math.pow check, so just return 1
	#4) negative ssign, negative mag (-e-15, -ee-15): layer 0 case would have been handled in the Math.pow check, so just return 1
	if (not is_finite(layer)) or (not is_finite(mag)):
		return from_components(0, 0, NAN)

	var a = self
	#handle layer 0 case - if no precision is lost just use Math.pow, else promote one layer
	if a.layer == 0:
		var newmag = pow(10, a.ssign * a.mag)
		if is_finite(newmag) and abs(newmag) >= 0.1:
			return from_components(1, 0, newmag)
		else:
			if a.ssign == 0:
				return from_components(1, 0, 1)
			else:
				a = from_components_no_normalize(a.ssign, a.layer + 1, num_log10(a.mag))

	#handle all 4 layer 1+ cases individually
	if a.ssign > 0 and a.mag >= 0:
		return from_components(a.ssign, a.layer + 1, a.mag)
	if a.ssign < 0 and a.mag >= 0:
		return from_components(-a.ssign, a.layer + 1, -a.mag)

	#both the negative mag cases are identical: one +/- rounding error
	return from_components(1, 0, 1)

#Power Base
func pow_base(value: Decimal):
	return value.pow(self)

#Root
func root(value: Decimal):
	return _pow(value.recip())

#Factorial
func factorial():
	if mag < 0:
		return add(from_number(1)).gamma()
	elif layer == 0:
		return add(from_number(1)).gamma()
	elif layer == 1:
		return (multiply(ln().sub(from_number(1))))._exp()
	else:
		return _exp()

#Gamma
func gamma():
	if mag < 0:
		return recip()
	elif layer == 0:
		if lt(from_components_no_normalize(1, 0, 24)):
			return from_number(f_gamma(ssign * mag))

		var t = mag - 1
		var l = 0.9189385332046727 # 0.5*Math.log(2*Math.PI)
		l = l + (t + 0.5) * log(t)
		l = l - t
		var n2 = t * t
		var np = t
		var lm = 12 * np
		var adj = 1 / lm
		var l2 = l + adj
		if l2 == l:
			return from_number_no_normalize(l)._exp()
		l = l2
		np = np * n2
		lm = 360 * np
		adj = 1 / lm
		l2 = l - adj
		if l2 == l:
			return from_number_no_normalize(l)._exp()
		l = l2
		np = np * n2
		lm = 1260 * np
		var lt_v = 1 / lm
		l = l + lt_v
		np = np * n2
		lm = 1680 * np
		lt_v = 1 / lm
		l = l - lt_v
		return l._exp()
	elif layer == 1:
		return (multiply(ln().subtract(from_number(1))))._exp()
	else:
		return _exp()

#Natural Log of Gamma
func lngamma():
	return gamma().ln()

#Exp
func _exp():
	if mag < 0:
		return from_components(1, 0, 1)
	if layer == 0 and mag <= 709.7:
		return from_number(exp(ssign * mag))
	elif layer == 0:
		return from_components(1, 1, ssign * num_log10(E) * mag)
	elif layer == 1:
		return from_components(1, 2, ssign * (num_log10(0.4342944819032518) + mag))
	else:
		return from_components(1, layer + 1, ssign * mag)

#Layer Add 10
func layer_add_10(diff: Decimal, linear: bool = false):
	var _diff = diff.to_number()
	var result = from_decimal(self)
	if _diff >= 1:
		#bug fix: if result is very smol (mag < 0, layer > 0) turn it into 0 first
		if result.mag < 0 and result.layer > 0:
			result.ssign = 0
			result.mag = 0
			result.layer = 0
		elif result.ssign == -1 and result.layer == 0:
			#bug fix - for stuff like -3.layeradd10(1) we need to move the ssign to the mag
			result.ssign = 1
			result.mag = - result.mag
		var layeradd = snappedi(_diff, 1)
		diff -= layeradd
		result.layer += layeradd
	if _diff <= -1:
		var _layeradd = snappedi(_diff, 1);
		diff -= _layeradd
		result.layer += _layeradd
		if result.layer < 0:
			for i in range(0, 100):
				result.layer += 1
				result.mag = num_log10(result.mag)
				if not is_finite(result.mag):
					#another bugfix: if we hit -Infinity mag, then we should return negative infinity, not 0. 0.layeradd10(-1) h its this
					if result.ssign == 0:
						result.ssign = 1
					#also this, for 0.layeradd10(-2)
					if result.layer < 0:
						result.layer = 0

					return result.normalize();
				if result.layer >= 0:
					break
	while result.layer < 0:
		result.layer += 1
		result.mag = num_log10(result.mag)
	#bugfix: before we normalize: if we started with 0, we now need to manually fix a layer ourselves!
	if result.ssign == 0:
		result.ssign = 1
	if result.mag == 0 and result.layer >= 1:
		result.layer -= 1
		result.mag = 1
	result.normalize()
	#layeradd10: like adding 'diff' to the number's slog(base) representation. Very similar to tetrate base 10 and iterated log base 10. Also equivalent to adding a fractional amount to the number's layer in its break_eternity.js representation.
	if not _diff == 0:
		return result.layer_add(_diff, 10, linear) # safe, only calls positive height 1 payload tetration, slog and log

	return result

#Layer Add
func layer_add(diff: int, base: int, linear: bool = false):
	var slogthis = slog(base).to_number()
	var slogdest = slogthis + diff
	if slogdest >= 0:
		return from_components(1, 0, 1).tetrate(slogdest, base, linear)
	elif not is_finite(slogdest):
		return from_components(0, 0, NAN)
	elif slogdest >= -1:
		return (from_components(1, 0, 1).tetrate(slogdest + 1, base, linear))._log(from_number(base))
	else:
		return ((from_components(1, 0, 1).tetrate(slogdest + 2, base, linear))._log(from_number(base)))._log(from_number(base))

### ITERATED FUNCTIONS ###

#Tetrate
func tetrate(height: int = 2, payload: Decimal = from_components_no_normalize(1, 0, 1), linear: bool = false):
	#x^^1 == x
	if height == 1:
		return _pow(payload)

	#x^^0 == 1
	if height == 0:
		return payload

	#1^^x == 1
	if eq(from_components(1, 0, 1)):
		return from_components(1, 0, 1)

	#-1^^x == -1
	if eq(from_number(-1)):
		return _pow(payload)

	if height == INF:
		var this_num = to_number();
		#within the convergence range?
		if this_num <= 1.44466786100976613366 and this_num >= 0.06598803584531253708:
			#hotfix for the very edge of the number range not being handled properly
			if this_num > 1.444667861009099:
				return from_number(E)

			#Formula for infinite height power tower.
			var negln = ln().neg()
			return negln.lambertw().divide(negln)

		elif this_num > 1.44466786100976613366:
			#explodes to infinity
			return from_number(INF)
		else:
			#0.06598803584531253708 > this_num >= 0: never converges
			#this_num < 0: quickly becomes a complex number
			return from_components(0, 0, NAN)

	#0^^x oscillates if we define 0^0 == 1 (which in javascript land we do), since then 0^^1 is 0, 0^^2 is 1, 0^^3 is 0, etc. payload is ignored
	#using the linear approximation for height (TODO: don't know a better way to calculate it ATM, but it wouldn't surprise me if it's just NaN)
	if eq(from_components(0, 0, 0)):
		var result = abs((height + 1) % 2)
		if result > 1:
			result = 2 - result
			return from_number(result)

	if height < 0:
		return iterated_log(payload.to_number(), -height, linear)
	var oldheight = height
	height = snappedi(height, 1)
	var fracheight = oldheight - height
	if gt(from_components(0, 0, 0)) and lte(from_number_no_normalize(1.44466786100976613366)) and (oldheight > 10000 or not linear):
		#similar to 0^^n, flip-flops between two values, converging slowly (or if it's below 0.06598803584531253708, never. so once again, the fractional part at the end will be a linear approximation (TODO: again pending knowledge of how to approximate better, although tbh I think it should in reality just be NaN)
		height = min(10000, height);
		for i in range(0, height - 1):
			var old_payload = payload
			payload = _pow(payload)
			#stop early if we converge
			if old_payload.eq(payload):
				return payload
		if (not fracheight == 0) or (oldheight > 10000):
			var next_payload = _pow(payload)
			if (oldheight <= 10000) or (ceil(oldheight) % 2 == 0):
				return payload.multiply(1 - fracheight).add(next_payload.multiply(fracheight))
			else:
				return payload.multiply(fracheight).add(next_payload.multiply(1 - fracheight))
		return payload
	#TODO: base < 0, but it's hard for me to reason about (probably all non-integer heights are NaN automatically?)
	if not fracheight == 0:
		if payload.eq(from_components(1, 0, 1)):
			#If (linear), use linear approximation even for bases <= 10
			#TODO: for bases above 10, revert to old linear approximation until I can think of something better
			if gt(from_number(10)) or linear:
				payload = _pow(fracheight)
			else:
				payload = from_number(tetrate_critical(to_number(), fracheight))
				#TODO: until the critical section grid can handle numbers below 2, scale them to the base
				#TODO: maybe once the critical section grid has very large bases, this math can be appropriate for them too? I'll think about it
				if lt(from_number(2)):
					payload = payload.subtract(from_number(1)).multiply(subtract(from_number(1))).plus(from_number(1))
		else:
			if eq(from_number(10)):
				payload = payload.layer_add_10(fracheight, linear)
			else:
				payload = payload.layer_add(fracheight, to_number(), linear)
	for i in range(0, height - 1):
		payload = _pow(payload)
		#bail if we're NaN
		if not (is_finite(payload.layer) or is_finite(payload.mag)):
			return payload.normalize()
		#shortcut
		if payload.layer - layer > 3:
			return from_components_no_normalize(payload.ssign, payload.layer + (height - i - 1), payload.mag)
		#give up after 10000 iterations if nothing is happening
		if i > 10000:
			return payload
	return payload

#Iterated Exp
func iterated_exp(height: int = 2, payload: Decimal = from_components_no_normalize(1, 0, 1), linear: bool = false):
	return tetrate(height, payload, linear)

#Iterated Log
func iterated_log(base: Decimal = from_number(10), times: int = 1, linear: bool = false):
	if times < 0:
		return tetrate(base.to_number(), from_number(-times), linear)
	var result = from_decimal(self)
	var fulltimes = times
	times = snappedi(times, 1)
	var fraction = fulltimes - times
	if result.layer - base.layer > 3:
		var layerloss = min(times, result.layer - base.layer - 3)
		times -= layerloss
		result.layer -= layerloss
	for i in range(0, times - 1):
		result = result.log(base);
		#bail if we're NaN
		if not (is_finite(result.layer) or is_finite(result.mag)):
			return result.normalize()
		#give up after 10000 iterations if nothing is happening
		if i > 10000:
			return result
	#handle fractional part
	if fraction > 0 and fraction < 1:
		if base.eq(from_number(10)):
			result = result.layer_add_10(from_number(-fraction), linear)
		else:
			result = result.layer_add(from_number(-fraction), base.to_number(), linear)
	return result

#Super Log
func slog(base: int = 10, iterations: int = 100, linear: bool = false):
	var step_size = 0.001
	var has_changed_directions_once = false
	var previously_rose = false
	var result = slog_internal(from_number(base), linear).to_number()
	for i in range(1, iterations - 1):
		var new_decimal = from_number(base).tetrate(result, from_number(1), linear)
		var currently_rose = new_decimal.gt(self)
		if i > 1:
			if not previously_rose == currently_rose:
				has_changed_directions_once = true
		previously_rose = currently_rose
		if has_changed_directions_once:
			step_size /= 2
		else:
			step_size *= 2
		if currently_rose:
			step_size = abs(step_size) * -1
		else:
			step_size = abs(step_size) * 1
		result += step_size
		if step_size == 0:
			break
	return from_number(result)

#Super Log (Internal)
func slog_internal(base: Decimal = from_number(10), linear: bool = false):
	#special cases:
	#slog base 0 or lower is NaN
	if base.lte(from_components(0, 0, 0)):
		return from_components(int(NAN), int(NAN), int(NAN))
	#slog base 1 is NaN
	if base.eq(from_components(1, 0, 1)):
		return from_components(int(NAN), int(NAN), int(NAN))
	#need to handle these small, wobbling bases specially
	if base.lt(from_components(1, 0, 1)):
		if eq(from_components(1, 0, 1)):
			return from_components(0, 0, 0)
		if eq(from_components(0, 0, 0)):
			return from_components(-1, 0, 1)
		#0 < this < 1: ambiguous (happens multiple times)
		#this < 0: impossible (as far as I can tell)
		#this > 1: partially complex (http://myweb.astate.edu/wpaulsen/tetcalc/tetcalc.html base 0.25 for proof)
		return from_components(int(NAN), int(NAN), int(NAN))
	#slog_n(0) is -1
	if mag < 0 or eq(from_components(0, 0, 0)):
		return from_components(-1, 0, 1)
	var result = 0;
	var copy = from_decimal(self)
	if copy.layer - base.layer > 3:
		var layerloss = copy.layer - base.layer - 3
		result += layerloss
		copy.layer -= layerloss
	for i in range(0, 100):
		if copy.lt(from_components(0, 0, 0)):
			copy = copy._pow(base)
			result -= 1
		elif copy.lte(from_components(1, 0, 1)):
			if linear:
				return from_number(result + copy.to_number() - 1)
			else:
				return from_number(result + slog_critical(base.to_number(), copy.to_number()))
		else:
			result += 1
			copy = copy._log(base)
	return from_number(result)

#Lambert's W Function
func lambert_w():
	if lt(from_number_no_normalize(-0.3678794411710499)):
		print("lambertw is unimplemented for results less than -1, sorry!")
	elif mag < 0:
		return from_number(f_lambertw(to_number()))
	elif layer == 0:
		return from_number(f_lambertw(ssign * mag))
	elif layer == 1:
		return d_lambertw(self)
	elif layer == 2:
		return d_lambertw(self)

	if layer >= 3:
		return from_components_no_normalize(ssign, layer - 1, mag)

	print("Unhandled behavior in lambert_w()")

#Super Square Root
func ssqrt():
	return linear_sroot(2)

#(Linear) Super Root
func linear_sroot(degree: int):
	#1st-degree super root just returns its input
	if degree == 1:
		return self
	if eq(from_components(int(INF), int(INF), int(INF))):
		return from_components(int(INF), int(INF), int(INF))
	if not _is_finite():
		return from_components(int(NAN), int(NAN), int(NAN))
	#Using linear approximation, x^^n = x^n if 0 < n < 1
	if degree > 0 and degree < 1:
		return root(from_number(degree))
	#Using the linear approximation, there actually is a single solution for super roots with -2 < degree <= -1
	if degree > -2 and degree < -1:
		return from_number(degree).add(from_number(2))._pow(recip())
	#Super roots with -1 <= degree < 0 have either no solution or infinitely many solutions, and tetration with height <= -2 returns NaN, so super roots of degree <= -2 don't work
	if degree <= 0:
		return from_components(int(NAN), int(NAN), int(NAN))
	#Infinite degree super-root is x^(1/x) between 1/e <= x <= e, undefined otherwise
	if degree == INF:
		var this_num = to_number();
		if this_num < E and this_num > _EXPN1:
			return _pow(recip())
		else:
			return from_components(int(NAN), int(NAN), int(NAN))
	#Special case: any super-root of 1 is 1
	if eq(from_number(1)):
		return from_components(1, 0, 1)
	#TODO: base < 0 (It'll probably be NaN anyway)
	if lt(from_number(0)):
		return from_components(int(NAN), int(NAN), int(NAN))
	#Treat all numbers of layer <= -2 as zero, because they effectively are
	if lte(from_components(1, -2, -16)): # 1ee-16
		if degree % 2 == 1:
			return self
		else:
			return from_components(int(NAN), int(NAN), int(NAN))
	#this > 1
	if gt(from_number(1)):
		#Uses guess-and-check to find the super-root.
		#If this > 10^^(degree), then the answer is under iteratedlog(10, degree - 1): for example, ssqrt(x) < log(x, 10) as long as x > 10^10, and linear_sroot(x, 3) < log(log(x, 10), 10) as long as x > 10^10^10
		#On the other hand, if this < 10^^(degree), then clearly the answer is less than 10
		#Since the answer could be a higher-layered number itself (whereas slog's maximum is 1.8e308), the guess-and-check is scaled to the layer of the upper bound, so the guess is set to the average of some higher-layer exponents of the bounds rather than the bounds itself (as taking plain averages on tetrational-scale numbers would go nowhere)
		var upperBound = from_components(1, 0, 10)
		if gte(from_number(degree).tetrate(10, from_number(1), true)):
			upperBound = iterated_log(from_number(10), degree - 1, true)
		if degree <= 1:
			upperBound = root(from_number(degree))
		var lower = from_components(0, 0, 0) # This is zero rather than one because we might be on a higher layer, so the lower bound might actually some 10^10^10...^0
		var _layer = upperBound.layer
		var upper = upperBound.iteratedlog(10, _layer, true)
		var previous = upper
		var guess = upper.divide(from_number(2))
		var loopGoing = true
		while loopGoing:
			guess = lower.add(upper).divide(from_number(2))
			if _layer.iterated_exp(10, guess, true).tetrate(degree, from_number(1), true).gt(self):
				upper = guess
			else:
				lower = guess
			if guess.eq(previous):
				loopGoing = false
			else:
				previous = guess
		return _layer.iterated_exp(10, guess, true)
	#0 < this < 1
	else:
		#A tetration of decimal degree can potentially have three different portions, as shown at https://www.desmos.com/calculator/ayvqks6mxa, which is a graph of x^^2.05:
		#The portion where the function is increasing, extending from a minimum (which may be at x = 0 or at some x between 0 and 1) up to infinity (I'll call this the "increasing" range)
		#The portion where the function is decreasing (I'll call this the "decreasing" range)
		#A small, steep increasing portion very close to x = 0 (I'll call this the "zero" range)
		#If ceiling(degree) is even, then the tetration will either be strictly increasing, or it will have the increasing and decreasing ranges, but not the zero range (because if ceiling(degree) is even, 0^^degree == 1).
		#If ceiling(degree) is odd, then the tetration will either be strictly increasing, or it will have all three ranges (because if ceiling(degree) is odd, 0^^degree == 0).
		#The existence of these ranges means that a super-root could potentially have two or three valid answers.
		#Out of these, we'd prefer the increasing range value if it exists, otherwise we'll take the zero range value (it can't have a decreasing range value if it doesn't have an increasing range value) if the zero range exists.
		#It's possible to identify which range that "this" is in:
		#If the tetration is decreasing at that point, the point is in the decreasing range.
		#If the tetration is increasing at that point and ceiling(degree) is even, the point is in the increasing range since there is no zero range.
		#If the tetration is increasing at that point and ceiling(degree) is odd, look at the second derivative at that point. If the second derivative is positive, the point is in the increasing range. If the second derivative is negative, the point is the zero range.
		#We need to find the local minimum (separates decreasing and increasing ranges) and the local maximum (separates zero and decreasing ranges).
		#(stage) is which stage of the loop we're in: stage 1 is finding the minimum, stage 2 means we're between the stages, and stage 3 is finding the maximum.
		#The boundary between the decreasing range and the zero range can be very small, so we want to use layer -1 numbers. Therefore, all numbers involved are log10(recip()) of their actual values.
		var stage = 1
		var minimum = from_components(1, 10, 1)
		var maximum = from_components(1, 10, 1)
		var _lower = from_components(1, 10, 1) # eeeeeeeee-10, which is effectively 0; I would use Decimal.dInf but its reciprocal is NaN
		var _upper = from_components(1, 1, -16) # ~ 1 - 1e-16
		var prevspan = from_components(0, 0, 0)
		var difference = from_components(1, 10, 1)
		var _upperBound = _upper.pow10().recip()
		var distance = from_components(0, 0, 0)
		var prevPoint = _upperBound
		var nextPoint = _upperBound
		var evenDegree = ceil(degree) % 2 == 0
		var rangeD = 0
		var lastValid = from_components(1, 10, 1)
		var infLoopDetector = false
		var previousUpper = from_components(0, 0, 0)
		var decreasingFound = false
		while stage < 4:
			if stage == 2:
				#The minimum has been found. If ceiling(degree) is even, there's no zero range and thus no local maximum, so end the loop here. Otherwise, begin finding the maximum.
				if evenDegree:
					break
				else:
					_lower = from_components(1, 10, 1)
					_upper = minimum
					stage = 3
					difference = from_components(1, 10, 1)
					lastValid = from_components(1, 10, 1)
			infLoopDetector = false
			while _upper.neq(_lower):
				previousUpper = _upper
				if _upper.pow10().recip().tetrate(degree, from_number(1), true).eq(from_number(1)) and _upper.pow10().recip().lt(from_number(0.4)):
					_upperBound = _upper.pow10().recip()
					prevPoint = _upper.pow10().recip()
					nextPoint = _upper.pow10().recip()
					distance = from_components(0, 0, 0)
					rangeD = -1 # This would cause problems with degree < 1 in the linear approximation... but those are already covered as a special case
					if stage == 3:
						lastValid = _upper
				elif _upper.pow10().recip().tetrate(degree, from_number(1), true).eq(_upper.pow10().recip()) and (not evenDegree) and _upper.pow10().recip().lt(from_number(0.4)):
					_upperBound = _upper.pow10().recip()
					prevPoint = _upper.pow10().recip();
					nextPoint = _upper.pow10().recip()
					distance = from_components(0, 0, 0)
					rangeD = 0
				elif _upper.pow10().recip().tetrate(degree, from_number(1), true).eq(_upper.pow10().recip().multiply(from_number(2)).tetrate(degree, from_number(1), true)):
					#If the upper bound is closer to zero than the next point with a discernable tetration, so surely it's in whichever range is closest to zero?
					#This won't happen in a strictly increasing tetration, as there x^^degree ~= x as x approaches zero
					_upperBound = _upper.pow10().recip()
					prevPoint = from_components(0, 0, 0)
					nextPoint = _upperBound.multiply(from_number(2))
					distance = _upperBound
					if evenDegree:
						rangeD = -1
					else:
						rangeD = 0
				else:
					#We want to use prevspan to find the "previous point" right before the upper bound and the "next point" right after the upper bound, as that will let us approximate derivatives
					prevspan = _upper.multiply(from_number(1.2e-16))
					_upperBound = _upper.pow10().recip()
					prevPoint = _upper.add(prevspan).pow10().recip()
					distance = _upperBound.subtract(prevPoint)
					nextPoint = _upperBound.add(distance)
					#...but it's of no use to us while its tetration is equal to upper's tetration, so widen the difference until it's not
					#We add prevspan and subtract nextspan because, since upper is log10(recip(upper bound)), the upper bound gets smaller as upper gets larger and vice versa
					while prevPoint.tetrate(degree, from_number(1), true).eq(_upperBound.tetrate(degree, from_number(1), true)) or nextPoint.tetrate(degree, from_number(1), true).eq(_upperBound.tetrate(degree, from_number(1), true)) or prevPoint.gte(_upperBound) or nextPoint.lte(_upperBound):
						prevspan = prevspan.multiply(from_number(2))
						prevPoint = _upper.add(prevspan).pow10().recip()
						distance = _upperBound.subtract(prevPoint)
						nextPoint = _upperBound.add(distance)
					if stage == 1 and nextPoint.tetrate(degree, from_number(1), true).gt(_upperBound.tetrate(degree, from_number(1), true)) and prevPoint.tetrate(degree, from_number(1), true).gt(_upperBound.tetrate(degree, from_number(1), true)) or stage == 3 and nextPoint.tetrate(degree, 1, true).lt(_upperBound.tetrate(degree, from_number(1), true)) and prevPoint.tetrate(degree, from_number(1), true).lt(_upperBound.tetrate(degree, from_number(1), true)):
						lastValid = _upper
					if nextPoint.tetrate(degree, from_number(1), true).lt(_upperBound.tetrate(degree, from_number(1), true)):
						#Derivative is negative, so we're in decreasing range
						rangeD = -1
					elif evenDegree:
						#No zero range, so we're in increasing range
						rangeD = 1
					elif stage == 3 and _upper.gt_tolerance(minimum, 1e-8):
						#We're already below the minimum, so we can't be in range 1
						rangeD = 0
					else:
						#Number imprecision has left the second derivative somewhat untrustworthy, so we need to expand the bounds to ensure it's correct
						while prevPoint.tetrate(degree, from_number(1), true).eq_tolerance(_upperBound.tetrate(degree, from_number(1), true), 1e-8) or nextPoint.tetrate(degree, from_number(1), true).eq_tolerance(_upperBound.tetrate(degree, from_number(1), true), 1e-8) or prevPoint.gte(_upperBound) or nextPoint.lte(_upperBound):
							prevspan = prevspan.multiply(from_number(2))
							prevPoint = _upper.add(prevspan).pow10().recip()
							distance = _upperBound.subtract(prevPoint)
							nextPoint = _upperBound.add(distance)
						if nextPoint.tetrate(degree, from_number(1), true).subtract(_upperBound.tetrate(degree, from_number(1), true)).lt(_upperBound.tetrate(degree, from_number(1), true).sub(prevPoint.tetrate(degree, from_number(1), true))):
							#Second derivative is negative, so we're in zero range
							rangeD = 0
						else:
							#By process of elimination, we're in increasing range
							rangeD = 1
				if rangeD == -1:
					decreasingFound = true
				if stage == 1 and rangeD == 1 or stage == 3 and (not rangeD == 0):
					#The upper bound is too high
					if _lower.eq(from_components(1, 10, 1)):
						_upper = _upper.multiply(from_number(2))
					else:
						var cutOff = false;
						if infLoopDetector and (rangeD == 1 and stage == 1 or rangeD == -1 and stage == 3):
							cutOff = true # Avoids infinite loops from floating point imprecision
						_upper = _upper.add(_lower).divide(from_number(2))
						if cutOff:
							break
				else:
					if _lower.eq(from_components(1, 10, 1)):
						#We've now found an actual lower bound
						_lower = _upper
						_upper = _upper.divide(from_number(2))
					else:
						#The upper bound is too low, meaning last time we decreased the upper bound, we should have gone to the other half of the new range instead
						var _cutOff = false;
						if infLoopDetector and (rangeD == 1 and stage == 1 or rangeD == -1 and stage == 3):
							_cutOff = true # Avoids infinite loops from floating point imprecision
						_lower = _lower.subtract(difference)
						_upper = _upper.subtract(difference)
						if _cutOff:
							break
				if _lower.subtract(_upper).divide(from_number(2))._abs().gt(difference.multiply(from_number(1.5))):
					infLoopDetector = true
				difference = _lower.subtract(_upper).divide(from_number(2))._abs()
				if _upper.gt(from_number(1e18)):
					break
				if (_upper.eq(previousUpper)):
					break # Another infinite loop catcher

				if _upper.gt(from_number(1e18)):
					break
				if not decreasingFound:
					break # If there's no decreasing range, then even if an error caused lastValid to gain a value, the minimum can't exist
				if lastValid == from_components(1, 10, 1):
					#Whatever we're searching for, it doesn't exist. If there's no minimum, then there's no maximum either, so either way we can end the loop here.
					break
				if stage == 1:
					minimum = lastValid
				elif stage == 3:
					maximum = lastValid
				stage += 1
			#Now we have the minimum and maximum, so it's time to calculate the actual super-root.
			#First, check if the root is in the increasing range.
			_lower = minimum;
			_upper = from_components(1, 1, -18)
			var _previous = _upper
			var _guess = from_components(0, 0, 0)
			var _loopGoing = true
			while _loopGoing:
				if _lower.eq(from_components(1, 10, 1)):
					_guess = _upper.multiply(from_number(2))
				else:
					_guess = _lower.add(_upper).div(2)
				if _guess._pow(from_number(10)).recip().tetrate(degree, from_number(1), true).gt(self):
					_upper = _guess
				else:
					_lower = _guess
				if _guess.eq(_previous):
					_loopGoing = false
				else:
					_previous = _guess
				if _upper.gt(from_number(1e18)):
					return from_components(int(NAN), int(NAN), int(NAN))
			#using guess.neq(minimum) led to imprecision errors, so here's a fixed version of that
			if not _guess.eq_tolerance(minimum, 1e-15):
				return _guess.pow10().recip()
			else:
				#If guess == minimum, we haven't actually found the super-root, the algorithm just kept going down trying to find a super-root that's not in the increasing range.
				#Check if the root is in the zero range.
				if maximum.eq(from_components(1, 10, 1)):
					#There is no zero range, so the super root doesn't exist
					return from_components(int(NAN), int(NAN), int(NAN))
				_lower = from_components(1, 10, 1)
				_upper = maximum
				_previous = _upper
				_guess = from_components(0, 0, 0)
				_loopGoing = true
				while _loopGoing:
					if _lower.eq(from_components(1, 10, 1)):
						_guess = _upper.multiply(from_number(2))
					else: _guess = _lower.add(_upper).divide(from_number(2))
					if _guess._pow(from_number(10)).recip().tetrate(degree, from_number(1), true).gt(self):
						_upper = _guess
					else:
						_lower = _guess
					if _guess.eq(_previous):
						_loopGoing = false
					else:
						_previous = _guess
					if _upper.gt(from_number(1e18)):
						return from_components(int(NAN), int(NAN), int(NAN))
				return _guess.pow10().recip()

#Pentate
func pentate(height = 2, payload = from_components_no_normalize(1, 0, 1), linear = false):
	var oldheight = height
	height = snappedi(height, 1)
	var fracheight = oldheight - height
	#I have no idea if this is a meaningful approximation for pentation to continuous heights, but it is monotonic and continuous.
	if not fracheight == 0:
		if payload.eq(from_number(1)):
			height += 1
			payload = Decimal.from_number(fracheight);
		else:
			if eq(from_number(10)):
				payload = payload.layer_add_10(fracheight, linear)
			else:
				payload = payload.layer_add(fracheight, self, linear)
	for i in range(0, height):
		payload = tetrate(payload.toNumber(), from_components(1, 0, 1), linear);
		#bail if we're NaN
		if not (is_finite(payload.layer) or is_finite(payload.mag)):
			return payload.normalize()
		#give up after 10 iterations if nothing is happening
		if i > 10:
			return payload
	return payload

### TRIGONOMETRY FUNCTIONS ###

#Sine
func _sin():
	if mag < 0:
		return self
	if layer == 0:
		return from_number(sin(ssign * mag))
	return from_components_no_normalize(0, 0, 0)

#Cosine
func _cos():
	if mag < 0:
		return from_components(1, 0, 1)
	if layer == 0:
		return from_number(cos(ssign * mag));
	return from_components_no_normalize(0, 0, 0)

#Tangent
func _tan():
	if mag < 0:
		return self
	if layer == 0:
		return from_number(tan(ssign * mag))
	return from_components_no_normalize(0, 0, 0)

#Arcsine
func _asin():
	if mag < 0:
		return self
	if layer == 0:
		return from_number(asin(ssign * mag))
	return from_components_no_normalize(int(NAN), int(NAN), int(NAN))

#Arccosine
func _acos():
	if mag < 0:
		return from_number(acos(to_number()))
	if layer == 0:
		return from_number(acos(ssign * mag));
	return from_components_no_normalize(int(NAN), int(NAN), int(NAN))
#Arctangent
func _atan():
	if mag < 0:
		return self
	if layer == 0:
		return from_number(atan(ssign * mag))
	return from_number(atan(ssign * 1.8e308))

#Hyperbolic Sine
func _sinh():
	return _exp().subtract(neg()._exp()).divide(from_number(2))

#Hyperbolic Cosine
func _cosh():
	_exp().add(neg()._exp()).divide(from_number(2))

#Hyperbolic Tangent
func _tanh():
	return _sinh().divide(_cosh())

#Hyperbolic Arcsine
func asinh():
	return add(sqr().add(from_number(1)).sqrt()).ln()

#Hyperbolic Arccosine
func acosh():
	return add(sqr().subtract(from_number(1)).sqrt()).ln()

#Hyperbolic Arctangent
func atanh():
	if _abs().gte(from_number(1)):
		return from_components_no_normalize(int(NAN), int(NAN), int(NAN))
	return (add(from_number(1)).divide(from_number(1).subtract(self))).divide(from_number(2)).ln()

### COMPARATORS ###

#Compare
func cmp(value: Decimal):
	if (ssign > value.ssign):
		return 1
	if (ssign < value.ssign):
		return -1
	return ssign * cmpabs(value)

#Compare Abs
func cmpabs(value: Decimal):
	var layera
	var layerb

	if (mag > 0):
		layera = layer
	else:
		layera = - layer

	if (value.mag > 0):
		layerb = value.layer
	else:
		layerb = - value.layer

	if (layera > layerb):
		return 1
	if (layera < layerb):
		return -1
	if (mag > value.mag):
		return 1
	if (mag < value.mag):
		return -1
	return 0

#Is NaN
func _is_nan():
	return is_nan(ssign) or is_nan(layer) or is_nan(mag)

#Is Finite
func _is_finite():
	return is_finite(ssign) and is_finite(layer) and is_finite(mag)

#Equals
func eq(value: Decimal):
	return ssign == value.ssign and layer == value.layer and mag == value.mag

#Not Equal
func neq(value: Decimal):
	return not eq(value)

#Less Than
func lt(value: Decimal):
	return cmp(value) == -1

#Less Than/Equal To
func lte(value: Decimal):
	return not gt(value)

#Greater Than
func gt(value: Decimal):
	return cmp(value) == 1

#Greater Than/Equal To
func gte(value: Decimal):
	return not lt(value)

### COMPARATORS (WITH TOLERANCE) ###

#Compare
func cmp_tolerance(value: Decimal, tolerance: float):
	if eq_tolerance(value, tolerance):
		return 0
	else:
		return cmp(value)

#Equals
func eq_tolerance(value: Decimal, tolerance: float):
	if tolerance == null:
		tolerance = 1e-7
	#Numbers that are too far away are never close.
	if not ssign == value.ssign:
		return false
	if abs(layer - value.layer) > 1:
		return false
	# return abs(a-b) <= tolerance * max(abs(a), abs(b))
	var magA = mag
	var magB = value.mag
	if layer > value.layer:
		magB = f_maglog10(magB)
	if layer < value.layer:
		magA = f_maglog10(magA)

	return abs(magA - magB) <= tolerance * max(abs(magA), abs(magB))

#Not Equals
func neq_tolerance(value: Decimal, tolerance: float):
	return not eq_tolerance(value, tolerance)

#Less Than
func lt_tolerance(value: Decimal, tolerance: float):
	return (not eq_tolerance(value, tolerance)) and lt(value)

#Less Than/Equal To
func lte_tolerance(value: Decimal, tolerance: float):
	return eq_tolerance(value, tolerance) or lt(value)

#Greater Than
func gt_tolerance(value: Decimal, tolerance: float):
	return (not eq_tolerance(value, tolerance)) and gt(value)

#Greater Than/Equal To
func gte_tolerance(value: Decimal, tolerance: float):
	return eq_tolerance(value, tolerance) or gt(value)

### CORE FUNCTIONS ###

func slog_critical(base: float, height: float):
	#TODO: for bases above 10, revert to old linear approximation until I can think of something better
	if base > 10:
		return height - 1
	return critical_section(base, height, critical_slog_values)

func tetrate_critical(base: float, height: float):
	return critical_section(base, height, critical_tetr_values)

func critical_section(base: float, height: float, grid: Array):
	#this part is simple at least, since it's just 0.1 to 0.9
	height *= 10
	if height < 0:
		height = 0
	if height > 10:
		height = 10

	#have to do this complicated song and dance since one of the critical_headers is E, and in the future I'd like 1.5 as well
	if base < 2:
		base = 2
	if base > 10:
		base = 10

	var lower = 0
	var upper = 0
	#basically, if we're between bases, we interpolate each bases' relevant values together
	#then we interpolate based on what the fractional height is.
	#accuracy could be improved by doing a non-linear interpolation (maybe), by adding more bases and heights (definitely) but this is AFAIK the best you can get without running some pari.gp or mathematica program to calculate exact values
	#however, do note http://myweb.astate.edu/wpaulsen/tetcalc/tetcalc.html can do it for arbitrary heights but not for arbitrary bases (2, e, 10 present)
	for i in range(0, critical_headers.size() - 1):
		if critical_headers[i] == base:
			# exact match
			lower = grid[i][floor(height)]
			upper = grid[i][ceil(height)]
			break
		elif (critical_headers[i] < base) and (critical_headers[i + 1]) > base:
			# interpolate between this and the next
			var basefrac = (base - critical_headers[i]) / (critical_headers[i + 1] - critical_headers[i])
			lower = grid[i][floor(height)] * (1 - basefrac) + grid[i + 1][floor(height)] * basefrac
			upper = grid[i][ceil(height)] * (1 - basefrac) + grid[i + 1][ceil(height)] * basefrac
			break
	var frac = height - floor(height);
	#improvement - you get more accuracy (especially around 0.9-1.0) by doing log, then frac, then powing the result
	#(we could pre-log the lookup table, but then fractional bases would get Weird)
	#also, use old linear for slog (values 0 or less in critical section). maybe something else is better but haven't thought about what yet
	if lower <= 0 or upper <= 0:
		return lower * (1 - frac) + upper * frac;
	else:
		return pow(base, log(lower) / log(base) * (1 - frac) + log(upper) / log(base) * frac)
