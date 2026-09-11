extends Control

@onready var lbl_subtotal: Label = $VBoxContainer/LblSubtotal
@onready var lbl_coupon: Label = $VBoxContainer/LblCoupon
@onready var lbl_total: Label = $VBoxContainer/LblTotal
@onready var btn_confirm: Button = $VBoxContainer/BtnConfirm

var applied_coupon: Dictionary = {}

func _ready() -> void:
	# Conectar señal programáticamente
	btn_confirm.pressed.connect(_on_confirm)
	_update_invoice()

func _on_confirm() -> void:
	if not applied_coupon.is_empty():
		GlobalManager.remove_coupon(applied_coupon)
	lbl_coupon.text = "Compra confirmada"

func _update_invoice() -> void:
	var base_name: String = GlobalManager.selection["base"]
	var item_1_quantity: int = GlobalManager.selection["item_1"]
	var item_2_quantity: int = GlobalManager.selection["item_2"]
	var base_price: int = GlobalManager.prices[base_name]
	var item_1_price: int = GlobalManager.prices["item_1"]
	var item_2_price: int = GlobalManager.prices["item_2"]
	var item_1_total: int = item_1_quantity * item_1_price
	var item_2_total: int = item_2_quantity * item_2_price
	lbl_subtotal.text = (
		"BASE ELEGIDA: %s $%d\n"
		+ "INGREDIENTE 1: %d × $%d $%d\n"
		+ "INGREDIENTE 2: %d × $%d $%d\n"
		+ "--------------------------------\n"
		+ "Subtotal: $%d"
	) % [
		base_name,
		base_price,
		item_1_quantity,
		item_1_price,
		item_1_total,
		item_2_quantity,
		item_2_price,
		item_2_total,
		GlobalManager.current_total
	]
	var subtotal: int = GlobalManager.current_total
	applied_coupon = GlobalManager.get_best_coupon(subtotal)
	var discount: int = 0
	if not applied_coupon.is_empty():
		discount = applied_coupon["value"]
	var final_total: int = max(subtotal - discount, 0)
	lbl_coupon.text = "Descuento aplicado por cupón: $%d" % discount
	lbl_total.text = "TOTAL: $%d" % final_total
