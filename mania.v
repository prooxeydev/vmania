module main

import gg
import gx
import gl
import glfw
import time
import freetype

const (
	WinWidth = 1280
	WinHeight = 720
	PixelPerSecond = 250
)


struct Mania {
mut:
	gg &gg.GG
	window &glfw.Window
	ft &freetype.FreeType
	scroll_speed int
	state int
	play_fields []&PlayField
	combo u32
	score u64
	last u16
}

struct PlayField {
mut:
	nodes []&Node
	key int
	pressed bool
	alpha int
}

struct Node {
	len int
	init int
mut:
	x int
}

fn main() {
	glfw.init_glfw()
	mut game := &Mania{
		scroll_speed: PixelPerSecond
		gg: 0
		state: 0 // Play
		window: 0
		combo: 0
		score: 0
		last: 0
		play_fields: []&PlayField{}
	}

	mut play_field := &PlayField{
		nodes: []&Node{}
		key: 68 //D
		pressed: false
		alpha: 0
	}

	game.play_fields << play_field

	mut node := &Node{
		len: 250 / 10
		init: 250 * 10
		x: 0
	}
	node.x = node.init

	mut node2 := &Node{
		len: 250 / 10
		init: 250 * 10+ 120
		x: 0
	}
	node2.x = node2.init

	play_field.nodes << node
	play_field.nodes << node2

	window := glfw.create_window(glfw.WinCfg{
		width: WinWidth
		height: WinHeight
		borderless: false
		title: 'V Mania'
		ptr: game
		always_on_top: false
	})
	game.window = window
	window.make_context_current()
	gg.init_gg()
	gg := gg.new_context(gg.Cfg{
		width: WinWidth
		height: WinHeight
		font_size: 20
		use_ortho: true
		window_user_ptr: 0
	})
	/*ft := freetype.new_context(gg.Cfg{
		width: WinWidth
		height: WinHeight
		font_size: 20
		use_ortho: true
		window_user_ptr: 0
	})*/

	game.gg = gg
	game.window.onkeydown(key_down)
	println('Starting game loop')
	go game.run()
	for {
		if window.should_close() {
			game.close()
			break
		}
		gl.clear()
		gl.clear_color(255, 255, 255, 255)
		game.draw()
		window.swap_buffers()
		glfw.wait_events()
	}
}

fn (game mut Mania) draw() {
	mut x := 480 / 2

	width := 800 / game.play_fields.len

	for play_field in game.play_fields {

		for node in play_field.nodes {
			if node.x < 720 && node.x > 0{
				delta_height := 720 - node.x
				mut height := node.len
				if delta_height < height {
					height = delta_height
				}
				game.gg.draw_rect(x, node.x, width, height, gx.rgb(0, 0, 0))
			} else if node.x <= 0 {
				mut height := node.len + node.x
				if height >= node.len {
					//Miss
					game.last = 0
					game.combo = 0
					play_field.remove_node(node.x) //TODO fix this
					continue
				}
				game.gg.draw_rect(x, 0, width, height, gx.rgb(0, 0, 0))
			}
		}
		if play_field.pressed {
			game.gg.draw_rect(x, 0, width, 50, gx.rgb(100, 0, 0))
		}

//		game.gg.draw_rect(x, 0, 200, 50, gx.rgba(100, 0, 0, play_field.alpha))

		x += 200
	}
}

fn (game mut Mania) run() {
	for {
		glfw.post_empty_event()
		for play_field in game.play_fields {
			for node in play_field.nodes {
				node.x -= 1
			}
			if play_field.pressed {
				if play_field.alpha < 255 {
					play_field.alpha += 1
				}
			} else {
				if play_field.alpha > 0 {
					play_field.alpha -= 1
				}
			}
		}
		time.sleep_ms(1000 / PixelPerSecond)
	}
}

fn (field mut PlayField) remove_node(x int) {
	field.nodes = field.nodes.filter(it.x > x)
}

fn (game mut Mania) key_input(key, action int) {
	match game.state {
		0 {
			for play_field in game.play_fields {
				if key == play_field.key {
					if action == 1 {
						//PRESSED
						play_field.pressed = true
						node := play_field.nodes[0]
						if node.x <= 100 {
							delta := 100 - node.x

							if delta > 100 && delta < 110 {
								//l100er
								game.last = 100
								game.combo += 1
								game.score += 100 * game.combo
							} else if delta > 110 && delta < 120 {
								//l50er
								game.last = 50
								game.combo += 1
								game.score += 50 * game.combo
							} else if delta < 50 {
								//50er
								game.last = 50
								game.combo += 1
								game.score += 50 * game.combo
							} else if delta > 50 && delta < 75 {
								//100er
								game.last = 100
								game.combo += 1
								game.score += 100 * game.combo
							} else if delta > 75 && delta < 100 {
								//300er
								game.last = 300
								game.combo += 1
								game.score += 300 * game.combo
							} else {
								//Miss
								game.last = 0
								game.combo = 0
							}

							play_field.remove_node(node.x)
						}
					} else if action == 0 {
						//RELEASED
						play_field.pressed = false
					}
				}
			}
		}
		else {
			panic('Wrong game state')
		}
	}
}

fn key_down(wnd voidptr, key, code, action, mods int) {
	mut game := &Mania(glfw.get_window_user_pointer(wnd))
	game.key_input(key, action)
}

fn (game mut Mania) close() {

}