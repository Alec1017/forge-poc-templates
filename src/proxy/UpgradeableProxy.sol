pragma solidity ^0.8.15;

contract UpgradeableProxy {

    uint256 constant TEMPLATE_SLOT = 0xBEEF;
    address immutable private admin;

    // forward all calls to a template address
    //
    // we also need a way to handle reverts in the template address
    //
    // we also want to be able to handle view functions as well, so our
    // fallback function should return data.

    // now, we have new requirements to make the proxy upgradeable.
    // 
    // the specific proxy functions should only be callable by an admin
    // 
    // we must change the template variable so that it is no longer immutable.
    //
    // we must introduce a private function to change the template
    //
    // we must introduce a external function to allow upgrading to a new template

    constructor(address _template) {

        // set the admin
        admin = msg.sender;

        // set the template
        _setTemplate(_template);
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "unauthorized");
        _;
    }

    function _setTemplate(address _template) private {
        assembly { sstore(TEMPLATE_SLOT, _template) }
    }

    function upgradeTo(address _template) external onlyAdmin {
        _setTemplate(_template);
    }

    fallback(bytes calldata callData) external payable returns (bytes memory) {

        address template;
        assembly { template := sload(TEMPLATE_SLOT)}

        if (msg.sender == admin) {
            bytes memory resultData;
            if (bytes4(callData) == bytes4(keccak256("admin()"))) {
                resultData = abi.encode(admin);
            }

            return resultData;
        } else {
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
}