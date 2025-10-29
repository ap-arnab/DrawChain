# DrawChain
# 🎴 OnChain Deck — Provably Fair Card Pulling

A simple Solidity smart contract that lets players **pull cards from an on-chain deck** with **provable fairness** using a **commit–reveal** scheme.  
Built for learning and experimenting with randomness, fairness, and on-chain logic.

---

## 🚀 Features
- 🃏 52-card deck stored on-chain  
- 🔒 Commit–reveal randomness for provable fairness  
- 🤝 Anyone can verify the shuffle off-chain  
- ⚡ Simple functions: commit → reveal → draw  
- 🧩 Beginner-friendly Solidity (~100 lines)

---

## 🧠 How It Works

1. **Owner commits** a hash of a secret seed:  
keccak256(seed)

markdown
Copy code
2. **Owner reveals** the seed later → the contract performs a deterministic **Fisher–Yates shuffle** using:
keccak256(seed, i)

yaml
Copy code
3. Players call `drawCard()` to pull cards one by one.  
4. Anyone can verify the shuffle off-chain using the revealed seed.

---

## 📜 Contract Overview

| Function | Description |
|-----------|--------------|
| `commit(bytes32 hash)` | Owner commits the hash of a secret seed. |
| `reveal(bytes seed)` | Reveals the seed & shuffles the deck. |
| `drawCard()` | Pulls the next card from the shuffled deck. |
| `remaining()` | Shows how many cards are left. |
| `getDeck()` | Returns the full shuffled deck (view only). |
| `resetForNewRound()` | Resets everything for a new game. |

---

## 🧩 Example Flow

```solidity
// Step 1: Off-chain
bytes memory seed = "my_secret_random_seed";
bytes32 hash = keccak256(seed);

// Step 2: On-chain
commit(hash);

// Step 3: Later...
reveal(seed);

// Step 4: Players draw cards
drawCard();
🧱 Tech Stack
Solidity ^0.8.19

Ethereum / EVM-compatible chain

Remix IDE or Hardhat for deployment/testing

🔐 Notes
The owner must commit before revealing (prevents cheating).

Fairness is provable since the shuffle can be verified using the revealed seed.

For real projects, consider using Chainlink VRF or multiple committers for true trustlessness.

🧑‍💻 Author
Arnab Paul
Learning Solidity, building fun and fair smart contracts 🧠⚡

📄 License
MIT License

yaml
Copy code

---

Would you like me to add a **Remix deploy guide** or a **Hardhat test script** section in it too?
