module lbos::mem;

const BLOCK_SIZE @builtin = 512;
// TODO: once tlocal is supported, use as regular stdlib allocator
/*
const VoreAllocator VORE_ALLOCATOR = {};

// Semi-arbitrary sizes for how it stores allocations
const MAX_REGIONS @private = BLOCK_SIZE;
const REGION_SIZE @private = 32; // how large each 'reigon' of memory is (the smallest size that can be allocated on the arena at once)
struct VorePage
{
	
	char[BLOCK_SIZE]* mem;
	VorePage* next;
}

struct VoreAllocator (Allocator)
{
	bool[MAX_REGIONS] used_regions;
	VorePage[] pages;
	VorePage* head;
	VorePage* tail;
}

// TODO: this is *really* *really* bad since alloc_blocks allocates in, well, blocks not bytes (and each block afaict is 512 bytes)
fn void*? VoreAllocator.acquire(&self, usz size, AllocInitType init_type, usz alignment = 0) @dynamic
{
	// assert(ceil(size, 512) == 1);
	println("acquiring block");
	assert (size < 512);
	void* data = alloc_blocks(/*ceil(size, 512)*/1);
	if (data == null) return mem::OUT_OF_MEMORY?;
	return data;
}

fn void*? VoreAllocator.resize(&self, void* ptr, usz new_size, usz alignment = 0) @dynamic
{
	println("resizing block");
	assert (new_size < 512);
	// return mem::OUT_OF_MEMORY?;
	return ptr;
}

fn void VoreAllocator.release(&self, void* ptr, bool aligned) @dynamic
{
	println("freeing block");
	free_blocks(ptr, 1);
}
*/
