extends Node

const RNC_FILE_IS_NOT_RNC = -1
const RNC_HUF_DECODE_ERROR = -2
const RNC_FILE_SIZE_MISMATCH = -3
const RNC_PACKED_CRC_ERROR = -4
const RNC_UNPACKED_CRC_ERROR = -5
const RNC_SIGNATURE = 0x524E4301

const CRCTAB = PoolIntArray([
	0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
	0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
	0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
	0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
	0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
	0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
	0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
	0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
	0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
	0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
	0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
	0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
	0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
	0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
	0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
	0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
	0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
	0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
	0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
	0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
	0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
	0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
	0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
	0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
	0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
	0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
	0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
	0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
	0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
	0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
	0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
	0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
])

const MIRROR_8BIT = PoolIntArray([
	0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0,
	0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8,
	0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4,
	0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC,
	0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2,
	0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA,
	0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6,
	0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE,
	0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1,
	0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9,
	0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5,
	0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD,
	0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3,
	0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB,
	0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7,
	0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF
])


static func _mirror_fast(x: int, n: int) -> int:
	if n <= 8:
		return MIRROR_8BIT[x & 0xFF] >> (8 - n)
	var result = 0
	var src_bit = 1
	var dst_bit = 1 << (n - 1)
	for i in range(n):
		if x & src_bit:
			result |= dst_bit
		src_bit <<= 1
		dst_bit >>= 1
	return result


static func rnc_crc(data: PoolByteArray) -> int:
	var val = 0
	var dataSize = data.size()
	for idx in range(dataSize):
		val ^= data[idx]
		val = (val >> 8) ^ CRCTAB[val & 0xFF]
	return val & 0xFFFF


static func blong(data: PoolByteArray, offset: int = 0) -> int:
	return (data[offset] << 24) | (data[offset + 1] << 16) | (data[offset + 2] << 8) | data[offset + 3]


static func bword(data: PoolByteArray, offset: int = 0) -> int:
	return (data[offset] << 8) | data[offset + 1]


