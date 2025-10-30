// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title OnChainDeck — commit-reveal provably-fair shuffle & draw (beginner)
/// @author
/// @notice Owner commits ahash(commitSeed). Later reveals seed, contract shuffles deck deterministically.
/// @dev Simple Fisher-Yates using keccak256(seed, i) as randomness source.
contract OnChainDeck {
    address public owner;
    bool public committed;
    bool public revealed;
    bytes32 public committedHash; // keccak256(seed)
    bytes public revealedSeed;

    uint8[] private deck;         // holds current deck order (card numbers 0..51)
    uint8 public nextIndex;       // index of next card to draw (0..51)

    event Committed(bytes32 indexed committedHash);
    event Revealed(bytes indexed seed);
    event CardDrawn(address indexed who, uint8 indexed card);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _initDeck();
    }

    function _initDeck() internal {
        // create an ordered deck 0..51
        delete deck;
        for (uint8 i = 0; i < 52; i++) {
            deck.push(i);
        }
        nextIndex = 0;
    }

    /// @notice Owner commits the hash of the seed before shuffling/drawing begin.
    /// @param _committedHash keccak256(abi.encodePacked(seed))
    function commit(bytes32 _committedHash) external onlyOwner {
        require(!committed, "already committed");
        committed = true;
        committedHash = _committedHash;
        emit Committed(_committedHash);
    }

    /// @notice Owner reveals the seed. This triggers deterministic shuffle.
    /// @param seed arbitrary bytes used to produce randomness (must match committed hash)
    function reveal(bytes calldata seed) external onlyOwner {
        require(committed, "not committed");
        require(!revealed, "already revealed");
        require(keccak256(seed) == committedHash, "seed mismatch");

        revealedSeed = seed;
        revealed = true;

        // perform deterministic Fisher-Yates shuffle using keccak256(revealedSeed, i)
        // deck length is small (52) so this is gas-feasible here.
        for (uint256 i = deck.length - 1; i > 0; i--) {
            // derive pseudorandom number from seed and i
            bytes32 rnd = keccak256(abi.encodePacked(seed, i));
            uint256 j = uint256(rnd) % (i + 1);
            // swap deck[i] and deck[j]
            uint8 tmp = deck[i];
            deck[i] = deck[j];
            deck[j] = tmp;
        }

        emit Revealed(seed);
    }

    /// @notice Draw next card from the shuffled deck (after reveal).
    /// @return card id 0..51 (map to suits/values off-chain)
    function drawCard() external returns (uint8) {
        require(revealed, "deck not revealed");
        require(nextIndex < deck.length, "no cards left");

        uint8 card = deck[nextIndex];
        nextIndex++;
        emit CardDrawn(msg.sender, card);
        return card;
    }

    /// @notice View the remaining cards count
    function remaining() external view returns (uint8) {
        return uint8(deck.length - nextIndex);
    }

    /// @notice Return full deck order (useful for off-chain verification after reveal).
    /// @dev This returns the on-chain deck array; gas cost of calling this view offchain is fine.
    function getDeck() external view returns (uint8[] memory) {
        return deck;
    }

    /// @notice Reset deck for a new round. Only owner, only after all draws or if not committed yet.
    function resetForNewRound() external onlyOwner {
        require(!committed || nextIndex == deck.length, "can't reset mid-round");
        committed = false;
        revealed = false;
        committedHash = bytes32(0);
        delete revealedSeed;
        _initDeck();
    }
}
