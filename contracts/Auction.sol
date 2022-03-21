// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

// Using ERC20 token
// interface IERC20 {
//     function transferFrom(
//         address,
//         address,
//         uint256
//     ) external returns (bool);

//     function balanceOf(address account) external view returns (uint256);
// }

// Using our own SimpleToken
import "./SimpleToken.sol";

// External contract to help update price daily
// interface Aion
// abstract contract Aion {
//     uint256 public serviceFee;

//     function ScheduleCall(
//         uint256 blocknumber,
//         address to,
//         uint256 value,
//         uint256 gaslimit,
//         uint256 gasprice,
//         bytes memory data,
//         bool schedType
//     ) public payable virtual returns (uint256, address);
// }

// main contract
contract DutchAuction {
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public immutable startPrice;

    // uint256 public currPrice;

    address payable public immutable seller;
    SimpleToken public immutable token;

    // Make sure that discountRate is integer because solidity does not support float
    uint256 public immutable discountRate;

    // Contract Tx
    constructor(
        uint256 _startPrice,
        uint256 _discountRate,
        uint256 _duration,
        address _token
    ) {
        require(_startPrice >= _discountRate * _duration * 1 days, "Negative price before expiration.");
        seller = payable(msg.sender);
        startPrice = _startPrice;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration * 1 days;

        token = SimpleToken(_token);
        discountRate = _discountRate;

        // currPrice = _startPrice;
        // dailyUpdate();
    }

    // Using Aion cost 120 Gwei (2 cents) a day
    // function dailyUpdate() public {
    //     Aion aion = Aion(0xFcFB45679539667f7ed55FA59A15c8Cad73d9a4E); // address on Ropsten, used in development
    //     // Aion aion = Aion(0xCBe7AB529A147149b1CF982C3a169f728bC0C3CA); // address on MainNet, used in deployment

    //     bytes memory data = abi.encodeWithSelector(
    //         bytes4(keccak256("priceUpdate()"))
    //     );
    //     uint256 callCost = 200000 * 1e9 + aion.serviceFee();
    //     aion.ScheduleCall{value: callCost}(
    //         block.timestamp + 1 days,
    //         address(this),
    //         0,
    //         200000,
    //         1e9,
    //         data,
    //         true
    //     );
    // }

    // function priceUpdate() public {
    //     currPrice = currPrice - (startPrice / ((endTime - startTime) / 1 days));
    // }

    // Contract call
    function getTokenValue() public view returns(uint256) {
        return token.allowance(seller, address(this));
    }

    // Contract call
    function getUpdatedPrice() public view returns(uint256) {
        return startPrice - (discountRate * (block.timestamp - startTime));
    }

    // Contract Tx
    function bid() public payable {
        require(block.timestamp <= endTime, "Auction already ended.");
        // require(msg.value >= currPrice, "Not enough Ether provided.");
        require(msg.value >= getUpdatedPrice(), "Not enough Ether provided.");

        // Contract Tx
        token.transferFrom(
            seller,
            msg.sender,
            token.allowance(seller, address(this))
        );

        if (msg.value - getUpdatedPrice() > 0) {
            payable(msg.sender).transfer(msg.value - getUpdatedPrice());
        }

        selfdestruct(seller);
    }
}
