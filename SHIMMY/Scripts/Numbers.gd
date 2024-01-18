extends Control

@onready var sfx:Array = [%Audio1, %Audio2, %Audio3, %Audio4, %Audio5, %Audio6, %Audio7, %Audio8, %Audio9, ]
@onready var ai:Array = [%AI7, %AI8, %AI9, %AI4, %AI5, %AI6, %AI1, %AI2, %AI3]
@onready var start_button = %StartButton
@onready var score_label = %ScoreLabel
@onready var error_sfx = %ERROR

@onready var _7 = %"7"
@onready var _8 = %"8"
@onready var _9 = %"9"
@onready var _4 = %"4"
@onready var _5 = %"5"
@onready var _6 = %"6"
@onready var _1 = %"1"
@onready var _2 = %"2"
@onready var _3 = %"3"

var playerCursor:int = 0
var sequence:Array = []
var idle:bool = true
var idle_change_timer:float = 5.0

const IDLE_CHANGE_TIMER_START:float = 5.0
const IDLE_CHANGE_TIMER_RESET:float = 3.0


func _ready():
	resetGame()

func _process(delta):
	if not idle:
		return
	
	idle_change_timer -= delta
	
	if idle_change_timer <= 0:
		idle_change_timer = IDLE_CHANGE_TIMER_RESET
		var element = randi() % 9
		ai[element].visible = true
		
		await get_tree().create_timer(0.5).timeout
		
		if not idle: 
			return
			
		ai[element].visible = false

func resetGame():
	randomize()
	
	for img in ai:
		img.visible = false
		
	_stopSounds()
	_disableButtons()
	
	start_button.disabled = false
	idle = true
	idle_change_timer = IDLE_CHANGE_TIMER_START

func _on_Button_pressed():
	idle = false
	start_button.disabled = true
	
	sequence.clear()
	startAIState()

func startAIState():
	for img in ai:
		img.visible = false
		
	_disableButtons()
	
	#Add one element to the sequence
	var newElement = randi() % 9
	
	sequence.append(newElement)
	score_label.text = "%02d" % sequence.size()
	
	await get_tree().create_timer(0.5).timeout
	
	#play the sequence
	for e in sequence:
		ai[e].visible = true
		sfx[e].play()
		await sfx[e].finished
		ai[e].visible = false
	
	#Set the player turn
	startPlayerState()

func startPlayerState():
	_enableButtons()
	
	#Set the player sequence at the begining
	playerCursor = 0

func _disableButtons():
	#Disable the buttons
	_7.disabled = true
	_8.disabled = true
	_9.disabled = true
	_4.disabled = true
	_5.disabled = true
	_6.disabled = true
	_1.disabled = true
	_2.disabled = true
	_3.disabled = true

func _enableButtons():
	#enable the buttons
	_7.disabled = false
	_8.disabled = false
	_9.disabled = false
	_4.disabled = false
	_5.disabled = false
	_6.disabled = false
	_1.disabled = false
	_2.disabled = false
	_3.disabled = false

func _stopSounds():
	for e in sfx:
		e.stop()

func _error():
	print("error")
	_stopSounds()
	_disableButtons()
	error_sfx.play()
	await error_sfx.finished
	resetGame()

#Connected from buttons with a diferent parameter each
func _checkPlayerButton(button:int):
	if playerCursor < sequence.size() and sequence[playerCursor] == button:
		sfx[button].play()
		playerCursor += 1
		
		if playerCursor >= sequence.size():
			await sfx[button].finished
			startAIState()
	else:
		_error()
