pragma experimental ABIEncoderV2;

contract Test {
	struct MemoryUint {
		uint field;
	}
	function test() public returns (uint) {
		uint[] memory before = new uint[](1); // at offset 0x80
		bytes memory corrupt = abi.encode(uint(32), // offset to "tuple"
										  uint(0)); // bogus first element
		/*
		  At this point the free pointer is 0x80 + 64 (size of before) + 32 (length field of corrupt) + 64 (two encoded words)

		  Now let's put random junk into memory immediately after the bogus first element. Our goal is to overflow the read pointer to point to before.
		  The value read out at this point will be added to beginning of the encoded tuple, AKA corrupt + 64. We need then to write x where:
		  x + 0x80 + 64 (before) + 32 (length of corrupt) + 32 (first word of corrupt) = 0x80 (mod 2^256)
		  that is MAX_UINT - 128
		*/
		MemoryUint memory afterCorrupt;
		afterCorrupt.field = uint(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80);
		before[0] = 123456;
		uint[][2] memory decoded = abi.decode(corrupt, (uint[][2]));
		return decoded[1][0];
	}

	struct MemoryTuple {
		uint field1;
		uint field2;
	}
	function withinArray() public returns (uint) {
		uint[] memory before = new uint[](1);
		bytes memory corrupt = abi.encode(uint(32),
										  uint(2));
		MemoryTuple memory afterCorrupt;
		before[0] = 123456;
		/*
		  As above, but in this case we are adding to:
		  0x80 + 64 (before) + 32 (length of corrupt) + 32 (offset) + 32 (field pointer)
		  giving MAX_UINT - 96
		*/
		afterCorrupt.field1 = uint(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60);
		afterCorrupt.field2 = uint(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60);
		uint[][] memory decoded = abi.decode(corrupt, (uint[][]));
		/*
		  Will return 123456 * 2, AKA before has been copied twice
		 */
		return decoded[0][0] + decoded[1][0];
	}
}
