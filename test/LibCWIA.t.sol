// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {LibCWIA} from "../src/utils/legacy/LibCWIA.sol";
import {CWIA} from "../src/utils/legacy/CWIA.sol";
import {SafeTransferLib} from "../src/utils/SafeTransferLib.sol";

contract LibCWIATest is SoladyTest, CWIA {
    error CustomError(uint256 currentValue);

    event ReceiveETH(uint256 amount);

    uint256 public value;

    mapping(bytes32 => bool) saltIsUsed;

    function setValue(uint256 value_) public {
        value = value_;
    }

    function revertWithError() public view {
        revert CustomError(value);
    }

    function getCalldataHash() public pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let extraLength := shr(0xf0, calldataload(sub(calldatasize(), 2)))
            if iszero(lt(extraLength, 2)) {
                let offset := sub(calldatasize(), extraLength)
                let m := mload(0x40)
                calldatacopy(m, offset, sub(extraLength, 2))
                result := keccak256(m, sub(extraLength, 2))
            }
        }
    }

    function _canReceiveETHCorrectly(address clone, uint256 deposit) internal {
        deposit = deposit % 1 ether;

        vm.deal(address(this), deposit * 2);

        vm.expectEmit(true, true, true, true);
        emit ReceiveETH(deposit);
        SafeTransferLib.safeTransferETH(clone, deposit);
        assertEq(clone.balance, deposit);

        vm.expectEmit(true, true, true, true);
        emit ReceiveETH(deposit);
        payable(clone).transfer(deposit);
        assertEq(clone.balance, deposit * 2);
    }

    function _shouldBehaveLikeClone(address clone, uint256 value_) internal {
        assertTrue(clone != address(0));

        uint256 thisValue = this.value();
        if (thisValue == value_) {
            value_ ^= 1;
        }
        LibCWIATest(clone).setValue(value_);
        assertEq(value_, LibCWIATest(clone).value());
        assertEq(thisValue, this.value());
        vm.expectRevert(abi.encodeWithSelector(CustomError.selector, value_));
        LibCWIATest(clone).revertWithError();
    }

    function getArgBytes(uint256 argOffset, uint256 length) public pure returns (bytes memory) {
        return _getArgBytes(argOffset, length);
    }

    function getArgAddress(uint256 argOffset) public pure returns (address) {
        return _getArgAddress(argOffset);
    }

    function getArgUint256(uint256 argOffset) public pure returns (uint256) {
        uint256 result = _getArgUint256(argOffset);
        unchecked {
            require(bytes32(result) == _getArgBytes32(argOffset));
            require(uint248(result) == _getArgUint248(argOffset + 1));
            require(uint240(result) == _getArgUint240(argOffset + 2));
            require(uint232(result) == _getArgUint232(argOffset + 3));
            require(uint224(result) == _getArgUint224(argOffset + 4));
            require(uint216(result) == _getArgUint216(argOffset + 5));
            require(uint208(result) == _getArgUint208(argOffset + 6));
            require(uint200(result) == _getArgUint200(argOffset + 7));
            require(uint192(result) == _getArgUint192(argOffset + 8));
            require(uint184(result) == _getArgUint184(argOffset + 9));
            require(uint176(result) == _getArgUint176(argOffset + 10));
            require(uint168(result) == _getArgUint168(argOffset + 11));
            require(uint160(result) == _getArgUint160(argOffset + 12));
            require(uint152(result) == _getArgUint152(argOffset + 13));
            require(uint144(result) == _getArgUint144(argOffset + 14));
            require(uint136(result) == _getArgUint136(argOffset + 15));
            require(uint128(result) == _getArgUint128(argOffset + 16));
            require(uint120(result) == _getArgUint120(argOffset + 17));
            require(uint112(result) == _getArgUint112(argOffset + 18));
            require(uint104(result) == _getArgUint104(argOffset + 19));
            require(uint96(result) == _getArgUint96(argOffset + 20));
            require(uint88(result) == _getArgUint88(argOffset + 21));
            require(uint80(result) == _getArgUint80(argOffset + 22));
            require(uint72(result) == _getArgUint72(argOffset + 23));
            require(uint64(result) == _getArgUint64(argOffset + 24));
            require(uint56(result) == _getArgUint56(argOffset + 25));
            require(uint48(result) == _getArgUint48(argOffset + 26));
            require(uint40(result) == _getArgUint40(argOffset + 27));
            require(uint32(result) == _getArgUint32(argOffset + 28));
            require(uint24(result) == _getArgUint24(argOffset + 29));
            require(uint16(result) == _getArgUint16(argOffset + 30));
            require(uint8(result) == _getArgUint8(argOffset + 31));
        }
        return result;
    }

    function getArgUint256Array(uint256 argOffset, uint256 length)
        public
        pure
        returns (uint256[] memory)
    {
        uint256[] memory result = _getArgUint256Array(argOffset, length);
        bytes32 hash = keccak256(abi.encode(_getArgBytes32Array(argOffset, length)));
        require(keccak256(abi.encode(result)) == hash);
        return result;
    }

    function getArgUint64(uint256 argOffset) public pure returns (uint64) {
        return _getArgUint64(argOffset);
    }

    function getArgUint8(uint256 argOffset) public pure returns (uint8) {
        return _getArgUint8(argOffset);
    }

    function testCloneWithImmutableArgs(
        uint256 value_,
        address argAddress,
        uint256 argUint256,
        uint256[] memory argUint256Array,
        uint64 argUint64,
        uint8 argUint8
    ) public {
        bytes memory data =
            abi.encodePacked(argAddress, argUint256, argUint256Array, argUint64, argUint8);
        LibCWIATest clone = LibCWIATest(LibCWIA.clone(address(this), data));
        _shouldBehaveLikeClone(address(clone), value_);

        // For avoiding stack too deep. Also, no risk of overflow.
        unchecked {
            uint256 argOffset;
            assertEq(clone.getArgAddress(argOffset), argAddress);
            argOffset += 20;
            assertEq(clone.getArgUint256(argOffset), argUint256);
            argOffset += 32;
            assertEq(clone.getArgUint256Array(argOffset, argUint256Array.length), argUint256Array);
            argOffset += 32 * argUint256Array.length;
            assertEq(clone.getArgUint64(argOffset), argUint64);
            argOffset += 8;
            assertEq(clone.getArgUint8(argOffset), argUint8);
        }
    }

    function testCloneWithImmutableArgs() public {
        uint256[] memory argUint256Array = new uint256[](2);
        argUint256Array[0] = 111;
        argUint256Array[1] = 222;
        testCloneWithImmutableArgs(1, address(uint160(0xB00Ba5)), 8, argUint256Array, 7, 6);
    }

    function testCloneDeteministicWithImmutableArgs(
        address argAddress,
        uint256 argUint256,
        uint256[] memory argUint256Array,
        bytes memory argBytes,
        uint64 argUint64,
        uint8 argUint8,
        uint256 deposit
    ) public {
        bytes memory data;
        bytes32 salt;

        // For avoiding stack too deep.
        unchecked {
            // Recycle for the salt.
            salt = bytes32(argUint256 + 123);

            data = abi.encodePacked(
                argUint256,
                argAddress,
                argUint256,
                argUint256Array,
                argBytes,
                argUint64,
                argUint8,
                argUint256
            );

            bytes32 saltKey = keccak256(abi.encode(data, salt));
            if (saltIsUsed[saltKey]) {
                vm.expectRevert(LibCWIA.DeploymentFailed.selector);
                LibCWIATest(this.cloneDeterministic(address(this), data, salt));
                return;
            }
            saltIsUsed[saltKey] = true;
        }

        bytes32 dataHashBefore = keccak256(data);

        LibCWIATest clone = LibCWIATest(this.cloneDeterministic(address(this), data, salt));
        // Check that memory management is done properly.
        assertEq(keccak256(data), dataHashBefore);

        _shouldBehaveLikeClone(address(clone), argUint256);
        _canReceiveETHCorrectly(address(clone), deposit);

        // For avoiding stack too deep. Also, no risk of overflow.
        unchecked {
            uint256 argOffset;
            assertEq(clone.getArgUint256(argOffset), argUint256);
            argOffset += (256 / 8);
            assertEq(clone.getArgAddress(argOffset), argAddress);
            argOffset += (160 / 8);
            assertEq(clone.getArgUint256(argOffset), argUint256);
            argOffset += (256 / 8);
            assertEq(clone.getArgUint256Array(argOffset, argUint256Array.length), argUint256Array);
            argOffset += (256 / 8) * argUint256Array.length;
            assertEq(clone.getArgBytes(argOffset, argBytes.length), argBytes);
            argOffset += (8 / 8) * argBytes.length;
            assertEq(clone.getArgUint64(argOffset), argUint64);
            argOffset += (64 / 8);
            assertEq(clone.getArgUint8(argOffset), argUint8);
            argOffset += (8 / 8);
            assertEq(clone.getArgUint256(argOffset), argUint256);
        }

        {
            address predicted =
                LibCWIA.predictDeterministicAddress(address(this), data, salt, address(this));
            assertEq(address(clone), predicted);
        }

        // Check that memory management is done properly.
        assertEq(keccak256(data), dataHashBefore);

        assertEq(clone.getCalldataHash(), dataHashBefore);
    }

    function testCloneDeteministicWithImmutableArgs() public {
        uint256[] memory argUint256Array = new uint256[](2);
        argUint256Array[0] = uint256(keccak256("zero"));
        argUint256Array[1] = uint256(keccak256("one"));
        bytes memory argBytes = bytes("Teehee");
        testCloneDeteministicWithImmutableArgs(
            address(uint160(uint256(keccak256("argAddress")))),
            uint256(keccak256("argUint256")),
            argUint256Array,
            argBytes,
            uint64(uint256(keccak256("argUint64"))),
            uint8(uint256(keccak256("argUint8"))),
            uint256(keccak256("deposit"))
        );
    }

    function testCloneWithImmutableArgsRevertsIfDataTooBig() public {
        uint256 n = 0xff9b;
        bytes memory data = _dummyData(n);

        address clone = this.cloneDeterministic(address(this), data, bytes32(gasleft()));
        _shouldBehaveLikeClone(clone, 1);
        assertEq(LibCWIATest(clone).argBytesHash(), keccak256(data));

        vm.expectRevert();
        this.cloneDeterministic(address(this), _dummyData(n + 1), bytes32(gasleft()));
    }

    function argBytesHash() public pure returns (bytes32) {
        return keccak256(_getArgBytes());
    }

    function _dummyData(uint256 n) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            mstore(0x00, n)
            mstore(0x20, 1)
            mstore(add(0x20, result), keccak256(0x00, 0x40))
            mstore(0x20, 2)
            mstore(add(add(0x20, result), n), keccak256(0x00, 0x40))
            mstore(0x20, 3)
            mstore(add(result, n), keccak256(0x00, 0x40))
            mstore(0x40, add(add(0x20, result), n))
            mstore(result, n)
        }
    }

    function testInitCode(address implementation, uint256 n) internal {
        _brutalizeMemory();
        bytes memory data;
        if ((n >> 32) & 31 > 0) data = _dummyData((n >> 128) & 0xff);
        bytes memory initCode = LibCWIA.initCode(implementation, data);
        _checkMemory(initCode);
        _brutalizeMemory();
        bytes32 expected = LibCWIA.initCodeHash(implementation, data);
        _checkMemory(initCode);
        assertEq(keccak256(initCode), expected);
    }

    function cloneDeterministic(address implementation, bytes calldata data, bytes32 salt)
        external
        returns (address)
    {
        return LibCWIA.cloneDeterministic(_brutalized(implementation), data, salt);
    }
}
