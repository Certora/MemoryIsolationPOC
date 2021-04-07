# Requirements

* Node

# Setup

Install `ganache-cli`, `solc`, and `web3` via npm, i.e., `npm install ganache-cli web3 solc --save`

# Reproducing

In another terminal window, begin the ganache test client: `./node_modules/.bin/ganache-cli`

Then, in this directory, simply run `node index.js`.

You should see something like the following output

    helogale:MemoryIsolationPOC jrw$ node index.js
	Done compiling
    Deployed corruptible contract
    123456
	246912

The first number shows that the decoder has:
1. Read the value of the `afterCorrupt.field` field during decoding
2. Added that value to the free pointer, yielding an overflow, and
3. Mistakenly decoded the contents of `before` as the second element of the decoded tuple

The second number shows that the decoder has:
1. Read the value of `afterCorrupt.field1` during decoding,
2. Added that value to the free pointer, yeilding an overlfow,
3. Mistakenly decoded the contents of `before` as the first element of the decoded array
4. Repeated steps 1-3, but instead reading `afterCorrupt.field2`, thereby copying `before` again

The number shown is the sum of the first elements of the two arrays decoded out of `corrupt`, i.e. 123456 * 2.
