module lbos::ktask;
import lbos::fs;
import lbos::syscall;

faultdef FS_OPEN_FAILED, FILE_OPEN_FAILED, FILE_READ_FAILED,
			DIR_NOT_FOUND, INVALID_RECORD, USER_ERROR,
			DIR_READ_FAILED,
			EOD, EOF;

enum KTaskRequestType : const ushort
{
	DO_NOTHING = 0,
	SAY_HI = 1,
	FS_OPEN = 2,
	FS_OPEN_DIR = 3,
	FS_READ_DIR = 4,
	FS_OPEN_FILE = 5,
	FS_READ_FILE = 6,
	FS_SEEK = 7,
	LOAD_DDI_FILE = 8,
}

struct KTaskRequest
{
	KTaskRequestType type;
	TaskID reply_to;
	uint return_val;
}

struct KTaskFSOpenRequest
{
	inline KTaskRequest base;
	FileSystem* fs;
}

struct KTaskFSOpenDirRequest
{
	inline KTaskRequest base;
	FileSystem* fs;
	DirectoryReader* dir;
	char* path;
	usz path_len;
}

struct KTaskFSReadDirRequest
{
	inline KTaskRequest base;
	FileSystem* fs;
	DirectoryReader* dir;
	Record* record;
}

struct KTaskFSOpenFileRequest
{
	inline KTaskRequest base;
	FileSystem* fs;
	Record* record;
	FileReader* reader;
}

struct KTaskFSReadFileRequest
{
	inline KTaskRequest base;
	FileSystem* fs;
	FileReader* reader;
	char* buffer;
	usz buffer_len;
}

struct KTaskFSSeek
{
	inline KTaskRequest base;
	FileSystem* fs;
	FileReader* reader;
	uint sectors;
}

struct KTaskLoadDDIFile
{
	inline KTaskRequest base;
	char* file_buf;
	usz file_buf_len;
	uint task_setup_ptr;
}

<*
 @require (uptr)req % BLOCK_SIZE == 0 : "req must be at the start of a block"
*>
fn void query(KTaskRequest* req)
{
	lbos::send_notification(0, (MemoryBlock)req);
	lbos::wait_for_notif_ack(0);
	MemoryBlock ret = lbos::wait_for_notification();
	if ((uptr)ret != (uptr)req)
	{
		lbos::print("ktask err!"/*"ktask failed to respond properly!\n"*/);
	}
}

<*
 @param [&out] fs
 @return? FS_OPEN_FAILED
*>
fn void? fs_open(FileSystem* fs)
{
	TaskID t = lbos::get_current_task();
	KTaskFSOpenRequest* req = (KTaskFSOpenRequest*)lbos::alloc_blocks(1);
	defer lbos::free_blocks((MemoryBlock)req, 1);
	req.type = FS_OPEN;
	req.reply_to = t;
	req.fs = fs;
	query(req);
	if (req.return_val != 0) return FS_OPEN_FAILED?;
}

<*
 @param [&in] fs
 @param [&out] dir
 @param [in] path
*>
fn void? fs_open_dir(FileSystem* fs, DirectoryReader* dir, String path)
{
	TaskID t = lbos::get_current_task();
	KTaskFSOpenDirRequest* req = (KTaskFSOpenDirRequest*)lbos::alloc_blocks(1);
	defer lbos::free_blocks((MemoryBlock)req, 1);
	req.type = FS_OPEN_DIR;
	req.reply_to = t;
	req.fs = fs;
	req.dir = dir;
	req.path = path.ptr;
	req.path_len = path.len;
	query(req);
	switch (req.return_val)
	{
		case 0: return;
		case 1: return DIR_NOT_FOUND?;
		case 2: return INVALID_RECORD?;
		case 3: return USER_ERROR?;
		default: panic::unreachable("fs_open_dir"/* invalid return value"*/);
	}
}

<*
 @param [&in] fs
 @param [&inout] dir
 @param [&out] record
*>
fn void? fs_read_dir(FileSystem* fs, DirectoryReader* dir, Record* record)
{
	TaskID t = lbos::get_current_task();
	KTaskFSReadDirRequest* req = (KTaskFSReadDirRequest*)lbos::alloc_blocks(1);
	defer lbos::free_blocks((MemoryBlock)req, 1);
	req.type = FS_READ_DIR;
	req.reply_to = t;
	req.fs = fs;
	req.dir = dir;
	req.record = record;
	query(req);
	switch (req.return_val)
	{
		case 0: return;
		case 1: return EOD?;
		case 2: return DIR_READ_FAILED?;
		default: panic::unreachable("fs_open_dir"/* invalid return value"*/);
	}

}

<*
 @param [&in] fs
 @param [&in] record
 @param [&out] reader
 @return? FILE_OPEN_FAILED
*>
fn void? fs_open_file(FileSystem* fs, Record* record, FileReader* reader)
{
	TaskID t = syscall::get_current_task();
	KTaskFSOpenFileRequest* req = (KTaskFSOpenFileRequest*)syscall::alloc_blocks(1);
	defer syscall::free_blocks((MemoryBlock)req, 1);
	req.type = FS_OPEN_FILE;
	req.reply_to = t;
	req.fs = fs;
	req.record = record;
	req.reader = reader;
	query(req);
	if (req.return_val != 0) return FILE_OPEN_FAILED?;
}

<*
 @param [&in] fs
 @param [&inout] reader
 @param [out] buf
 @return? EOF, FILE_READ_FAILED
*>
fn void? fs_read_file(FileSystem* fs, FileReader* reader, char[] buf)
{
	TaskID t = lbos::get_current_task();
	KTaskFSReadFileRequest* req = (KTaskFSReadFileRequest*)syscall::alloc_blocks(1);
	defer syscall::free_blocks((MemoryBlock)req, 1);
	req.type = FS_READ_FILE;
	req.reply_to = t;
	req.fs = fs;
	req.reader = reader;
	req.buffer = buf.ptr;
	req.buffer_len = buf.len;
	query(req);
	switch (req.return_val)
	{
		case 0: return;
		case 1: return EOF?;
		case 2: return FILE_READ_FAILED?;
		default: panic::unreachable("fs_read_file"/* unexpected return value"*/);
	}
}
