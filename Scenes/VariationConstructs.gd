extends Node
class_name VariationConstructs

enum vari {
	s = 0
	w = 1
	n = 2
	e = 3
	sw = 4
	nw = 5
	ne = 6
	se = 7
	all = 8
	center = 27
}

const slab_center = [
	vari.center, vari.center, vari.center,
	vari.center, vari.center, vari.center,
	vari.center, vari.center, vari.center,
]

const slab_partial_center = [
	vari.s, vari.s, vari.s,
	vari.e, vari.e, vari.w,
	vari.n, vari.n, vari.n,
]

const slab_s = [
	vari.s, vari.s, vari.s,
	vari.s, vari.s, vari.s,
	vari.s, vari.s, vari.s,
]
const slab_w = [
	vari.w, vari.w, vari.w,
	vari.w, vari.w, vari.w,
	vari.w, vari.w, vari.w,
]
const slab_n = [
	vari.n, vari.n, vari.n,
	vari.n, vari.n, vari.n,
	vari.n, vari.n, vari.n,
]
const slab_e = [
	vari.e, vari.e, vari.e,
	vari.e, vari.e, vari.e,
	vari.e, vari.e, vari.e,
]
const slab_sw = [
	vari.sw, vari.sw, vari.sw,
	vari.sw, vari.sw, vari.sw,
	vari.sw, vari.sw, vari.sw,
]
const slab_nw = [
	vari.nw, vari.nw, vari.nw,
	vari.nw, vari.nw, vari.nw,
	vari.nw, vari.nw, vari.nw,
]
const slab_ne = [
	vari.ne, vari.ne, vari.ne,
	vari.ne, vari.ne, vari.ne,
	vari.ne, vari.ne, vari.ne,
]
const slab_se = [
	vari.se, vari.se, vari.se,
	vari.se, vari.se, vari.se,
	vari.se, vari.se, vari.se,
]
const slab_solo = [
	vari.all, vari.all, vari.all,
	vari.all, vari.all, vari.all,
	vari.all, vari.all, vari.all,
]
const slab_sn = [
	vari.n, vari.n, vari.n,
	vari.n, vari.n, vari.n,
	vari.s, vari.s, vari.s,
]

const slab_ew = [
	vari.w, vari.w, vari.e,
	vari.w, vari.w, vari.e,
	vari.w, vari.w, vari.e,
]

const slab_sen = [
	vari.ne, vari.ne,  vari.ne,
	vari.ne, vari.all, vari.all,
	vari.se, vari.se,  vari.se,
]

const slab_swe = [
	vari.sw, vari.sw,  vari.se,
	vari.sw, vari.all, vari.se,
	vari.sw, vari.all, vari.se,
]

const slab_swn = [
	vari.nw,  vari.nw,  vari.nw,
	vari.all, vari.all, vari.nw,
	vari.sw,  vari.sw,  vari.sw,
]

const slab_wne = [
	vari.nw, vari.all, vari.ne,
	vari.nw, vari.all, vari.ne,
	vari.nw, vari.nw,  vari.ne,
]
