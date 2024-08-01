# Credit to Coding with Russ for helping with primary game code: 
# https://www.youtube.com/watch?v=nKBhz6oJYsc

extends Node

# preload obstacles
var chair_scene = preload("res://scenes/chair.tscn")
var fridge_scene = preload("res://scenes/fridge.tscn")
var tv_scene = preload("res://scenes/tv.tscn")
var table_scene = preload("res://scenes/table.tscn")
var box_scene = preload("res://scenes/box.tscn")

# preload scoreline and game_over scene, as well as results scene
var scoreline_scene = preload("res://scenes/scoreline.tscn")
var gameover_scene = preload("res://scenes/game_over.tscn")

# Make an array for the obstacles on the ground and in the air, as well as one for obstacles on screen
var ground_obstacles := [chair_scene, fridge_scene, box_scene]
var flying_obstacles := [tv_scene, table_scene]
var screen_obstacles : Array

# Array for the possible heights the objects can fly at
var flight_heights := [200, 400]

# define initial positions of player character and camera
const PLAYER_START_POSITION := Vector2i(72, 456)
const CAMERA_START_POSITION := Vector2i(576, 324)
const BOX_Y_POSITION := 100

# Basic variables
# Score Variables
var score : int
var high_score : int
# Used to slow down score
const SCORE_MODIFIER : int = 20

# Difficulty Variables
var difficulty : int
const MAX_DIFFICULTY : int = 2
const DIFFICULTY_MODIFIER : int = 5000

# Other Variables
var speed : float
const START_SPEED : int = 3
const MAX_SPEED : int = 5
const SPEED_MODIFIER : int = 15000
var screen_size : Vector2i
var ground_height : int
var game_running : bool

# Variable to track the last obstacle spawned
var last_obstacle

# Variable for player name
var player_name

# Called when the node enters the scene tree for the first time.
func _ready():
	
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	
	# Connect to the final result canvas
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer/YesButton").pressed.connect(submit_score)
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer/NoButton").pressed.connect(go_to_leaderboard)
	new_game()
	
	# Configure Leaderboard - credit to SilentWolf and Escada Games for setup help
	SilentWolf.configure({
	"api_key": "cKHnzgICxZ6a8HOBP8wgA5E8TVyKLqF1EaORHG6c",
	"game_id": "uhaulpanic",
	"log_level": 1
	})
	
func new_game():
	
	# Reset the positions of everything, initialize velocity and score back to 0, fetch most recent high score
	score = 0
	
	show_score()
	game_running = false
	
	# Unpause the game if game is restarting
	get_tree().paused = false
	
	# Set difficulty back to 0
	difficulty = 0
	
	# delete all obstacles in the screen_obstacles via queue free, then clear array
	for obstacle in screen_obstacles:
		obstacle.queue_free()
	screen_obstacles.clear()
	
	$Worker.position = PLAYER_START_POSITION
	$Worker.velocity = Vector2i(0, 0)
	$Camera2D.position = CAMERA_START_POSITION
	$Ground.position = Vector2i(0, 0)
	
	#Show Start Label again and reset HUD
	$BasicHUD.get_node("StartLabel").show()
	$FinalResultCanvas.hide()
	
	# Attempted to load in newest scores before - unfortunately didn't work
	#var fetchHighScore: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	#
	##Fetch highest score so far
	#var highest_score : int = 0;
	#for score in fetchHighScore.scores:
		#if (int(score.score) > highest_score):
			#highest_score = int(score.score)
	#$BasicHUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(highest_score)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If game is running and not still waiting to start
	if (game_running):
		
		# Set speed as game progresses - we want it to increment relatively slowly
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
			
		# adjust the difficulty
		change_difficulty()
		
		# generate obstacles
		generate_obstacle()
		
		# Move the player character and the camera
		$Worker.position.x += speed
		$Camera2D.position.x += speed
		
		# Update the score using the speed
		score += speed
		show_score()
		
		# Check if right edge of ground gets to right edge of screen, if so, shift the ground
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			# Shift the ground by the width of the screen so worker doesn't fall off
			$Ground.position.x += screen_size.x
		
		# remove off-screen obstacles
		for obstacle in screen_obstacles:
			if obstacle.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obstacle(obstacle)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$BasicHUD.get_node("StartLabel").hide()

func show_score():
	$BasicHUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$BasicHUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
	
