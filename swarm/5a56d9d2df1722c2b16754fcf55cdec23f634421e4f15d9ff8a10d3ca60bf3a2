// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 < 0.9.0;
pragma experimental ABIEncoderV2;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library RoleHash {

    //////////////////////////////////////////////////////////////////////////////////////////
    // Generate & Compare Roles Hash
    //////////////////////////////////////////////////////////////////////////////////////////
    function createHash(string memory _str) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str));
    }

    function compareHash(string memory _str, bytes32 _hashed) public pure returns(bool) {
        bytes32 hashed = keccak256(abi.encodePacked(_str));
        require(hashed == _hashed, "Hashed does not Matched!!!");
        return true;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library VerifySig {

    /*
    1. Need a message to sign
    2. hash(message)
    3. sign(hash(message), private key) | offchain (prefixed strings will be added to hash(message) and hash again while signing)
    4. ecrecover(hash(message), signature) == signer

    example:
    account: poachain1
    0x808CC794c04A37B6969Ca18c83fE508a14550c1b
    message: jon
    hash: 0x408f03ab78bc13e6304da5357a4b0b4447b1c81f3a32d6a913938cadbfdfc05a
    signature:
    0xd3df207f5010f55498de35842ac39b396b80ae96ef6ac8725b2edde17b838eed3fe8f4d273b575cc4f4e01bb590a728c51a2082792d8e6944d49e730233e0e171b

    */

    // address private constant poachain1 = 0x808CC794c04A37B6969Ca18c83fE508a14550c1b;
    
    function verify(string memory _message, bytes memory _sig) internal view returns(bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        // return recover(ethSignedMessageHash, _sig) == msg.sender;
        return recover(ethSignedMessageHash, _sig) == msg.sender;
    }

    // Functions below are used to Verify Signer
    function getMessageHash(string memory _message) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            // These strings are appended prefix before signing
            "\x19Ethereum Signed Message:\n32",
            _messageHash
        ));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) internal pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid Signature Length");

        assembly {
            /* Bytes memory _sig 
            --> Is dynamic data types, so the 1st 32 bytes stores the length of the data 
            --> _sig variable is not the actual signature. It is as pointer to where the signature is stored in the Memory
            */

            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0,mload(add(_sig, 96)))

        }

    }

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library Hashing {
    // Hashing Function
    // Logging Events
    event CountLog(uint indexed currentUsrCnt);
    event HashLog(bytes32 indexed addrHashed);

    // To set an Address Hash to store the information
    function setAddrHash(uint _subjectID, uint _usrRecCnt) internal returns(bytes32) {
        bytes32 addrHashed = keccak256(abi.encodePacked(_subjectID, _usrRecCnt));
        emit CountLog(_usrRecCnt);
        emit HashLog(addrHashed);
        return addrHashed;
    }

    // Str to Bytes Convertion
    function StrByteCvt(string memory _str) internal pure returns(bytes memory) {
        bytes memory bytesStr = bytes(_str);
        return bytesStr;
    }

    // Bytes to Str Convertion
    function ByteStrCvt(bytes memory _bytes) internal pure returns(string memory) {
        string memory strBytes = string(_bytes);
        return strBytes;
    }

    // Get One Time Token Hash
    function getTokenHash(address _addr, bytes calldata _sig) internal view returns(bytes32) {
        return keccak256(abi.encodePacked(_addr, _sig, block.timestamp));
    }
}