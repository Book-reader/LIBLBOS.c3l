module lbos::fs;
import lbos::ktask;

const MAX_FILENAME = 12;

faultdef FILE_NOT_FOUND, NOT_FILE, UNKNOWN_ERR;

enum RecordType : const char
{
	NONE,
	DIRECTORY,
	FILE,
	UNKNOWN,
}

typedef FileSystem = char[32];
typedef DirectoryReader = char[32];
typedef FileReader = char[32];

struct Record
{
	char[MAX_FILENAME] name;
	RecordType type;
	// depends on FS implementation, shouldn't rely on
	uint target;
	uint total_size_bytes;
}

macro String Record.get_name(&self)
{
	usz? idx = index_of_char(&self.name, 0);

	if (try i = idx)
	{
		return (String)self.name[:i];
	}
	return (String)self.name[..];
}

macro usz? index_of_char(char[] str, char c)
{
	foreach (i, ch : str)
	{
		if (ch == c) return i;
	}
	return NOT_FOUND?;
}

/*tlocal*/ FileSystem fs;

fn void? init()
{
	ktask::fs_open(&fs)!;
}

<*
 @require name.len > 0
*>
macro File? open_file(String name)
{
	if (name[0] == '/')
	{
		lbos::abort("TODO");
	}

	DirectoryReader dir;

	ktask::fs_open_dir(&fs, &dir, /*env.current_directory_path*/"/")!;

	Record file_record;
	do
	{
		if (catch err = ktask::fs_read_dir(&fs, &dir, &file_record)) switch (err)
		{
			case ktask::EOF:
				return FILE_NOT_FOUND?;
			default:
				return UNKNOWN_ERR?;
		}
	} while (file_record.get_name() != name);
	if (file_record.type != FILE) return NOT_FILE?;

	File file;
	file.total_size_bytes = file_record.total_size_bytes;
	ktask::fs_open_file(&fs, &file_record, &file.reader)!;
	return file;
}

struct File
{
	FileReader reader;
	usz total_size_bytes;
}

macro char? File.read_byte(&self)
{
	char c;
	ktask::fs_read_file(&fs, &self.reader, (&c)[:1])!;
	return c;
}
