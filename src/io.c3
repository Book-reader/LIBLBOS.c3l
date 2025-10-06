module lbos::io;
import lbos::syscall;

macro void print(String str)
{
	syscall::write_terminal(str);
}

fn void printn(String str)
{
	print(str);
	print("\n");
}

macro void printc(char c) => syscall::syscall(WRITE_TERMINAL, (usz)&c, 1);
// TODO: test that this actually works
macro void printcn(char c) => syscall::write_terminal((String){c, '\n'});

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

