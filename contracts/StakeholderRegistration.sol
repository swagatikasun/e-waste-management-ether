pragma solidity ^0.5.13;

contract StakeholderRegistration {
    enum stakeholderType {
        Manufacturer,
        Wholesaler,
        Retailer,
        Customer,
        Collector,
        Segregator,
        RecyclingCenter,
        RawMaterialSuppiler
    } // ENUM for Stakeholder types

    address public Issuer; // Address of Ceator & Administrator of the contract
    address[] public TempRegistrations; // List of Temporary Registrations
    mapping(uint256 => address[]) private stakeholderTypeMap; // Mapping for Stakeholder Type list
    mapping(address => bool) public Stakeholders; // Mapping for Stakeholders
    mapping(address => tempRegistration) public tempRegistrationMap; // Mapping to store Temporary Registrations (Stakeholder's address) => (tempRegistration)
    mapping(address => stakeholder) public StakeholderMap; // Mapping to store (Stakeholder's Address) => (Stakeholders's Details)

    // Structure to store details of temporary registration
    struct tempRegistration {
        string Payload; // Registration Payload
        address Creator; // Tx Sender Address
    }

    // Structure to store Stakeholder Type Array
    struct stakeholderArray {
        address Stakeholder; // list of Stakeholders
    }

    // Structure to store details of a Stakeholder
    struct stakeholder {
        address Account; // Address of Stakeholder
        string ID; // ID of Stakeholder
        string Name; // Name of Stakeholder
        string Information; // Encrypted Information of Stakeholder
        stakeholderType Type; // Type of Stakeholder
    }

    modifier onlyIssuer() {
        require(msg.sender == Issuer, "Sender NOT Issuer."); // Check if Sender is Issuer
        _;
    }

    modifier onlyStakeholder() {
        require(Stakeholders[msg.sender], "Sender NOT Stakeholder."); // Check if Sender is Stakeholder
        _;
    }

    // Constructor to create the Contract
    constructor() public {
        Issuer = msg.sender; // Setting the Issuer
        TempRegistrations = new address[](0); // Init. of address[] TempRegistrations List
    }

    // Function to Create new tempRegistration
    function createTempRegistration(string memory _Payload) public {
        tempRegistration memory newTempRegistration =
            tempRegistration({Payload: _Payload, Creator: msg.sender});
        TempRegistrations.push(msg.sender); // Push TempRegistration ID to tempRegistration List
        tempRegistrationMap[msg.sender] = newTempRegistration; // Add newTempRegistration to tempRegistration
    }

    // Function to Create new Stakeholder
    function createStakeholder(
        address _Account,
        string memory _ID,
        string memory _Name,
        string memory _Information,
        uint8 _Type
    ) public onlyIssuer {
        stakeholder memory newStakeholder =
            stakeholder({
                Account: _Account,
                ID: _ID,
                Name: _Name,
                Information: _Information,
                Type: stakeholderType(_Type)
            });
        Stakeholders[_Account] = true; // Add Stakeholder's Address to Stakeholders mapping
        StakeholderMap[_Account] = newStakeholder; // Add new Stakeholder to StakeholderMap
        stakeholderTypeMap[getTypeValue(stakeholderType(_Type))].push(_Account); // Add new Stakeholder's address to stakeholderTypeMap
        removeTempRegistration(_Account); // Remove Temporary Registration
    }

    // Function to check if Stakeholder exists
    function existsStakeholder(address _Address) public view returns (bool) {
        return Stakeholders[_Address];
    }

    // Function to check if Stakeholder exists
    function getStakeholdersOfType(uint256 _type)
        public
        view
        returns (address[] memory)
    {
        return stakeholderTypeMap[getTypeValue(stakeholderType(_type))];
    }

    // Function to check if Stakeholder exists
    function getTempRegistrations()
        public
        view
        returns (address[] memory)
    {
        return TempRegistrations;
    }

    // Function to Update a Stakeholder
    function updateStakeholder(string memory _Name, string memory _Information)
        public
        onlyStakeholder
    {
        require(Stakeholders[msg.sender], "Stakeholder Doesn't Exist!");
        StakeholderMap[msg.sender].Name = _Name;
        StakeholderMap[msg.sender].Information = _Information;
    }

    // ----------------
    // Helper Functions
    // ----------------

    // Function to Remove tempRegistration from array and mapping
    function removeTempRegistration(address _target) private {
        uint8 index = 0;

        // Determine Index of the target
        for (uint8 i = 0; i < TempRegistrations.length; i++) {
            if (TempRegistrations[i] == _target) {
                index = i;
            }
        }

        // Remove target from TempRegistrations
        if (index >= TempRegistrations.length) return;
        for (uint8 i = index; i < TempRegistrations.length - 1; i++) {
            TempRegistrations[i] = TempRegistrations[i + 1];
        }
        TempRegistrations.length--;

        delete tempRegistrationMap[_target];
    }

    function getTypeValue(stakeholderType _stype)
        private
        pure
        returns (uint256)
    {
        return uint256(stakeholderType(_stype));
    }

    // Function to self-destruct ONLY FOR TESTING
    function kill() public onlyIssuer {
        selfdestruct(address(uint160(Issuer)));
    }
}
