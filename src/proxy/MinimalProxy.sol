pragma solidity ^0.8.15;

contract MinimalProxy {

    address immutable template;

    // forward all calls to a template address
    //
    // we also need a way to handle reverts in the template address
    //
    // we also want to be able to handle view functions as well, so our
    // fallback function should return data.

    constructor(address _template) {
        template = _template;
    }

    fallback(bytes calldata callData) external payable returns (bytes memory) {
        
        // delegate call to the template contract with any passed in ETH
        (bool success, bytes memory resultData) = template.delegatecall(callData);

        // if unsuccessful, construct a revert from the result data
        if (!success) {

            if (resultData.length == 0) {
                revert("MinimalProxy: Error");
            } else {
                assembly { 
                    // bytes encoding looks like: first word is length, second word is data
                    // revert takes in a starting pointer, and how many bytes to read
                    // Because mload(resultData) loads the first 32 bytes, we can use that to
                    // get the length.
                    // to get the pointer to the actual data, we just just incrememt the resultData pointer
                    // by 32 bytes
                    revert(add(resultData, 0x20), mload(resultData))
                }
            }
        }

        // return byte data which will be decoded to whatever the return type is of the function
        // signature that called the proxy
        return resultData;
    }
}