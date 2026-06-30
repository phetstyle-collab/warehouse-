import os
import re
path = r'c:\preerr\kanzi\longgradan\MiniCPlayground.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

new_logic = '''	var result_bbcode := ""
	var typed_lines := typed.split("\n")
	var target_lines := target.split("\n")

	for line_idx in range(target_lines.size()):
		var tgt_line: String = target_lines[line_idx]
		var typ_line: String = ""
		if line_idx < typed_lines.size():
			typ_line = typed_lines[line_idx]

		var tgt_len := tgt_line.length()
		var typ_len := typ_line.length()

		for char_idx in range(tgt_len):
			var ch: String = tgt_line[char_idx]
			if char_idx < typ_len:
				result_bbcode += "[color=#00000000]%s[/color]" % ch
			else:
				result_bbcode += "[color=#404855]%s[/color]" % ch

		if line_idx < target_lines.size() - 1:
			result_bbcode += "\n"

	_ghost_label.text = result_bbcode'''

pattern = r'# ????? BBCode ??????????????????????.*_ghost_label\.text = result_bbcode'
content = re.sub(pattern, new_logic, content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Replaced using regex')

