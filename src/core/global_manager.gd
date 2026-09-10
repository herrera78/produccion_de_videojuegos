# res://src/core/global_manager.gd
extends Node

var prices: Dictionary = {
 	"base_1": 5000,
 	"base_2": 7000,
 	"item_1": 1000,
 	"item_2": 1500
 }

var selection: Dictionary = {
 	"base": "base_1",
 	"item_1": 0,
 	"item_2": 0
 }

var current_total: int = 0

# Ejemplo de la información de los cupones
#{
	#"value": 2000,
	#"minimum_purchase": 10000
#}
var coupons : Array = []

func _ready() -> void:
	EventBus.base_selected.connect(_on_base_selected)
	EventBus.item_added.connect(_on_item_added)
	EventBus.coupon_obtained.connect(_on_coupon_obtained)
	_update_total()

func _on_coupon_obtained(coupon: Dictionary) -> void:
	coupons.append(coupon)


func _on_base_selected(base_id: String) -> void:
	selection["base"] = base_id
	_update_total()

func _on_item_added(item_id: String) -> void:
	selection[item_id] += 1
	_update_total()

func _update_total() -> void:
	current_total = prices[selection["base"]]
	current_total += selection["item_1"] * prices["item_1"]
	current_total += selection["item_2"] * prices["item_2"]
	EventBus.total_changed.emit(current_total)

func get_best_coupon(subtotal: int) -> Dictionary:
	var best_coupon := {}
	for coupon in coupons:
		if subtotal >= coupon["minimum_purchase"]:
			if best_coupon.is_empty():
				best_coupon = coupon
			elif coupon["value"] > best_coupon["value"]:
				best_coupon = coupon
	return best_coupon

func remove_coupon(coupon: Dictionary) -> void:
	if coupon in coupons:
		coupons.erase(coupon)
