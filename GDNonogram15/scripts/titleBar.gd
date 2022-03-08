extends ColorRect

const POSITION = Vector2(0, 0)

func _draw():   # 描画関数
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color("#2e4f4f")   # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	draw_style_box(style_box, Rect2(POSITION, self.rect_size))      # style_box に設定した矩形を描画

func _ready():
	pass # Replace with function body.

