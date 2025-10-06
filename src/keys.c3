module lbos::keys;
import lbos::syscall;

macro void KeyState.update(&self) => syscall::get_keymap(self);

struct KeyState
{
	bitstruct : ushort
	{
		bool esc;
		bool key1;
		bool key2;
		bool key3;
		bool key4;
		bool key5;
		bool key6;
		bool key7;
		bool key8;
		bool key9;
		bool key0;
		bool minus;
		bool equal;
		bool backspace;
		bool tab;
		bool enter;
	}
	bitstruct : uint
	{
		bool a;
		bool b;
		bool c;
		bool d;
		bool e;
		bool f;
		bool g;
		bool h;
		bool i;
		bool j;
		bool k;
		bool l;
		bool m;
		bool n;
		bool o;
		bool p;
		bool q;
		bool r;
		bool s;
		bool t;
		bool u;
		bool v;
		bool w;
		bool x;
		bool y;
		bool z;
	}
	bitstruct : ushort
	{
		bool left_bracket;
		bool right_bracket;
		bool semicolon;
		bool apostrophe;
		bool grave;
		bool backslash;
		bool comma;
		bool dot;
		bool slash;
		bool space;
		bool control;
		bool shift;
		bool alt;
	}
	bitstruct : ushort
	{
		bool up_arrow;
		bool down_arrow;
		bool left_arrow;
		bool right_arrow;
	}
}
