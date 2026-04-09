pragma solidity >=0.5.0 <0.6.0;

import "./JoinSplitABIEncoder.sol";
import "../../../interfaces/JoinSplitInterface.sol";

/**
 * @title 
 * @author Zachary Williamson, AZTEC
 * @dev Library to validate AZTEC JoinSplit proofs
 * Don't include this as an internal library. This contract uses a static memory table to cache
 * elliptic curve primitives and hashes.
 * Calling this internally from another function will lead to memory mutation and undefined behaviour.
 * The intended use case is to call this externally via `staticcall`.
 * External calls to OptimizedAZTEC can be treated as pure functions as this contract contains no
 * storage and makes no external calls (other than to precompiles)
 *
 * Copyright 2020 Spilsbury Holdings Ltd 
 *
 * Licensed under the GNU Lesser General Public Licence, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 **/
contract JoinSplit {
    /**
     * @dev AZTEC will take any transaction sent to it and attempt to validate a zero knowledge proof.
     * If the proof is not valid, the transaction throws.
     * @notice See AZTECInterface for how method calls should be constructed.
     * 'Cost' of raw elliptic curve primitives for a transaction:
     * 260,700 gas + (124,500 * number of input notes) + (167,600 * number of output notes).
     * For a basic 'joinSplit' with 2 inputs and 2 outputs = 844,900 gas.
     * AZTEC is written in YUL to enable manual memory management and for other efficiency savings.
     **/

    // solhint-disable payable-fallback
    function() external {
        assembly {
            // We don't check for function signatures,
            // there's only one function that ever gets called: validateJoinSplit()
            // We still assume calldata is offset by 4 bytes so that we can represent this contract
            // through a compatible ABI

            validateJoinSplit()
            // if we get to here, the proof is valid. We now 'fall through' the assembly block
            // and into JoinSplitABI.validateJoinSplit()
            // reset the free memory pointer because we're touching Solidity code again
            mstore(0x40, 0x60)

            /**
             * New calldata map
             * 0x04:0x24      = calldata location of proofData byte array
             * 0x24:0x44      = message sender
             * 0x44:0x64      = h_x
             * 0x64:0x84      = h_y
             * 0x84:0xa4      = t2_x0
             * 0xa4:0xc4      = t2_x1
             * 0xc4:0xe4      = t2_y0
             * 0xe4:0x104     = t2_y1
             * 0x104:0x124    = length of proofData byte array
             * 0x124:0x144    = m
             * 0x144:0x164    = challenge
             * 0x164:0x184    = publicOwner
             * 0x184:0x1a4    = offset in byte array to notes
             * 0x1a4:0x1c4    = offset in byte array to inputOwners
             * 0x1c4:0x1e4    = offset in byte array to outputOwners
             * 0x1e4:0x204    = offset in byte array to metadata
             */
            // SWC-101-Integer Overflow and Underflow: L75-L78
            function validateJoinSplit() {
   mstore(0x80, calldataload(0x44))
    mstore(0xa0, calldataload(0x64))
    let notes := add(0x104, calldataload(0x184))
    let m := calldataload(0x124)
    let n := calldataload(notes)
    let gen_order := 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
    let challenge := mod(calldataload(0x144), gen_order)

    if gt(m, n) { mstore(0x00, 404) revert(0x00, 0x20) }
    let kn := calldataload(sub(add(notes, SafeMath.mul(calldataload(notes), 0xc0)), 0xa0))
    mstore(0x2a0, calldataload(0x24))
    mstore(0x2c0, kn)
    mstore(0x2e0, m)
    mstore(0x300, calldataload(0x164))
    kn := mulmod(sub(gen_order, kn), challenge, gen_order)
    hashCommitments(notes, n)
    let b := add(0x320, SafeMath.mul(n, 80))
}

            /**        
             * @dev evaluate if e(P1, t2) . e(P2, g2) == 0.
             * @notice we don't hard-code t2 so that contracts that call this library can use
             * different trusted setups.
             **/
            function validatePairing(t2) {
                let field_order := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                let t2_x_1 := calldataload(t2)
                let t2_x_2 := calldataload(add(t2, 0x20))
                let t2_y_1 := calldataload(add(t2, 0x40))
                let t2_y_2 := calldataload(add(t2, 0x60))

                // check provided setup pubkey is not zero or g2
                if or(or(or(or(or(or(or(
                    iszero(t2_x_1),
                    iszero(t2_x_2)),
                    iszero(t2_y_1)),
                    iszero(t2_y_2)),
                    eq(t2_x_1, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)),
                    eq(t2_x_2, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)),
                    eq(t2_y_1, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)),
                    eq(t2_y_2, 0x90689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b))
                {
                    mstore(0x00, 400)
                    revert(0x00, 0x20)
                }

                // store coords in memory
                // indices are a bit off, scipr lab's libff limb ordering (c0, c1) is opposite
                // to what precompile expects
                // We can overwrite the memory we used previously as this function is called at the
                // end of the validation routine.
                mstore(0x20, mload(0x1e0)) // sigma accumulator x
                mstore(0x40, mload(0x200)) // sigma accumulator y
                mstore(0x80, 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed)
                mstore(0x60, 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2)
                mstore(0xc0, 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa)
                mstore(0xa0, 0x90689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b)
                mstore(0xe0, mload(0x260)) // gamma accumulator x
                mstore(0x100, mload(0x280)) // gamma accumulator y
                mstore(0x140, t2_x_1)
                mstore(0x120, t2_x_2)
                mstore(0x180, t2_y_1)
                mstore(0x160, t2_y_2)

                let success := staticcall(gas, 8, 0x20, 0x180, 0x20, 0x20)

                if or(iszero(success), iszero(mload(0x20))) {
                    mstore(0x00, 400)
                    revert(0x00, 0x20)
                }
            }

            /**
             * @dev check that this note's points are on the altbn128 curve(y^2 = x^3 + 3)
             * and that signatures 'k' and 'a' are modulo the order of the curve.
             * Transaction throws if this is not the case.
             * @param note the calldata loation of the note
             **/
            function validateCommitment(note, k, a) {
                let gen_order := 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001
                let field_order := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
                let gammaX := calldataload(add(note, 0x40))
                let gammaY := calldataload(add(note, 0x60))
                let sigmaX := calldataload(add(note, 0x80))
                let sigmaY := calldataload(add(note, 0xa0))
                if iszero(
                    and(
                        and(
                        and(
                            eq(mod(a, gen_order), a), // a is modulo generator order?
                            gt(a, 1)                  // can't be 0 or 1 either!
                        ),
                        and(
                            eq(mod(k, gen_order), k), // k is modulo generator order?
                            gt(k, 1)                  // and not 0 or 1
                        )
                        ),
                        and(
                        eq( // y^2 ?= x^3 + 3
                            addmod(
                                mulmod(mulmod(sigmaX, sigmaX, field_order), sigmaX, field_order),
                                3,
                                field_order
                            ),
                            mulmod(sigmaY, sigmaY, field_order)
                        ),
                        eq( // y^2 ?= x^3 + 3
                            addmod(
                                mulmod(mulmod(gammaX, gammaX, field_order), gammaX, field_order),
                                3,
                                field_order
                            ),
                            mulmod(gammaY, gammaY, field_order)
                        )
                        )
                    )
                ) {
                    mstore(0x00, 400)
                    revert(0x00, 0x20)
                }
            }

            /**
             * @dev Calculate the keccak256 hash of the commitments for both input notes and output notes.
             * This is used both as an input to validate the challenge `c` and also to
             * generate pseudorandom relationships
             * between commitments for different outputNotes, so that we can combine them
             * into a single multi-exponentiation for the purposes of validating the bilinear pairing relationships.
             * @param notes calldata location notes
             * @param n number of notes
             **/
            function hashCommitments(notes, n) {
                for { let i := 0 } lt(i, n) { i := add(i, 0x01) } {
                    let index := add(add(notes, mul(i, 0xc0)), 0x60)
                    calldatacopy(add(0x320, mul(i, 0x80)), index, 0x80)
                }
                mstore(0x00, keccak256(0x320, mul(n, 0x80)))
            }

        }
        // if we've reached here, we've validated the join-split transaction and haven't thrown an error.
        // Encode the output according to the ACE standard and exit.
        JoinSplitABIEncoder.encodeAndExit();
    }
}
