extends Control

@onready var purchase_lbl: Label = $PurchaseLbl
@onready var quant_lbl: Label = $QuantLbl

var quant_buy = -1
var item
var purchase_text = "Now Purchasing: "

func _process(delta: float) -> void:
	$CurrencyLbl.text = str(PlayerData.currency)
	
	if quant_buy <= 0:
		$BuyBtn.disabled = true
	else:
		$BuyBtn.disabled = false
	
	if Input.is_action_pressed("sprint"):
		quant_lbl.text = "x10"
	else:
		quant_lbl.text = "x1"
	
	if quant_buy != -1 or quant_buy <= -2:
		purchase_lbl.text = purchase_text + item + " x" + str(quant_buy)
	else:
		purchase_lbl.text = ":)"
	
	if Input.is_action_just_pressed("debug"):
		ui_show()

func ui_show() -> void:
	visible = not visible
	if visible == true:
		PlayerData.can_move = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		quant_buy = -1
		PlayerData.can_move = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$LeftBtn.visible = false
		$RightBtn.visible = false
		$QuantLbl.visible = false
		$BuyBtn.visible = false


func _on_lemon_btn_pressed() -> void:
	quant_buy = 0
	item = "Lemon"


func _on_lime_btn_pressed() -> void:
	quant_buy = 0
	item = "Lime"


func _on_left_btn_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		quant_buy -= 10
	else:
		quant_buy -= 1
	
	if quant_buy <= 0:
		quant_buy = 0


func _on_right_btn_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		quant_buy += 10
	else:
		quant_buy += 1


func _on_item_btn_pressed() -> void:
	$LeftBtn.visible = true
	$RightBtn.visible = true
	$QuantLbl.visible = true
	$BuyBtn.visible = true


func _on_buy_btn_pressed() -> void:
	if item == "Lemon":
		PlayerData.currency -= 2.5 * quant_buy
	else:
		PlayerData.currency -= 1.5 * quant_buy