static func rnc_unpack(packed: PoolByteArray):
	var packed_size = packed.size()
	if packed_size < 18 or blong(packed, 0) != RNC_SIGNATURE:
		return RNC_FILE_IS_NOT_RNC
	
	var ret_len = blong(packed, 4)
	var input_len = blong(packed, 8)
	if packed_size < 18 + input_len:
		return RNC_FILE_SIZE_MISMATCH
	
	var input_data = packed.subarray(18, 18 + input_len - 1)
	var input_size = input_data.size()
	
	if rnc_crc(input_data) != bword(packed, 14):
		return RNC_PACKED_CRC_ERROR
	
	var out_crc = bword(packed, 12)
	var output = PoolByteArray()
	output.resize(ret_len)
	
	var input_offset = 0
	var bitbuf: int
	if input_offset + 1 < input_size:
		bitbuf = input_data[input_offset] | (input_data[input_offset + 1] << 8)
	elif input_offset < input_size:
		bitbuf = input_data[input_offset]
	else:
		bitbuf = 0
	var bitcount = 16
	
	bitbuf >>= 2
	bitcount -= 2
	if bitcount < 16:
		input_offset += 2
		if input_offset + 1 < input_size:
			bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
		elif input_offset < input_size:
			bitbuf |= (input_data[input_offset] << bitcount)
		bitcount += 16
	
	var output_pos = 0
	var chunk_num = 0
	var raw_codes = PoolIntArray()
	var raw_codelens = PoolIntArray()
	var raw_values = PoolIntArray()
	var raw_num = 0
	var dist_codes = PoolIntArray()
	var dist_codelens = PoolIntArray()
	var dist_values = PoolIntArray()
	var dist_num = 0
	var len_codes = PoolIntArray()
	var len_codelens = PoolIntArray()
	var len_values = PoolIntArray()
	var len_num = 0
	raw_codes.resize(32)
	raw_codelens.resize(32)
	raw_values.resize(32)
	dist_codes.resize(32)
	dist_codelens.resize(32)
	dist_values.resize(32)
	len_codes.resize(32)
	len_codelens.resize(32)
	len_values.resize(32)
	
	while output_pos < ret_len:
		chunk_num += 1
		if chunk_num > 100000:
			return RNC_FILE_SIZE_MISMATCH
		
		var entry_num = bitbuf & 0x1F
		bitbuf >>= 5
		bitcount -= 5
		if bitcount < 16:
			input_offset += 2
			if input_offset + 1 < input_size:
				bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
			elif input_offset < input_size:
				bitbuf |= (input_data[input_offset] << bitcount)
			bitcount += 16
		
		if entry_num:
			var leaflen = PoolIntArray()
			leaflen.resize(entry_num)
			var leafmax = 1
			for i in range(entry_num):
				var length = bitbuf & 0x0F
				bitbuf >>= 4
				bitcount -= 4
				if bitcount < 16:
					input_offset += 2
					if input_offset + 1 < input_size:
						bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
					elif input_offset < input_size:
						bitbuf |= (input_data[input_offset] << bitcount)
					bitcount += 16
				leaflen[i] = length
				if leafmax < length:
					leafmax = length
			
			var codeb = 0
			var k = 0
			for current_len in range(1, leafmax + 1):
				for j in range(entry_num):
					if leaflen[j] == current_len:
						raw_codes[k] = _mirror_fast(codeb, current_len)
						raw_codelens[k] = current_len
						raw_values[k] = j
						codeb += 1
						k += 1
				codeb <<= 1
			raw_num = k
		else:
			raw_num = 0
		
		entry_num = bitbuf & 0x1F
		bitbuf >>= 5
		bitcount -= 5
		if bitcount < 16:
			input_offset += 2
			if input_offset + 1 < input_size:
				bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
			elif input_offset < input_size:
				bitbuf |= (input_data[input_offset] << bitcount)
			bitcount += 16
		
		if entry_num:
			var leaflen = PoolIntArray()
			leaflen.resize(entry_num)
			var leafmax = 1
			for i in range(entry_num):
				var length = bitbuf & 0x0F
				bitbuf >>= 4
				bitcount -= 4
				if bitcount < 16:
					input_offset += 2
					if input_offset + 1 < input_size:
						bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
					elif input_offset < input_size:
						bitbuf |= (input_data[input_offset] << bitcount)
					bitcount += 16
				leaflen[i] = length
				if leafmax < length:
					leafmax = length
			
			var codeb = 0
			var k = 0
			for current_len in range(1, leafmax + 1):
				for j in range(entry_num):
					if leaflen[j] == current_len:
						dist_codes[k] = _mirror_fast(codeb, current_len)
						dist_codelens[k] = current_len
						dist_values[k] = j
						codeb += 1
						k += 1
				codeb <<= 1
			dist_num = k
		else:
			dist_num = 0
		
		entry_num = bitbuf & 0x1F
		bitbuf >>= 5
		bitcount -= 5
		if bitcount < 16:
			input_offset += 2
			if input_offset + 1 < input_size:
				bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
			elif input_offset < input_size:
				bitbuf |= (input_data[input_offset] << bitcount)
			bitcount += 16
		
		if entry_num:
			var leaflen = PoolIntArray()
			leaflen.resize(entry_num)
			var leafmax = 1
			for i in range(entry_num):
				var length = bitbuf & 0x0F
				bitbuf >>= 4
				bitcount -= 4
				if bitcount < 16:
					input_offset += 2
					if input_offset + 1 < input_size:
						bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
					elif input_offset < input_size:
						bitbuf |= (input_data[input_offset] << bitcount)
					bitcount += 16
				leaflen[i] = length
				if leafmax < length:
					leafmax = length
			
			var codeb = 0
			var k = 0
			for current_len in range(1, leafmax + 1):
				for j in range(entry_num):
					if leaflen[j] == current_len:
						len_codes[k] = _mirror_fast(codeb, current_len)
						len_codelens[k] = current_len
						len_values[k] = j
						codeb += 1
						k += 1
				codeb <<= 1
			len_num = k
		else:
			len_num = 0
		
		var ch_count = bitbuf & 0xFFFF
		bitbuf >>= 16
		bitcount -= 16
		if bitcount < 16:
			input_offset += 2
			if input_offset + 1 < input_size:
				bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
			elif input_offset < input_size:
				bitbuf |= (input_data[input_offset] << bitcount)
			bitcount += 16
		
		while true:
			var val = -1
			for i in range(raw_num):
				var codelen = raw_codelens[i]
				var mask = (1 << codelen) - 1
				if (bitbuf & mask) == raw_codes[i]:
					bitbuf >>= codelen
					bitcount -= codelen
					if bitcount < 16:
						input_offset += 2
						if input_offset + 1 < input_size:
							bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
						elif input_offset < input_size:
							bitbuf |= (input_data[input_offset] << bitcount)
						bitcount += 16
					val = raw_values[i]
					if val >= 2:
						var extra_bits_needed = val - 1
						var temp = 1 << extra_bits_needed
						var extra_bits = bitbuf & (temp - 1)
						bitbuf >>= extra_bits_needed
						bitcount -= extra_bits_needed
						if bitcount < 16:
							input_offset += 2
							if input_offset + 1 < input_size:
								bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
							elif input_offset < input_size:
								bitbuf |= (input_data[input_offset] << bitcount)
							bitcount += 16
						val = temp | extra_bits
					break
			
			if val == -1:
				return RNC_HUF_DECODE_ERROR
			
			if val:
				var safe_length = min(val, min(input_size - input_offset, ret_len - output_pos))
				if safe_length > 0:
					for i in range(safe_length):
						output[output_pos + i] = input_data[input_offset + i]
					output_pos += safe_length
					input_offset += safe_length
					
					bitcount -= 16
					bitbuf &= (1 << bitcount) - 1
					if input_offset + 1 < input_size:
						bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
					elif input_offset < input_size:
						bitbuf |= (input_data[input_offset] << bitcount)
					bitcount += 16
			
			ch_count -= 1
			if ch_count <= 0:
				break
			
			val = -1
			for i in range(dist_num):
				var codelen = dist_codelens[i]
				var mask = (1 << codelen) - 1
				if (bitbuf & mask) == dist_codes[i]:
					bitbuf >>= codelen
					bitcount -= codelen
					if bitcount < 16:
						input_offset += 2
						if input_offset + 1 < input_size:
							bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
						elif input_offset < input_size:
							bitbuf |= (input_data[input_offset] << bitcount)
						bitcount += 16
					
					val = dist_values[i]
					if val >= 2:
						var extra_bits_needed = val - 1
						var temp = 1 << extra_bits_needed
						var extra_bits = bitbuf & (temp - 1)
						bitbuf >>= extra_bits_needed
						bitcount -= extra_bits_needed
						if bitcount < 16:
							input_offset += 2
							if input_offset + 1 < input_size:
								bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
							elif input_offset < input_size:
								bitbuf |= (input_data[input_offset] << bitcount)
							bitcount += 16
						val = temp | extra_bits
					break
			
			if val == -1:
				return RNC_HUF_DECODE_ERROR
			var posn = val + 1
			
			val = -1
			for i in range(len_num):
				var codelen = len_codelens[i]
				var mask = (1 << codelen) - 1
				if (bitbuf & mask) == len_codes[i]:
					bitbuf >>= codelen
					bitcount -= codelen
					if bitcount < 16:
						input_offset += 2
						if input_offset + 1 < input_size:
							bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
						elif input_offset < input_size:
							bitbuf |= (input_data[input_offset] << bitcount)
						bitcount += 16
					
					val = len_values[i]
					if val >= 2:
						var extra_bits_needed = val - 1
						var temp = 1 << extra_bits_needed
						var extra_bits = bitbuf & (temp - 1)
						bitbuf >>= extra_bits_needed
						bitcount -= extra_bits_needed
						if bitcount < 16:
							input_offset += 2
							if input_offset + 1 < input_size:
								bitbuf |= ((input_data[input_offset] | (input_data[input_offset + 1] << 8)) << bitcount)
							elif input_offset < input_size:
								bitbuf |= (input_data[input_offset] << bitcount)
							bitcount += 16
						val = temp | extra_bits
					break
			
			if val == -1:
				return RNC_HUF_DECODE_ERROR
			var length = val + 2
			
			if output_pos < posn:
				return RNC_FILE_SIZE_MISMATCH
			
			var to_copy = min(length, ret_len - output_pos)
			if to_copy > 0:
				var src_start = output_pos - posn
				for i in range(to_copy):
					output[output_pos + i] = output[src_start + i]
				output_pos += to_copy

	if output_pos != ret_len:
		return RNC_FILE_SIZE_MISMATCH
	return output if rnc_crc(output) == out_crc else RNC_UNPACKED_CRC_ERROR


