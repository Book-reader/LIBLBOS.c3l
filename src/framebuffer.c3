module lbos::fb;

const SCREEN_WIDTH @builtin = 320;
const SCREEN_HEIGHT @builtin = 240;

struct Colour @packed
{
	// Will be RGB888 on the actual hardware
	char a;
	char r;
	char g;
	char b;
}
macro bool Colour.equals(self, Colour other) @operator(==) => self.a == other.a && self.r == other.r && self.g == other.g && self.b == other.b;

const Colour WHITE @builtin = {255, 255, 255, 255};
const Colour BLACK @builtin = {255, 0, 0, 0};
const Colour RED @builtin = {255, 255, 0, 0};
const Colour GREEN @builtin = {255, 0, 255, 0};
const Colour BLUE @builtin = {255, 0, 0, 255};

typedef FrameBuffer = void*;

<*
 @require x + width <= SCREEN_WIDTH
 @require y + height <= SCREEN_HEIGHT
*>
fn void FrameBuffer.fill_rect(self, usz x, usz y, usz width, usz height, Colour col)
{
	for (usz ys = y; ys < y + height; ys++)
	{
		((Colour*)self)[ys * SCREEN_WIDTH + x:width] = col;
	}
}
fn void FrameBuffer.trace_rect(self, usz x, usz y, usz width, usz height, Colour col, usz outline_width = 1)
{
	// TODO: I could make this a lot more efficient
	self.fill_rect(x, y, width, outline_width, col/*, flush: flush*/); // @inline;
	self.fill_rect(x, y + height, width, outline_width, col/*, flush: flush*/); // @inline;
	self.fill_rect(x, y, outline_width, height + outline_width, col/*, flush: flush*/); // @inline;
	self.fill_rect(x + height, y, outline_width, height + outline_width, col/*, flush: flush*/); // @inline;
}

fn void FrameBuffer.set_pixel(self, ushort x, ushort y, Colour col)
{
	((Colour*)self)[y * SCREEN_WIDTH + x] = col;
}

macro void FrameBuffer.reset(self) => enable_fb();
macro void FrameBuffer.clear(self, Colour col)
{
	self.fill_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, col/*, flush: true*/);
	self.flush(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}
// fn void FrameBuffer.clear_rect(self, usz x, usz y, usz width, usz height) => self.fill_rect(x, y, width, height, WHITE, flush: flush);

<*
 @require x + width <= SCREEN_WIDTH
 @require y + height <= SCREEN_HEIGHT
*>
macro void FrameBuffer.flush(self, usz x, usz y, usz width, usz height) => flush_fb_rect(x, y, width, height);
