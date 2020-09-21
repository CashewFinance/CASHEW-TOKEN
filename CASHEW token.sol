pragma solidity^ 0.4.26;

import "./ERC20.sol";
import "./Standard Token.sol";

contract CASHEW is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function activateCASHEW() {
        uint256 total_coins = 200000 * 10 ** uint256(18);
        balances[msg.sender] = total_coins;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        totalSupply = total_coins;                        // Update total supply
        name = "CASHEW";                                   // Set the name for display purposes
        decimals = 18;                                               // Amount of decimals for display purposes
        symbol = "CASH";                                             // Set the symbol for display purposes

    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) returns (bool success) {
        uint256 toBurn = _value / 1000;
        if (StandardToken.transfer (_to, _value - toBurn)) {
            require (burn (toBurn));
            return true;
        } else return false;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        uint256 toBurn = _value / 1000;
        if (StandardToken.transferFrom (_from, _to, _value - toBurn)) {
            require (burnFrom (_from, toBurn));
            return true;
        } else return false;
    }
}