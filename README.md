# 💧 Liqui-Mine

**Liqui-Mine** is a decentralized liquidity mining smart contract written in Clarity for the [Stacks](https://www.stacks.co) blockchain. It allows DeFi projects to incentivize liquidity providers with token rewards distributed over time.

---

## 📜 Contract Overview

Liqui-Mine enables a protocol to reward users for staking eligible LP tokens. Rewards are calculated based on the share of the total liquidity pool and the duration of the stake. Admins can configure multiple pools with customizable reward rates.

---

## ⚙️ Features

- 🏦 **Deposit LP Tokens**: Users can stake supported liquidity pool (LP) tokens.
- 💰 **Claim Rewards**: Rewards are automatically accrued and can be claimed anytime.
- 🔁 **Withdraw Liquidity**: Users can exit the pool and withdraw both tokens and rewards.
- 🔐 **Admin Control**: Admins can register LP token pools and set reward parameters.

---

## 🛠️ Functions

| Function            | Access      | Description                                         |
|---------------------|-------------|-----------------------------------------------------|
| `deposit`           | Public      | Deposit LP tokens to start earning rewards          |
| `withdraw`          | Public      | Withdraw LP tokens and any unclaimed rewards        |
| `claim-reward`      | Public      | Claim accumulated rewards without withdrawing       |
| `set-reward-rate`   | Admin-only  | Set the rate of reward distribution for a pool      |
| `set-token-pool`    | Admin-only  | Register a new LP token as a valid pool             |

---

## 🧪 Testing

Liqui-Mine is fully compatible with [Clarinet](https://docs.stacks.co/write-smart-contracts/clarity/clarinet), the local development environment for Clarity smart contracts.

To run tests:
```bash
clarinet test
