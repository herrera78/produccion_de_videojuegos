#res://src/scenes/gamification/pizza_rush/delivery_area.gd
extends Area2D

signal pizza_delivered

func confirm_delivery():
	pizza_delivered.emit()
