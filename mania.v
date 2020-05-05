module main

import gg
import gx
import gl
import glfw
import time

const (
	WinWidth = 1280
	WinHeight = 720
	PixelPerSecond = 250 
)

struct Mania {
mut:
	keys map[string]int
	gg &gg.GG
	window &glfw.Window
	scroll_speed int

	play_fields []&PlayField
}

struct PlayField {
mut:
	nodes []&Node
}

struct Node {
	len int
	init int
mut:
	x int
}

fn main() {
	glfw.init_glfw()
	mut keys := map[string]int
	keys['ll'] = 0
	keys['ml'] = 1
	keys['mr'] = 2
	keys['rr'] = 3
	mut game := &Mania{
		keys: keys
		scroll_speed: PixelPerSecond
		gg: 0
		window: 0
		play_fields: []&PlayField{}
	}

	mut play_field := &PlayField{
		nodes: []&Node{}
	}

	game.play_fields << play_field

	mut node := &Node{
		len: 250 / 10
		init: 250 * 10
		x: 0
	}
	node.x = node.init

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
		window_user_ptr: 0
	})
	game.gg = gg
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
	mut x := 480
	for play_field in game.play_fields {
		for node in play_field.nodes {
			if node.x < 720 {
				delta_height := 720 - node.x
				mut height := node.len
				if delta_height < height {
					height = delta_height
				}
				game.gg.draw_rect(x, node.x, 200, height, gx.rgb(0, 0, 0))
			}
		}
		x += 200
	}
}

fn (game mut Mania) run() {
	for {
		glfw.post_empty_event()
		for play_field in game.play_fields {
			for node in play_field.nodes {
				if node.x > 0 {
					node.x -= 1
				} else {
					play_field.nodes = play_field.nodes.filter(it.x > 0)
				}
			}
		}
		time.sleep_ms(1000 / PixelPerSecond)
	}
}

fn (game mut Mania) close() {

}