static func load_file(path: String) -> PoolByteArray:
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return PoolByteArray()
	var data = file.get_buffer(file.get_len())
	file.close()
	return data


func decompress_to_bytes(path: String) -> PoolByteArray:
	var packed_data = load_file(path)
	if packed_data.empty():
		return PoolByteArray()
	var result = rnc_unpack(packed_data)
	return result if typeof(result) != TYPE_INT else PoolByteArray()


func decompress(path: String) -> PoolByteArray:
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return PoolByteArray()
	
	var file_data = file.get_buffer(file.get_len())
	file.close()
	
	if file_data.size() < 4:
		return PoolByteArray()
	
	if file_data[0] != 82 or file_data[1] != 78 or file_data[2] != 67 or file_data[3] != 1:
		return file_data
	
	var decompressed_data = rnc_unpack(file_data)
	if typeof(decompressed_data) == TYPE_INT or decompressed_data.empty():
		return PoolByteArray()
	
	if file.open(path, File.WRITE) != OK:
		return PoolByteArray()
	file.store_buffer(decompressed_data)
	file.close()
	
	return decompressed_data


func check_for_rnc_compression(path) -> bool:
	var file = File.new()
	if file.open(path, File.READ) != OK or file.get_len() < 4:
		if file.is_open():
			file.close()
		return false
	
	var header = file.get_buffer(4)
	file.close()
	
	return header[0] == 82 and header[1] == 78 and header[2] == 67 and header[3] == 1
