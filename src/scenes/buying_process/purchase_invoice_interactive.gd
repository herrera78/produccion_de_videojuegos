extends Control

@onready var lbl_subtotal: Label = $VBoxContainer/LblSubtotal
@onready var lbl_coupon: Label = $VBoxContainer/LblCoupon
@onready var btn_confirm: Button = $VBoxContainer/BtnConfirm
@onready var pop_up_confirm: Panel = $PurchaseSuccessPopup

var applied_coupon: Dictionary = {}

func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	_update_invoice()

func _on_confirm() -> void:
	if not applied_coupon.is_empty():
		GlobalManager.remove_coupon(applied_coupon)
	lbl_coupon.text = "Compra confirmada"
	pop_up_confirm.show()

func _update_invoice() -> void:
	var left_id: String = GlobalManager.pizza_selection["left"]
	var right_id: String = GlobalManager.pizza_selection["right"]

	var left_name := "Sin selección"
	var right_name := "Sin selección"
	var left_price := 0
	var right_price := 0
	for ingredient in GlobalManager.ingredients:
		if ingredient.id == left_id:
			left_name = ingredient.display_name
			left_price = ingredient.price
		if ingredient.id == right_id:
			right_name = ingredient.display_name
			right_price = ingredient.price
	var subtotal: int = GlobalManager.pizza_total
	lbl_subtotal.text = (
        "MITAD IZQUIERDA: %s    $%d\n"
		+ "MITAD DERECHA: %s    $%d\n"
		+ "--------------------------------\n"
		+ "Subtotal: $%d"
	) % [
		left_name,
		left_price,
		right_name,
		right_price,
		subtotal
	]
	applied_coupon = GlobalManager.get_best_coupon(subtotal)
	var discount := 0
	if not applied_coupon.is_empty():
		discount = applied_coupon["value"]
	var final_total = max(subtotal - discount, 0)
	lbl_coupon.text = (
        "Descuento aplicado por cupón: $%d\n"
		+ "TOTAL: $%d"
	) % [
		discount,
		final_total
	]
