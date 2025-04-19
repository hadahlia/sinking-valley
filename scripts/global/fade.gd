extends RefCounted
class_name SceneTransition
 
class Signals extends Object:
	signal fade_finished()
 
static var signals:Signals = Signals.new()  
 
class Fader extends Object:
 
	var _animationplayer:AnimationPlayer
	var _canvaslayer:CanvasLayer
	var _color_rect:ColorRect
	var _tree = null
	var _scene_path = null
	
	func do_fade(mode:String, seconds:float, color:Color, audiostreamplayers:Array[AudioStreamPlayer] = [], scene_path:NodePath = NodePath()):
 
		# local declarations
		var anim_name = "fade_in" if mode == "in" else "fade_out" 
		var start_alpha = 1.0 if mode == "in" else 0.0
		var end_alpha = 0.0 if mode == "in" else 1.0
		var start_volume = -80.0 if mode == "in" else 0.0
		var end_volume = 0.0 if mode == "in" else -80.0
 
		# store scene_path for use later
		_scene_path = scene_path
 
		# get the scenetree
		_tree = Engine.get_main_loop()
		
		await _tree.process_frame
 
		# get the size of the current viewport
		var viewport_size = _tree.root.get_visible_rect().size
		
		# create and add the CanvasLayer
		_canvaslayer = CanvasLayer.new()
		_canvaslayer.layer = 99999
		_tree.root.add_child(_canvaslayer)
		
		# create and add the AnimationPlayer
		_animationplayer = AnimationPlayer.new()
		_canvaslayer.add_child(_animationplayer)
 
		# create and add the ColorRect
 
		_color_rect = ColorRect.new()
		_color_rect.modulate = color
		_color_rect.modulate.a = 0.0 if mode == "out" else 1.0
		_color_rect.size = viewport_size
		_color_rect.name = "fade_screen"
		_canvaslayer.add_child(_color_rect)
 
		# wait one frame so the tree has caught up
		await _tree.process_frame
 
		# create the animation library
		var lib = AnimationLibrary.new()
		_animationplayer.add_animation_library("", lib)
		
		# create the ColorRect fade animation
		var animation = Animation.new()
		animation.length = seconds 
		var track = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath(str(_color_rect.get_path()) + ":modulate:a"))
		animation.track_insert_key(track, 0.0, start_alpha) 
		animation.track_insert_key(track, seconds, end_alpha)
		
		# create the ColorRect fade animation
		for asplayer in audiostreamplayers:
			track = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(track, NodePath(str(asplayer.get_path()) + ":volume_db"))
			animation.track_insert_key(track, 0.0, start_volume) 
			animation.track_insert_key(track, seconds, end_volume)
			
		# add the created animation to the library
		lib.add_animation(anim_name, animation)
				
		# determine which on_finished event to use
		var on_finished:Callable = on_fade_in_finished if mode == "in" else on_fade_out_finished
			
		# connect the on_finished event
		_animationplayer.animation_finished.connect(on_finished)
			
		# finally play the animation
		_animationplayer.play(anim_name)
 
	func clean_up():
		_canvaslayer.queue_free()
 
	func on_fade_in_finished(_anim_name:String):
		clean_up()
		
	func on_fade_out_finished(_anim_name:String):
		clean_up()
		SceneTransition.signals.fade_finished.emit()
		if !_scene_path.is_empty():
			_tree.change_scene_to_file(_scene_path)
 
static func fade_in(seconds:float = 1.0, color:Color = Color.BLACK, audiostreamplayers:Array[AudioStreamPlayer] = []):
	var fader = Fader.new()
	fader.do_fade("in", seconds, color, audiostreamplayers)
 
static func fade_out(seconds:float = 1.0, color:Color = Color.BLACK, scene_path:NodePath = NodePath(), audiostreamplayers:Array[AudioStreamPlayer] = []):
	var fader = Fader.new()
	fader.do_fade("out", seconds, color, audiostreamplayers, scene_path)