func generate_obstacle():
	if screen_obstacles.is_empty() or last_obstacle.position.x < score + randi_range(250, 400):
		var obstacle_type = ground_obstacles[randi() % ground_obstacles.size()]
		var generated_obstacle
		
		# var for the number of obstacles that can stacked right next to each other
		
		generated_obstacle = obstacle_type.instantiate()
		
		# place the generated obstacle
		var obstacle_height
		var obstacle_scale
		
		if (generated_obstacle.name == "Box"):
			print("Box!")
			var box_dimensions = generated_obstacle.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("break_apart", 0).get_size()
			obstacle_height = box_dimensions.y
			obstacle_scale = Vector2i(1, 1)
		else:
			obstacle_height = generated_obstacle.get_node("Sprite2D").texture.get_height()
			obstacle_scale = generated_obstacle.get_node("Sprite2D").scale
		
		var obstacle_x : int = screen_size.x + score + 100
		var obstacle_y : int = screen_size.y - ground_height - (obstacle_height * obstacle_scale.y / 2) + 5
		
		last_obstacle = generated_obstacle
		
		# Add the obstacle
		add_obstacle(generated_obstacle, obstacle_x, obstacle_y)
		
		# if difficulty is at or above 1, start spawning flying objects and breakable boxes
		if difficulty >= 1:
			if (randi() % 2) == 0:
				# Choose a flying obstacle
				var flying_obs_type = flying_obstacles[randi() % flying_obstacles.size()]
				generated_obstacle = flying_obs_type.instantiate()
				var flying_obstacle_x : int = screen_size.x + score + 100
				var flying_obstacle_y : int = flight_heights[randi() % flight_heights.size()]
				add_obstacle(generated_obstacle, flying_obstacle_x, flying_obstacle_y)
				
		
		
		
	
func add_obstacle(obstacle, x, y):
		obstacle.position = Vector2i(x, y)
		
		# connect to obstacle so we can do collision detection w/ extra arguments so we can detect who called it
		obstacle.body_entered.connect(hit_obstacle.bind(obstacle))
		
		add_child(obstacle)
		screen_obstacles.append(obstacle)

func remove_obstacle(obstacle):
	obstacle.queue_free()
	screen_obstacles.erase(obstacle)
	
func hit_obstacle(body, obstacle):
	if body.name == "Worker":
		# Check if the obstacle is part of the breakable group and if the worker is attacking - if so, just take damage
		if ($Worker.attacking) and obstacle.is_in_group("breakable"):
			obstacle.call_deferred("reduce_health")
		else:
		# Unless it is a crate and the player is kicking, collision = game over
			game_over()

func change_difficulty():
	difficulty = score / DIFFICULTY_MODIFIER
	if (difficulty > MAX_DIFFICULTY):
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	#Show final score on final result canvas
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer/ActualScoreLabel").text = str(score / SCORE_MODIFIER)
	$FinalResultCanvas.show()
	

# Credit to SilentWolf for leaderboard usage: https://silentwolf.com/leaderboard
func submit_score():
	var input_text = $FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer/EnteredNameLine").text
	player_name = input_text
	var final_score = score / SCORE_MODIFIER
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, final_score).sw_save_score_complete
	go_to_leaderboard()

func reset_game():
	# Reset the game by reloading the current scene
	get_tree().reload_current_scene()
	
func go_to_leaderboard():
	# Get the 5 top scores
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	
	# Clear previous final_result container
	var result_container = $FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer")
	for i in range(0, result_container.get_child_count()):
		result_container.get_child(i).queue_free()
	
	# Insert number of scorelines based on number of scores
	var startingIndex : int = 1
	for score in sw_result.scores:
		var scoreline = scoreline_scene.instantiate()
		scoreline.get_node("PositionLabel").text = '#'+str(startingIndex)
		scoreline.get_node("NameLabel").text = score.player_name
		scoreline.get_node("ScoreLabel").text = str(score.score)
		$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer").add_child(scoreline)
		startingIndex+=1
	
	# Display Player's score and position within the leaderboard
	var player_score_result = await SilentWolf.Scores.get_score_position(score / SCORE_MODIFIER).sw_get_position_complete
	var player_score_position = player_score_result.position
	var player_hseperator = HSeparator.new()
	var player_scoreline = scoreline_scene.instantiate()
	player_scoreline.get_node("PositionLabel").text = '#'+str(player_score_position)
	player_scoreline.get_node("NameLabel").text = "Your Score"
	player_scoreline.get_node("ScoreLabel").text = str(score / SCORE_MODIFIER)
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer").add_child(player_hseperator)
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer").add_child(player_scoreline)
	

	# Insert retry button after a seperator and connect to it to allow for retry
	var extra_hseperator = HSeparator.new()
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer").add_child(extra_hseperator)
	var restartbutton = gameover_scene.instantiate()
	restartbutton.pressed.connect(reset_game)
	$FinalResultCanvas.get_node("FinalResult/FinalResult/ScoreContainer").add_child(restartbutton)
	
