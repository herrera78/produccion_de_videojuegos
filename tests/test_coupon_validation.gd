class_name GdUnitExampleTest
extends GdUnitTestSuite

const GlobalManagerScript = preload(
    "res://src/core/global_manager.gd"
)

var manager

func before() -> void:
	manager = GlobalManagerScript.new()

func after() -> void:
	manager.free()


func test_returns_coupon_when_subtotal_is_sufficient() -> void:
	manager.coupons = [
		{
			"value": 2000,
			"minimum_purchase": 10000
		}
	]

	var result = manager.get_best_coupon(12000)

	assert_object(result).is_equal({
		"value": 2000,
		"minimum_purchase": 10000
	})


func test_returns_empty_dictionary_when_no_coupon_is_valid() -> void:
	manager.coupons = [
		{
			"value": 2000,
			"minimum_purchase": 10000
		}
	]

	var result = manager.get_best_coupon(9999)

	assert_bool(result.is_empty()).is_true()


func test_returns_coupon_with_highest_value() -> void:
	manager.coupons = [
		{
			"value": 1000,
			"minimum_purchase": 5000
		},
		{
			"value": 3000,
			"minimum_purchase": 10000
		}
	]

	var result = manager.get_best_coupon(12000)

	assert_object(result).is_equal({
		"value": 3000,
		"minimum_purchase": 10000
	})
