pragma solidity ^0.8.0;


library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract Counter {
    uint private counter;

    function add(uint256 i) public {
        counter += 1;
    }

    function get() public view returns(uint) {
        return counter;
    }
}

contract CounterV2 {
    uint private counter;
    uint public counter2;
    

    function add(uint256 i) public {
        counter += i;
    }

    function get() public view returns(uint) {
        return counter;
    }

    function add2(uint256 i) public {
        counter2 += i;
    }

    function get2() public view returns(uint) {
        return counter2;
    }


    function upgradesdgasTo(address _implementation) external {

    }

    
}

contract CounterProxy {

    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);


    constructor() {
    }

    function _delegate(address _implementation) internal virtual {
        assembly {
            // 1. 复制原始调用数据
            calldatacopy(0, 0, calldatasize())

            // 2. 执行委托调用
            let result := delegatecall(
                gas(),  // 传递全部gas 
                _implementation,  // 目标合约地址
                0,  // 输入数据指针
                calldatasize(),  // 输入数据长度
                0,  // 输出数据指针
                0 // 输出数据长度
            )

            // 3. 复制返回数据
            returndatacopy(0, 0, returndatasize())

            // 4. 处理调用结果
            switch result
            case 0 {
                revert(0, returndatasize()) // 失败时回滚
            }
            default {
                return(0, returndatasize()) // 成功时返回
            }
        }
    }

    // 代理到 Counter
    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }



    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function upgradeTo(address _implementation) external {
        _setImplementation(_implementation);
    }

    

}