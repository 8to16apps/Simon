extends Control

var playerCursor:int = 0;
var sequence:Array = [];
var idle:bool = true;
var _idleChangeTimer:float = 5.0;
const _idleChangeTimerStart:float = 5.0;
const _idleChangeTimerReset:float = 3.0;

onready var sfx:Array = [$sfx/Do,$sfx/Re,$sfx/Mi,$sfx/Fa];
onready var ai:Array = [$AIRed, $AIGreen, $AIBlue, $AIYellow];

func _ready():
	resetGame();

func _process(delta):
	if not idle:
		return;
	
	_idleChangeTimer -= delta;
	if _idleChangeTimer <= 0:
		_idleChangeTimer = _idleChangeTimerReset;
		var element = randi()%4;
		ai[element].visible = true;
		
		yield(get_tree().create_timer(0.5), "timeout")
		
		if not idle: return;
		ai[element].visible = false;

func resetGame():
	randomize();
	for img in ai:
		img.visible = false;
	_stopSounds();
	_disableButtons();
	$Panel/Button.disabled = false;
	idle = true;
	_idleChangeTimer = _idleChangeTimerStart;

func startAIState():
	for img in ai:
		img.visible = false;
	_disableButtons();
	
	#Add one element to the sequence
	var newElement = randi()%4;
	sequence.append(newElement);
	$Panel/LabelBg/Label.text = "%02d" % sequence.size(); 
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	#play the sequence
	for e in sequence:
		ai[e].visible = true;
		sfx[e].play();
		yield( sfx[e], "finished" );
		ai[e].visible = false;
	
	#Set the player turn
	startPlayerState();


func startPlayerState():
	_enableButtons();
	
	#Set the player sequence at the begining
	playerCursor = 0;


func _disableButtons():
	#Disable the buttons
	$Red.disabled = true;
	$Green.disabled = true;
	$Blue.disabled = true;
	$Yellow.disabled = true;


func _enableButtons():
	#enable the buttons
	$Red.disabled = false;
	$Green.disabled = false;
	$Blue.disabled = false;
	$Yellow.disabled = false;


func _stopSounds():
	for e in sfx:
		e.stop();


func _error():
	_stopSounds();
	_disableButtons();
	$sfx/error.play();
	yield( $sfx/error, "finished" );
	resetGame();

#Connected from buttons with a diferent parameter each
func _checkPlayerButton(button:int):
	if playerCursor < sequence.size() and sequence[playerCursor] == button:
		sfx[button].play();
		playerCursor += 1;
		if playerCursor >= sequence.size():
			yield( sfx[button], "finished" );
			startAIState();
	else:
		_error();


func _on_Button_pressed():
	idle = false;
	$Panel/Button.disabled = true;
	sequence.clear();
	startAIState();
