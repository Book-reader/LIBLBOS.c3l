module lbos::syscall;
import lbos::fb;
import lbos::keys;

typedef TaskID = char;
typedef MemoryBlock = void*;

enum Syscall : const usz
{
	DO_NOTHING = 0,
	KERNEL_INFO = 1,
	CURRENT_TASK = 4,
	READ_INPUT_BUF = 5,
	WRITE_TERMINAL = 6,
	ALLOC_BLOCKS = 7,
	FREE_BLOCKS = 8,
	SEND_NOTIFICATION = 10,
	WAIT_FOR_NOTIFICATION = 11,
	PENDING_NOTIFICATIONS = 12,
	WAIT_FOR_NOTIFICATION_ACK = 13,
	ENVIRONMENT_POINTER = 14,
	DISABLE_FB_CONSOLE = 15,
	ENABLE_FB_CONSOLE = 16,
	FB_POINTER = 17,
	FLUSH_FB = 18,
	GET_CURRENT_KEYMAP = 19,
}

struct Environment
{
	String current_directory_path;
}

macro void write_terminal(String str) => syscall(WRITE_TERMINAL, (usz)str.ptr, str.len);
macro MemoryBlock alloc_blocks(usz num_blocks) => (MemoryBlock)syscall(ALLOC_BLOCKS, num_blocks);
macro void free_blocks(MemoryBlock block, usz num_blocks) => syscall(FREE_BLOCKS, (usz)block, num_blocks);
macro void disable_fb() => syscall(DISABLE_FB_CONSOLE);
macro void enable_fb() => syscall(ENABLE_FB_CONSOLE);
<*
 @ensure (void*)return != null : "Failed to get FrameBuffer pointer"
*>
macro FrameBuffer get_fb() => (FrameBuffer)syscall(FB_POINTER);
macro void flush_fb_rect(usz x, usz y, usz w, usz h) => syscall(FLUSH_FB, x, y, w, h);
macro void get_keymap(KeyState* state) => syscall(GET_CURRENT_KEYMAP, (usz)state);
macro void get_kernel_info(KernelInfo* info) => syscall(KERNEL_INFO, (usz)info);
macro usz read_input_buf(char[] buf) => syscall(READ_INPUT_BUF, (usz)buf.ptr, buf.len);
macro usz send_notification(TaskID dst, MemoryBlock blk) => syscall(SEND_NOTIFICATION, (usz)dst, (usz)blk);
macro void wait_for_notif_ack(TaskID task) => syscall(WAIT_FOR_NOTIFICATION_ACK, (usz)task);
macro MemoryBlock wait_for_notification() => (MemoryBlock)syscall(WAIT_FOR_NOTIFICATION);
macro TaskID get_current_task() => (TaskID)syscall(CURRENT_TASK);
macro Environment* get_env_ptr() => (Environment*)syscall(ENVIRONMENT_POINTER);

fn usz syscall(Syscall syscall, usz a1 = 0, usz a2 = 0, usz a3 = 0, usz a4 = 0, usz a5 = 0, usz a6 = 0) @naked @noinline
{
	asm
	(`
		ecall
		ret
	`);
}

struct KernelInfo
{
	usz current_process_count;
	usz total_mem_blocks;
	usz free_mem_blocks;
}
