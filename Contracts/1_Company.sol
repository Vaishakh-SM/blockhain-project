// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CompanyContract {
    // Only officials can produce stocks of a company
    uint256 public companyID = 0;

    struct Company {
        address[] officials;
        string companyName;
        string companyUrl;
        uint256 stocks;
        bool isSet;
    }

    mapping(uint256 => Company) registeredCompanies;

    function addCompany(string memory _companyName, string memory _companyUrl)
        public
        returns (uint256 _companyID)
    {
        if (!registeredCompanies[companyID].isSet) {
            Company storage newCompany = registeredCompanies[companyID];
            newCompany.companyName = _companyName;
            newCompany.companyUrl = _companyUrl;
            newCompany.officials.push(msg.sender);
            newCompany.stocks = 0;
            newCompany.isSet = true;
            companyID = companyID + 1;
            return companyID - 1;
        }
    }

    function addOfficial(uint256 _companyID, address official) public {
        address[] storage officials = registeredCompanies[_companyID].officials;
        for (uint256 i = 0; i < officials.length; i++) {
            if (officials[i] == msg.sender) {
                registeredCompanies[_companyID].officials.push(official);
                break;
            }
        }
    }

    function getCompany(uint256 _companyID)
        public
        view
        returns (Company memory)
    {
        return registeredCompanies[_companyID];
    }

    function isOfficial(address _sender, uint256 _companyID)
        public
        view
        returns (bool)
    {
        address[] storage officials = registeredCompanies[_companyID].officials;
        for (uint256 i = 0; i < officials.length; i++) {
            if (officials[i] == _sender) {
                return true;
            }
        }

        return false;
    }

    function addStocks(uint256 _companyID, uint256 amount) public {
        address[] storage officials = registeredCompanies[_companyID].officials;
        for (uint256 i = 0; i < officials.length; i++) {
            if (officials[i] == tx.origin) {
                registeredCompanies[_companyID].stocks += amount;
                break;
            }
        }
    }
    /**
     * @dev Return value
     * @return value of 'number'
     */
}

/*
Exchange: listings, buy, sell, produce stocks
Stock: Maintains mapping of company ID to Name website etc and verification process
User: Maintains the list of stocks that he has
*/
