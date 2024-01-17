extends Control

@onready var sfx:Array = [%Do,%Re,%Mi,%Fa]
@onready var ai:Array = [%AIRed, %AIGreen, %AIBlue, %AIYellow]
@onready var start_button = %StartButton
@onready var score_label = %ScoreLabel
@onready var error_sfx = %ERROR

@onready var red_button = %Red
@onready var green_button = %Green
@onready var yellow_button = %Yellow
@onready var blue_button = %Blue

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
		var element = randi()%4
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
	var newElement = randi()%4
	
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
	red_button.disabled = true
	green_button.disabled = true
	blue_button.disabled = true
	yellow_button.disabled = true

func _enableButtons():
	#enable the buttons
	red_button.disabled = false
	green_button.disabled = false
	blue_button.disabled = false
	yellow_button.disabled = false

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
