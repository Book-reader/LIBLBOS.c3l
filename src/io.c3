module lbos::io;

macro void print(String str)
{
	write_terminal(str);
}

fn void printn(String str)
{
	print(str);
	print("\n");
}

macro void printc(char c) => syscall(WRITE_TERMINAL, (usz)&c, 1);
// TODO: test that this actually works
macro void printcn(char c) => syscall(WRITE_TERMINAL, (usz)(char*){c, '\n'}, 2);

macro void prints(String... args)
{
	foreach (arg : args)
	{
		print(arg);
	}
}

macro void printsn(String... args)
{
	prints(...args);
	print("\n");
}

